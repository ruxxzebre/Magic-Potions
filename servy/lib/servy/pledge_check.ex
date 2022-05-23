alias Servy.PledgeServerOwn, as: PledgeServer

{:ok, pid} = PledgeServer.start()

# :sys.trace(pid, true)
send(pid, {:stop, "hammertime"})

# PledgeServer.blow()
IO.inspect(PledgeServer.create_pledge("larry", 10))
# IO.inspect PledgeServer.create_pledge("moe", 20)
# IO.inspect PledgeServer.create_pledge("curly", 30)
IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect PledgeServer.create_pledge("grace", 50)

IO.inspect(PledgeServer.recent_pledges())

IO.inspect(PledgeServer.total_pledged())

IO.inspect(Process.info(pid, :messages))
