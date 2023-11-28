defmodule PeekPoc.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PeekPoc.Organizations` context.
  """

  @doc """
  Generate a unique customer email.
  """
  def unique_customer_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        email: unique_customer_email()
      })
      |> PeekPoc.Organizations.create_customer()

    customer
  end

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        original_cost: 42
      })
      |> PeekPoc.Organizations.create_order()

    order
  end
end
