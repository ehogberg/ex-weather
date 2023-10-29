# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :weather, Weather.Repo,
    url: database_url,
    # ssl: true,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")


  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :weather, WeatherWeb.Endpoint,
    server: true,
    load_from_system_env: true,
    http: [
      port: {:system, "PORT"},
      compress: true,
      transport_options: [socket_opts: [:inet6]]],
    secret_key_base: secret_key_base,
    url: [host: System.get_env("APP_NAME") <> ".gigalixirapp.com", port: 443],
    # force_ssl: [hsts: true],
    cache_static_manifest: "priv/static/cache_manifest.json"
end

# Weather service API key
# To fetch weather data from Open Weathermap, you'll need an API key.  A free account can be
# set up at https://home.openweathermap.org/users/sign_up.  Once set up, visit
# https://home.openweathermap.org/api_keys to generate an API key.
# Once your API key has been set, store it in an env var named WEATHER_SERVICE_API

weather_service_api_key =
  System.get_env("WEATHER_SERVICE_API_KEY") ||
    raise """
    Environment variable WEATHER_SERVICE_API_KEY is missing.

    To fetch weather data from Open Weathermap, you'll need an API key.  A free account can be
    set up at https://home.openweathermap.org/users/sign_up.  Once set up, visit
    https://home.openweathermap.org/api_keys to generate an API key.
    """
config :weather, weather_service_api_key: weather_service_api_key
