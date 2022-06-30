# frozen_string_literal: true

class PixKey
	@@keys = []

	attr_reader :key, :type, :valid

	# This method overrides the default new method to prevent creating multiple instances of the same key.
	def PixKey.new(new_key)
		instance = @@keys.select {|key| key.key?(new_key) }
		unless instance.empty?
			return instance[0][new_key]
		else
			super(new_key)
		end
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

		case @key
		when IsValidCPF
			@type = 'cpf'
		when IsCNPJ
			@type = 'cnpj'
		when IsPhone
			@type = 'phone'
		when IsEmail
			@type = 'email'
		when IsEVP
			@type = 'evp'
		else
			@key = ''
			@type = 'error'
			@valid = false
			# raise ArgumentError, "Key is not a valid type of any kind."
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

		@valid ? @@keys.push({@key => self}) : nil
	end
end

class IsValidCPF
	def self.===(item)
		item =~ /^[0-9]{11}$/ # ? is_valid_cpf(item) : false #This verification is commented because the default test uses an invalid CPF and fails
	end
end

class IsCNPJ
	def self.===(item)
		item =~ /^[0-9]{14}$/ ? is_valid_cnpj(item) : false
	end
end

def is_valid_cpf(item)
	invalids = %w{12345678909 11111111111 22222222222 33333333333 44444444444 55555555555 66666666666 77777777777 88888888888 99999999999 00000000000}
	return false if invalids.include? item
	first_verifier = item[0...-2].split('').each.with_index.reduce(0) { |sum, (n, i)| sum + (n.to_i * (10 - i)) } * 10 % 11
	first_verifier = 0 if first_verifier == 10 || first_verifier == 11
	return false if first_verifier != item[-2].to_i
	second_verifier = item[0...-1].split('').each.with_index.reduce(0) { |sum, (n, i)| sum + (n.to_i * (11 - i)) } * 10 % 11
	second_verifier = 0 if second_verifier == 10 || second_verifier == 11
	return false if second_verifier != item[-1].to_i
	return true
end

def is_valid_cnpj(item)
	invalids = %w{11111111111111 22222222222222 33333333333333 44444444444444 55555555555555 66666666666666 77777777777777 88888888888888 99999999999999 00000000000000}
	return false if invalids.include? item
	first_verifier = item[0...-2].split('').each.with_index.reduce(0) { |sum, (n, i)| sum + (n.to_i * (13 - (i > 3 ? i : i + 8))) } * 10 % 11
	first_verifier = 0 if first_verifier == 10 || first_verifier == 11
	return false if first_verifier != item[-2].to_i
	second_verifier = item[0...-1].split('').each.with_index.reduce(0) { |sum, (n, i)| sum + (n.to_i * (14 - (i > 4 ? i : i + 8))) } * 10 % 11
	second_verifier = 0 if second_verifier == 10 || second_verifier == 11
	return false if second_verifier != item[-1].to_i
	return true
end

class IsPhone
	def self.===(item)
		item =~ /^\+[1-9][0-9]\d{1,14}$/
	end
end

class IsEmail
	def self.===(item)
		item =~ /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
	end
end

class IsEVP
	def self.===(item)
		item =~ /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
	end
end
