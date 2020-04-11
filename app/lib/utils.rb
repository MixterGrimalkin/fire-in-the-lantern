require 'io/console'

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
    end
  rescue Interrupt
    # ignored
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

  def pick_from(list)
    i = 1
    options = {}
    list.each do |item|
      puts "#{i}. #{item}"
      options[i] = item
      i += 1
    end
    response = STDIN.getch.strip
    options[response.to_i]
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

  def sum_array(array)
    return 0 if array.empty?

    array.inject(0.0) { |sum, value| sum + value }
  end

  def avg_array(array)
    return 0 if array.empty?

    sum_array(array) / array.size
  end
end