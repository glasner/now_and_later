## NowAndLater::Runner Mixin
# shortcuts for running services namespaced under object
# e.g. account.run(:my_service, one: 1) = Account::MyService.now account, one: 1

module NowAndLater::Runner
  
  # run given service now
  def run(symbol,args={})
    service(symbol).now self,args
  end
  
  # run given service later
  def later(symbol,args={})
    service(symbol).later self,args
  end
  
  private
  
  # returns namesaced service class for given symbol
  # e.g. account.service(:my_service) return Account::MyService
  def service(symbol)
    "#{self.class}::#{symbol.to_s.camelcase}".constantize
  end
  
end