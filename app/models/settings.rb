class Settings < ActiveRecord::Base
  def self.method_missing(method_sym, *arguments, &block)
    # the first argument is a Symbol, so you need to_s it if you want to pattern match
    setting = find_by(key: method_sym)
    return setting.value if setting.present?
    super
  end
end
