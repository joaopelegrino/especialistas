# DSM:PLATFORM:web_views HEALTHCARE:page_templates
defmodule HealthcareCMSWeb.PageHTML do
  @moduledoc """
  Healthcare CMS Page HTML Module

  Sprint 0-1: Page template rendering.
  """

  use HealthcareCMSWeb, :html

  embed_templates "page_html/*"

  def dashboard(assigns) do
    ~H"""
    <%= Phoenix.Template.embed_template("page_html/dashboard.html.heex", assigns) %>
    """
  end
end