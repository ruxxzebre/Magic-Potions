defmodule SaturdayWeb.FormFieldComponent do

end

defmodule SaturdayWeb.ApplyingFormComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
    <div class="field">
      <label class="label">ПІБ</label>
      <div class="control">
        <input class="input" type="text" placeholder="Іванов Іван Іванович">
      </div>
    </div>
    <div class="field">
      <label class="label">Пошта</label>
      <div class="control has-icons-left has-icons-right">
        <input class="input is-danger" type="email" placeholder="danger.a@gmail.com" value="hello">
        <span class="icon is-small is-left">
          <i class="fas fa-envelope"></i>
        </span>
        <span class="icon is-small is-right">
          <i class="fas fa-exclamation-triangle"></i>
        </span>
      </div>
      <!-- <p class="help is-danger">This email is invalid</p> -->
    </div>
    <div class="field">
      <label class="label">Телефон</label>
      <div class="control has-icons-left has-icons-right">
        <input class="input is-danger" type="phone" placeholder="+380-XX-XX-XX-XXX" value="hello@">
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
        <button class="button is-link">Submit</button>
      </div>
      <div class="control">
        <button class="button is-link is-light">Cancel</button>
      </div>
    </div>
  </div>

    """
  end
end
