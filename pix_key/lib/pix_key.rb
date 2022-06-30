# frozen_string_literal: true

class IsCPF
	def self.===(item)
		item =~ /^[0-9]{11}$/
	end
 end

class IsCNPJ
	def self.===(item)
		item =~ /^[0-9]{14}$/
	end
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
 
 class PixKey
	@@keys = []
	
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
			@type = 'error'
			@valid = false
			return
		end

		@key = key.strip.freeze

		case @key
		when IsCPF
			@type = 'cpf'
			@valid = true
		when IsCNPJ
			@type = 'cnpj'
			@valid = true
		when IsPhone
			@type = 'phone'
			@valid = true
		when IsEmail
			@type = 'email'
			@valid = true
		when IsEVP
			@type = 'evp'
			@valid = true
		else
			@type = 'error'
			@valid = false
		end

		def valid?
			@valid
		end

		def invalid?
			!@valid
		end

		def value
			@valid ? @key : ''
		end

		def key
			@key
		end

		def type
			@type
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
