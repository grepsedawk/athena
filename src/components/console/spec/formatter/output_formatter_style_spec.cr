require "../spec_helper"

describe ACON::Formatter::OutputStyle do
  it ".new" do
    ACON::Formatter::OutputStyle.new(:green, :black, ACON::Formatter::Mode.flags Bold, Underline)
      .apply("foo").should eq "\e[32;40;1;4mfoo\e[0m"

    ACON::Formatter::OutputStyle.new(:red, options: ACON::Formatter::Mode::Blink)
      .apply("foo").should eq "\e[31;5mfoo\e[0m"

    ACON::Formatter::OutputStyle.new(background: :white)
      .apply("foo").should eq "\e[107mfoo\e[0m"

    ACON::Formatter::OutputStyle.new("red", "#000000", ACON::Formatter::Mode.flags Bold, Underline)
      .apply("foo").should eq "\e[31;48;2;0;0;0;1;4mfoo\e[0m"
  end

  describe "foreground=" do
    it "with ANSI color" do
      style = ACON::Formatter::OutputStyle.new
      style.foreground = :black
      style.apply("foo").should eq "\e[30mfoo\e[0m"
    end

    it "with default value" do
      style = ACON::Formatter::OutputStyle.new
      style.foreground = :default
      style.apply("foo").should eq "foo"
    end

    it "with HEX RGB value" do
      style = ACON::Formatter::OutputStyle.new
      style.foreground = "#aedfff"
      style.apply("foo").should eq "\e[38;2;174;223;255mfoo\e[0m"
    end

    it "with invalid color" do
      style = ACON::Formatter::OutputStyle.new

      expect_raises ArgumentError do
        style.foreground = "invalid"
      end
    end
  end

  describe "background=" do
    it "with ANSI color" do
      style = ACON::Formatter::OutputStyle.new
      style.background = :black
      style.apply("foo").should eq "\e[40mfoo\e[0m"
    end

    it "with default value" do
      style = ACON::Formatter::OutputStyle.new
      style.background = :default
      style.apply("foo").should eq "foo"
    end

    it "with HEX RGB value" do
      style = ACON::Formatter::OutputStyle.new
      style.background = "#aedfff"
      style.apply("foo").should eq "\e[48;2;174;223;255mfoo\e[0m"
    end

    it "with invalid color" do
      style = ACON::Formatter::OutputStyle.new

      expect_raises ArgumentError do
        style.background = "invalid"
      end
    end
  end

  it "add/remove_option" do
    style = ACON::Formatter::OutputStyle.new

    style.add_option "reverse"
    style.add_option "hidden"
    style.apply("foo").should eq "\e[7;8mfoo\e[0m"

    style.add_option "bold"
    style.apply("foo").should eq "\e[1;7;8mfoo\e[0m"

    style.remove_option "reverse"
    style.apply("foo").should eq "\e[1;8mfoo\e[0m"

    style.add_option "bold"
    style.apply("foo").should eq "\e[1;8mfoo\e[0m"

    style.options = ACON::Formatter::Mode::Bold
    style.apply("foo").should eq "\e[1mfoo\e[0m"
  end

  it "href" do
    previous_term_emulator = ENV["TERMINAL_EMULATOR"]?
    ENV.delete "TERMINAL_EMULATOR"

    style = ACON::Formatter::OutputStyle.new

    begin
      style.href = "idea://open/?file=/path/SomeFile.php&line=12"
      style.apply("some URL").should eq "\e]8;;idea://open/?file=/path/SomeFile.php&line=12\e\\some URL\e]8;;\e\\"
    ensure
      if previous_term_emulator
        ENV["TERMINAL_EMULATOR"] = previous_term_emulator
      else
        ENV.delete "TERMINAL_EMULATOR"
      end
    end
  end
end
