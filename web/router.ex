defmodule Fulcrum.Router do
  use Fulcrum.Web, :router
  use Addict.RoutesHelper

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :initializer
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :initial_setup_browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :initializer
  end

  scope "/l" do
    pipe_through :browser
    addict :routes
  end

  scope "/", Fulcrum do
    pipe_through :browser # Use the default browser stack

    get "/login", LoginController, :new
    #get "register", RegistrationController, :new

    get "register", RegistrationController, :new

    resources "/registration", RegistrationController, except: [:index, :create, :new]

    get "/", ComponentController, :index

    resources "/owners", OwnerController
    resources "/components", ComponentController
    resources "/instances", InstanceController, except: [:index, :create]
  end

  scope "/setup", Fulcrum.InitialSetup do
    pipe_through :initial_setup_browser

    get "/validate_token", TokenValidatorController, :index
    #put "/validate_token/:token", TokenValidatorController, :validate
    post "/validate_token", TokenValidatorController, :validate
    post "/initial", TokenValidatorController, :setup
  end

  def initializer(conn, opts) do
    Plugs.Initializer.call(conn, opts)
  end

  # Other scopes may use custom stacks.
  # scope "/api", Fulcrum do
  #   pipe_through :api
  # end
end
