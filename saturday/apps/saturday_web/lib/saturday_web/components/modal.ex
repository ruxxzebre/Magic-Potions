defmodule SaturdayWeb.ModalComponent do
  use Phoenix.LiveComponent

  alias Saturday.Schedule

  def render(assigns) do
    ~H"""
    <div id={@id} class={"modal#{if @datetime_exists, do: " is-active", else: ""}"} phx-hook="InitModal">
    <div class="modal-background"></div>
    <div class="modal-card">
    <header class="modal-card-head">
      <%= if @datetime_exists do %>
        <p class="modal-card-title">Запис на <%= Schedule.format_date!(@datetime) %></p>
      <% end %>
      <button class="delete" aria-label="close"></button>
    </header>
    <section class="modal-card-body">
      <.live_component module={SaturdayWeb.ApplyingFormComponent} id="applying-form-component" />
    </section>
    <footer class="modal-card-foot">
      <button class="button is-success">Save changes</button>
      <button class="button">Cancel</button>
    </footer>
    </div>
    </div>
    """
  end
end
