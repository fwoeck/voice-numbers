class AmiEvent
  include Mongoid::Document

  field :target_call_id, type: String
  field :timestamp,      type: String
  field :name,           type: String
  field :headers,        type: Hash


  def self.log(payload)
    data = JSON.parse payload
    create(
      name:           data['name'],
      headers:        data['headers'],
      timestamp:      data['timestamp'],
      target_call_id: data['target_call_id']
    )
  end
end
