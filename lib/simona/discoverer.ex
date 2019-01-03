defmodule Simona.Discoverer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_) do
    init_peers_table()

    default_peers()
    |> Enum.map(fn d ->
      query_res(d)
      |> Enum.each(&insert_peer/1)
    end)
    {:ok, nil}
  end
  def get_rand_peer do
    [{ip, nil}|_] = list_peers()
    ip
  end

  def init_peers_table do
    :ets.new(:peers_table, [:named_table, :set])
  end

  def insert_peer(peer) do
    :ets.insert(:peers_table, {peer, nil})
  end

  def list_peers do
    :ets.tab2list(:peers_table)
  end

  def default_peers do
    [
      'seed.bitcoinsv.io'
    ]
  end

  def query_res(domain) do
    :inet_res.lookup(domain, :in, :a)
  end

  def test do
    init(nil)

    list_peers()
  end


end
