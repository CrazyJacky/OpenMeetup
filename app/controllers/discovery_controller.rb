# encoding: UTF-8

class DiscoveryController < CommonController
  before_filter :authenticate
  before_filter :use_city, only: [:index, :events, :interests]

  def index
    unless params[:q].blank?
      @groups = Group.joins(:tags).where('groups.name LIKE ? OR tags.name LIKE ?', "%#{params[:q]}%", "#{params[:q]}%").group('groups.id')
    else
      order = case params[:order]
        when 'name' then 'name ASC'
        when 'members' then 'memberships_count DESC'
        else 'id ASC'
      end
      @groups = Group.order(order).paginate page: params[:page]
      if Settings.group_discovery_min_member_count and Settings.group_discovery_mandatory_header_image
        @groups = @groups.where('memberships_count >= ?', Settings.group_discovery_min_member_count).where('image_updated_at IS NOT ?', nil)
      elsif Settings.group_discovery_min_member_count
        @groups = @groups.where('memberships_count >= ?', Settings.group_discovery_min_member_count)
      elsif Settings.group_discovery_mandatory_header_image
        @groups = @groups.where('image_updated_at IS NOT ?', nil)
      end
      @groups = @groups.joins(:city).where('groups.city_id' => @city.id) if @city
    end
    @groups = @groups.where('groups.id NOT IN (?)', current_user.uninterested_group_ids) if current_user.uninterested_group_ids.present?
  end

  def events
    @events = Event.where('start_time > ?', Time.now).order('start_time ASC').paginate page: params[:page]
    @events = @events.where('events.id NOT IN (?)', current_user.uninterested_event_ids) if current_user and current_user.uninterested_event_ids.present?
    @events = @events.joins(group: :city).where('groups.city_id' => @city.id) if @city
  end

  def friends
    @users = User.where(id: current_user.friend_ids).order('name ASC').paginate page: params[:page]
  end

  def interests
    @tags = Tag.order('name ASC').paginate page: params[:page]
    @tags = @tags.joins(groups: :city).where('groups.city_id' => @city.id) if @city
  end
end
