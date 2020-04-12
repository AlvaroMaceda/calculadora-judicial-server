class AutonomousCommunity < ApplicationRecord
  belongs_to :country
  has_many :holidays, as: :holidayable

  # validates :name, presence: true, uniqueness: { message: "%{attribute} #{data} is already taken" }

  validates :name,
    presence: true,
    uniqueness: {
      message: ->(object, data) do
        "(#{data[:model]}): #{data[:value]} is taken already!"
      end
    }
end
