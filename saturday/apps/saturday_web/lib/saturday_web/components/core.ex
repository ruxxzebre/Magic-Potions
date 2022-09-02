defmodule SaturdayWeb.CoreComponents do
  use Phoenix.Component
  import SaturdayWeb.Gettext

  def header(assigns) do
    ~H"""
    <div class="navbar-end">
      <div class="navbar-item">
        <div class="buttons">
          <%= if @current_path == "booking" do %>
            <a
              href={"/management"}
              class="button is-warning"><%= dgettext("management", "open-management-panel") %>
            </a>
          <% else %>
            <a
              href={"/booking"}
              class="button is-warning"><%= dgettext("management", "open-booking-page") %>
            </a>
          <% end %>
          <a href="/management/download_report" class="button is-primary"><%= dgettext("management", "download-report") %></a>
          <a href="/dashboard/home" class="button is-info"><%= dgettext("management", "dashboard") %></a>
          <a href="/users/log_out" class="button is-danger"><%= dgettext("management", "logout") %></a>
        </div>
      </div>
    </div>
    """
  end
end
