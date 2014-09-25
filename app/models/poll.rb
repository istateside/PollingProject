class Poll < ActiveRecord::Base
  validates :title, uniqueness: true, presence: true
  validates :author_id, presence: true

  has_many :questions,
  class_name: "Question",
  foreign_key: :poll_id,
  primary_key: :id

  belongs_to :author,
  class_name: "User",
  foreign_key: :author_id,
  primary_key: :id

end