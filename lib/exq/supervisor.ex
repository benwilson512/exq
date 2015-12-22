defmodule Exq.Supervisor do
  use Supervisor

  @default_name :exq

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, [])
  end

  def init(config) do
    name = config.name
    redis_pool_name = String.to_atom("#{name}_redis_pool")
    opts = Keyword.put(config, :redis, redis_pool_name)

    [
      Exq.Redis.Pool.child_spec(redis_pool_name, config),
      worker(Exq.Stats, [config]),
      worker(Exq.Enqueuer, [config]),
      worker(Exq.Scheduler, [config]),
      worker(Exq.Manager, [config]),
    ] |> supervise(strategy: :one_for_one, max_restarts: 5, max_seconds: 5)
  end
end
