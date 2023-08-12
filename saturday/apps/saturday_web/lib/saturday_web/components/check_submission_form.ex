defmodule SaturdayWeb.CSFormComponent do
  use Phoenix.LiveComponent

  alias Saturday.Queue

  def mount(socket) do
    socket =
      assign(socket,
        phone: ""
      )

    {:ok, socket}
  end

  def handle_event("update-form", %{"phone" => phone}, socket) do
    socket =
      assign(socket,
        phone: phone
      )

    {:noreply, socket}
  end

  def remove_non_digits(phone) do
    Regex.replace(~r/\D/, phone, "")
  end

  def handle_event("submit-form", _, socket) do
    phone = socket.assigns.phone

    require Logger

    entry =
      Enum.find(Saturday.Entries.list_entries(), fn entry ->
        remove_non_digits(entry.agent_phone) == remove_non_digits(phone)
      end)

    case entry do
      nil ->
        Logger.info("entry is nil")

        send_update(SaturdayWeb.CSModalComponent,
          id: "cs1-modal",
          state: :error
        )

      _ ->
        send(self(), {:record_token, "check-submission"})

        send_update(SaturdayWeb.CSModalComponent,
          id: "cs1-modal",
          state: :success,
          booking_date: entry.booking_date
        )
    end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <form
        phx-change="update-form"
        phx-submit="submit-form"
        phx-target={@myself}
      >
      <div class="field">
        <label class="label">Телефон</label>
        <div class="control has-icons-left has-icons-right">
          <input class="input"
          value={@phone} type="phone" name="phone" placeholder="+380-XX-XX-XX-XXX">
          <span class="icon is-small is-left">
            <i class="fas fa-envelope"></i>
          </span>
          <span class="icon is-small is-right">
            <i class="fas fa-exclamation-triangle"></i>
          </span>
        </div>
      </div>
      <div class="field is-grouped">
        <div class="control">
          <button type="submit" class="button is-link">Перевірити</button>
        </div>
      </div>
      </form>
    </div>

    """
  end
end
