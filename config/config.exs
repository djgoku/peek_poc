import Config

config :peek_poc,
  ecto_repos: [PeekPoc.Repo]

import_config "#{config_env()}.exs"
