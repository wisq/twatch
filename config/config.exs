use Mix.Config

config :hound, driver: "chrome_driver"

config :logger, :console,
  # level: :info,
  format: "[$level] $message\n"

config :briefly,
  directory: [{:system, "TMPDIR"}, "tmp", "/tmp"],
  default_prefix: "briefly",
  default_extname: ""
