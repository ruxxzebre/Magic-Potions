defmodule Servy.HttpServer do
  @spec sendClientRequest(List.Chars) :: binary()
  def sendClientRequest(data \\ 'some data') do
    host = 'localhost'

    {:ok, sock} =
      :gen_tcp.connect(host, 4000, [
        :binary,
        packet: :raw,
        active: false
      ])

    :ok = :gen_tcp.send(sock, to_charlist(data))
    {:ok, response} = :gen_tcp.recv(sock, 0)
    :ok = :gen_tcp.close(sock)

    response
  end

  @spec start(1..1_114_111) :: no_return
  def start(port) when is_integer(port) and port > 1234 do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [
        :binary,
        packet: :raw,
        active: false,
        reuseaddr: true
      ])

    IO.puts("\n🎧Listening for connections from #{port}")
    accept_loop(listen_socket)
  end

  def accept_loop(listen_socket) do
    IO.puts("\n⏳Waiting for connections")
    {:ok, client_socket} = :gen_tcp.accept(listen_socket)

    IO.puts("\n💡New connection accepted!")

    pid = spawn(fn -> serve(client_socket) end)

    :ok = :gen_tcp.controlling_process(client_socket, pid)

    accept_loop(listen_socket)
  end

  @spec serve(port | {:"$inet", atom, any}) :: any
  def serve(client_socket) do
    IO.puts("#{inspect(self())}: Working on it")

    case client_socket |> read_request do
      {:ok, request} ->
        request
        |> log(:request)
        |> Servy.Handler.handle()
        |> write_response(client_socket)
        |> log(:response)

      {:error, reason} ->
        log(reason, :error)
    end
  end

  defp log(entity, flag \\ :ok) do
    case flag do
      :request ->
        IO.puts("\n👉Received request")

      :response ->
        IO.puts("\n👈Sent response")

      :error ->
        IO.puts("\n⛔️Error")

      :ok ->
        IO.puts("\n✅Log entity")
    end

    IO.inspect(entity)
  end

  def read_request(client_socket) do
    Servy.Parser.verify(:gen_tcp.recv(client_socket, 0))
  end

  def write_response(response, client_socket) do
    IO.inspect(response)
    :ok = :gen_tcp.send(client_socket, response)
    :gen_tcp.close(client_socket)
    response
  end
end
