require_relative 'orm'

class QuestionLike
  attr_accessor :id, :user_id, :question_id

  def self.all
    all = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM question_likes
    SQL
    all.map {|datum| QuestionLike.new(datum) }
  end

  def self.likers_for_question_id(question_id)
    likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_likes
      JOIN users ON users.id = question_likes.user_id
      WHERE
        question_id = ?
    SQL
    likers.map { |likes| QuestionLike.new(likes)  }
  end

  def self.num_likes_for_question_id(question_id)
    count = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        COUNT(user_id) AS count
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL
    count.first['count']
  end

  def self.liked_questions_for_user_id(user_id)
    liked = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_likes
      JOIN users ON users.id = question_likes.user_id
      WHERE
        user_id = ?
    SQL
    liked.map { |likes| QuestionLike.new(likes)  }
  end

  def self.most_liked_questions(n)
    liked = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.title, COUNT(question_likes.user_id) AS c
      FROM
        question_likes
      JOIN users ON users.id = question_likes.user_id
      JOIN questions ON questions.id = question_likes.question_id
      GROUP BY
        question_likes.question_id
      ORDER BY
        COUNT(question_likes.user_id)
      LIMIT
        n
    SQL
    liked
  end

  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end
end
