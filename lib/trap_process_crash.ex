defmodule PortsExample.TrapProcessCrash do
  use GenServer
  require Logger

  @command "./bin/long_running.rb"

  # GenServer API
  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args \\ []) do
    Process.flag(:trap_exit, true)

    port = Port.open({:spawn, @command}, [:binary, :exit_status])
    Port.monitor(port)

    {:ok, %{port: port, latest_output: nil, exit_status: nil} }
  end

  def terminate(reason, %{port: port} = state) do
    Logger.info "** TERMINATE: #{inspect reason}. This is the last chance to clean up after this process."
    Logger.info "Final state: #{inspect state}"

    port_info = Port.info(port)
    os_pid = port_info[:os_pid]

    Logger.warn "Orphaned OS process: #{os_pid}"

    :normal
  end

  # This callback handles data incoming from the command's STDOUT
  def handle_info({port, {:data, text_line}}, %{port: port} = state) do
    Logger.info "Data: #{inspect text_line}"
    {:noreply, %{state | latest_output: String.trim(text_line)}}
  end

  # This callback tells us when the process exits
  def handle_info({port, {:exit_status, status}}, %{port: port} = state) do
    Logger.info "Port exit: :exit_status: #{status}"

    new_state = %{state | exit_status: status}

    {:noreply, new_state}
  end

  def handle_info({:DOWN, _ref, :port, port, :normal}, state) do
    Logger.info "Handled :DOWN message from port: #{inspect port}"
    {:noreply, state}
  end

  def handle_info({:EXIT, port, :normal}, state) do
    Logger.info "handle_info: EXIT"
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info "Unhandled message: #{inspect msg}"
    {:noreply, state}
  end

end