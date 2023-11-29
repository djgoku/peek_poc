defmodule PeekPoc.Organizations.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  alias PeekPoc.Organizations.Order

  schema "payments" do
    field(:amount, :integer)
    field(:client_identifier, :string)
    belongs_to(:order, Order)

    timestamps()
  end

  @doc false
  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :client_identifier, :order_id])
    |> validate_required([:amount, :client_identifier, :order_id])
    |> unique_constraint([:order_id, :client_identifier])
  end
end
