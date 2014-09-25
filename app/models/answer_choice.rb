class AnswerChoice < ActiveRecord::Base
  validates :question_id, :text, presence: true

  before_destroy do
    self.responses.each { |response| response.destroy }
  end

  belongs_to :question,
  class_name: "Question",
  foreign_key: :question_id,
  primary_key: :id

  has_many :responses,
  class_name: "Response",
  foreign_key: :answer_choice_id,
  primary_key: :id
end