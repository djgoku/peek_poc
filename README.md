# PeekPoc

There is one main context [PeekPoc.Organizations](./lib/peek_poc/organizations.ex). There are 3 schemas [PeekPoc.Organizations.Customer](./lib/peek_poc/organizations/customer.ex), [PeekPoc.Organizations.Order](./lib/peek_poc/organizations/order.ex) and [PeekPoc.Organizations.Payment](./lib/peek_poc/organizations/payment.ex). These are all backed by a SQLite3 database.

Current State: *Tests Passing*

It is easier to say what I didn't implement yet and that was the randomized payment failures.

Here is a run down how to use the code in this repository:
```elixir
{:ok, customer} = PeekPoc.Organizations.create_customer(%{email: "a@example.com"})
{:ok, order_without_payment} = PeekPoc.Organizations.create_order(%{customer_id: customer.id, original_cost: 30})
PeekPoc.Organizations.get_order(order_without_payment.id)
PeekPoc.Organizations.get_orders_for_customer(customer.email)
{:ok, :payment_made} = PeekPoc.Organizations.apply_payment_to_order(order_without_payment, "payment-1", 1)
{:ok, %{order: order, payment: payment}} = PeekPoc.Organizations.create_order_and_pay(customer, %{original_cost: 5}, %{amount: 1, client_identifier: "payment-1"})
```
