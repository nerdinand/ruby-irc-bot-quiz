require_relative 'quiz_item'

class MoxQuizzQuestionParser
  attr_reader :path, :quiz_items

  def initialize(path)
    @path = path
    @quiz_items = []
    start_quiz_item
  end

  def parse
    i = 0

    File.open(path, 'r:iso-8859-1').each_line do |line|
      i += 1
      next if line.start_with?('#')

      begin
        parse_line(line.chomp)
      rescue => e
        puts "Error parsing on line #{i} in #{path}: #{e.message}"
      end
    end

    quiz_items
  end

  private

  def parse_line(line)
    if line.empty?
      end_quiz_item
      start_quiz_item
    else
      read_content_line(line)
    end
  end

  def read_content_line(line)
    match_data = /^(.*?): (.*)$/.match(line)
    if match_data
      key = match_data[1]
      value = match_data[2]

      send("read_#{key.downcase}", value)
    end
  end

  def read_category(value)
    @quiz_item.category = value
  end

  def read_question(value)
    @quiz_item.question = value
  end

  def read_answer(value)
    @quiz_item.add_answer value
  end

  def read_level(value)
    @quiz_item.level = value
  end

  def read_regexp(value)
    @quiz_item.regexp = value
  end

  def read_tip(value)
    @quiz_item.add_tip(value)
  end

  def read_comment(value)
    @quiz_item.comment = value
  end

  def read_score(value)
    @quiz_item.score = value
  end

  def read_author(value)
    @quiz_item.author = value
  end

  def read_tipcycle(value)
    @quiz_item.tipcycle = value
  end

  def start_quiz_item
    @quiz_item = QuizItem.new
  end

  def end_quiz_item
    quiz_items << @quiz_item unless @quiz_item.nil?
  end
end
