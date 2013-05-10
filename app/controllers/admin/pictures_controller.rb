class Admin::PicturesController < ApplicationController
  layout "admin"
  before_filter :authenticate_operator!  
  before_filter :authorize_admin!
  before_filter :find_picture, :only => [:delete,
                                         :edit,
                                         :update,
                                         :destroy]  

  def index
    @pictures = Picture.all
  end
  def show
  end
  def new
    @picture = Picture.new
  end
  def create
    @picture = Picture.new(params[:picture])
    if @picture.save
      flash[:notice] = "Picture has been created."
      redirect_to admin_pictures_path
    else
      flash[:alert] = "Picture has not been created."
      render "new"
    end    
  end
  def update
    if @picture.update_attributes(params[:picture])
      flash[:notice] = "Picture has been updated."
      redirect_to admin_pictures_path
    else
      flash[:alert] = "Picture has not been updated."
      render :action => "edit"
    end
  end
  def destroy
    @picture.destroy
    flash[:notice] = "Picture has been deleted."
    redirect_to admin_pictures_path    
  end
  def delete
    @picture.destroy
    flash[:notice] = "Picture has been deleted."
    redirect_to admin_pictures_path
  end
  private
    def find_picture
      @picture = Picture.find(params[:id])
      rescue ActiveRecord::RecordNotFound
      flash[:alert] = "The picture you were looking" +
                      " for could not be found."
      redirect_to admin_pictures_path
    end
    def authorize_admin!
      unless current_operator.has_role? :admin or current_operator.has_role? :superadmin
        flash[:alert] = "You must be an admin to do that."
        redirect_to admin_schedules_path
      end
    end
end
