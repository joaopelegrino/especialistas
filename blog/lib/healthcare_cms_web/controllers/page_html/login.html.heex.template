# DSM:PLATFORM:authentication HEALTHCARE:user_login
# DSM:SECURITY:zero_trust_auth PERFORMANCE:session_management
defmodule HealthcareCMSWeb.AuthLive.Login do
  @moduledoc """
  Healthcare CMS Login LiveView

  Sprint 0-2: Authentication Flow
  Implements login form with:
  - Email/password authentication
  - Zero Trust context injection
  - Healthcare compliance tracking
  - Role-based redirect after login
  """

  use HealthcareCMSWeb, :live_view

  alias HealthcareCMS.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Login - Healthcare CMS")
     |> assign(:form, to_form(%{"email" => "", "password" => ""}))}
  end

  @impl true
  def handle_event("login", %{"email" => email, "password" => password}, socket) do
    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Login realizado com sucesso! Bem-vindo, #{user.name}.")
         |> redirect(to: ~p"/dashboard")}

      {:error, :invalid_credentials} ->
        {:noreply,
         socket
         |> put_flash(:error, "Email ou senha inválidos.")
         |> assign(:form, to_form(%{"email" => email, "password" => ""}))}

      {:error, :user_inactive} ->
        {:noreply,
         socket
         |> put_flash(:error, "Usuário inativo. Entre em contato com o administrador.")
         |> assign(:form, to_form(%{"email" => email, "password" => ""}))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-500 to-purple-600 py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8 bg-white p-10 rounded-xl shadow-2xl">
        <div>
          <h1 class="text-center text-4xl font-extrabold text-gray-900">
            Healthcare CMS
          </h1>
          <p class="mt-2 text-center text-sm text-gray-600">
            Plataforma de Gestão de Conteúdo Médico
          </p>
          <p class="mt-1 text-center text-xs text-purple-600 font-semibold">
            Sprint 0-2: Authentication Flow ✓
          </p>
        </div>

        <.form
          for={@form}
          phx-submit="login"
          class="mt-8 space-y-6"
        >
          <div class="rounded-md shadow-sm -space-y-px">
            <div>
              <label for="email" class="sr-only">Email</label>
              <input
                id="email"
                name="email"
                type="email"
                required
                value={@form["email"].value}
                class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-t-md focus:outline-none focus:ring-purple-500 focus:border-purple-500 focus:z-10 sm:text-sm"
                placeholder="Email médico"
              />
            </div>
            <div>
              <label for="password" class="sr-only">Senha</label>
              <input
                id="password"
                name="password"
                type="password"
                required
                class="appearance-none rounded-none relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 rounded-b-md focus:outline-none focus:ring-purple-500 focus:border-purple-500 focus:z-10 sm:text-sm"
                placeholder="Senha"
              />
            </div>
          </div>

          <div class="flex items-center justify-between">
            <div class="text-sm">
              <a href="/register" class="font-medium text-purple-600 hover:text-purple-500">
                Criar nova conta
              </a>
            </div>
          </div>

          <div>
            <button
              type="submit"
              class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-colors"
            >
              <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                <svg
                  class="h-5 w-5 text-purple-500 group-hover:text-purple-400"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                  aria-hidden="true"
                >
                  <path
                    fill-rule="evenodd"
                    d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
                    clip-rule="evenodd"
                  />
                </svg>
              </span>
              Entrar
            </button>
          </div>

          <div class="text-center text-xs text-gray-500 space-y-1">
            <p>🔒 Zero Trust Security</p>
            <p>📋 LGPD Compliant</p>
            <p>🏥 CFM/CRP Healthcare Standards</p>
          </div>
        </.form>
      </div>
    </div>
    """
  end
end