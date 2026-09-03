class Micropost < ApplicationRecord
  belongs_to :user

  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [ 500, 500 ]
  end

  default_scope -> { order(created_at: :desc) }

  validates :content,
            presence: true,
            length: { maximum: 140 }

  validates :image,
            content_type: {
              in: %w[image/jpeg image/png image/gif],
              message: "must be a JPEG, PNG, or GIF"
            },
            size: {
              less_than: 5.megabytes,
              message: "should be less than 5 MB"
            }
end
