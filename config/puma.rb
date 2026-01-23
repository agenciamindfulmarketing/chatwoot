# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Default is 5 threads for both, matching Active Record.
#
max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5)
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the port Puma will listen on
# Render injects PORT automatically
#
port ENV.fetch('PORT', 3000)

# Specifies the environment Puma will run in
#
environment ENV.fetch('RAILS_ENV', 'development')

# Specifies the pidfile
#
pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

# Specifies the number of workers
# Render Free → 0 or 1 worker (0 is safest)
#
workers ENV.fetch('WEB_CONCURRENCY', 0)

# Preload the application for better memory usage
#
preload_app!

# Allow Puma to be restarted by `rails restart`
#
plugin :tmp_restart
