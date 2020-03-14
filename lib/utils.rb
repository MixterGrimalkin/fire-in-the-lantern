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
end