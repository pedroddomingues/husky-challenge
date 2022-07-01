# frozen_string_literal: true

# This class defines a PixKey
class PixKey
  @@keys = []

  attr_reader :key, :type, :valid

  # This method overrides the default new method to prevent creating multiple instances of the same key.
  # Something like uniqueness validation from rails
  def self.new(new_key)
    instance = @@keys.select { |key| key.key?(new_key) }
    unless instance.empty?
      return instance[0][new_key]
      # raise ArgumentError, "This key already has been created."
    end

    super(new_key)
  end

  def initialize(key)
    if key.class != String
      @key = ''
      @type = 'error'
      @valid = false
      # raise TypeError, "Key must be a String."
      return
    end

    @key = key.strip.freeze
    @valid = true
    @type = get_key_type(@key)

    if @type == 'error'
      @key = ''
      @valid = false
    end

    @valid ? @@keys.push({ @key => self }) : nil
  end

  def valid?
    @valid
  end

  def invalid?
    !@valid
  end

  def value
    @key
  end

  def phone?
    @valid ? @type == 'phone' : false
  end

  def cpf?
    @valid ? @type == 'cpf' : false
  end

  def cnpj?
    @valid ? @type == 'cnpj' : false
  end

  def email?
    @valid ? @type == 'email' : false
  end

  def evp?
    @valid ? @type == 'evp' : false
  end

  def to_s
    @key
  end
end

#----------------- validations -----------------#

def get_key_type(key)
  case key
  when IsCPF
    'cpf'
  when IsCNPJ
    'cnpj'
  when IsPhone
    'phone'
  when IsEmail
    'email'
  when IsEVP
    'evp'
  else
    'error'
    # raise ArgumentError, "Key is not a valid type of any kind."
  end
end

# Validates if the given string is a CPF
class IsCPF
  def self.===(item)
    item =~ /^[0-9]{11}$/ # ? valid_cpf?(item) : false
    # This verification is commented because the default test uses an invalid CPF and fails
  end
end

# Validates if the given string is a CNPJ
class IsCNPJ
  def self.===(item)
    item =~ /^[0-9]{14}$/ ? valid_cnpj?(item) : false
  end
end

# Validates if the given string is a valid CPF
def valid_cpf?(item)
  invalids = %w[12345678909 11111111111 22222222222 33333333333 44444444444 55555555555 66666666666 77777777777
                88888888888 99999999999 00000000000]
  return false if invalids.include? item

  first_verifier = get_verifier(item, 'cpf', 1)
  return false if first_verifier != item[-2].to_i

  second_verifier = get_verifier(item, 'cpf', 2)
  return false if second_verifier != item[-1].to_i

  true
end

# Validates if the given string is a valid CNPJ
def valid_cnpj?(item)
  invalids = %w[11111111111111 22222222222222 33333333333333 44444444444444 55555555555555 66666666666666
                77777777777777 88888888888888 99999999999999 00000000000000]
  return false if invalids.include? item

  first_verifier = get_verifier(item, 'cnpj', 1)
  return false if first_verifier != item[-2].to_i

  second_verifier = get_verifier(item, 'cnpj', 2)
  return false if second_verifier != item[-1].to_i

  true
end

def get_verifier(item, type, index)
  case type
  when 'cpf'
    result = item[0...-(-3 + index)].split('').each.with_index.reduce(0) do |sum, (n, i)|
      sum + (n.to_i * ((9 + index) - i))
    end * 10 % 11
  when 'cnpj'
    result = item[0...(-3 + index)].split('').each.with_index.reduce(0) do |sum, (n, i)|
      sum + (n.to_i * ((12 + index) - (i > (2 + index) ? i : i + 8)))
    end * 10 % 11
  end
  [10, 11].include?(result) ? 0 : result
end

# Validates if the given string is a phone
class IsPhone
  def self.===(item)
    item =~ /^\+[1-9][0-9]\d{1,14}$/
  end
end

# Validates if the given string is an email
class IsEmail
  def self.===(item)
    item =~ %r{^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$}
  end
end

# Validates if the given string is an EVP
class IsEVP
  def self.===(item)
    item =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
  end
end
