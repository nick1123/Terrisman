require 'json'

def execute_curl_command(command)
  `#{command}`
end

def build_curl_command_base
  "curl --silent "
end

def build_curl_command_for_new_job(base_url)
  [
    build_curl_command_base,
    '-X POST --data "" ',
    base_url,
    "/jobs/"
  ].join('')
end

########################
## SETUP

# Example:
#   http://localhost:4568
base_url = ARGV[0]

# Ensure base_url does NOT have a trailing '/'
if base_url[-1] == '/'
  base_url = base_url.chomp('/')
end



########################
## TESTING

# Create a new job
results = JSON.parse(
  execute_curl_command(
    build_curl_command_for_new_job(
      base_url
    )
  )
)
puts results.inspect


# TEST: guid size
guid = results['meta']['guid']
raise "Bad Guid" if guid.size != 32


# TEST: secret size
secret = results['meta']['secret']
raise "Bad Secret" if secret.size != 48


# TEST: expires_at
expires_at = results['meta']['expires_at']
twenty_nine_days_in_the_future = Time.now.to_i + 29 * 24 * 60 * 60
thirty_one_days_in_the_future  = Time.now.to_i + 31 * 24 * 60 * 60
if expires_at < twenty_nine_days_in_the_future || expires_at > thirty_one_days_in_the_future
  raise "Bad expires_at"
end



