defmodule API.Graphql.Data do
  def data() do
    Dataloader.Ecto.new(API.Repo, query: &query/2)
  end

  def loader() do
    Dataloader.new()
    |> Dataloader.add_source(:db, data())
  end

  def query(queryable, _params) do
    queryable
  end
end
