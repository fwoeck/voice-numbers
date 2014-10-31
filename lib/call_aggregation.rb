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
    @memo_delays ||= queued_calls.map { |c| c.queued_at }.sort
  end


  def pre_queued_calls
    incoming_calls.select { |c| !c.queued_at && !c.dispatched_at }
  end


  def queued_calls
    @memo_queued_calls ||= incoming_calls.select { |c| c.queued_at && !c.dispatched_at }
  end


  def incoming_calls
    raw_calls.select { |c|
      !c.call_tag && !c.hungup_at && (
        c.extension == '0' || c.extension == Numbers.conf['admin_name']
      )
    }
  end


  def dispatched_calls
    @memo_dispatched_calls ||= raw_calls.select { |c| c.dispatched_at && !c.hungup_at }
  end


  def dispatched_call_pairs
    @memo_dispatched_call_pairs ||= dispatched_calls.group_by { |c| c.call_tag }
  end
end
