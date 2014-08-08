module AmqpManager
  class << self


    def numbers_channel
      Thread.current[:numbers_channel] ||= @connection.create_channel
    end

    def numbers_xchange
      Thread.current[:numbers_xchange] ||= numbers_channel.topic('voice.numbers', auto_delete: false)
    end

    def numbers_queue
      Thread.current[:numbers_queue] ||= numbers_channel.queue('voice.numbers', auto_delete: false)
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
    rescue Bunny::TCPConnectionFailed
      sleep 1
      retry
    end


    def start
      establish_connection

      numbers_queue.bind(numbers_xchange, routing_key: 'voice.numbers')
      numbers_queue.subscribe { |delivery_info, metadata, payload|
        AmiEvent.log(payload)
      }
    end
  end
end
