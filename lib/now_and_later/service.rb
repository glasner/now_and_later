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
  
  
  
  
  # setup args for runners
  def self.takes(*names)
    return @takes if names.empty?
    @takes = names
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
  def set_instance_variables(values)
    values.each_with_index do |value,i|
      name = self.class.takes[i]
      instance_variable_set "@#{name}",value
    end
  end
  
end