class DeviceDetector
  class MemoryCache

    DEFAULT_MAX_KEYS = 5000

    attr_reader :data, :max_keys, :lock
    private :lock

    def initialize(config)
      @data = {}
      @max_keys = config[:max_cache_keys] || DEFAULT_MAX_KEYS
      @lock = Mutex.new
    end

    def set(key, value)
      lock.synchronize do
        purge_cache
        data[String(key)] = value
      end
    end

    def get(key)
      data[String(key)]
    end

    def get_or_set(key, value = nil)
      result = get(key)

      return result if result

      set(
        key,
        block_given? ? yield : value
      )
    end

    private

    def purge_cache
      key_size = data.size

      if key_size >= max_keys
        # always remove about 1/3 of keys to reduce garbage collecting
        amount_of_keys = key_size / 3

        data.keys.first(amount_of_keys).each { |key| data.delete(key) }
      end
    end

  end
end
