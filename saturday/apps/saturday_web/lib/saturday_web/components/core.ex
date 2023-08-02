defmodule SaturdayWeb.CoreComponents do
  use Phoenix.Component
  import SaturdayWeb.Gettext

  def navbar_brand(assigns) do
    # Routes.static_path(@conn, "/images/logo.png")
    ~H"""
    <a href="https://www.donnu.edu.ua/uk/" class="image is-96x96 m-2">
      <img src={@brand_src} alt="DonNU Logo"/>
    </a>
    """
  end

  def management_navbar(assigns) do
    ~H"""
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
    """
  end

  def header(assigns) do
    ~H"""
    <nav class="navbar has-background-primary-light">
      <div class="navbar-brand">
        <.navbar_brand brand_src={@brand_src} />
        <%= if @is_authorized do %>
          <a role="button" class="navbar-burger" data-target="navMenu" aria-label="menu" aria-expanded="false">
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        <% end %>
      </div>
      <div class="navbar-menu" id="navMenu">
        <%= if @is_authorized do %>
          <div class="navbar-end">
            <.management_navbar current_path={@current_path} />
          </div>
        <% end %>
      </div>
    </nav>
    """
  end
end
