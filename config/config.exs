# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :fulcrum, Fulcrum.Endpoint,
  url: [host: "172.17.8.101"],
  root: Path.dirname(__DIR__),
  secret_key_base: "9IZCszsUeHW5cwLJltx/FbeCn7Qa2T9FF91zPXw4D4ByFsPR+fxa/wHiYOQvU/KS",
  debug_errors: false,
  check_origin: ["//172.17.8.101", "//172.17.8.101:32769"],
  pubsub: [name: Fulcrum.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :addict, not_logged_in_url: "/login",
                db: Fulcrum.Repo,
                user: Fulcrum.Owner,
                register_from_email: "Fulcrum Registration <welcome@fulcrum.space>", # email registered users will receive from address
                register_subject: "Welcome to Fulcrum!", # email registered users will receive subject
                password_recover_from_email: "Password Recovery <support@fulcrum.tech>",
                password_recover_subject: "You requested a password recovery link",
                email_templates: Fulcrum.MyEmailTemplates, # email templates for sending e-mails, more on this further down
                mailgun_domain: "mg.fulcrum.space",
                mailgun_key: "key-6397be9b24b045c0372e666a54d2076f",
                redirect_string: "/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
