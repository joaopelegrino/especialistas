# DSM:PLATFORM:i18n HEALTHCARE:localization
defmodule HealthcareCMSWeb.Gettext do
  @moduledoc """
  Healthcare CMS Gettext Module

  Sprint 0-1: Internationalization foundation.
  Support for pt-BR (primary) and en (secondary).
  """

  use Gettext.Backend, otp_app: :healthcare_cms
end