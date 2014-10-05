class Call

  Nil    = "\x04\b0"
  FORMAT = %w{call_id call_tag origin_id language skill extension caller_id hungup called_at mailbox queued_at hungup_at dispatched_at}
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
    call_keys = Numbers.redis.with { |con| con.keys(call_key_pattern) }
    return [] if call_keys.empty?

    Numbers.redis.with { |con| con.mget(*call_keys) }.map { |call|
      Marshal.load(call || Nil)
    }.compact.select { |call|
      !call.hungup
    }
  end
end
