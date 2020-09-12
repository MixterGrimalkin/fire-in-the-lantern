class GradientLayer < Layer
  include Colors

  def initialize(
      name: 'gradient',
      size:,
      gradient_size: size,
      from: Color.new, to: Color.new,
      sym: false,
      assets: Assets.new
  )
    super(name: name, size: size, assets: assets)
    @from = from
    @to = to
    @sym = sym
    @gradient_size = gradient_size
    refresh
  end

  attr_reader :from, :to, :sym, :gradient_size

  def refresh
    draw Tools.gradient from, to, size: gradient_size, sym: sym
  end
end