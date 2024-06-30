class Dog
  attr_accessor :name, :breed, :id

  #  has a name and a breed
  # has an id that defaults to `nil` on initialization
  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  # creates the dogs table in the database
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  # drops the dogs table from the database
  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name,breed)
      VALUES(?,?)
    SQL

    # insert the dog
    DB[:conn].execute(sql, name, breed)

    # get the dog ID from the database and save it to the Ruby instance
    self.id = DB[:conn].execute('SELECT last_insert_rowid() FROM dogs')[0][0]

    # return the Ruby instance
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  def self.new_from_db(row)
    # self.new is equivalent to Dog.new
    new(id: row[0], name: row[1], breed: row[2])
  end

  def self.all
    sql = <<-SQL
    SELECT *
    FROM dogs
    SQL

    DB[:conn].execute(sql).map do |row|
      new_from_db(row)
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      new_from_db(row)
    end.first
  end

  def self.find(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL

    result = DB[:conn].execute(sql, id).first
    result ? new_from_db(result) : nil
  end
end
