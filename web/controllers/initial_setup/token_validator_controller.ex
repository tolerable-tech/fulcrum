defmodule Fulcrum.InitialSetup.TokenValidatorController do
  use Fulcrum.Web, :controller

  #plug :scrub_params, "token_validator" when action in [:create, :update]
  plug Plugs.Initializer when not action in [:index, :validate]

  def index(conn, params) do
    token = Map.get(params, "token")
    render(conn, "token_confirmation.html", token: token, conn: conn, invalid: false)
  end

  def validate(conn, parms = %{"token" => token}) do
    # put token in session if valid
    case Fulcrum.Initializer.validate(token) do
      :valid ->
        cs = Fulcrum.Owner.changeset(%Fulcrum.Owner{email: Fulcrum.Settings.owner_email})
        conn
        |> put_session(:token, token)
        #|> redirect(to: token_validator_path(conn, :choose_setup))
        |> render("choose_setup_path.html", parms: parms, changeset: cs)
      :invalid ->
        render(conn, "token_confirmation.html", token: token, conn: conn, invalid: true)
    end
  end

  def setup(conn, params = %{"recover_from_url" => url}) when is_bitstring(url) do
    # trigger restore from provided url
  end
  def setup(conn, params = %{"connect_to_url" => url}) when is_bitstring(url) do
    # setup Repo to talk to existing database
  end
  def setup(conn, params = %{"owner" => owner_params}) do
    # launch DB on current platform
    # create owner record from params, start login
    cs = Fulcrum.Owner.changeset(%Fulcrum.Owner{}, owner_params)
    case Repo.insert(cs) do
      {:ok, owner} ->
        IO.inspect owner
        Fulcrum.Initializer.owner_created(owner.id)
        conn
        |> delete_session(:token)
        |> redirect(to: login_path(conn, :new))
      {:error, cs} ->
        render(conn, "choose_setup_path.html", parms: owner_params, changeset: cs)
    end
  end

  #def index(conn, _params) do
    #validators = Repo.all(TokenValidator)
    #render(conn, "index.html", validators: validators)
  #end

  #def new(conn, _params) do
    #changeset = TokenValidator.changeset(%TokenValidator{})
    #render(conn, "new.html", changeset: changeset)
  #end

  #def create(conn, %{"token_validator" => token_validator_params}) do
    #changeset = TokenValidator.changeset(%TokenValidator{}, token_validator_params)

    #case Repo.insert(changeset) do
      #{:ok, _token_validator} ->
        #conn
        #|> put_flash(:info, "Token validator created successfully.")
        #|> redirect(to: token_validator_path(conn, :index))
      #{:error, changeset} ->
        #render(conn, "new.html", changeset: changeset)
    #end
  #end

  #def show(conn, %{"id" => id}) do
    #token_validator = Repo.get!(TokenValidator, id)
    #render(conn, "show.html", token_validator: token_validator)
  #end

  #def edit(conn, %{"id" => id}) do
    #token_validator = Repo.get!(TokenValidator, id)
    #changeset = TokenValidator.changeset(token_validator)
    #render(conn, "edit.html", token_validator: token_validator, changeset: changeset)
  #end

  #def update(conn, %{"id" => id, "token_validator" => token_validator_params}) do
    #token_validator = Repo.get!(TokenValidator, id)
    #changeset = TokenValidator.changeset(token_validator, token_validator_params)

    #case Repo.update(changeset) do
      #{:ok, token_validator} ->
        #conn
        #|> put_flash(:info, "Token validator updated successfully.")
        #|> redirect(to: token_validator_path(conn, :show, token_validator))
      #{:error, changeset} ->
        #render(conn, "edit.html", token_validator: token_validator, changeset: changeset)
    #end
  #end

  #def delete(conn, %{"id" => id}) do
    #token_validator = Repo.get!(TokenValidator, id)

    ## Here we use delete! (with a bang) because we expect
    ## it to always work (and if it does not, it will raise).
    #Repo.delete!(token_validator)

    #conn
    #|> put_flash(:info, "Token validator deleted successfully.")
    #|> redirect(to: token_validator_path(conn, :index))
  #end
end
