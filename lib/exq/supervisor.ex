defmodule Exq.Supervisor do
  use Supervisor

  @default_name :exq

  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts, [])
  end

  def init(opts) do
    name = Keyword.get(opts, :name, @default_name)
    redis_pool_name = String.to_atom("#{name}_redis_pool")
    opts = Keyword.put(opts, :redis, redis_pool_name)

    [
      Exq.Redis.Pool.child_spec(redis_pool_name, opts),
      worker(Exq.Stats.Server, [opts]),
      worker(Exq.Enqueuer.Server, [opts]),
      worker(Exq.Scheduler.Server, [opts]),
      worker(Exq.Manager.Server, [opts]),
    ] |> supervise(strategy: :one_for_one, max_restarts: 500, max_seconds: 5)
  end
end
