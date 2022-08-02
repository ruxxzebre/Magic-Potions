defmodule SaturdayWeb.FormFieldComponent do

end

defmodule SaturdayWeb.ApplyingFormComponent do
  use Phoenix.LiveComponent

  alias Saturday.Queue

  def mount(socket) do
    # TODO: with changeset

    socket = assign(socket,
      name: "",
      email: "",
      phone: ""
    )
    {:ok, socket}
  end

  def handle_event("update-form", %{"email" => email, "phone" => phone, "name" => name}, socket) do
    socket = assign(socket,
      email: email,
      name: name,
      phone: phone
    )

    {:noreply, socket}
  end

  def handle_event("submit-form", _, socket) do
    name = socket.assigns.name
    email = socket.assigns.email
    phone = socket.assigns.phone
    datetime = socket.assigns.datetime

    socket = case Queue.apply_to_entry(%{
      agent_name: name,
      agent_phone: phone,
      booking_date: datetime,
      misc: "email: #{email}"
    }) do
      {:error} ->
        socket
        |> assign(error: "Unknown error")
      {:ok} ->
        send(self(), :close_modal)
        socket
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
      <label class="label">ПІБ</label>
      <div class="control">
        <input class="input"
        value={@name} type="text" name="name" placeholder="Іванов Іван Іванович">
      </div>
    </div>
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
    <div class="field">
      <label class="label">Пошта (опціонально)</label>
      <div class="control has-icons-left has-icons-right">
        <input class="input"
        value={@email} type="email" name="email" placeholder="danger.a@gmail.com">
        <span class="icon is-small is-left">
          <i class="fas fa-envelope"></i>
        </span>
        <span class="icon is-small is-right">
          <i class="fas fa-exclamation-triangle"></i>
        </span>
      </div>
      <!-- <p class="help is-danger">This email is invalid</p> -->
    </div>
    <div class="field is-grouped">
      <div class="control">
        <button type="submit" class="button is-link">Зберегти</button>
      </div>
    </div>
    </form>
  </div>

    """
  end
end
