defmodule Twatch.Actions.Category.Filters do
  alias Hound.Helpers.Element

  def channel_name(regex) do
    fn elem ->
      Element.visible_text(elem) =~ regex
    end
  end
end
