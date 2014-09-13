class CallEvent
  include Mongoid::Document

  field :timestamp, type: Time
  field :headers,   type: Hash


  def self.log(call)
    create(
      timestamp: Time.now.utc,
      headers:   call.to_hash
    )
  end
end
