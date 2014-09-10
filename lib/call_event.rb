class CallEvent
  include Mongoid::Document

  field :target_call_id, type: String
  field :timestamp,      type: String
  field :headers,        type: Hash


  def self.log(payload)
    data = Marshal.load(payload)

    create(
      headers:        data[:headers],
      timestamp:      data[:timestamp],
      target_call_id: data[:target_call_id]
    )
  end
end
