defmodule PeekPoc.Organizations.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "customers" do
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
