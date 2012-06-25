class DiscoveryController < ApplicationController

  def index
    if params[:q]
      @groups = Group.joins(:tags).where('groups.name LIKE ? OR tags.name LIKE ?', "%#{params[:q]}%", "#{params[:q]}%").group('groups.id')
    else
      @groups = Group.paginate :page => params[:page]
    end
  end

  def search
    index
    render :layout => false
  end
end
