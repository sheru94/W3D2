DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS question_follows;
DROP TABLE IF EXISTS replies;
DROP TABLE IF EXISTS question_likes;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Yoseph', 'Habtewold'),
  ('Shamsher', 'Singh'),
  ('Steve', 'Jobs');

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('what is life?', 'life is ruby', (SELECT id FROM users WHERE fname = 'Yoseph')),
  ('what is Ruby?', 'ruby is a programming Language', (SELECT id FROM users WHERE fname = 'Shamsher')),
  ('what is Apple?', 'Its a computer', (SELECT id FROM users WHERE fname = 'Steve'));

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

INSERT INTO
  question_follows(question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'what is life?'), (SELECT id FROM users WHERE fname = 'Steve')),
  ((SELECT id FROM questions WHERE title = 'what is Ruby?'), (SELECT id FROM users WHERE fname = 'Yoseph'));

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  reply TEXT,
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,

  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

INSERT INTO
  replies(reply, user_id, question_id, parent_reply_id)
VALUES
  (
    'life is Apple',
    (SELECT id FROM users WHERE fname = 'Shamsher'),
    (SELECT id FROM questions WHERE title = 'what is life?'),
    NULL
  ),
  (
    'no its not!',
    (SELECT id FROM users WHERE fname = 'Yoseph'),
    (SELECT id FROM questions WHERE title = 'what is life?'),
    (SELECT id FROM replies WHERE reply = 'life is Apple')
  );

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  question_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);


INSERT INTO
  question_likes(user_id, question_id)
VALUES
  ((SELECT id FROM users WHERE fname = 'Yoseph'), (SELECT id FROM questions WHERE title = 'what is life?')),
  ((SELECT id FROM users WHERE fname = 'Shamsher'), (SELECT id FROM questions WHERE title = 'what is Ruby?'));
