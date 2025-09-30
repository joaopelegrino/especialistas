# DSM:PLATFORM:web_components HEALTHCARE:core_ui
defmodule HealthcareCMSWeb.CoreComponents do
  @moduledoc """
  Healthcare CMS Core Components

  Sprint 0-1: Minimal core components para foundation.
  Serão expandidos em Sprint 0-2 e 0-3.
  """

  use Phoenix.Component

  @doc """
  Renders a flash message.
  """
  def flash(%{kind: _kind, flash: _flash} = assigns) do
    ~H"""
    <div :if={msg = Phoenix.Flash.get(@flash, @kind)} class={"flash flash-#{@kind}"}>
      <%= msg %>
    </div>
    """
  end
end