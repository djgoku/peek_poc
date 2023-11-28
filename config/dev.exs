import Config

config :peek_poc, PeekPoc.Repo,
  database: Path.expand("../peek_poc_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true
