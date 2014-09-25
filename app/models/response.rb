class Response < ActiveRecord::Base
  validates :user_id, :answer_choice_id, presence: true
  validate :respondent_has_not_already_answered_question
  validate :user_cant_respond_to_own_poll

  belongs_to :respondent,
  class_name: "User",
  foreign_key: :user_id,
  primary_key: :id

  belongs_to :answer_choice,
  class_name: "AnswerChoice",
  foreign_key: :answer_choice_id,
  primary_key: :id

  has_one :question, through: :answer_choice, source: :question

  def sibling_responses
    question_id = AnswerChoice.select(:question_id)
      .where("answer_choices.id = ?", self.answer_choice_id)

    Response.joins(:answer_choice)
      .where(:answer_choices => { :question_id => question_id} )
      .reject { |response| response.id == self.id }
  end

  private
  def respondent_has_not_already_answered_question
    if self.sibling_responses.any?{ |response| response.user_id == self.user_id }
      errors[:user_id] << "can't respond to same question twice"
    end
  end

  def user_cant_respond_to_own_poll
    poll = Poll.find_by_sql([<<-SQL, self.answer_choice_id])
      SELECT
        polls.*
      FROM
        polls
      JOIN questions ON questions.poll_id = polls.id
      JOIN answer_choices ON answer_choices.question_id = questions.id
      WHERE
        answer_choices.id = ?
    SQL

    if poll.first.author_id == self.user_id
      errors[:user_id] << "can't respond to own poll"
    end
  end

end