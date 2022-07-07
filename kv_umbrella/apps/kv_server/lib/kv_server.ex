defmodule KVServer do
  require Logger
  @moduledoc """
  Documentation for `KVServer`.
  Currently it is simple echo server.
  """

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [
      :binary,
      packet: :line,
      active: false,
      reuseaddr: true
    ])
    Logger.info("Accepting connections from port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(
      KVServer.TaskSupervisor,
      fn -> serve(client) end
    )
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    msg =
      with {:ok, data} <- read_line(socket),
          {:ok, command} <- KVServer.Command.parse(data),
          do: KVServer.Command.run(command, KV.Registry)

    write_line(socket, msg)
    serve(socket)
  end

  defp old_serve(socket) do
    msg =
      case read_line(socket) do
        {:ok, data} ->
          case KVServer.Command.parse(data) do
            {:ok, command} ->
              KVServer.Command.run(command, KV.Registry)
            {:error, _} = err ->
              err
          end
        {:error, _} = err ->
          err
      end

    write_line(socket, msg)
    serve(socket)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line(socket, {:ok, :quit}) do
    :gen_tcp.send(socket, "OK\r\nBYE!!!\r\n")
    :gen_tcp.close(socket)
  end

  defp write_line(socket, {:ok, text}) do
    :gen_tcp.send(socket, text)
  end

  defp write_line(socket, {:error, :unknown_command}) do
    :gen_tcp.send(socket, "UNKNOWN COMMAND\r\n")
  end

  defp write_line(_socket, {:error, :closed}) do
    exit(:shutdown)
  end

  defp write_line(socket, {:error, :not_found}) do
    :gen_tcp.send(socket, "NOT FOUND\r\n")
  end

  defp write_line(socket, {:error, error}) do
    :gen_tcp.send(socket, "ERROR\r\n")
    exit(error)
  end
end
