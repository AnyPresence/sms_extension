class SmsExtension::ApplicationController < ApplicationController
  layout "layouts/admin"
  
  before_filter :authenticate_admin!
end
