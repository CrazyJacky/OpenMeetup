# -*- encoding : utf-8 -*-

class EventsController < ApplicationController
  load_resource :group
  load_resource :event, :through => :group, :shallow => true
  authorize_resource :except => [:index, :show, :users]

  def show
    @title = @event.title
  end

  def new
    @event.start_time = Time.zone.now.beginning_of_day + 19.hours
    @event.end_time = Time.zone.now.beginning_of_day + 22.hours
    render :layout => false if request.xhr?
  end

  def create
    if @event.save
      create_activity @event
      redirect_to @event
    else
      render :new
    end
  end

  def edit
    render :layout => false if request.xhr?
  end

  def update
    if @event.update_attributes params[:event]
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to @event.group, :notice => 'Esemény törölve.'
  end

  def invited
    @event_invitation_targets = @event.event_invitation_targets.order('created_at DESC')
  end

  def users
    @participations = @event.participations.includes(:user).paginate :page => params[:page]
  end
end
