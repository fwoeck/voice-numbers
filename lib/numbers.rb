module Numbers
  cattr_reader :number_conf, :redis_db, :sql_db


  def self.read_config
    @@number_conf = YAML.load(File.read(File.join('./config/app.yml')))
  end


  def self.setup_redis
    @@redis_db = ConnectionPool::Wrapper.new(size: 5, timeout: 3) {
      Redis.new(host: number_conf['redis_host'], port: number_conf['redis_port'], db: number_conf['redis_db'])
    }
  end


  def self.setup_mongodb
    Mongoid.load!('./config/mongoid.yml', ENV['RAILS_ENV'].to_sym)
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


  def self.redis_key
    @@redis_key ||= "last_timestamp_#{ENV['RAILS_ENV'] || 'development'}"
  end


  def self.set_timestamp
    start = redis_db.get(redis_key) || '2014-01-01T00:00:00.000+00:00'
    stop  = Time.now.utc.strftime '%Y-%m-%dT%H:%M:%S.%L+00:00'

    redis_db.set(redis_key, stop)
    [start, stop]
  end
end
