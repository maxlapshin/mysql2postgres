
class Mysql2psql
  
  class GeneralError < StandardError
	end

  class ConfigurationError < StandardError
	end
  class UninitializedValueError < ConfigurationError
	end
  class ConfigurationFileNotFound < ConfigurationError
	end
  class ConfigurationFileInitialized < ConfigurationError
	end	
	
end