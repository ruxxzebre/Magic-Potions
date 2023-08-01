defmodule SaturdayWeb.ModalComponent.StateComponents do
  use Phoenix.Component

  def error(assigns) do
    assigns = assign_new(assigns, :hrs_until_expires, fn -> 24 end)

    ~H"""
    <div>
      <div class="is-size-2 mb-5">Сталась похибка. Спробуйте ще раз.</div>
      <%= close_button(type: "is-danger") %>
    </div>
    """
  end

  def success(assigns) do
    ~H"""
    <div>
      <div class="is-size-2 mb-5">Все супер!</div>
      <%= close_button(type: "is-success") %>
    </div>
    """
  end

  def already_booked(assigns) do
    ~H"""
    <div>
      <div class="is-size-2 mb-5">
        Схоже хтось впорався швидше...
        <br> Але не переймайся, все ще можеш обрати інший час.
      </div>
      <%= close_button(type: "is-info") %>
    </div>
    """
  end

  def close_button(assigns \\ [type: "is-info"]) do
    assigns = Enum.into(assigns, %{})

    ~H"""
    <button phx-click="close-modal" class={"button #{@type}"}>Закрити</button>
    """
  end
end

defmodule SaturdayWeb.ModalComponent do
  use Phoenix.LiveComponent

  alias Saturday.Schedule
  alias Saturday.Entries
  alias SaturdayWeb.ModalComponent.StateComponents

  def update(assigns, socket) do
    state =
      cond do
        Entries.booked?(assigns.datetime) -> :already_booked_error
        true -> :application
      end

    assigns =
      assigns
      |> Map.put_new(:state, state)

    socket = assign(socket, assigns)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"modal #{if @datetime_exists, do: "is-active", else: ""}"}
      phx-hook="InitModal"
    >
    <div class="modal-background"></div>
    <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title">Запис на <br /><%= Schedule.format_date!(@datetime, with_time: true) %></p>
      <button class="delete" aria-label="close"></button>
    </header>
      <section class="modal-card-body">
      <%= case @state do %>
        <% :application -> %>
          <.live_component module={SaturdayWeb.ApplyingFormComponent}
          datetime={@datetime}
          id="applying-form-component" />
        <% :error -> %>
          <StateComponents.error />
        <% :success -> %>
          <StateComponents.success />
        <% :already_booked_error -> %>
          <StateComponents.already_booked />
      <% end %>
      </section>
    </div>
    </div>
    """
  end
end
