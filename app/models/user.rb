class User < ActiveRecord::Base
  validates :user_name, uniqueness: true, presence: true

  has_many :authored_polls,
  class_name: "Poll",
  foreign_key: :author_id,
  primary_key: :id

  has_many :responses,
  class_name: "Response",
  foreign_key: :user_id,
  primary_key: :id

  def completed_polls

    Poll.find_by_sql([<<-SQL, self.id])
    SELECT
      polls.*
    FROM
      polls
    JOIN
      questions ON questions.poll_id = polls.id
    JOIN
      answer_choices ON answer_choices.question_id = questions.id
    LEFT OUTER JOIN
      (
      SELECT
        responses.*
        FROM
          responses
        WHERE
          responses.user_id = ?
      ) as user_responses ON answer_choices.id = user_responses.answer_choice_id
    GROUP BY
       polls.id
    HAVING
      COUNT(DISTINCT(questions.id)) = COUNT(user_responses.id)
    SQL
  end

  def uncompleted_polls
    Poll.find_by_sql([<<-SQL, self.id])
    SELECT
      polls.*
    FROM
      polls
    JOIN
      questions ON questions.poll_id = polls.id
    JOIN
      answer_choices ON answer_choices.question_id = questions.id
    LEFT OUTER JOIN
      (
      SELECT
        responses.*
        FROM
          responses
        WHERE
          responses.user_id = ?
      ) as user_responses ON answer_choices.id = user_responses.answer_choice_id
    GROUP BY
       polls.id
    HAVING
      COUNT(DISTINCT(questions.id)) > COUNT(user_responses.id)
    SQL
  end

end