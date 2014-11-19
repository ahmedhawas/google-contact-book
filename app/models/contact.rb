class Contact < ActiveRecord::Base
  validates :number, format: { with: /\d{3}-\d{3}-\d{4}/, notice: "phone should be xxx-xxx-xxxx" }
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, notice: "Wrong Email format"}
  belongs_to :user
  default_scope { order('name') } 
end
