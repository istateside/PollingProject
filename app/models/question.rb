class Question < ActiveRecord::Base
  validates :poll_id, :text, presence: true

  before_destroy do
    self.answer_choices.each { |a_c| a_c.destroy }
  end

  belongs_to :poll,
  class_name: "Poll",
  foreign_key: :poll_id,
  primary_key: :id

  has_many :answer_choices,
  class_name: "AnswerChoice",
  foreign_key: :question_id,
  primary_key: :id

  has_many :responses, through: :answer_choices, source: :responses

  def results
    results_hash = Hash.new(0)

    answer_choices_with_counts = self
      .answer_choices.select("answer_choices.*, COUNT(responses.id) as response_count")
      .joins("LEFT OUTER JOIN responses ON responses.answer_choice_id = answer_choices.id")
      .group("answer_choices.id")
      .where("answer_choices.question_id = ?", self.id)

    answer_choices_with_counts.each do |answer_choice|
      results_hash[answer_choice.text] = answer_choice.response_count
    end
    results_hash
  end
end