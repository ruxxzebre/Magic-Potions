defmodule CH125.ECC do
  # * DOMAIN PARAMS {p, a, b, G, n, h}
  # * p - mod for field restriction/cycling
  # * y**2 = x**3+ax+b
  # * CURVE - y**2 = x**3+2x+2 (mod 17)
  defmodule Point do
    defstruct x: 0.0, y: 0.0
  end

  defmodule Params do
    defstruct g: %Point{x: 5, y: 1},
    p: 17,
    a: 2,
    b: 2
  end

  def calc_params(%Params{} = params \\ %Params{}) do
    # %Params{G: %Point{x: 5, y: 1}}
  end

  # Eucledian extended algorithm
  def egcd(a, m) do
    case a do
      0 -> {m, 0, 1}
      _ ->
        {g, y, x} = egcd(rem(m, a), a)
        {g, x - Float.floor(m/a) * y, y}
    end
        # {_g, x, _y} = egcd(a, mod)
    # # ! g must be 1
    # rem(x, mod)
  end

  # Modular multiplicative inverse
  # https://9to5answer.com/modular-multiplicative-inverse-function-in-python
  @spec modinv(number, integer) :: integer
  def modinv(a, mod) do
    rem(a**(mod-2), mod)
  end

  def calculate_slope(%Params{g: g, a: a, p: p}) do
    %{x: x, y: y} = g
    rem(rem(3*(x**2)+a, p)*modinv(2*y, p), p)
  end

  # p1 - P, p2 - Q
  def add_two_points(%Point{} = p1, %Point{} = p2) do
    slope = (p1.y - p2.y)/(p1.x - p2.x)
    xr = slope**2-p1.x+p2.x
    yr = slope*(p1.x-xr)-p2.y
    %Point{
      x: xr,
      y: yr
    }
  end

  def double_point(p, a) do
    slope = (3*(p.x**2) + a)/(2*p.y)
    xr = slope**2-2*p.x
    yr = slope*(p.x-xr)-p.y
    %Point{
      x: xr,
      y: yr
    }
  end

  def k_point(p, k) do
    cond do
      k == 1 ->
        p
      rem(k, 2) == 0 ->
        k_point(double_point(p, 2), k - 1)
      true ->
        add_two_points(p, k_point(p, k - 1))
    end
  end

  def x_2g(params, slope) do
    rem(slope**2 - 2*params.g.x, params.p)
  end

  def y_2g(params, slope) do
    rem(slope*(params.g.x - x_2g(params, slope)) - params.g.y, 17)
  end

  def generate_cyclic_group do

  end
end
