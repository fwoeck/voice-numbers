require 'rrd'

module RrdTool

  SvnFile = Numbers.conf['stats_image']
  RrdFile = Numbers.conf['stats_rrd']

  RrdOpts = {
    rigid: true,
    imgformat: 'SVG',
    upper_limit: 100,
    disable_rrdtool_tag: true,
    title: 'Call Queue History',
    width: 902, height: 147, border: 0,
    color: ['FONT#444444', 'BACK#FFFFFF']
  }

  cattr_reader :queue_stats


  def self.start
    @@queue_stats = RRD::Base.new(RrdFile)

    unless queue_stats.info
      res = queue_stats.create(start: Time.now - 10.seconds, step: 2.seconds) do
        [:active, :queued, :incoming, :dispatched, :delay_max, :delay_avg
        ].each { |src|
          datasource src, type: :gauge, heartbeat: 10.minutes, min: 0, max: :unlimited
        }
        archive :max, every: 30.seconds, during: 1.day
      end
    end
  end


  def self.update_with(data)
    queue_stats.update Time.now,
      data.active_call_count, data.queued_call_count,
      data.pre_queued_call_count, data.dispatched_call_count,
      data.queued_calls_delay_max, data.queued_calls_delay_avg
  end


  def self.render_images
    RRD.graph SvnFile, RrdOpts do
    # line RrdFile, delay_max:  :max, color: '#999999', label: 'Max. queue delay'
      line RrdFile, delay_avg:  :max, color: '#EE4444', label: 'Avg. queue delay'

    # line RrdFile, active:     :max, color: '#00EE00', label: 'Active calls'
      line RrdFile, incoming:   :max, color: '#AAAAAA', label: 'Incoming calls'
      line RrdFile, queued:     :max, color: '#2222FF', label: 'Queued calls'
      line RrdFile, dispatched: :max, color: '#00EE00', label: 'Dispatched calls'
    end

    puts "#{Time.now.utc} :: Updated realtime charts."
  end
end
