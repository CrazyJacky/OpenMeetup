# encoding: UTF-8

class PostMailer < CommonMailer

  def notification(post, user)
    @recipient = user
    @email = @recipient.email
    @post = post
    @group = @post.postable
    set_locale @recipient.andand.locale
    mail :to => @email, :subject => "Notification about a new post: #{@group.name}"
  end


  class Preview < MailView

    def notification
      post = Post.last
      user = User.first
      mail = PostMailer.notification(post, user)
      mail
    end
  end
end