defmodule Servy.Manager do
  alias Servy.HttpServer
  alias Servy.PledgeServer
  alias Servy.C404Counter

  @name :allmanager

  def run do
    # TODO: agents api check
    storage =
      %{}
      |> Map.put("http", spawn(HttpServer, :start, [4000]))
      |> Map.put("pledge", spawn(PledgeServer, :start, []))
      |> Map.put("404", spawn(C404Counter, :start, []))

    pid = spawn(__MODULE__, :accept_loop, [storage])
    expid = Process.whereis(@name)

    if expid != nil do
      Process.exit(expid, :kill)
      Process.unregister(@name)
    end

    Process.register(pid, @name)
    pid
  end

  def accept_loop(storage) do
    receive do
      {:stop, :all} ->
        # IO.inspect Enum.map(storage, fn ({ k, v }) -> "#{k}: #{inspect v}" end)
        Process.exit(storage["http"], :kill)
        Process.exit(storage["pledge"], :kill)
        Process.exit(storage["404"], :kill)
        accept_loop(storage)
    end
  end

  def kill do
    send(@name, {:stop, :all})
  end
end
