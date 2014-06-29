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


  def self.get_timeframe
    start = 1
    stop  = 2

    [start, stop]
  end
end
