defmodule Identicons do
  alias Identicons.Image

  def create(input, rgb \\ nil) do
    input
    |> hash
    |> get_colors(rgb)
    |> create_grid
    |> get_even_cells
    |> create_image_map
    |> generate_image
    |> save_image(input)
  end

  def hash(input) do
    hash = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Image{grid: hash}
  end

  def get_colors(%Image{grid: [r,g,b | _tail]} = image, nil) do
    %Image{image | rgb: {r,g,b}}
  end

  def get_colors(%Image{grid: _grid} = image, rgb) do
    %Image{image | rgb: rgb}
  end

  def create_grid(%Image{grid: grid} = image) do
    grid = grid
    |> Enum.chunk(3)
    |> Enum.map(&mirror_row/1)
    |> List.flatten
    |> Enum.with_index

    %Image{image | grid: grid}
  end

  defp mirror_row([a,b|_] = row) do
    row ++ [b,a]
  end

  def get_even_cells(%Image{grid: grid} = image) do
    grid = Enum.filter(grid, fn({val, _idx}) ->
      rem(val, 2) == 0
    end)

    %Image{image | grid: grid}
  end

  def create_image_map(%Image{grid: grid} = image) do
    image_map = grid
    |> Enum.map(fn({_val, idx}) ->
      x1 = rem(idx, 5) * 50
      y1 = div(idx, 5) * 50
      x2 = x1 + 50
      y2 = y1 + 50

      {{x1,y1}, {x2,y2}}
    end)

    %Image{image | image_map: image_map}
  end

  def generate_image(%Image{rgb: rgb, image_map: image_map}) do
    image = :egd.create(250, 250)
    color = :egd.color(rgb)

    Enum.each(image_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, color)
    end)

    :egd.render(image)
  end

  def save_image(image, name) do
    File.write("#{name}.png", image)
  end
end
