class Plugin
  attr_reader :channel

  class << self
    def inherited(base)
      registry << base.new
    end

    def registry
      @registry ||= []
    end

    def each
      registry.each do |member|
        yield(member)
      end
    end

    def each_c
      registry.map(&:class).each do |member|
        yield(member)
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
