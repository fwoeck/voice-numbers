require 'json'
require 'time'


class DataSet

  attr_reader :raw_calls


  def initialize(calls)
    @raw_calls = calls
  end


  def active_call_count
    pre_queued_call_count + queued_call_count + dispatched_call_count
  end


  def pre_queued_call_count
    pre_queued_calls.size
  end


  def queued_call_count
    queued_calls.size
  end


  def dispatched_call_count
    dispatched_call_pairs.keys.size
  end


  def time_now
    @memo_time_now ||= Time.now.utc
  end


  def queued_calls_delay_max
    time_now - (call_queued_times.first || time_now)
  end


  def queued_calls_delay_avg
    return 0 if call_queued_times.size == 0

    (call_queued_times.inject(0) { |sum, t|
      sum += time_now - t
    } / call_queued_times.size).floor
  end


  def to_json
    JSON.dump({
      active_call_count:      active_call_count,
      queued_call_count:      queued_call_count,
      pre_queued_call_count:  pre_queued_call_count,
      dispatched_call_count:  dispatched_call_count,
      queued_calls_delay_max: queued_calls_delay_max,
      queued_calls_delay_avg: queued_calls_delay_avg
    })
  end


  private


  def call_queued_times
    @memo_delays ||= queued_calls.map { |c| Time.parse c['QueuedAt'] }.sort
  end


  def pre_queued_calls
    incoming_calls.select { |c| !c['QueuedAt'] && !c['DispatchedAt'] }
  end


  def queued_calls
    incoming_calls.select { |c| c['QueuedAt'] && !c['DispatchedAt'] }
  end


  def incoming_calls
    raw_calls.select { |c|
      !c['CallTag'] && !c['Hungup'] && (
        c['Extension'].blank? || c['Extension'] == '100'
      )
    }
  end


  def dispatched_calls
    raw_calls.select { |c| c['DispatchedAt'] && !c['Hungup'] }
  end


  def dispatched_call_pairs
    dispatched_calls.group_by { |c| c['CallTag'] }
  end
end
