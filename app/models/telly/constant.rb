module Telly
  class Constant
    def self.find_by_name(name)
      name.constantize
    rescue NameError
      nil
    end
  end
end
