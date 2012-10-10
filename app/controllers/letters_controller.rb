# encoding: UTF-8

class LettersController < CommonController
  load_resource
  # authorize_resource

  def index
    @letters = Letter.order('-mailed_at ASC').paginate :page => params[:page]
    @title = 'Levelek'
  end

  def show
    @user = @letter.testuser || current_user
  end

  def new
  end

  def create
    if @letter.save
      redirect_to @letter
    else
      render_new
    end
  end

  def edit
  end

  def update
    if @letter.update_attributes params[:letter]
      update_page @letter
    else
      render_edit
    end
  end

  def mail
    @letter.mail!
    redirect_to @letter
  end

  def mailtest
    LetterMailer.letter(@letter, @letter.user).deliver
    flash[:notice] = "Tesztlevél elküldve #{@letter.user.email.az} címre."
    redirect_to @letter
  end
end