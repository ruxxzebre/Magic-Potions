defmodule Servy.GenericServerImpl do
  def start(callback_module, initial_state, name) do
    if alive(name), do: Process.unregister(name)
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, name)
    {:ok, pid}
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, value} -> value
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def alive(name) do
    Process.whereis(name) != nil
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender, message} when is_pid(sender) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        new_state = callback_module.handle_info(unexpected, state)
        listen_loop(new_state, callback_module)
    end
  end
end
