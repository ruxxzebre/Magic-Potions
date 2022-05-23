defmodule Servy.KickStarter do
  use GenServer

  def start do
    IO.puts("Starting a KickStarter")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    Process.flag(:trap_exit, true)
    server_pid = launch_http_server()
    {:ok, server_pid}
  end

  def get_server, do: GenServer.call(__MODULE__, :get_server)

  def handle_call(:get_server, _from, state), do: {:reply, state, state}

  def handle_info({:EXIT, _pid, reason}, _state) do
    server_pid = launch_http_server()
    IO.puts("HTTP Server exited (#{inspect(reason)})")
    {:noreply, server_pid}
  end

  defp launch_http_server do
    server_pid = spawn_link(Servy.HttpServer, :start, [4000])

    # * Here KickStart process being linked to server process, because init runs inside Kickstart process
    # * Process.link(server_pid) - no need because of spawn_link
    Process.register(server_pid, :http_server)
    server_pid
  end
end
