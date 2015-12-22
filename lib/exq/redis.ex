defmodule Exq.Redis do
  def flushdb!(pool_name) do
    {:ok, res} = q(pool_name, [:flushdb])
    res
  end

  def decr!(pool_name, key) do
    {:ok, count} = q(pool_name, ["DECR", key])
    count
  end

  def incr!(pool_name, key) do
    {:ok, count} = q(pool_name, ["INCR", key])
    count
  end

  def get!(pool_name, key) do
    {:ok, val} = q(pool_name, ["GET", key])
    val
  end

  def set!(pool_name, key, val \\ 0) do
    q(pool_name, ["SET", key, val])
  end

  def del!(pool_name, key) do
    q(pool_name, ["DEL", key])
  end

  def expire!(pool_name, key, time \\ 10) do
    q(pool_name, ["EXPIRE", key, time])
  end

  def llen!(pool_name, list) do
    {:ok, len} = q(pool_name, ["LLEN", list])
    len
  end

  def keys!(pool_name, search \\ "*") do
    {:ok, keys} = q(pool_name, ["KEYS", search])
    keys
  end

  def scan!(pool_name, cursor, search, count) do
    {:ok, keys} = q(pool_name, ["SCAN", cursor, "MATCH", search, "COUNT", count])
    keys
  end

  def scard!(pool_name, set) do
    {:ok, count} = q(pool_name, ["SCARD", set])
    count
  end

  def smembers!(pool_name, set) do
    {:ok, members} = q(pool_name, ["SMEMBERS", set])
    members
  end

  def sadd!(pool_name, set, member) do
    {:ok, res} = q(pool_name, ["SADD", set, member])
    res
  end

  def srem!(pool_name, set, member) do
    {:ok, res} = q(pool_name, ["SREM", set, member])
    res
  end

  def lrange!(pool_name, list, range_start \\ "0", range_end \\ "-1") do
    {:ok, items} = q(pool_name, ["LRANGE", list, range_start, range_end])
    items
  end

  def lrem!(pool_name, list, value, count \\ 1) do
    {:ok, res} = q(pool_name, ["LREM", list, count, value])
    res
  end

  def rpush!(pool_name, key, value) do
    {:ok, res} = q(pool_name, ["RPUSH", key, value])
    res
  end

  def lpop(pool_name, key) do
    q(pool_name, ["LPOP", key])
  end

  def zadd(pool_name, set, score, member) do
    q(pool_name, ["ZADD", set, score, member])
  end

  def zadd!(pool_name, set, score, member) do
    {:ok, res} = q(pool_name, ["ZADD", set, score, member])
    res
  end

  def zcard!(pool_name, set) do
    {:ok, count} = q(pool_name, ["ZCARD", set])
    count
  end

  def zrangebyscore!(pool_name, set, min \\ "0", max \\ "+inf") do
    {:ok, items} = q(pool_name, ["ZRANGEBYSCORE", set, min, max])
    items
  end

  def zrange!(pool_name, set, range_start \\ "0", range_end \\ "-1") do
    {:ok, items} = q(pool_name, ["ZRANGE", set, range_start, range_end])
    items
  end

  def zrem!(pool_name, set, member) do
    {:ok, res} = q(pool_name, ["ZREM", set, member])
    res
  end

  def q(pool_name, command) do
    Exq.Redis.Pool.q(pool_name, command, Config.get(:pool_name_timeout, @default_timeout))
  end

  def qp(pool_name, command) do
    Exq.Redis.Pool.qp(pool_name, command, Config.get(:pool_name_timeout, @default_timeout))
  end
end
