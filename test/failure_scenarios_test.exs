defmodule FailureScenariosTest do
  use ExUnit.Case
  use Timex
  import ExqTestUtil

  @moduletag :failure_scenarios

  defmodule PerformWorker do
    def perform do
      send :exqtest, {:worked}
    end
  end

  setup do
    TestRedis.setup
    Application.start(:ranch)
    on_exit fn ->
      wait
      TestRedis.teardown
    end
    :ok
  end

  test "handle Redis connection lost on manager" do
    conn = FlakyRedis.start(redis_host, redis_port)

    {:ok, _} = Exq.start_link([name: :exq_f, port: conn.port ])

    wait_long
    # Stop Redis and wait for a bit
    FlakyRedis.stop(conn)
    # Not ideal - but seems to be min time for manager to die past supervision
    :timer.sleep(5100)

    # Restart Flakey connection manually, things should be back to normal
    {:ok, agent} = Agent.start_link(fn -> [] end)
    {:ok, _} = :ranch.start_listener(conn.ref, 100, :ranch_tcp, [port: conn.port],
                  FlakyRedisHandler, ['127.0.0.1', redis_port, agent])

    wait_long
    assert_exq_up(:exq_f)
    Exq.stop(:exq_f)
  end

  test "handle Redis connection lost on enqueue" do
    conn = FlakyRedis.start(redis_host, redis_port)

    # Start Exq but don't listen to any queues
    {:ok, _} = Exq.start_link([name: :exq_f, port: conn.port])

    wait_long
    # Stop Redis
    FlakyRedis.stop(conn)
    wait_long

    # enqueue with redis stopped
    enq_result = Exq.enqueue(:exq_f, "default", "FakeWorker", [])
    assert enq_result ==  {:error, :closed}

    enq_result = Exq.enqueue_at(:exq_f, "default", Time.now, ExqTest.PerformWorker, [])
    assert enq_result ==  {:error, :closed}

    # Starting Redis again and things should be back to normal
    wait_long

    # Restart Flakey connection manually
    {:ok, agent} = Agent.start_link(fn -> [] end)
    {:ok, _} = :ranch.start_listener(conn.ref, 100, :ranch_tcp, [port: conn.port],
                  FlakyRedisHandler, ['127.0.0.1', redis_port, agent])
    wait_long

    assert_exq_up(:exq_f)
    Exq.stop(:exq_f)
  end
end
