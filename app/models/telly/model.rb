module Telly
  class Model < Constant
    def self.find_by_name(name)
      const = super

      const if const && const < ActiveRecord::Base || const == ActiveRecord::Base
    end
  end
end
