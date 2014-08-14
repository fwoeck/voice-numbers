module Numbers

  cattr_reader :number_conf, :redis_db, :sql_db, :rails_env


  def self.read_config
    @@rails_env   = ENV['RAILS_ENV'] || 'development'
    @@number_conf = YAML.load(File.read(File.join('./config/app.yml')))
  end


  def self.setup_redis
    @@redis_db = ConnectionPool::Wrapper.new(size: 5, timeout: 3) {
      Redis.new(host: number_conf['redis_host'], port: number_conf['redis_port'], db: number_conf['redis_db'])
    }
  end


  def self.setup_mongodb
    Mongoid.load!('./config/mongoid.yml', rails_env.to_sym)
  end


  def self.setup_sqldb
    plug = RUBY_PLATFORM =~ /java/ ? 'jdbc:mysql' : 'mysql2'
    db   = number_conf['mysql_db']
    host = number_conf['mysql_host']
    port = number_conf['mysql_port']
    user = number_conf['mysql_user']
    pass = number_conf['mysql_pass']
    uri  = "#{plug}://#{host}:#{port}/#{db}?user=#{user}&password=#{pass}"

    @@sql_db = Sequel.connect(uri)
  end


  def self.setup
    read_config
    setup_redis
    setup_mongodb
    setup_sqldb
  end


  def self.redis_timestamp
    @@redis_timestamp ||= "#{rails_env}.numbers-timestamp"
  end


  def self.redis_dataset
    @@redis_dataset ||= "#{rails_env}.numbers-dataset"
  end


  def self.set_timestamp
    start = redis_db.get(redis_timestamp) || '2014-01-01T00:00:00.000+00:00'
    stop  = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%S.%L+00:00'

    redis_db.set(redis_timestamp, stop)
    [start, stop]
  end


  def self.get_raw_calls
    redis_db.keys("#{rails_env}.call.*").map { |k|
      JSON.parse redis_db.get(k) || '{}'
    }
  end


  def self.store_dataset(data)
    redis_db.set(redis_dataset, data)
  end
end
