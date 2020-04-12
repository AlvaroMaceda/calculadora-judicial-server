class Municipality < ApplicationRecord
  belongs_to :autonomous_community
  has_many :municipalities

  has_many :holidays, as: :holidayable

  validates :code, presence: true, uniqueness: true, length: {minimum: 5, maximum: 5}, allow_blank: false
  validates :name, presence: true

end
