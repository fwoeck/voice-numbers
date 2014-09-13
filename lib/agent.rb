class Agent

  attr_accessor :id, :name, :languages, :skills, :activity, :visibility, :call_id,
                :locked, :availability, :idle_since, :mutex, :unlock_scheduled


  def handle_update
    AgentEvent.log(self)
  end


  def to_hash
    { id:        id,
      name:      name,
      skills:    skills,
      call_id:   call_id,
      languages: languages
    }
  end
end
