require 'pry'

class Student
  attr_accessor :id, :name, :tagline, :github, :twitter, :blog_url, :image_url, :biography

  def initialize
    @id = id
    @name = name
    @tagline = tagline
    @github = github
    @twitter = twitter
    @blog_url = blog_url
    @image_url = image_url
    @biography = biography
  end

  def attributes
    [name, tagline, github, twitter, blog_url, image_url, biography]
  end

  def self.create_table
    students_table = <<-SQL
      CREATE TABLE IF NOT EXISTS students
      (
        id INTEGER PRIMARY KEY,
        name TEXT,
        tagline TEXT,
        github TEXT,
        twitter TEXT,
        blog_url TEXT,
        image_url TEXT,
        biography TEXT
      )
    SQL

    DB[:conn].execute(students_table)
  end

  def self.drop_table
    drop_students = <<-SQL
      DROP TABLE students
    SQL

    DB[:conn].execute(drop_students)
  end

  def insert
    insert_students = <<-SQL
      INSERT INTO students (name, tagline, github, twitter, blog_url, image_url, biography)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    SQL

    DB[:conn].execute(insert_students, attributes)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
  end

  def self.new_from_db(row)
    obj = self.new

    obj.id = row[0]
    obj.name = row[1]
    obj.tagline = row[2]
    obj.github = row[3]
    obj.twitter = row[4]
    obj.blog_url = row[5]
    obj.image_url = row[6]
    obj.biography = row[7]

    obj
  end

  def self.find_by_name(name)
    find_student = <<-SQL
      SELECT * FROM students
      WHERE name = ?
    SQL

    ## sends query to SQL
    results = DB[:conn].execute(find_student, name)

    ## converts query result into Student objects
    results.map { |row| self.new_from_db(row) }.first
  end

  def update
    update_student = <<-SQL
      UPDATE students
      SET name=?, tagline=?, github=?, twitter=?, blog_url=?, image_url=?, biography=?
      WHERE id=?
    SQL

    results = DB[:conn].execute(update_student, attributes, id)
  end

  def persisted?
    !!id
  end

  def save
    if persisted?
      update
    else
      insert
    end
  end

end
