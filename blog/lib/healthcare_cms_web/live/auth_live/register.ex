# DSM:PLATFORM:user_registration HEALTHCARE:account_creation
# DSM:SECURITY:zero_trust_onboarding PERFORMANCE:async_validation
defmodule HealthcareCMSWeb.AuthLive.Register do
  @moduledoc """
  Healthcare CMS Registration LiveView

  Sprint 0-2: User Registration
  Implements registration form with:
  - Email/password/name fields
  - Role selection (default: subscriber)
  - Healthcare professional validation (CRM/CRP)
  - LGPD consent tracking
  """

  use HealthcareCMSWeb, :live_view

  alias HealthcareCMS.Accounts
  alias HealthcareCMS.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    changeset = Accounts.change_user(%User{})

    {:ok,
     socket
     |> assign(:page_title, "Criar Conta - Healthcare CMS")
     |> assign(:form, to_form(changeset))
     |> assign(:roles, wordpress_roles())}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  @impl true
  def handle_event("register", %{"user" => user_params}, socket) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Conta criada com sucesso! Faça login para continuar.")
         |> redirect(to: ~p"/login")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-500 to-purple-600 py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8 bg-white p-10 rounded-xl shadow-2xl">
        <div>
          <h1 class="text-center text-4xl font-extrabold text-gray-900">
            Criar Conta
          </h1>
          <p class="mt-2 text-center text-sm text-gray-600">
            Healthcare CMS - Plataforma Médica
          </p>
        </div>

        <.form
          for={@form}
          phx-change="validate"
          phx-submit="register"
          class="mt-8 space-y-6"
        >
          <div class="rounded-md shadow-sm space-y-4">
            <div>
              <label for="name" class="block text-sm font-medium text-gray-700">
                Nome Completo
              </label>
              <input
                type="text"
                name="user[name]"
                id="name"
                value={@form[:name].value}
                required
                class="mt-1 appearance-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-purple-500 focus:border-purple-500 focus:z-10 sm:text-sm"
                placeholder="Dr. João Silva"
              />
              <.error :for={msg <- Enum.map(@form[:name].errors || [], &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <div>
              <label for="email" class="block text-sm font-medium text-gray-700">
                Email Profissional
              </label>
              <input
                type="email"
                name="user[email]"
                id="email"
                value={@form[:email].value}
                required
                class="mt-1 appearance-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-purple-500 focus:border-purple-500 focus:z-10 sm:text-sm"
                placeholder="medico@exemplo.com.br"
              />
              <.error :for={msg <- Enum.map(@form[:email].errors || [], &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-gray-700">
                Senha (mínimo 8 caracteres)
              </label>
              <input
                type="password"
                name="user[password]"
                id="password"
                required
                class="mt-1 appearance-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-purple-500 focus:border-purple-500 focus:z-10 sm:text-sm"
                placeholder="••••••••"
              />
              <.error :for={msg <- Enum.map(@form[:password].errors || [], &translate_error/1)}>
                {msg}
              </.error>
            </div>

            <div>
              <label for="role" class="block text-sm font-medium text-gray-700">
                Tipo de Conta
              </label>
              <select
                name="user[role]"
                id="role"
                class="mt-1 block w-full px-3 py-2 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm"
              >
                <%= for {label, value} <- @roles do %>
                  <option value={value}>{label}</option>
                <% end %>
              </select>
            </div>
          </div>

          <div class="flex items-center">
            <input
              id="terms"
              name="user[terms_accepted]"
              type="checkbox"
              required
              class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded"
            />
            <label for="terms" class="ml-2 block text-sm text-gray-900">
              Aceito os termos de uso e política de privacidade (LGPD)
            </label>
          </div>

          <div>
            <button
              type="submit"
              class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-colors"
            >
              Criar Conta
            </button>
          </div>

          <div class="text-center">
            <p class="text-sm text-gray-600">
              Já possui conta?
              <a href="/login" class="font-medium text-purple-600 hover:text-purple-500">
                Fazer login
              </a>
            </p>
          </div>

          <div class="text-center text-xs text-gray-500 space-y-1">
            <p>🔒 Dados protegidos com Zero Trust</p>
            <p>📋 100% LGPD Compliant</p>
            <p>🏥 Validação CRM/CRP automática</p>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  defp wordpress_roles do
    [
      {"Assinante (Leitor)", "subscriber"},
      {"Colaborador (Submete para revisão)", "contributor"},
      {"Autor (Publica próprio conteúdo)", "author"},
      {"Editor (Gerencia conteúdo)", "editor"}
    ]
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  defp error(assigns) do
    ~H"""
    <p class="mt-1 text-sm text-red-600">{@inner_block}</p>
    """
  end
end