class Image < ActiveRecord::Base
  key :image_file_name
  key :image_content_type
  key :image_file_size, :as => :integer
  key :image_updated_at, :as => :datetime
  key :caption
  timestamps

  belongs_to :imageable, :polymorphic => true
  belongs_to :user

  has_attached_file :image,
    :path => ':rails_root/public/system/:class/:style/:class_:id.:extension',
    :url => '/system/:class/:style/:class_:id.:extension',
    :default_url => '/system/:class/missing_:style.png',
    :styles => {
      :normal => ['920x920>', :jpg],
      :small => ['80x80>', :jpg]
    },
    :convert_options => {:all => '-quality 95 -strip'}
end

Image.auto_upgrade!