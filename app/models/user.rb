# Attributes:
# * id [integer, primary, not null] - primary key
# * created_at [datetime, not null] - creation time
# * current_sign_in_at [datetime] - devise trackable
# * current_sign_in_ip [string] - devise trackable
# * email [string, default=, not null]
# * encrypted_password [string, default=, not null]
# * last_sign_in_at [datetime] - devise trackable
# * last_sign_in_ip [string] - devise trackable
# * password_salt [string]
# * remember_created_at [datetime] - devise rememberable
# * reset_password_sent_at [datetime] - devise recoverable
# * reset_password_token [string] - devise recoverable
# * sign_in_count [integer, default=0] - devise trackable
# * updated_at [datetime, not null] - last update time
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  validates :email, :presence => true, :uniqueness => true
end
