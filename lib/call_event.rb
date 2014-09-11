class CallEvent
  include Mongoid::Document

  field :target_call_id, type: String
  field :timestamp,      type: String
  field :headers,        type: Hash


  def self.log(call)
    create(
      headers:        call.to_hash,
      timestamp:      Time.now.utc,
      target_call_id: call.target_id
    )
  end
end
