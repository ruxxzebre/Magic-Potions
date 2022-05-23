defmodule PledgeServerTest do
  use ExUnit.Case
  alias Servy.PledgeServer

  test "check is state consists of 3 tuples and total amount is correct" do
    ps_pid = PledgeServer.start()

    PledgeServer.create_pledge("Garry", 100)
    PledgeServer.create_pledge("Marry", 100)
    PledgeServer.create_pledge("Jack", 100)
    PledgeServer.create_pledge("Pablo", 696)

    assert length(PledgeServer.recent_pledges()) == 3

    assert PledgeServer.recent_pledges() == [
             {"Pablo", 696},
             {"Jack", 100},
             {"Marry", 100}
           ]

    assert PledgeServer.total_pledged() == 896

    Process.exit(ps_pid, :kill)
  end
end
