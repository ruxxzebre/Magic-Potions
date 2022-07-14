defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    # {:ok, assign(socket, query: "", results: %{})}
    Logger.info("ID IS #{room_id}")

    topic = "room: " <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket), do: ChatWeb.Endpoint.subscribe(topic)

    {:ok, assign(socket, room_id: room_id,
    topic: topic,
    message: "",
    username: username,
    messages: [%{
      uuid: UUID.uuid4(),
      text: "#{username} joined the room",
      username: "system"
    }],
    temporary_assigns: [messages: []])}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
  {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_event("submit_message",
    %{"chat" => %{"message" => message}}, socket) do
    Logger.info(message)
    ChatWeb.Endpoint.broadcast(
      socket.assigns.topic,
      "new-message",
      %{
        uuid: UUID.uuid4(),
        text: message,
        username: socket.assigns.username
      }
    )
    {:noreply, assign(socket, message: "")}
  end
end
