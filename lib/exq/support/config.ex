defmodule Exq.Support.Config do
  defstruct [
    redis: %{
      host: "127.0.0.1",
      port: 6379,
      database: 0,
      password: "",
      namespace: "exq"
    },
    scheduler_poll_timeout: 200,
    poll_timeout: 50,
    scheduler_enable: true,
    reconnect_on_sleep: 100,
    concurrency: 100,
    redis_timeout: 5000,
    genserver_timeout: 5000,
    max_retries: 25
  ]

  @moduledoc """
  This module holds the default configuration for Exq.

  Values can be overridden by configuration in the user application config,
  or values passed in as the configuration to Exq.start_link

  It also contains the logic for dynamically retrieving configuration values
  set in the sytem environment. Example:

  ```
  config :exq,
    password: {:system, "REDIS_PASSWORD"}
  ```

  This will do `System.get_env("REDIS_PASSWORD")`` at runtime. This is very
  important for exrm releases which build the configuration at compile time,
  making it impractical to use `System.get_env` directly in the config files.
  """

  def get() do
    %__MODULE__{}
    |> Map.from_struct
    |> Enum.reduce(%__MODULE__{}, fn
      {:redis, redis}, config ->
        Map.put(config, :redis, build_redis_config(redis))
      {k, v}, config ->
        Map.put(config, k, Application.get_env(:exq, k, v))
    end)
  end

  defp build_redis_config(redis) do
    Enum.reduce(redis, %{}, fn {k, v}, config ->
      Map.put(config, k, Application.get_env(:exq, k, v))
    end)
  end
end
