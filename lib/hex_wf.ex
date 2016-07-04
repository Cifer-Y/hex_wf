defmodule HexWf do

  def main(args) do
    args |> parse_args |> process
  end


  def process([search: name]) do
    "https://hex.pm/api/packages?search=#{name}"
    |> get_res_map
    |> Enum.map(&Task.async(fn -> fetch_repo(&1["name"]) end))
    |> Enum.map(&Task.await(&1, 50000))
    |> List.foldl("", fn(x, acc) -> x <> acc end)
    |> output
  end
  def process([name: name]), do: name |> fetch_repo |> output


  def output(elem) do
    result = """
    <?xml version="1.0" encoding="utf-8"?>
    <items>
    #{elem}
    </items>
    """
    IO.write(result)
  end

  def parse_args(args) do
    {option, _, _} = OptionParser.parse(args, switches: [search: :string, name: :string])
    option
  end

  def fetch_repo(repo_name) do
    repo_url = "https://hex.pm/api/packages/#{repo_name}"
    r = get_res_map(repo_url)
    version = List.first(r["releases"])["version"]
    """
    <item valid="yes"><title>#{r["name"]} - #{version}</title><subtitle>#{r["meta"]["description"]}</subtitle><arg>#{r["name"]}</arg></item>
    """
  end

  def get_res_map(url) do
    {:ok, res} = url |> Maxwell.url |> Maxwell.opts(hackney: [:insecure], timeout: 50000) |> Maxwell.get
    {:ok, json} = Poison.decode res.body
    json
  end
end
