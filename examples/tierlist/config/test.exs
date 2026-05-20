import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tierlist, TierlistWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "e+MU+VTfOKYXTSvF+ttYo640BPdw7CLQssn+95WDc5ulmd/GQNM7D77gujJdzRLm",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
