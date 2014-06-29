class AggregatesNumbers

  # TODO
  #   - Are AmiEvent-timestamps unique?
  #   - Mongodb: ami_events should be a capped collection

  attr_reader :start, :stop


  def initialize(timeframe)
    @start, @stop = timeframe
  end


  def table
    AmiEvent.where(timestamp: {
      '$gt'  => start, '$lte' => stop
    }).order(timestamp: :asc).to_a
  end
end
