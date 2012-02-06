class NowAndLater::Queue
  
  # current queue instance
  def self.current
    @@current ||= new
  end
  
  # public class method for enqueuing services
  def self.add(service,*args)
    current.send :add, service, *args
  end
  
  private 
  
  
  
  ## Add
  # proxies backend enqueue service e.g. Enqueue::WithDelayedJob
  def add(service,*args)
    NowAndLater.with_backend('Enqueue').now service, args
  end
  
  
  
end