module ItemsHelper
  def ratios(item)
    [item.ratio_1, item.ratio_2, item.ratio_3, item.ratio_4, item.ratio_5].map { |ratio|
      number_to_percentage ratio, precision: 2
    }.join ", "
  end
end
