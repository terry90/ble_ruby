class Plugin
  attr_reader :channel

  class << self
    def inherited(base)
      registry << base.new
    end

    def registry
      @registry ||= []
    end

    def each(&block)
      registry.each do |member|
        block.call(member)
      end
    end

    def each_c(&block)
      registry.map(&:class).each do |member|
        block.call(member)
      end
    end
  end

  def cycle
    true
  end

  def delay
    5
  end
end
