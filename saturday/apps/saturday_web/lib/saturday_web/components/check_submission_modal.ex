defmodule SaturdayWeb.ModalComponent.CSStateComponents do
  use Phoenix.Component

  alias Saturday.Schedule

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
      <div class="is-size-2 mb-2">Запис знайдено!</div>
      <div class="is-size-2 mb-3"><%= @booking_date %></div>
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
    <button type="button" phx-click="close-cs-modal" class={"button #{@type}"}>Закрити</button>
    """
  end
end

defmodule SaturdayWeb.CSModalComponent do
  use Phoenix.LiveComponent

  alias Saturday.Schedule
  alias Saturday.Entries
  alias SaturdayWeb.ModalComponent.CSStateComponents

  def update(assigns, socket) do
    assigns =
      assigns
      |> Map.put_new(:state, :application)

    socket = assign(socket, assigns)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={"modal is-active"}
      phx-hook="InitCSModal"
    >
    <div class="modal-background"></div>
    <div class="modal-card">
    <header class="modal-card-head">
      <p class="modal-card-title is-flex-shrink-1">Перевірити свій запис</p>
      <button class="delete" aria-label="close"></button>
    </header>
      <section class="modal-card-body">
      <%= case @state do %>
        <% :application -> %>
          <.live_component module={SaturdayWeb.CSFormComponent}
          id="cs1-form-component" />
        <% :error -> %>
          <CSStateComponents.error />
        <% :success -> %>
          <CSStateComponents.success booking_date={@booking_date} />
        <% :already_booked_error -> %>
          <CSStateComponents.already_booked />
      <% end %>
      </section>
    </div>
    </div>
    """
  end
end
