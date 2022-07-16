defmodule ChatWeb.RoomLive do
  use ChatWeb, :live_view
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room: " <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      ChatWeb.Endpoint.subscribe(topic)
      ChatWeb.Presence.track(self(), topic, username, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       message: "",
       user_list: [],
       username: username,
       errors: %{},
       messages: [
         %{
           uuid: UUID.uuid4(),
           text: "#{username} joined the room",
           type: :system
         }
       ],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_info(
        %{
          event: "presence_diff",
          payload: %{
            joins: joins,
            leaves: leaves
          }
        },
        socket
      ) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), text: "#{username} joined", type: :system}
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{uuid: UUID.uuid4(), text: "#{username} left", type: :system}
      end)

    user_list = ChatWeb.Presence.list(socket.assigns.topic) |> Map.keys()

    {:noreply, assign(socket, messages: join_messages ++ leave_messages, user_list: user_list)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
    # cond do
    #   String.length(message) < 3 ->
    #     {:noreply, assign(socket, errors: %{message: "Message must be at least 3 characters long"})}
    #   true ->
    # end
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) when byte_size(message) >= 2 do
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

    {:noreply, assign(socket, message: "", errors: %{})}
  end

  @impl true
  def handle_event("submit_message", _payload, socket) do
    {:noreply, assign(socket, errors: %{message: "Message must be at least 2 characters long"})}
  end

  def display_message(%{type: :system, text: text}) do
    ~E"""
    <p><em><%= text %></em></p>
    """
  end

  def display_message(%{uuid: uuid, text: text, username: username}) do
    ~E"""
    <p><strong><%= username %> : </strong><%= text %></p>
    """
  end
end
