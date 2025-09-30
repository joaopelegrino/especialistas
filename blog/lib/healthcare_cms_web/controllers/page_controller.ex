# DSM:PLATFORM:web_controllers HEALTHCARE:landing_page
defmodule HealthcareCMSWeb.PageController do
  @moduledoc """
  Healthcare CMS Page Controller

  Sprint 0-1: Landing page controller.
  Handles public homepage rendering.
  """

  use HealthcareCMSWeb, :controller

  @doc """
  Render homepage (GET /)
  """
  def home(conn, _params) do
    render(conn, :home, layout: false)
  end

  @doc """
  Login form (GET /login)
  """
  def login(conn, _params) do
    render(conn, :login, layout: false)
  end

  @doc """
  Process login (POST /login)
  """
  def do_login(conn, %{"email" => email, "password" => password}) do
    alias HealthcareCMS.Accounts

    case Accounts.authenticate_user(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> Accounts.update_last_login()
        |> put_flash(:info, "Login realizado com sucesso! Bem-vindo, #{user.first_name}.")
        |> redirect(to: ~p"/dashboard")

      {:error, :invalid_credentials} ->
        conn
        |> put_flash(:error, "Email ou senha inválidos.")
        |> redirect(to: ~p"/login")

      {:error, :user_inactive} ->
        conn
        |> put_flash(:error, "Usuário inativo. Entre em contato com o administrador.")
        |> redirect(to: ~p"/login")
    end
  end

  @doc """
  Registration form (GET /register)
  """
  def register(conn, _params) do
    render(conn, :register, layout: false)
  end

  @doc """
  Process registration (POST /register)
  """
  def do_register(conn, %{"user" => user_params}) do
    alias HealthcareCMS.Accounts

    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Conta criada com sucesso! Faça login para continuar.")
        |> redirect(to: ~p"/login")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Erro ao criar conta. Verifique os dados e tente novamente.")
        |> redirect(to: ~p"/register")
    end
  end

  @doc """
  Logout user (GET /logout)
  """
  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Logout realizado com sucesso.")
    |> redirect(to: ~p"/")
  end

  @doc """
  Dashboard protected page (GET /dashboard)
  """
  def dashboard(conn, _params) do
    user = conn.assigns.current_user

    conn
    |> put_flash(:info, "Bem-vindo, #{user.first_name}!")
    |> render(:dashboard, user: user)
  end
end