defmodule Exq.Support.Config do
  def get(key, fallback \\ nil) do
    Application.get_env(:exq, key, fallback)
  end

  def get() do
    Application.get_all_env(:exq)
  end
end
