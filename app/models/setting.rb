# encoding: UTF-8

class Setting < ActiveRecord::Base
  key :key, index: true
  key :permalink, index: true
  key :description, as: :text
  key :value, as: :text

  auto_permalink :key

  before_validation do
    self.key = key.parameterize.gsub(/-+/, '_')
  end

  def self.[](key)
    Setting.find_by_permalink(key.to_s.parameterize.gsub(/-+/, '_')).andand.value
  end
end

Setting.auto_upgrade!
