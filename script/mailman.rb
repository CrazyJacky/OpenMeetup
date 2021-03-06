require 'mailman'
require 'email_reply_parser'


def body_reader(message)
  part = message.text_part || message.html_part || message
  EmailReplyParser.parse_reply(part.body.decoded.force_encoding(part.charset).encode('UTF-8').gsub(/\r?\n\r?\n\r?\n(.|\r?\n)+/, ''))
end


Mailman.config.pop3 = {
  server: 'mail.meetupedia.org',
  username: 'szimpa01',
  password: 'almafa123'
}

Mailman::Application.run do

  to '%group%@meetupedia.org' do
    bounce = false
    if user = User.find_by_email(message.from.first)
      if group = Group.find_by_permalink(params[:group])
        if group.members.include?(user)
          post = group.posts.create user: user, post: body_reader(message)
          Activity.create_from(post, user, group)
          (group.members - [user]).each do |recipient|
            begin
              PostMailer.notification(post.id, recipient.id).deliver
            rescue
            end
          end
        else
          bounce = true
        end
      else
        bounce = true
      end
    else
      bounce = true
    end
    if bounce
      MailmanMailer.bounce(message)
    end
  end
end
