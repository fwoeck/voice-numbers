class AggregatesNumbers

  # TODO
  #   - Are CallEvent-timestamps unique?
  #   - Mongodb: call_events should be a capped collection

  attr_reader :start, :stop


  def initialize(timeframe)
    @start, @stop = timeframe
  end


  def table
    CallEvent.where(timestamp: {
      '$gt'  => start, '$lte' => stop
    }).order(timestamp: :asc).to_a
  end
end
