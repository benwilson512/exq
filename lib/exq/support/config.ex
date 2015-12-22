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

  @type t :: %__MODULE__{
    redis: %{
      host: binary,
      port: non_neg_integer,
      database: non_neg_integer,
      password: binary,
      namespace: binary
    },
    scheduler_poll_timeout: non_neg_integer,
    poll_timeout: non_neg_integer,
    scheduler_enable: true,
    reconnect_on_sleep: non_neg_integer,
    concurrency: non_neg_integer,
    redis_timeout: non_neg_integer,
    genserver_timeout: non_neg_integer,
    max_retries: non_neg_integer
  }

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

  @doc """
  Builds an Exq configuration struct.
  """
  @spec build(overrides :: Dict.t) :: t
  def build(overrides) do
    overrides = overrides |> Enum.into(%{})

    %__MODULE__{}
    |> Map.from_struct
    |> Enum.reduce(%__MODULE__{}, fn
      {:redis, redis}, config ->
        Map.put(config, :redis, build_redis_config(redis, overrides))
      {k, v}, config ->
        Map.put(config, k, Map.get(overrides, k, v))
    end)
  end

  defp build_redis_config(redis, overrides) do
    Enum.reduce(redis, %{}, fn {k, v}, config ->
      Map.put(config, k, Map.get(overrides, k, v))
    end)
  end
end
