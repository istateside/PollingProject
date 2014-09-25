class AnswerChoices < ActiveRecord::Migration
  def change
    create_table :answer_choices do |t|
      t.text :text
      t.integer :question_id

      t.timestamps
    end
  end
end
