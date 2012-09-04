## NowAndLater::Service
# base class of all app services

## Setup for Subclasses

### Args
# pass one or more arg names to self.takes
# e.g. takes :name, :address
# each arch will be setup as an instance variable (@name,@address above)

## Subclass#run
# put your app logic inside a public run method
# all other helper methods should be private

## Running
### Now
# to run a service an return the results immediately use Service.now
# e.g. @user = UpdateUserAdress.now @name, @address

### Later with Delayed::Job
# you can also run your service later with delayed job later
# e.g. SendWelcomeEmail.later @user

class NowAndLater::Service
  
  ## Args
  # setup args for runners
  def self.takes(*names)
    return @takes if names.empty?
    @takes = names
  end
  
  ## ActiveRecord Args
  # setup an arg so that it be passed as ActiveRecord instance or integer
  # calling sets up two instance methods #arg (instance) and #arg_id (int)
  # which should be used to access arg instead of @arg
  # e.g. can_find :account sets up:
  # * Service#account #=> Account instance
  # * Service#account_id #=> 1
  ### Override Class Name
  # use opt[:class_name] to set ActiveRecord class name as a string when
  # class can't be inferred from arg name
  def self.can_find(arg,opt={})
    @finders ||= {}
    @finders[arg] = opt
    define_record_getter arg
    define_id_getter arg
  end
  
  ## Runners
  
  def self.now(*args)
    new(*args).run
  end
  
  def self.later(*args)
    NowAndLater::Queue.add self, *args
  end
  
  ## Initialize
  # takes any number of args which are set as instance variables
  def initialize(*args)
    set_instance_variables args
  end
  
  ## Run
  # called by Service.now override with app logic
  def run; raise NotImplementedError; end
  # called by Delayed::Job after using Service.later
  alias :perform :run
  
  private

  ## Instance Variables
  # creates an instance variable for each arg passed to initialize
  # variable names pulled from self.class.takes

  # Special Cases:
  # @opt is set to hash when nil
  def set_instance_variables(values)
    values.each_with_index do |value,i|
      name = self.class.takes[i]
      instance_variable_set "@#{name}",value
    end
    @opt = {} if self.class.takes.include?(:opt) and @opt.nil?
  end
  
  
  ## ActiveRecord Args
  
  def self.define_record_getter(arg)
    define_method arg do
      value = instance_variable_get "@#{arg}"
      return value unless given_id_for? value
      record = instance_variable_get "@#{arg}_record"
      return record if record
      opt = self.class.finders[arg]
      class_name = opt[:class_name] || arg.to_s.camelcase
      conditions = {id: value}
      conditions["#{opt[:belongs_to]}_id".to_sym] = send opt[:belongs_to] if opt[:belongs_to]
      record = class_name.constantize.where(conditions).first
      instance_variable_set "@#{arg}_record", record
      record
    end
  end
  
  def given_id_for?(value)
    value.is_a?(Integer) or value.is_a?(String)
  end
  
  def self.define_id_getter(arg)
    define_method "#{arg}_id".to_sym do
      value = instance_variable_get "@#{arg}"
      value.is_a?(Integer) ? value : value.id
    end
  end
  
  # hash of all findable args
  def self.finders; @finders; end
  
end