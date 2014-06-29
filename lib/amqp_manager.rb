module AmqpManager
  class << self

    def channel
      Thread.current[:channel] ||= @connection.create_channel
    end

    def xchange
      Thread.current[:xchange] ||= channel.topic('voice.numbers', auto_delete: false)
    end

    def queue
      Thread.current[:queue] ||= channel.queue('voice.numbers', auto_delete: false)
    end

    def numbers_publish(*args)
      xchange.publish(*args)
    end

    def shutdown
      @connection.close
    end

    def establish_connection
      @connection = Bunny.new(
        host:     Numbers.number_conf['rabbit_host'],
        user:     Numbers.number_conf['rabbit_user'],
        password: Numbers.number_conf['rabbit_pass']
      ).tap { |c| c.start }
    end

    def start
      establish_connection

      queue.bind(xchange, routing_key: 'voice.numbers')
      queue.subscribe do |delivery_info, metadata, payload|
        AmiEvent.log(payload)
      end
    end
  end
end
