defmodule Simona.Peer do
  @moduledoc """
  look at https://github.com/rosettacash/bitcoin-elixir/blob/develop/lib/bitcoin/node/network/peer.ex
  """
  alias Simona.Discoverer
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    ip = Discoverer.get_rand_peer()

    %{ip: ip}
  end

end
