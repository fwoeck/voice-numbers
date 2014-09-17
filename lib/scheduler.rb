RS = Rufus::Scheduler.new

module Scheduler

  def self.start
    Signal.trap('TERM') do
      puts "#{Time.now.utc} :: Shutting down.."
      sleep 1 while RS.running_jobs.size > 0

      AmqpManager.shutdown
      RequestWorker.shutdown
      puts "#{Time.now.utc} :: Numbers finished.."
      exit
    end


    RS.cron '* * * * *', overlap: false do
      GeneratesReports.new(
        AggregatesNumbers.new Numbers.set_timestamp
      ).log

      RrdTool.render_images
    end


    RS.every '2s' do
      ds = Dataset.new(Call.all)
      ds.store
      RrdTool.update_with(ds)
    end


    puts "#{Time.now.utc} :: Numbers launched.."
    begin
      RS.join
    rescue ThreadError
      # see https://github.com/jmettraux/rufus-scheduler/issues/98
    end
  end
end
