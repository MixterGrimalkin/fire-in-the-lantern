class GradientLayer < Layer
  include Colors

  def initialize(
      name: 'gradient_',
      size:,
      offset: 0,
      gradient_size: size,
      from: RED, to: BLUE,
      sym: false,
      assets: Assets.new
  )
    super(name: name, size: size, assets: assets)
    @offset = offset
    @from = from
    @to = to
    @sym = sym
    @gradient_size = gradient_size
    refresh
  end

  attr_reader :from, :to, :sym, :gradient_size, :offset

  def refresh
    draw Tools.block(BLACK, offset) + Tools.gradient(from, to, size: gradient_size, sym: sym)
  end
end