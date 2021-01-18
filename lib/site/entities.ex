defmodule Site.Entities do
  # Taken from https://github.com/martinsvalin/html_entities/blob/master/lib/html_entities.ex.

  @doc "Encode HTML entities in a string."
  @spec encode(String.t()) :: String.t()
  def encode(string) when is_binary(string) do
    for <<x <- string>>, into: "" do
      case x do
        ?' -> "&apos;"
        ?" -> "&quot;"
        ?& -> "&amp;"
        ?< -> "&lt;"
        ?> -> "&gt;"
        _ -> <<x>>
      end
    end
  end
end
