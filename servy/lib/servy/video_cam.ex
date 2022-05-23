defmodule Servy.VideoCam do
  def get_snapshot(cam_name) do
    :timer.sleep(1000)
    "#{cam_name}-snapshot-#{:rand.uniform(1000)}.jpg"
  end
end
