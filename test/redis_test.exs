defmodule Exq.RedisTest do
  use ExUnit.Case

  alias Exq.Redis

  setup_all do
    ExqTestUtil.reset_config
    TestRedis.setup
    on_exit fn ->
      ExqTestUtil.reset_config
      TestRedis.teardown
    end
  end

  setup do
    on_exit fn ->
      Redis.flushdb! :testredis
    end
    :ok
  end

  test "info" do
    Mix.Config.persist([exq: [host: '127.0.0.1', port: 6379, password: '', database: 0, reconnect_on_sleep: 100, redis_timeout: 5000]])
    {[host: host, port: port, database: database, password: password],
      [backoff: reconnect_on_sleep, timeout: timeout, name: client_name]}
     = Exq.Redis.Supervisor.info
    assert host == '127.0.0.1'
    assert port == 6379
    assert password == ''
    assert database == 0
    assert reconnect_on_sleep == 100
    assert timeout == 5000
    assert client_name == Exq.Redis.Client

    Mix.Config.persist([exq: [host: '127.1.1.1', password: 'password']])
    {redis_opts, _} = Exq.Redis.Supervisor.info
    assert redis_opts[:host] == '127.1.1.1'
    assert redis_opts[:password] == 'password'

    Mix.Config.persist([exq: [password: "binary_password"]])

    {redis_opts, _} = Exq.Redis.Supervisor.info
    assert redis_opts[:password] == "binary_password"

    Mix.Config.persist([exq: [password: nil]])
    {redis_opts, _} = Exq.Redis.Supervisor.info
    assert redis_opts[:password] == nil

  end

  test "smembers empty" do
    m = Redis.smembers!(:testredis, "bogus")
    assert m == []
  end

  test "sadd" do
    r = Redis.sadd!(:testredis, "theset", "amember")
    assert r == 1
    assert Redis.smembers!(:testredis, "theset") == ["amember"]
  end

  test "lpop empty" do
    assert Redis.lpop(:testredis, "bogus")  == {:ok, nil}
  end

  test "rpush / lpop" do
    Redis.rpush!(:testredis, "akey", "avalue")
    assert Redis.lpop(:testredis, "akey")  == {:ok, "avalue"}
    assert Redis.lpop(:testredis, "akey")  == {:ok, nil}
  end

  test "zadd / zcard / zrem" do
    assert Redis.zcard!(:testredis, "akey") == 0
    assert Redis.zadd!(:testredis, "akey", "1.7", "avalue") == 1
    assert Redis.zcard!(:testredis, "akey") == 1
    assert Redis.zrem!(:testredis, "akey", "avalue") == 1
    assert Redis.zcard!(:testredis, "akey") == 0
  end

  test "zrangebyscore" do
    assert Redis.zcard!(:testredis, "akey") == 0
    assert Redis.zadd!(:testredis, "akey", "123456.123455", "avalue") == 1
    assert Redis.zadd!(:testredis, "akey", "123456.123456", "bvalue") == 1
    assert Redis.zadd!(:testredis, "akey", "123456.123457", "cvalue") == 1

    assert Redis.zrangebyscore!(:testredis, "akey", 0, "111111.111111") == []
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "123456.123455") == ["avalue"]
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "123456.123456") == ["avalue", "bvalue"]
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "123456.123457") == ["avalue", "bvalue", "cvalue"]
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "999999.999999") == ["avalue", "bvalue", "cvalue"]

    assert Redis.zrem!(:testredis, "akey", "bvalue") == 1
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "123456.123457") == ["avalue", "cvalue"]
    assert Redis.zrem!(:testredis, "akey", "avalue") == 1
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "123456.123456") == []
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "123456.123457") == ["cvalue"]
    assert Redis.zrem!(:testredis, "akey", "avalue") == 0
    assert Redis.zrem!(:testredis, "akey", "cvalue") == 1
    assert Redis.zrangebyscore!(:testredis, "akey", 0, "999999.999999") == []
  end

  test "flushdb" do
    Redis.sadd!(:testredis, "theset", "amember")
    Redis.flushdb! :testredis
    assert Redis.smembers!(:testredis, "theset") == []
  end
end
