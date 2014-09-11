class CallEvent
  include Mongoid::Document

  field :call_id,   type: String
  field :headers,   type: Hash
  field :timestamp, type: Time


  def self.log(call)
    create(
      timestamp: Time.now.utc,
      headers:   call.to_hash,
      call_id:   call.call_id
    )
  end
end
