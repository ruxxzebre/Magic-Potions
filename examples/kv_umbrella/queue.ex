defmodule Q do

  defmodule Node do
    defstruct value: nil, next: nil
  end

  defmodule Queue do
    use GenServer

    @name :queue_server

    def start_link() do
      GenServer.start_link(__MODULE__, :ok, name: @name)
    end

    @impl true
    def init(:ok) do
      {:ok, %{ head: nil, tail: nil }}
    end

    def enqueue(value) do
      GenServer.call(@name, {:enqueue, value})
    end

    def dequeue() do
      GenServer.call(@name, :dequeue)
    end

    @impl true
    def handle_call({:enqueue, value}, _from, %{head: head, tail: tail}) when head == :JUNK_HEAD do
      new_node = %Node{value: value, next: nil}
      {:ok, new_node, %{
        head: new_node,
        tail: new_node
      }}
    end

    @impl true
    def handle_call({:enqueue, value}, _from, %{head: head, tail: tail} = state) do
      traverse(head, value)
    end

    def traverse(head, value) do
      if head.next == nil do
        new_node = %Node{value: value, next: nil}
        {:ok, new_node, %{
          head: new_node,
          tail: new_node
        }}
        else
          traverse(head.next, value)
      end
    end

    @impl true
    def handle_call(:dequeue, _from, %{head: head, tail: tail} = state) do
      {:ok, state}
    end
  end
end
