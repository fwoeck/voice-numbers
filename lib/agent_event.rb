class AgentEvent
  include Mongoid::Document

  field :timestamp, type: Time
  field :headers,   type: Hash


  def self.log(agent)
    create(
      timestamp: Time.now.utc,
      headers:   agent.to_hash
    )
  end
end
