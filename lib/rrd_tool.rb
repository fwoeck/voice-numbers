require 'rrd'

module RrdTool

  cattr_reader :queue_delay


  def self.start
    @@queue_delay = RRD::Base.new('./data/queue_delay.rrd')

    unless queue_delay.info
      queue_delay.create start: Time.now - 10.seconds, step: 1.minute do
        datasource 'max_queue_delay', type: :gauge, heartbeat: 1.minute, min: 0, max: :unlimited
        datasource 'avg_queue_delay', type: :gauge, heartbeat: 1.minute, min: 0, max: :unlimited
        archive :average, every: 10.minutes, during: 1.week
      end
    end
  end


  def self.update_with(data)
    queue_delay.update Time.now,
      data.max_queue_delay,
      data.avg_queue_delay
  end


  def self.render_images
    RRD.graph './data/queue_delay.png', title: 'Queue delays', width: 800, height: 250, color: ['FONT#000000', 'BACK#FFFFFF'] do
      line './data/queue_delay.rrd', max_queue_delay: :average, color: '#0000FF', label: 'Max. queue delay'
      line './data/queue_delay.rrd', avg_queue_delay: :average, color: '#00FF00', label: 'Avg. queue delay'
    end
  end
end
