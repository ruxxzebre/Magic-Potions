defmodule SaturdayWeb.DemoLive do
  use SaturdayWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, key: 1, opened: false)
    {:ok, socket}
  end

  @impl true
  def handle_event("toggle", _, socket) do
    socket = assign(socket, opened: !socket.assigns.opened)
    {:noreply, socket}
  end
end
