require 'simplecov'

SimpleCov.start 'rails' do
  add_filter "/spec/"
  add_filter "/config/"
  add_filter "/vendor/"
end

puts "SimpleCov started, test coverage will be calculated."
