class Question < ApplicationRecord
  belongs_to :level
  has_many :answers

  def correct_answer=(answer)
    self.answers.build(:value => answer)
  end

  def correct_answer
    self.answers.empty? ?
      nil :
      self.answers.first.value
  end

  def matches_any_answer(answer_value)
    self.answers.any? {|answer| answer.value.mb_chars.upcase.to_s == answer_value.mb_chars.upcase.to_s}
  end
end
