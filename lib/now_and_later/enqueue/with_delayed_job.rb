class NowAndLater::Enqueue::WithDelayedJob < NowAndLater::Service
  
  takes :service, :args
  
  def run
    Delayed::Job.enqueue @service.new(*args)
  end
  
end