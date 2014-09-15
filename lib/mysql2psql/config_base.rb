require 'yaml'
require 'mysql2psql/errors'

class Mysql2psql
  class ConfigBase
    attr_reader :config, :filepath

    def initialize(yaml)
      @filepath = nil
      @config = yaml # YAML::load(File.read(filepath))
    end

    def [](key)
      send(key)
    end

    def method_missing(name, *args)
      token = name.to_s
      default = args.length > 0 ? args[0] : ''
      must_be_defined = default == :none
      case token
      when /mysql/i
        key = token.sub(/^mysql/, '')
        value = config['mysql'][key]
      when /dest/i
        key = token.sub(/^dest/, '')
        value = config['destination'][key]
      when /only_tables/i
        value = config['tables']
      else
        value = config[token]
      end
      value.nil? ? ( must_be_defined ? (fail Mysql2psql::UninitializedValueError.new("no value and no default for #{name}")) : default) : value
    end
  end
end
