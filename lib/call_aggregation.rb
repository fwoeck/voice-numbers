module CallAggregation

  def active_call_count
    pre_queued_call_count + queued_call_count + dispatched_call_count
  end


  def queued_call_count
    queued_calls.size
  end


  def pre_queued_call_count
    pre_queued_calls.size
  end


  def dispatched_call_count
    dispatched_call_pairs.keys.size
  end


  def queued_calls_delay_max
    (time_now - (call_queued_times.first || time_now)).round
  end


  def queued_calls_delay_avg
    return 0 if call_queued_times.size == 0

    (call_queued_times.inject(0) { |sum, t|
      sum += time_now - t
    } / call_queued_times.size).round
  end

  private


  def time_now
    @memo_time_now ||= Time.now.utc
  end


  def call_queued_times
    @memo_delays ||= queued_calls.map { |c| Time.parse c['QueuedAt'] }.sort
  end


  def pre_queued_calls
    incoming_calls.select { |c| !c['QueuedAt'] && !c['DispatchedAt'] }
  end


  def queued_calls
    @memo_queued_calls ||= incoming_calls.select { |c| c['QueuedAt'] && !c['DispatchedAt'] }
  end


  def incoming_calls
    admin_ext = Numbers.number_conf['admin_name']

    raw_calls.select { |c|
      !c['CallTag'] && !c['Hungup'] && (
        c['Extension'] == '0' || c['Extension'] == admin_ext
      )
    }
  end


  def dispatched_calls
    @memo_dispatched_calls ||= raw_calls.select { |c| c['DispatchedAt'] && !c['Hungup'] }
  end


  def dispatched_call_pairs
    @memo_dispatched_call_pairs ||= dispatched_calls.group_by { |c| c['CallTag'] }
  end
end
