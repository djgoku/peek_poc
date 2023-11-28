defmodule PeekPoc.Organizations.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias PeekPoc.Organizations.Customer
  alias PeekPoc.Organizations.Payment

  schema "orders" do
    field(:original_cost, :integer)
    belongs_to(:customer, Customer)
    has_many(:payments, Payment)

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:original_cost, :customer_id])
    |> cast_assoc(:customer)
    |> cast_assoc(:payments)
    |> validate_required([:original_cost, :customer_id])
  end
end
