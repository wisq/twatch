defmodule Twatch.Actions.Image do
  require Logger
  alias Hound.Helpers.{Element, Page, Screenshot}
  import Twatch.Helpers

  @old_file "old.png"
  @new_file "new.png"

  def ensure_image_changing(tmp_path) do
    new_file = Path.join(tmp_path, @new_file)
    old_file = Path.join(tmp_path, @old_file)

    if File.exists?(new_file) do
      File.rename(new_file, old_file)
      take_screenshot(new_file)

      if image_difference(old_file, new_file, frame_geometry()) < 100 do
        Logger.warn("Stream image has not changed since last screenshot.")
        navigate_to("data:,")
        :halt
      else
        :cont
      end
    else
      Logger.info("No previous screenshots to compare to.")
      take_screenshot(new_file)
      :cont
    end
  end

  defp take_screenshot(file) do
    Screenshot.take_screenshot(file)
    size = File.stat!(file).size
    Logger.debug("Screenshot taken: #{file} (#{size} bytes)")
    file
  end

  defp frame_geometry do
    frame = Page.find_element(:class, "video-player__container")
    {size_x, size_y} = Element.element_size(frame)
    {off_x, off_y} = Element.element_location(frame)

    "#{round(size_x)}x#{round(size_y)}+#{round(off_x)}+#{round(off_y)}"
  end

  defp image_difference(file1, file2, geom) do
    Logger.debug("Comparing #{geom} in #{file1} to #{file2} ...")
    args = ["-extract", geom, "-metric", "AE", file1, file2, "null:"]

    diff =
      case System.cmd("compare", args, stderr_to_stdout: true) do
        {"0", 0} -> 0
        {out, 1} -> String.trim(out) |> String.to_integer()
      end

    Logger.debug("Pixel difference: #{inspect(diff)}")
    diff
  end
end
