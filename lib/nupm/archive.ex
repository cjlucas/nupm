defmodule NuPM.Archive do
  @moduledoc """
  This module provides utility functions for extracting and searching tar
  and zip archives.
  """

  def extract(archive_path) do
    tmp = Path.join(System.tmp_dir!, "primer_tmp")
    File.rm_rf!(tmp)
    File.mkdir!(tmp)

    case System.cmd("tar", ["xf", archive_path, "-C", tmp]) do
      {_, 0} ->
        {:ok, tmp}
      _ ->
        File.rm_rf!(tmp)
        :error
    end
  end

  @doc """
  Find a file matching the given pattern somewhere in the given package_path.
  """
  def find_file(package_path, pattern) do
    case Path.join([package_path, "**", pattern]) |> Path.wildcard do
      [] ->
        :error
      files ->
        {:ok, List.first(files)}
    end
  end
end
