defmodule Fulcrum.Owner do
  use Fulcrum.Web, :model

  alias Addict.Interactors.GenerateEncryptedPassword, as: PasswordHashGenerator

  schema "owners" do
    field :username,           :string
    field :email,              :string
    field :encrypted_password, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps
  end

  @required_fields ~w(email)
  @optional_fields ~w(username password password_confirmation)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_password_confirmation_and_set_hash
  end

  defp validate_password_confirmation_and_set_hash(cs = %{changes: %{password: password}}) when is_bitstring(password) do
    case password == get_change(cs, :password_confirmation) do
      true ->
        cs
        |> change(%{encrypted_password: PasswordHashGenerator.call(password)})
        |> delete_change(:password)
        |> delete_change(:password_confirmation)
      _ -> add_error(cs, :password, "Password does not match confirmation.")
    end
  end
  defp validate_password_confirmation_and_set_hash(cs), do: cs

end
