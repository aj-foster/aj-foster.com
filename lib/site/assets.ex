defmodule Site.Assets do
  @moduledoc false
  use GenServer

  def start_link(opts) do
    case Mix.env() do
      :dev ->
        GenServer.start_link(__MODULE__, opts, name: __MODULE__)

      _ ->
        :ignore
    end
  end

  def init(_opts) do
    root = File.cwd!() |> Path.absname()
    assets_dir = Path.join(root, "assets")

    # Tableau's websocket reloader subscribes to this named watcher.
    watcher =
      case FileSystem.start_link(
             backend: :fs_poll,
             dirs: [root],
             name: :web_dev_utils_file_watcher
           ) do
        {:ok, pid} -> pid
        {:error, {:already_started, pid}} -> pid
        :ignore -> nil
      end

    unless is_nil(watcher) do
      FileSystem.subscribe(watcher)
      {:ok, %{watcher: watcher, assets_dir: assets_dir}}
    else
      {:error, :no_watch}
    end
  end

  def handle_info({:file_event, _, {path, _events}}, state) do
    if css_asset?(path, state.assets_dir) do
      IO.puts("[Assets] Updating #{path}")
      copy_file(path, state.assets_dir)
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _, _info}, state), do: {:noreply, state}

  def copy do
    File.mkdir_p!("site")
    File.cp_r!("assets", "site/assets")
  end

  defp css_asset?(path, assets_dir) do
    Path.extname(path) == ".css" and
      String.starts_with?(Path.expand(path), assets_dir <> "/")
  end

  defp copy_file(path, assets_dir) do
    relative_path = Path.relative_to(path, assets_dir)
    destination = Path.join("site/assets", relative_path)

    if File.regular?(path) do
      destination |> Path.dirname() |> File.mkdir_p!()
      File.cp!(path, destination)
    else
      File.rm(destination)
    end
  end
end
