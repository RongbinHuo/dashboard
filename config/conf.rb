require 'active_support/core_ext/hash' # for symbolize_keys

module Conf
  
  def self.app()
    @@app_config ||= vars_from_yaml(File.expand_path('application.yml', File.dirname(__FILE__)))
  end
  
  private_class_method
  
  def self.vars_from_yaml(path)
    YAML.load_file(path).symbolize_keys
  end
  
end
