require 'io/console'
require 'enumerator'

module Utils

  LOGO = %q{
    ___
   (_  '_ _   '  _// _   /  _  _/_ _
   /  // (-  //) //)(-  (__(//)/(-/ /)

       p  i  x  e  l  a  t  o  r

}

  def logo
    puts LOGO
  end

  def message(msg)
    puts
    puts "  #{msg}"
    puts
  end

  def wait_for_interrupt
    while true
      sleep 0.25
    end
  rescue Interrupt
    # ignored
  end

  def print_table(data)
    max_widths = []
    data.each do |row|
      row.each_with_index do |value, i|
        max_widths[i] = [max_widths[i]||0, value.to_s.size].max
      end
    end
    table = data.collect do |row|
      row.enum_for(:each_with_index).collect do |value, i|
        value.to_s.ljust(max_widths[i], ' ')
      end.join '  '
    end.join "\n"
    puts table
  end

  def pick_from(list)
    pages = (list.size / 9.0).ceil
    page = 0
    options = {}
    list.each_slice(9) do |items|
      page += 1
      options[page] = {}
      i = 1
      items.each do |item|
        puts "#{i}. #{item}"
        options[page][i] = item
        i += 1
      end
      if page < pages
        puts '0. more...'
      end
      puts

      response = STDIN.getch.strip
      next if response == '0' && page < pages

      return options[page][response.to_i]
    end
  end

  def symbolize_keys(hash)
    result = {}
    hash.each do |key, value|
      result[key.to_sym] =
          case value
            when Hash
              symbolize_keys value
            when Array
              symbolize_array value
            else
              value
          end
    end
    result
  end

  def symbolize_array(array)
    array.collect do |value|
      case value
        when Hash
          symbolize_keys value
        when Array
          symbolize_array value
        else
          value
      end
    end
  end

  def sum_array(array, zero: 0.0)
    return zero if array.empty?

    array.inject(zero) { |sum, value| sum + value }
  end

  def avg_array(array, zero: 0.0)
    return zero if array.empty?

    sum_array(array, zero: zero) / array.size
  end
end