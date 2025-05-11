# frozen_string_literal: true

# configuration option
class Uncov::Configuration::Option
  attr_reader :name, :description, :options, :default, :value_parse, :value

  def initialize(name, description, options, default, allowed_values, value_parse)
    @name = name
    @description = description
    @options = Array(options)
    @default = default.freeze
    @value = default
    @allowed_values = allowed_values
    @value_parse = value_parse
  end

  def value=(value)
    if allowed_values&.none?(value)
      raise \
        Uncov::OptionValueNotAllowed,
        "Configuration option(#{name.inspect}) tried to set: #{value.inspect}, only: #{allowed_values.inspect} allowed"
    else
      @value = value
    end
  end

  def on_parser(parser) = parser.on(*options, options_description) { |value| self.value = value_parse.call(value) }

  private

  def options_description
    if allowed_values
      "#{description}, one_of: #{options_one_of.join(', ')}"
    else
      "#{description}, default: #{default.inspect}"
    end
  end

  def options_one_of
    allowed_values.map do |value|
      if value == default
        "#{value.inspect}(default)"
      else
        # :nocov: for now as there is no case yet in Configuration
        value.inspect
        # :nocov:
      end
    end
  end

  def allowed_values
    if @allowed_values.respond_to?(:call)
      @allowed_values = @allowed_values.call
    else
      @allowed_values
    end
  end
end
