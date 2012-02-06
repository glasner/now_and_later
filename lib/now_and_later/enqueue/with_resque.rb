## NowAndLater::Enqueue::WithResque
# service enqueues any service with Resque
# encodes any ActiveRecord args into a hash to work with Resque

class NowAndLater::Enqueue::WithResque < NowAndLater::Service
  
  takes :service, :args
  
  def run
    Resque.enqueue @service, *encoded_args
  end
  
  private
  
  def encoded_args
    @args.map do |arg|
      active_record?(arg) ? encode_active_record(arg) : arg
    end
  end
  
  def active_record?(value)
    value.is_a? ActiveRecord::Base
  end
  
  def encode_active_record(arg)
    "nal:#{arg.class}|#{arg.id}"
  end
  
end