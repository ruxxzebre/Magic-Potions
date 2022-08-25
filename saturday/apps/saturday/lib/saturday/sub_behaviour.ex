defmodule Saturday.SubBehaviour do
  defmacro __using__(opts) do
    topic = Keyword.get(opts, :topic, nil)
    if topic == nil do
      raise "Be sure to pass topic to as an option to SubBehaviour"
    end

    quote bind_quoted: [topic: topic] do
      def subscribe(topic_prefix \\ "") do
        Phoenix.PubSub.subscribe(Saturday.PubSub, unquote(topic) <> topic_prefix)
      end

      def broadcast(event) do
        Phoenix.PubSub.broadcast(Saturday.PubSub, unquote(topic), event)
      end

      def broadcast(event, data) do
        Phoenix.PubSub.broadcast(Saturday.PubSub, unquote(topic), {event, data})
      end

      def broadcast2(data, event) do
        Phoenix.PubSub.broadcast(Saturday.PubSub, unquote(topic), {event, data})
        data
      end

      def broadcast_w_prefix(event, topic_prefix) when is_binary(topic_prefix) do
        Phoenix.PubSub.broadcast(Saturday.PubSub, unquote(topic) <> topic_prefix, event)
      end

      def broadcast_w_prefix(event, data, topic_prefix) when is_binary(topic_prefix) do
        Phoenix.PubSub.broadcast(Saturday.PubSub, unquote(topic) <> topic_prefix, {event, data})
      end
    end
  end
end
