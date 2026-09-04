class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,
         class_name: "Relationship",
         foreign_key: "follower_id",
         dependent: :destroy

  has_many :passive_relationships,
          class_name: "Relationship",
          foreign_key: "followed_id",
          dependent: :destroy

  has_many :following,
          through: :active_relationships,
          source: :followed

  has_many :followers,
          through: :passive_relationships,
          source: :follower

  before_create :create_activation_digest
  before_save { self.email = email.downcase }

  validates :name,
            presence: true,
            length: { maximum: Settings.user.name.max_length }

  validates :email,
            presence: true,
            length: { maximum: Settings.user.email.max_length },
            format: { with: Regexp.new(Settings.user.email.format) },
            uniqueness: { case_sensitive: false }
  validates :password,
            presence: true,
            length: { minimum: Settings.user.password.min_length }
  has_secure_password

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(
      reset_digest: User.digest(reset_token),
      reset_sent_at: Time.current
    )
  end
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  def password_reset_expired?
    reset_sent_at.nil? ||
      reset_sent_at < Settings.user.password_reset.expiration_hours.hours.ago
  end

  def forget
    update_column(:remember_digest, nil)
  end

  def remember
    self.remember_token = User.new_token
    update_column(:remember_digest, User.digest(remember_token))
  end

  def activate
    update_columns(
      activated: true,
      activated_at: Time.current
    )
  end
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def feed
    followed_user_ids = active_relationships.select(:followed_id)

    Micropost
      .where(user_id: followed_user_ids)
      .or(Micropost.where(user_id: id))
      .includes(:user, image_attachment: :blob)
      .recent
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  private
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
