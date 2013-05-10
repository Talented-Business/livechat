class RegistrationsController < Devise::RegistrationsController
  self.scoped_views = false
  
  def new
    super
  end

  protected
end