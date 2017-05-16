require 'byebug'
require_relative 'orm'
require_relative 'Question'
require_relative 'User'

class Reply

  attr_accessor :id, :user_id, :question_id, :reply, :parent_reply_id

  def initialize(option)
    @id = option['id']
    @user_id = option['user_id']
    @question_id = option['question_id']
    @reply = option['reply']
    @parent_reply_id = option['parent_reply_id']
  end

  def self.all
    all = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM replies
    SQL
    all.map {|datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    query = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id =  ?
    SQL
    Reply.new(query.first)
  end

  def find_by_question_id
    Question.find_by_id(@question_id)
  end

  def author
    User.find_by_id(user_id)
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    reply = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    reply.first
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_reply_id = ?
    SQL
    reply.first
  end

end
