class AmqpManager
  include Celluloid

  TOPICS = [:rails, :numbers]


  TOPICS.each { |name|
    class_eval %Q"
      def #{name}_channel
        @#{name}_channel ||= connection.create_channel
      end
    "

    class_eval %Q"
      def #{name}_xchange
        @#{name}_xchange ||= #{name}_channel.topic('voice.#{name}', auto_delete: false)
      end
    "

    class_eval %Q"
      def #{name}_queue
        @#{name}_queue ||= #{name}_channel.queue('voice.#{name}', auto_delete: false)
      end
    "
  }


  def rails_publish(payload)
    data = Marshal.dump(payload)
    rails_xchange.publish(data, routing_key: 'voice.rails')
  end


  def connection
    establish_connection unless @@connection
    @@connection
  end


  def shutdown
    connection.close
  end


  def establish_connection
    @@connection = Bunny.new(
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


  class << self

    def start
    # Celluloid.logger = nil
      Celluloid::Actor[:amqp] = AmqpManager.pool(size: 32)
      @@manager ||= new.tap { |m| m.start }
    end


    def shutdown
      @@manager.shutdown
    end


    def rails_publish(*args)
      Celluloid::Actor[:amqp].async.rails_publish(*args)
    end
  end
end
