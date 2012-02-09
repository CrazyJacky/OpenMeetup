class EventsController < InheritedResources::Base
  load_and_authorize_resource :only => [:new, :create, :edit, :update, :destroy]
end
