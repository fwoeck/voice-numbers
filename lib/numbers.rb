module Numbers

  cattr_reader :conf, :redis, :rails_env


  def self.read_config
    @@rails_env = ENV['RAILS_ENV'] || 'development'
    @@conf      = YAML.load(File.read(File.join('./config/app.yml')))
  end


  def self.setup_redis
    @@redis = ConnectionPool.new(size: 5, timeout: 3) {
      Redis.new(host: conf['redis_host'], port: conf['redis_port'], db: conf['redis_db'])
    }
  end


  def self.setup_mongodb
    Mongoid.load!('./config/mongoid.yml', rails_env.to_sym)
  end


  def self.setup
    read_config
    setup_redis
    setup_mongodb
  end


  def self.redis_timestamp
    @@redis_timestamp ||= "#{rails_env}.numbers-timestamp"
  end


  def self.set_timestamp
    start = redis.with { |con| con.get(redis_timestamp) } || '2014-01-01T00:00:00.000+00:00'
    stop  = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%S.%L+00:00'

    redis.with { |con| con.set(redis_timestamp, stop) }
    [start, stop]
  end
end
