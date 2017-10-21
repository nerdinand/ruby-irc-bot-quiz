class QuizItem
  attr_accessor :category, :question, :answers, :level, :regexp, :tips, :comment, :score, :author, :tipcycle, :tips_given, :last_tip

  def initialize
    @tips = []
    @answers = []
  end

  def reset
    @tips_given = 0
  end

  def correct?(guess)
    words = guess.split(/\s/)
    correct = word_correct?(guess) || words.any? { |word| word_correct?(word) }

    correct
  end

  def give_tip
    tip = if tips.any?
      tips[tips_given]
    else
      generate_tip
    end

    @last_tip = tip
    @tips_given += 1

    tip
  end

  def add_tip(value)
    tips << value
  end

  def add_answer(value)
    answers << value
  end

  def complete?
    !question.nil? && !answers.empty?
  end

  private

  def word_correct?(guess)
    answers.any? do |answer|
      if answer.include? '#'
        answer.downcase.include? "##{guess.downcase}#"
      else
        guess.downcase == answer.downcase
      end
    end
  end

  def generate_tip
    answer = answers.first

    if tips_given == 0
      '.' * answer.length
    else
      letter_index = (0...answer.length).to_a.sample
      last_tip[letter_index] = answer[letter_index]
      last_tip
    end
  end
end
