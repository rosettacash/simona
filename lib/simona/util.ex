defmodule Simona.Util do


  def nonce64 do
    :rand.uniform(0xFF_FF_FF_FF_FF_FF_FF_FF) - 1
  end

  def timestamp do
    DateTime.utc_now() |> DateTime.to_unix()
  end
end
