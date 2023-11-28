defmodule PeekPoc.Repo do
  use Ecto.Repo,
    otp_app: :peek_poc,
    adapter: Ecto.Adapters.SQLite3
end
