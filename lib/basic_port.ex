defmodule PortsExample.BasicPort do
  use GenServer
  require Logger

  @command "./bin/long_running.rb"

  # GenServer API
  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(_args \\ []) do
    port = Port.open({:spawn, @command}, [:binary, :exit_status])

    {:ok, %{latest_output: nil, exit_status: nil} }
  end

  # This callback handles data incoming from the command's STDOUT
  def handle_info({port, {:data, text_line}}, state) do
    latest_output = text_line |> String.trim
    
    Logger.info "Latest output: #{latest_output}"

    {:noreply, %{state | latest_output: latest_output}}
  end

  # This callback tells us when the process exits
  def handle_info({port, {:exit_status, status}}, state) do
    Logger.info "External exit: :exit_status: #{status}"

    new_state = %{state | exit_status: status}
    {:noreply, %{state | exit_status: status}}
  end

  # no-op catch-all callback for unhandled messages
  def handle_info(_msg, state), do: {:noreply, state}
end