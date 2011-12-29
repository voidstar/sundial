require 'ostruct'

module Sundial
  # Root Config item
  Config = OpenStruct.new unless defined?(::Sundial::Config)
end
