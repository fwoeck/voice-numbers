class AgentEvent
  include Mongoid::Document

  field :call_id,   type: String
  field :headers,   type: Hash
  field :timestamp, type: Time


  def self.log(agent)
    create(
      timestamp: Time.now.utc,
      headers:   agent.to_hash,
      call_id:   agent.call_id
    )
  end
end
