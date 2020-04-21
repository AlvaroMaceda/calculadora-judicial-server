class Holiday < ApplicationRecord
  belongs_to :holidayable, polymorphic: true

  validates :date,
  presence: true,
  uniqueness: {
    scope: :holidayable,
    message: ->(object, data) do
      "(#{data[:model]}): #{data[:value]} already exist!"
    end
  }
  

  # validates_uniqueness_of :user_name, scope: :account_id
end
