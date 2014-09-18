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


    def rails_channel
      Thread.current[:rails_channel] ||= @connection.create_channel
    end

    def rails_xchange
      Thread.current[:rails_xchange] ||= rails_channel.topic('voice.rails', auto_delete: false)
    end

    def rails_publish(payload)
      data = Marshal.dump(payload)
      rails_xchange.publish(data, routing_key: 'voice.rails')
    end


    def shutdown
      @connection.close
    end


    def establish_connection
      @connection = Bunny.new(
        host:     Numbers.conf['rabbit_host'],
        user:     Numbers.conf['rabbit_user'],
        password: Numbers.conf['rabbit_pass']
      ).tap { |c| c.start }
    rescue Bunny::TCPConnectionFailed
      sleep 1
      retry
    end


    def start
      establish_connection

      numbers_queue.bind(numbers_xchange, routing_key: 'voice.numbers')
      numbers_queue.subscribe { |delivery_info, metadata, payload|
        Marshal.load(payload).handle_message
      }
    end
  end
end
