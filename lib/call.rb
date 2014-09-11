class Call

  FORMAT = %w{target_id call_tag language skill extension caller_id hungup called_at mailbox queued_at hungup_at dispatched_at}
           .map(&:to_sym)

  attr_accessor *FORMAT


  def to_hash
    FORMAT.each_with_object({}) { |key, hash|
      hash[key] = self.send(key)
    }
  end


  def self.call_key_pattern
    "#{Numbers.rails_env}.call.*"
  end


  def self.all
    Numbers.redis_db.keys(call_key_pattern).map { |key|
      Marshal.load(Numbers.redis_db.get(key) || "\x04\b0")
    }.compact.select { |call|
      !call.hungup
    }
  end
end
