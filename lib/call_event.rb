class CallEvent
  include Mongoid::Document

  field :timestamp, type: Time
  field :headers,   type: Hash


  def self.log(call)
    create(
      timestamp: Time.now.utc,
      headers:   call.to_hash,
      call_id:   call.call_id
    )
  end
end
