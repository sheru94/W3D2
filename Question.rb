class Question
  attr_accessor :id, :title, :body, :author_id

  def initialize(option)
    @id = option['id']
    @title = option['title']
    @body = option['body']
    @author_id = option['author_id']
  end

  def self.find_by_id(id)
    query = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id =  ?
    SQL
    Question.new(query.first)
  end

  def self.all
    all = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM questions
    SQL
    all.map {|datum| Question.new(datum) }
  end

  def self.find_by_author_id(author_id)
    id = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        author_id =  ?
    SQL
    Question.new(id.first)
  end

  def author
    User.find_by_id(@id)
  end

  def replies
    Reply.find_by_question_id(@id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def most_followed(n)
    QuestionFollows.followers_for_question_id(n)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end
end
