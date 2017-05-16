require_relative 'orm'
require_relative 'User'


class QuestionFollows
  attr_accessor :question_id, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_id = options['user_id']
  end

  def create
    raise 'already exists' if @id
    name = QuestionsDatabase.instance.execute(<<-SQL, question_id, user_id)
      INSERT INTO
        question_follows(question_id, user_id)
      VALUES
        (?, ?)
    SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def self.all
    all = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT * FROM question_follows
    SQL
    all.map {|datum| QuestionFollows.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        users.*
      FROM
        question_follows
      JOIN users ON users.id = question_follows.user_id
      JOIN questions ON questions.id = question_follows.question_id
      WHERE
        question_follows.question_id = ?
    SQL
    followers.map { |follower| User.new(follower)  }
  end

  def self.followed_questions_for_user_id(user_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        questions.*
      FROM
        question_follows
      JOIN users ON users.id = question_follows.user_id
      JOIN questions ON questions.id = question_follows.question_id
      WHERE
        question_follows.user_id = ?
    SQL
    followers.map { |follower| Question.new(follower)  }
  end

  def self.most_followed_questions(n)
    most_followed = QuestionsDatabase.instance.execute(<<-SQL, n)
      SELECT
        questions.title, COUNT(question_follows.user_id) AS count
      FROM
        question_follows
      JOIN users ON users.id = question_follows.user_id
      JOIN questions ON questions.id = question_follows.question_id
      GROUP BY
        question_follows.question_id
      ORDER BY
        COUNT(question_follows.user_id) DESC
      LIMIT n
   SQL
   most_followed
  end
end
