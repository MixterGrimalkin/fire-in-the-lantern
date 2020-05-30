require 'io/console'
require 'enumerator'
require 'socket'

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
    puts "   #{msg}"
    puts
  end

  def wait_for_interrupt(msg = nil)
    message msg if msg
    while true
      sleep 0.25
    end
  rescue Interrupt
    # ignored
  end

  def local_ip_address
    until (addr = Socket.ip_address_list.detect { |intf| intf.ipv4_private? })
    end
    addr.ip_address
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

  def in_rows(array, row_size)
    result = []
    array.each_slice(row_size) do |slice|
      row = []
      slice.each do |option|
        row << "#{option}   "
      end
      result << row
    end
    result
  end

  ENTER = 13
  BACKSPACE = 127
  TAB = 9
  ESC = 27

  INVERT = "\e[7m"
  NORMAL = "\e[27m"

  def text_menu(options, label = 'option')
    puts
    puts "Start typing to select #{label}:"
    puts
    print_table in_rows(options.sort, 5)
    puts

    input = ''
    escape = false

    until escape
      char = STDIN.getch
      match = word_match(input, options)
      case char.ord
        when ENTER
          input = match[:suggestion].strip
          match[:remainder] = ''
          escape = true
        when BACKSPACE
          input = input[0..-2]
        when ESC
          escape = true
        else
          input << char
      end
      output = "\r#{input}#{INVERT}#{match[:remainder]}#{NORMAL}"
      print "\r#{' ' * output.length}   "
      print output
    end
    puts
    puts

    if options.include? input
      input
    else
      nil
    end
  end

  def word_match(string, options)
    match = options.sort.select { |option| option.start_with? string }.first
    {
        suggestion: match || '',
        remainder: match ? match[string.size+1..-1] : ''
    }
  end

  def read_json(filename)
    symbolize_keys JSON.parse File.read filename
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

  CONSOLE_FG_COLOURS = {
      default: '38',
      black: '30', dark_gray: '1;30', gray: '37', white: '1;37', brown: '33',
      red: '31', green: '32', blue: '34', yellow: '1;33', purple: '35', cyan: '36',
      light_red: '1;31', light_green: '1;32', light_blue: '1;34',
      light_purple: '1;35', light_cyan: '1;36'
  }.freeze

  BG_COLOURS = {default: '0', black: '40', red: '41', green: '42', brown: '43', blue: '44',
                purple: '45', cyan: '46', gray: '47', dark_gray: '100', light_red: '101', light_green: '102',
                yellow: '103', light_blue: '104', light_purple: '105', light_cyan: '106', white: '107'}.freeze

  FONT_OPTIONS = {bold: '1', dim: '2', italic: '3', underline: '4', reverse: '7', hidden: '8'}.freeze

  def colorize(text, colour = :default, bg_colour = :default, **options)
    colour_code = CONSOLE_FG_COLOURS[colour]
    bg_colour_code = BG_COLOURS[bg_colour]
    font_options = options.select { |k, v| v && FONT_OPTIONS.key?(k) }.keys
    font_options = font_options.map { |e| FONT_OPTIONS[e] }.join(';').squeeze
    "\e[#{bg_colour_code};#{font_options};#{colour_code}m#{text}\e[0m".squeeze(';')
  end
end