module NowAndLater::Service::WithResque
  extend ActiveSupport::Concern
  
  included do 
    cattr_accessor :queue
    self.queue = :now_and_later
    
    ## Perform
    # decodes args from redis and passes on to Service#now
    def self.perform(*encoded)
      decoded = encoded.map do |arg|
        encoded_active_record?(arg) ? decode_active_record(arg) : arg 
      end
      now *decoded
    end

    def self.encoded_active_record?(arg)
      arg.is_a?(String) and arg[0..2].eql?('nal')
    end

    def self.decode_active_record(arg)
      class_name,id = arg[4..-1].split '|'
      class_name.constantize.find id
    end
  end
  
  
  
end