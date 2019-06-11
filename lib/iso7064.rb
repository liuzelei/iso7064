class ISO7064
  NUMERIC_CHAR_SET = "0123456789"
  MOD_112_CHAR_SET = "0123456789X"
  HEX_CHAR_SET = "0123456789ABCDEF"
  ALPHA_CHAR_SET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  ALPHANUMERIC_CHAR_SET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  MOD_372_CHAR_SET = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ*"

  def calculate_check_digit(value, char_set, double_digit)
    radix, modulus = get_check_digit_radix_and_modulus(char_set, double_digit)

    if modulus != radix + 1
      return calculate_pure_system_check_digit(value, radix, modulus, char_set, double_digit)
    else
      return calculate_hybrid_system_check_digit(value, char_set)
    end
  end

  # Algorithm from: https://github.com/danieltwagner/iso7064.
  def calculate_pure_system_check_digit(value,  radix,  modulus, char_set, double_digit)
    return nil if value.nil? || value.empty?

    value = value.upcase
    p = 0

    value.each_char do |c|
      i = char_set.index(c)
      return nil if i == -1
      p = ((p + i) * radix) % modulus
    end

    p = (p * radix) % modulus if double_digit

    check_digit = (modulus - p + 1) % modulus

    if double_digit
      second = check_digit % radix
      first = (check_digit - second) / radix
      return value + char_set[first] + char_set[second]
    else
      return value + char_set[check_digit]
    end
  end

  # Algorithm from: http://www.codeproject.com/Articles/16540/Error-Detection-Based-on-Check-Digit-Schemes
  def calculate_hybrid_system_check_digit(value, char_set)
    return nil if value.nil? || value.empty?

    value = value.upcase
    radix = char_set.length
    pos = radix

    value.each_char do |c|
      i = char_set.index(c)
      return nil if i == -1
      pos += i
      pos -= radix if pos > radix
      pos *= 2
      pos -= radix + 1 if pos >= radix + 1
    end

    pos = radix + 1 - pos
    pos = 0 if (pos == radix)
    return value + char_set[pos]
  end

  # Verifies that the last character(s) of the supplied value are valid check digit(s).
  def verify_check_digit(value, char_set, double_digit)
    radix, modulus = get_check_digit_radix_and_modulus(char_set, double_digit)
    return verify_check_digit_by_radix_and_modulus(value, radix, modulus, char_set, double_digit)
  end

  def verify_check_digit_by_radix_and_modulus(value, radix, modulus, char_set, double_digit)
    num_digits = (double_digit ? 2 : 1)

    return false if (value == null || value.length <= num_digits)

    value = value.upcase
    orig_value = value[0, value.length - num_digits]

    if (modulus != radix + 1)
      return (value == calculate_pure_system_check_digit(orig_value, radix, modulus, char_set, double_digit))
    else
      return (value == calculate_hybrid_system_check_digit(orig_value, char_set))
    end
  end

  # Calculates ISO 7064 MOD 11,10 in single digit mode and MOD 97,10 in double digit mode.
  def calculate_numeric_check_digit(value, double_digit)
    return calculate_check_digit(value, NUMERIC_CHAR_SET, double_digit)
  end

  # Verifies ISO 7064 MOD 11,10 in single digit mode and MOD 97,10 in double digit mode.
  def verify_numeric_check_digit(value, double_digit)
    return verify_check_digit(value, NUMERIC_CHAR_SET, double_digit)
  end

  # Calculates ISO 7064 MOD 17,16 in single digit mode and MOD 251,16 in double digit mode.
  def calculate_hex_check_digit(value, double_digit)
    return calculate_check_digit(value, HEX_CHAR_SET, double_digit)
  end

  # Verifies ISO 7064 MOD 11,10 in single digit mode and MOD 97,10 in double digit mode.
  def verify_hex_check_digit(value, double_digit)
    return verify_check_digit(value, HEX_CHAR_SET, double_digit)
  end

  # Calculates ISO 7064 MOD 27,26 in single digit mode and MOD 661,26 in double digit mode.
  def calculate_alph_check_digit(value, double_digit)
    return calculate_check_digit(value, ALPHA_CHAR_SET, double_digit)
  end

  # Verifies ISO 7064 MOD 27,26 in single digit mode and MOD 661,26 in double digit mode.
  def verify_alpha_check_digit(value, double_digit)
    return verify_check_digit(value, ALPHA_CHAR_SET, double_digit)
  end

  # Calculates ISO 7064 MOD 37,36 in single digit mode and MOD 1271,36 in double digit mode.
  def calculate_alphanumeric_check_digit(value, double_digit)
    return calculate_check_digit(value, ALPHANUMERIC_CHAR_SET, double_digit)
  end

  # Verifies ISO 7064 MOD 37,36 in single digit mode and MOD 1271,36 in double digit mode.
  def verify_alphanumeric_check_digit(value, double_digit)
    return verify_check_digit(value, ALPHANUMERIC_CHAR_SET, double_digit)
  end

  private
  # Returns the correct ISO 7064 radix and modulus for the given character set and digit count.
  def get_check_digit_radix_and_modulus(char_set, double_digit)
    radix = char_set.length
    modulus = radix + 1

    if (double_digit)
      # The modulus numbers below for double digit calculations are defined by ISO 7064.
      case (radix)
      when 10 then modulus = 97
        #Mod 251,16 isn't defined in ISO 7064, but it could be useful so I added it anyway.
      when 16 then modulus = 251
      when 26 then modulus = 661
      when 36 then modulus = 1271
      end
    elsif (radix == 11)
      # MOD 11,2 - Single digit 0-9 check with an added 'X' check digit.
      modulus = 11
      radix = 2
    elsif (radix == 37)
      # MOD 37,2 - Single digit 0-9,A-Z check with an added '*' check digit.
      modulus = 37
      radix = 2
    end
    raise 'Invalid character set' if (radix != 2 && radix != 10 && radix != 16 && radix != 26 && radix != 36)
    return radix, modulus
  end
end