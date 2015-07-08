defmodule HexWf do

  def main(args) do
    args |> parse_args |> process
  end


  def process([search: name]) do
    "https://hex.pm/api/packages?search=#{name}"
    |> get_res_map
    |> Enum.map(&Task.async(fn -> fetch_repo(&1["url"]) end))
    |> Enum.map(&Task.await(&1, 50000))
    |> List.foldl("", fn(x, acc) -> x <> acc end)
    |> output
  end
  def process([name: name]), do: "https://hex.pm/api/packages/#{name}" |> fetch_repo |> output


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

  def fetch_repo(repo_url) do
    r = get_res_map(repo_url)
    version = List.first(r["releases"])["version"]
    """
    <item valid="yes"><title>#{r["name"]} - #{version}</title><subtitle>#{r["meta"]["description"]}</subtitle><arg>#{r["name"]}</arg></item>
    """
  end

  def get_res_map(url) do
    {:ok, res} = HTTPoison.get(url, [], hackney: [:insecure], timeout: 50000)
    {:ok, json} = Poison.decode res.body
    json
  end
end
