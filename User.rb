require 'byebug'
require_relative 'orm'
require_relative 'Question'
require_relative 'reply'

class User
  attr_accessor :id, :fname, :lname

  def self.all
    all = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM users
    SQL
    all.map {|datum| User.new(datum) }
  end

  def self.find_by_id(id)
    query = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    User.new(query.first)
  end

  def self.find_by_name(fname, lname)
    names = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    User.new(names.first)
  end


  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise 'already exists' if @id
    name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def authored_questions
    author = Question.find_by_author_id(@id)
    # debugger
     id2 = QuestionsDatabase.instance.execute(<<-SQL,author.author_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
      SQL

  end

  def authored_replies
    reply = Reply.find_by_user_id(@id)

    id2 = QuestionsDatabase.instance.execute(<<-SQL, reply.user_id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
  end

  def followed_question
    QuestionFollows.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(@id)
  end
end
