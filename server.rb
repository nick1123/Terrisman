require 'sinatra'
require 'redis'
require 'securerandom'
require 'json'

#> $redis.set('chunky', 'bacon')
#> $redis.get('chunky')

DATA_KEY     = 'data'
META_KEY     = 'meta'
MESSAGES_KEY = 'messages'
GUID_KEY     = 'guid'
EXPIRES_KEY  = 'expires_at'
APP_NAME     = 'terrisman'

def redis
  @redis ||= Redis.new
end

def build_guid
  SecureRandom.hex(16)
end

def build_secret
  SecureRandom.hex(24)
end

# 30 days in the future
def build_expires_at
  Time.now.to_i + (30 * 24 * 60 * 60)
end

def build_job(guid)
  {
    DATA_KEY => {
      MESSAGES_KEY => []
    },
    META_KEY => {
      GUID_KEY => guid,
      EXPIRES_KEY => build_expires_at
    }
  }
end

def redis_key_for_job(guid)
  "#{APP_NAME}:job:#{guid}"
end

get '/logs/:guid' do
  "Hello #{params['guid']}!"
end

# curl -X POST --data "" http://localhost:4567/jobs/
post '/jobs/' do
  guid = build_guid
  value = build_job(guid).to_json
  redis.set(
    redis_key_for_job(guid),
    value
  )
  value
end

