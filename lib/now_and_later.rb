module NowAndLater
  VERSION = '0.0.1'
  
  ## Backend
  # stores reference to backend class
  def self.backend; @backend ||= find_backend; end
  
  # returns symbol for current backend, e.g. :delayed_job
  def self.find_backend
    return :delayed_job if defined?(Delayed::Job)
    return :resque if defined?(Resque)
    raise LoadError, "NowAndLater::Queue requires delayed_job or resque gem"
  end
  
  ### WithBackend
  # all extensions take form Class::WithBackend, e.g. Enqueue::WithDelayedJob
  def self.with_backend(namespace = nil)
    mixin = "With#{backend.to_s.camelcase}"
    namespace.nil? ? mixin : "NowAndLater::#{namespace}::#{mixin}".constantize
  end
  
end

require 'rails'

require 'now_and_later/service'
require 'now_and_later/service/with_resque'
require 'now_and_later/queue'
require 'now_and_later/enqueue'
require 'now_and_later/enqueue/with_delayed_job'
require 'now_and_later/enqueue/with_resque'
require 'now_and_later/runner'

case NowAndLater.backend
  when :resque then NowAndLater::Service.send :include, NowAndLater::Service::WithResque
end
