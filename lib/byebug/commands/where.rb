require 'pathname'
require 'byebug/command'
require 'byebug/helpers/frame'

module Byebug
  #
  # Show current backtrace.
  #
  class WhereCommand < Command
    include Helpers::FrameHelper

    self.allow_in_post_mortem = true

    def self.regexp
      /^\s* (?:w(?:here)?|bt|backtrace)\s*(.*)\s*$/x
    end

    def self.description
      <<-DESCRIPTION
        w[here]|bt|backtrace [pattern]

        #{short_description}

        Print the entire stack frame. Each frame is numbered; the most recent
        frame is 0. A frame number can be referred to in the "frame" command.
        "up" and "down" add or subtract respectively to frame numbers shown.
        The position of the current frame is marked with -->. C-frames hang
        from their most immediate Ruby frame to indicate that they are not
        navigable.
      DESCRIPTION
    end

    def self.short_description
      'Displays the backtrace'
    end

    def execute
      @pattern = @match[1]
      print_backtrace
    end

    private

    def print_backtrace
      bt = prc('frame.line', (0...context.stack_size)) do |_, index|
        frame = Frame.new(context, index)
        if @pattern.nil? || @pattern.empty? || frame.deco_file.include?(@pattern)
          frame.to_hash
        end
      end

      print(bt)
    end
  end
end
