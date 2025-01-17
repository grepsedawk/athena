abstract class Athena::Console::Input; end

# Represents a value (or array of values) provided to a command as a ordered positional argument,
# that can either be required or optional, optionally with a default value and/or description.
#
# Arguments are strings separated by spaces that come _after_ the command name.
# For example, `./console test arg1 "Arg2 with spaces"`.
#
# Arguments can be added via the `ACON::Command#argument` method,
# or by instantiating one manually as part of an `ACON::Input::Definition`.
# The value of the argument could then be accessed via one of the `ACON::Input::Interface#argument` overloads.
#
# See `ACON::Input::Interface` for more examples on how arguments/options are parsed, and how they can be accessed.
class Athena::Console::Input::Argument
  @[Flags]
  # Represents the possible modes of an `ACON::Input::Argument`,
  # that describe the "type" of the argument.
  #
  # Modes can also be combined using the [Enum.flags](https://crystal-lang.org/api/master/Enum.html#flags%28%2Avalues%29-macro) macro.
  # For example, `ACON::Input::Argument::Mode.flags REQUIRED, IS_ARRAY` which defines a required array argument.
  enum Mode
    # Represents a required argument that _MUST_ be provided.
    # Otherwise the command will not run.
    REQUIRED

    # Represents an optional argument that could be omitted.
    OPTIONAL

    # Represents an argument that accepts a variable amount of values.
    # Arguments of this type must be last.
    IS_ARRAY
  end

  # Returns the name of the `self`.
  getter name : String

  # Returns the `ACON::Input::Argument::Mode` of `self`.
  getter mode : ACON::Input::Argument::Mode

  # Returns the description of `self`.
  getter description : String

  @default : ACON::Input::Value? = nil

  def initialize(
    @name : String,
    @mode : ACON::Input::Argument::Mode = :optional,
    @description : String = "",
    default = nil
  )
    raise ACON::Exceptions::InvalidArgument.new "An argument name cannot be blank." if name.blank?

    self.default = default
  end

  # Returns the default value of `self`, if any.
  def default
    @default.try do |value|
      case value
      when ACON::Input::Value::Array
        value.value.map &.value
      else
        value.value
      end
    end
  end

  # Returns the default value of `self`, if any, converted to the provided *type*.
  def default(type : T.class) : T forall T
    {% if T.nilable? %}
      self.default.as T
    {% else %}
      @default.not_nil!.get T
    {% end %}
  end

  # Sets the default value of `self`.
  def default=(default = nil)
    raise ACON::Exceptions::Logic.new "Cannot set a default value when the argument is required." if @mode.required? && !default.nil?

    if @mode.is_array?
      if default.nil?
        return @default = ACON::Input::Value::Array.new
      elsif !default.is_a? Array
        raise ACON::Exceptions::Logic.new "Default value for an array argument must be an array."
      end
    end

    @default = ACON::Input::Value.from_value default
  end

  # Returns `true` if `self` is a required argument, otherwise `false`.
  def required? : Bool
    @mode.required?
  end

  # Returns `true` if `self` expects an array of values, otherwise `false`.
  def is_array? : Bool
    @mode.is_array?
  end
end
