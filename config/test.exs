import Config

config :peek_poc, PeekPoc.Repo,
  database: Path.expand("../peek_poc_test.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  pool: Ecto.Adapters.SQL.Sandbox
