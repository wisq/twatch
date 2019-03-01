defmodule Twatch.PageHandler do
  require Logger
  alias __MODULE__

  @enforce_keys [:match, :actions]
  defstruct(
    match: nil,
    actions: []
  )

  def find(handlers, url) do
    Enum.find(handlers, &is_match(&1.match, url))
  end

  def execute(%PageHandler{actions: actions}) do
    Enum.reduce_while(actions, :cont, fn action, _acc ->
      Logger.debug("Executing: #{inspect(action)}")

      case action.() do
        :cont ->
          {:cont, :cont}

        :halt ->
          Logger.debug("Halting actions.")
          {:halt, :halt}
      end
    end)
  end

  defp is_match(string, url) when is_binary(string) do
    url == string || URI.decode(url) == string
  end

  defp is_match(%Regex{} = regex, url) do
    url =~ regex || URI.decode(url) == regex
  end
end
