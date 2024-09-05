require "pg"
require "sequel"
require "active_support/core_ext/string/inflections"

require_relative "lib/polychrome"

CONN = Sequel.connect("postgresql://pc:pcpc@localhost:5432/polychrome")

class Author < Polychrome::SQL::Model
  attr_accessor :name

  many :books do |ids|
    Book.sql("select * from books where author_id in ?", ids).group_by(&:author_id)
  end
end

class Book < Polychrome::SQL::Model
  attr_accessor :title, :author_id
end

Polychrome::Context.connection = CONN

CONN.run("drop table books")
CONN.run("drop table authors")
CONN.run("create table books (id SERIAL PRIMARY KEY, author_id integer, title varchar(255))")
CONN.run("create table authors (id SERIAL PRIMARY KEY, name varchar(255))")
berg_id = CONN["insert into authors (name) VALUES (?) RETURNING id", "berg"].first[:id]
marc_id = CONN["insert into authors (name) VALUES (?) RETURNING id", "marc"].first[:id]
CONN[:books].insert(author_id: berg_id, title: "berg is the best")
CONN[:books].insert(author_id: berg_id, title: "berg is the worlds best")
CONN[:books].insert(author_id: marc_id, title: "marc is the best")
CONN[:books].insert(author_id: marc_id, title: "marc is the worlds best")

a = Author.get(berg_id)
b = Author.get(marc_id)

puts "berg books is #{a.books.inspect}"
puts "marc books is #{b.books.inspect}"
