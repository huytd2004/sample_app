class Micropost < ApplicationRecord
  belongs_to :user

  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: [
                          Settings.micropost.image.width,
                          Settings.micropost.image.height
                        ]
  end

  scope :recent, -> { order(created_at: :desc) }

  validates :content,
            presence: true,
            length: { maximum: Settings.micropost.content.max_length }

  validates :image,
            content_type: {
              in: Settings.micropost.image.allowed_content_types,
              message: :invalid_content_type
            },
            size: {
              less_than: Settings.micropost.image.max_size_mb.megabytes,
              message: :too_large
            }
end
