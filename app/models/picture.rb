class Picture < ActiveRecord::Base
  attr_accessible :description, :name,:image
  has_attached_file :image, styles: { medium: "400x300#", small: "150x150#",large: "800x600#{}",thumbnail: "45x45#" },
                             path: ":rails_root/public/system/:class/:id/img_:style.:extension",
                             url: "/system/:class/:id/img_:style.:extension"  
  validates :name, :presence => true  
end
