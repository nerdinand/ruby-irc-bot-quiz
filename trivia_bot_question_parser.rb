require_relative 'quiz_item'

class TriviaBotQuestionParser
  attr_reader :path, :quiz_items

  def initialize(path)
    @path = path
    @quiz_items = []
  end

  def parse
    i = 0

    File.open(path, 'r:iso-8859-1').each_line do |line|
      i += 1

      begin
        parse_line(line.chomp)
      rescue => e
        puts "Error parsing on line #{i}: #{e.message}"
      end
    end

    quiz_items
  end

  def parse_line(line)
    match_data = /^(.*?)`(.*)$/.match(line)

    if match_data
      question = match_data[1]
      answers = match_data[2].split('`')

      quiz_item = QuizItem.new
      quiz_item.question = question

      answers.each do |answer|
        quiz_item.add_answer(answer)
      end

      quiz_items << quiz_item
    end
  end
end
