defmodule PeekPoc.OrganizationsTest do
  use PeekPoc.DataCase

  alias PeekPoc.Organizations

  describe "customers" do
    alias PeekPoc.Organizations.Customer

    import PeekPoc.OrganizationsFixtures

    @invalid_attrs %{email: nil}

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Organizations.list_customers() == [customer]
    end

    test "get_customer!/1 returns the customer with given id" do
      customer = customer_fixture()
      assert Organizations.get_customer!(customer.id) == customer
    end

    test "create_customer/1 with valid data creates a customer" do
      valid_attrs = %{email: "some email"}

      assert {:ok, %Customer{} = customer} = Organizations.create_customer(valid_attrs)
      assert customer.email == "some email"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      update_attrs = %{email: "some updated email"}

      assert {:ok, %Customer{} = customer} = Organizations.update_customer(customer, update_attrs)
      assert customer.email == "some updated email"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_customer(customer, @invalid_attrs)
      assert customer == Organizations.get_customer!(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Organizations.delete_customer(customer)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_customer!(customer.id) end
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Organizations.change_customer(customer)
    end
  end

  describe "orders" do
    alias PeekPoc.Organizations.Order

    import PeekPoc.OrganizationsFixtures

    @invalid_attrs %{original_cost: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Organizations.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Organizations.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{original_cost: 42}

      assert {:ok, %Order{} = order} = Organizations.create_order(valid_attrs)
      assert order.original_cost == 42
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{original_cost: 43}

      assert {:ok, %Order{} = order} = Organizations.update_order(order, update_attrs)
      assert order.original_cost == 43
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_order(order, @invalid_attrs)
      assert order == Organizations.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Organizations.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Organizations.change_order(order)
    end
  end
end
