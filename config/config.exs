use Mix.Config

config :hound, driver: "chrome_driver"

config :logger, :console,
  # level: :info,
  format: "[$level] $message\n"
