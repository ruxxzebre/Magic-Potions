defmodule Servy.PledgeServerOwn do
  alias Servy.GenericServerImpl, as: GenericServer

  @name :pledge_server_hand_rolled

  # Client Interface

  def start(initial_state \\ []) do
    IO.puts("Starting the a #{@name} server...")
    GenericServer.start(__MODULE__, initial_state, @name)
  end

  def create_pledge(name, amount), do: GenericServer.call(@name, {:create_pledge, name, amount})
  def recent_pledges, do: GenericServer.call(@name, :recent_pledges)
  def total_pledged, do: GenericServer.call(@name, :total_pledged)
  def clear, do: GenericServer.cast(@name, :clear)

  # Server callbacks

  def handle_call(:total_pledged, state), do: {Enum.map(state, &elem(&1, 1)) |> Enum.sum(), state}
  def handle_call(:recent_pledges, state), do: {state, state}

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_info(message, state) do
    IO.puts("Unexpected message: #{inspect(message)}")
    state
  end

  def handle_cast(:clear, _state), do: []

  defp send_pledge_to_service(_name, _amount) do
    # CODE GOES HERE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
