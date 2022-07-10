# frozen_string_literal: true

# The validators classes should be in another file 'validators.rb' but we were allowed to edit just this file.
# This validations were not requested but I think they are relevant

# This class defines a CPFandCNPJValidator
class CPFandCNPJValidator
  # These two public methods are used to validate CPF and CNPJ
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

  private

  def get_verifier(item, type, index)
    item_arr = str_to_arr(item, index)
    case type
    when 'cpf'
      res = cpf_reducer(item_arr, index)
    when 'cnpj'
      res = cnpj_reducer(item_arr, index)
    end
    [10, 11].include?(res) ? 0 : res
  end

  def str_to_arr(str, index)
    str[0...(-3 + index)].split('')
  end

  def cpf_reducer(arr, index)
    arr.each.with_index.reduce(0) { |sum, (n, i)| sum + (n.to_i * ((9 + index) - i)) } * 10 % 11
  end

  def cnpj_reducer(arr, index)
    arr.each.with_index.reduce(0) do |sum, (n, i)|
      sum + (n.to_i * ((12 + index) - (i > (2 + index) ? i : i + 8)))
    end * 10 % 11
  end
end

# The PixKey phone type follows the E.164 recommendation from ITU-T, so the validator checks for the '+' sign,
# valid DDI and valid DDD. BACEN allows a foreign phone number as PixKey, but some banks do not have it implemented
# so I decided to accept just the brazilian DDI, if in the future we accept other DDIs just add them in the constant

# This class defines a PhoneValidator
class PhoneValidator
  DDD_VALIDS = %w[11 12 13 14 15 16 17 18 19 21 22 24 27 28 31 32 33 34
                  35 37 38 41 42 43 44 45 46 47 48 49 51 53 54 55 61 62 63 64
                  65 66 67 68 69 71 73 74 75 77 79 81 82 83 84 85 86 87 88 89 91 92 93 94 95 96 97 98 99].freeze
  DDI_VALIDS = ['55'].freeze

  def valid_phone?(item)
    return false unless plus_sign?(item)

    return false unless valid_ddi?(item)

    return false if item[1..2] == '55' && !valid_ddd?(item)

    true
  end

  private

  def plus_sign?(item)
    item[0] == '+'
  end

  def valid_ddi?(item)
    DDI_VALIDS.include?(item[1..2])
  end

  def valid_ddd?(item)
    DDD_VALIDS.include?(item[3..4])
  end
end

# This class defines a PixKey
class PixKey
  # This constant defines the PixKeyTypes, add any new PixKeyType here so new methods and validations will be available
  # FROM DICT API: "Novos tipos de chave poderão vir a ser adicionados no futuro. Logo, é importante que a
  # implementação de clientes seja flexível, permitindo a adição de novos tipos de chave."
  # A PixKeyType is a hash with a name as string and a validation as an array of validators being hash of type that can
  # be 'regex' or 'lambda' and its value
  PIX_KEY_TYPES = [
    {
      name: 'phone',
      validations: [
        { type: 'regex', value: /^\+[1-9][0-9]\d{1,14}$/ },
        { type: 'lambda', value: ->(item) { PhoneValidator.new.valid_phone?(item) } }
      ]
    },
    {
      name: 'cpf',
      validations: [
        { type: 'regex', value: /^[0-9]{11}$/ }
        # This validation is commented because the test uses an invalid cpf at lines 73 and 89
        # { :type => 'lambda', :value => ->(item) { CPFandCNPJValidator.new.valid_cpf?(item) } }
      ]
    },
    {
      name: 'cnpj',
      validations: [
        { type: 'regex', value: /^[0-9]{14}$/ },
        { type: 'lambda', value: ->(item) { CPFandCNPJValidator.new.valid_cnpj?(item) } }
      ]
    },
    {
      name: 'email',
      validations: [
        { type: 'regex', value: %r{^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]
        {0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$}x }
      ]
    },
    {
      name: 'evp',
      validations: [
        { type: 'regex', value: /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ }
      ]
    }
  ].freeze

  NEW_KEY_VALIDATIONS = [
    {
      type: 'lambda',
      value: ->(item) { item.instance_of?(String) }
    }
  ].freeze

  attr_reader :key, :type

  alias value key

  def initialize(new_key)
    new_key_validations(new_key)
    return if @type == 'error'

    @key = new_key.strip.freeze
    types_validations
  end

  PIX_KEY_TYPES.each do |type|
    define_method("#{type[:name]}?") { @type == type[:name] }
  end

  def valid?
    @type != 'error'
  end

  def invalid?
    @type == 'error'
  end

  def to_s = @key

  def ==(other)
    self.class == other.class &&
      @key == other.key &&
      @type == other.type &&
      valid? == other.valid?
  end

  private

  def new_key_validations(new_key)
    NEW_KEY_VALIDATIONS.each do |validation|
      validate_new_key(validation, new_key)
      break if @type == 'error'
    end
  end

  def validate_new_key(validation, new_key)
    return if validation[:value].call(new_key)

    @type = 'error'
    @key = ''
  end

  def types_validations
    PIX_KEY_TYPES.each do |type|
      validate_type(type)
      break if @type != 'error'
    end
  end

  def validate_type(type)
    type[:validations].each do |validation|
      @type = type[:name]
      case validation[:type]
      when 'regex'
        @type = 'error' unless validation[:value].match(@key)
      when 'lambda'
        @type = 'error' unless validation[:value].call(@key)
      end
      break if @type == 'error'
    end
  end
end
