class Mysql2psql
  
  class Config
    attr_accessor :config
    class UninitializedValueError < StandardError
  	end
    def initialize(filepath)
      @config = YAML::load(File.read(filepath))
    end
    def [](key)
      self.send( key )
    end
    def method_missing(name, *args)
      token=name.to_s
      default = args.length>0 ? args[0] : ''
      must_be_defined = default == :none
      case token
      when /mysql/i
        key=token.sub( /^mysql/, '' )
        value=@config["mysql"][key]
      when /pg/i
        key=token.sub( /^pg/, '' )
        value=@config["destination"]["postgres"][key]
      when /dest/i
        key=token.sub( /^dest/, '' )
        value=@config["destination"][key]
      when /only_tables/i
        value=@config["tables"] 
      else
        value=@config[token]
      end
      value.nil? ? ( must_be_defined ? (raise UninitializedValueError.new) : default ) : value
    end
  
  end

end