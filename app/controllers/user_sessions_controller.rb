class UserSessionsController < ApplicationController
  skip_authorization_check

  # GET /user_sessions
  # GET /user_sessions.xml
  def index
    @user_sessions = UserSession.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_sessions }
    end
  end

    # GET /user_sessions/1
    # GET /user_sessions/1.xml
  def show
    @user_session = UserSession.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_session }
    end
  end

    # GET /user_sessions/new
    # GET /user_sessions/new.xml
  def new

    # Detect if user is already logged in
    if current_user
      redirect_to schedules_path, :cui => current_user_marker
    end

    @user_session = UserSession.new

    #flash[:alert] = flash[:alert]
    respond_to do |format|
      format.html {render 'new.html.haml'} # new.html.erb
      format.xml  { render :xml => @user_session }
    end
  end

    # GET /user_sessions/1/edit
  def edit
    @user_session = UserSession.find(params[:id])
  end

    # POST /user_sessions
    # POST /user_sessions.xml
  def create
    @user_session = UserSession.new(params[:user_session])

    respond_to do |format|
      if @user_session.save
        format.html {
          Rails.logger.info "Logging in User: #{current_user.id}"
          redirect_to(:schedules, :notice => 'Login Successful')
        }
        format.xml  { render :xml => @user_session, :status => :created, :location => @user_session }
      else
        format.html { render :action => "new"}
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end

    # PUT /user_sessions/1
    # PUT /user_sessions/1.xml
  def update
    @user_session = UserSession.find(params[:id])

    respond_to do |format|
      if @user_session.update_attributes(params[:user_session])
        format.html { redirect_to(@user_session, :notice => 'User session was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_session.errors, :status => :unprocessable_entity }
      end
    end
  end

    # DELETE /user_sessions/1
    # DELETE /user_sessions/1.xml
  def destroy
    @user_session = UserSession.find
    # message = 'Successfully logged out'
    if @user_session
      @user_session.destroy
    else
      message = 'You are not logged in'
    end

    respond_to do |format|
      format.html {
        redirect_to(root_url, :notice => message)
      }
      format.xml  { head :ok }
    end
  end

end
