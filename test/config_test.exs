Code.require_file "test_helper.exs", __DIR__
defmodule Exq.ConfigTest do
  use ExUnit.Case
  alias Exq.Support.Config

  setup_all do
    ExqTestUtil.reset_config
    :ok
  end

  test "Config should override defaults" do
    config = Config.build(%{
      host: "127.1.1.1",
      concurrency: 10
    })

    assert %{redis: %{host: "127.1.1.1", port: 6379}, concurrency: 10} = config
  end

end
