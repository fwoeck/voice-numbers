class Call

  FORMAT = %w{call_id call_tag language skill extension caller_id hungup called_at mailbox queued_at hungup_at dispatched_at}
           .map(&:to_sym)

  attr_accessor *FORMAT


  def handle_message
    CallEvent.log(self)
  end


  def to_hash
    FORMAT.each_with_object({}) { |key, hash|
      hash[key] = self.send(key)
    }
  end


  def self.call_key_pattern
    "#{Numbers.rails_env}.call.*"
  end


  def self.all
    call_keys = Numbers.redis_db.keys(call_key_pattern)
    return [] if call_keys.empty?

    Numbers.redis_db.mget(*call_keys).map { |call|
      Marshal.load(call || "\x04\b0")
    }.compact.select { |call|
      !call.hungup
    }
  end
end
