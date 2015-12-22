defmodule Exq.Redis.Pool do
  alias Exq.Support.Config

  def child_spec(name, opts) do
    pool_opts = Application.get_env(:exq, :pool)
    |> Keyword.put(:name, {:local, name})
    |> Keyword.put(:worker_module, Ex)

    :poolboy.child_spec(name, pool_opts, redis_opts(opts))
  end

  def q(pool, args) do
    :poolboy.transaction(pool, &Redix.command(&1, args, [timeout: Config.get(:redis_timeout, @default_timeout)]))
  end

  def qp(pool, args) do
    :poolboy.transaction(pool, &Redix.pipeline(&1, args, [timeout: Config.get(:redis_timeout, @default_timeout)]))
  end

  def redis_opts(opts) do
    [
      host: Keyword.get(opts, :host, Config.get(:host, "127.0.0.1")),
      port: Keyword.get(opts, :port, Config.get(:port, 6379)),
      database: Keyword.get(opts, :database, Config.get(:database, 0)),
      password: Keyword.get(opts, :password, Config.get(:password) || ""),
      timeout: Keyword.get(opts, :redis_timeout, Config.get(:redis_timeout, 5000)),
      reconnect_on_sleep: Keyword.get(opts, :reconnect_on_sleep, Config.get(:reconnect_on_sleep, 100)),
    ]
    |> Enum.map(fn
      {k, v} when is_binary(v) -> {k, String.to_char_list(v)}
      other -> other
    end)
  end
end
