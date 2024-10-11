# frozen_string_literal: true

require "sequel"
require_relative "lib/polychrome"

DB = Sequel.connect("postgresql://pc:pcpc@localhost:5432/polychrome")

DB.drop_table? :authors
DB.drop_table? :books
DB.drop_table? :chapters

DB.create_table :authors do
  primary_key :id
  String :name
end

DB.create_table :books do
  primary_key :id
  String :title
  Integer :author_id
end

DB.create_table :chapters do
  primary_key :id
  String :title
  Integer :book_id
end

marc_id = DB[:authors].insert(name: "marc")
berg_id = DB[:authors].insert(name: "berg")

berg_best_id = DB[:books].insert(author_id: berg_id, title: "berg is the best")
DB[:chapters].insert(book_id: berg_best_id, title: "How to win friends?")
DB[:chapters].insert(book_id: berg_best_id, title: "And influence frenemies?")

DB[:books].insert(author_id: berg_id, title: "berg is the worlds best")
DB[:books].insert(author_id: marc_id, title: "marc is the best")
DB[:books].insert(author_id: marc_id, title: "marc is the worlds best")

class Author < Sequel::Model
  include Polychrome::Sequel::Loader

  load_many :books, get: :id do |ids, _|
    Book.where(author_id: ids).to_a.group_by(&:author_id)
  end
end

class Book < Sequel::Model
  include Polychrome::Sequel::Loader

  load_one :author, get: :author_id do |ids, _|
    Author.where(id: ids).to_a.group_by(&:id)
  end

  load_many :chapters, get: :id do |ids, _|
    Chapter.where(book_id: ids).to_a.group_by(&:book_id)
  end
end

class Chapter < Sequel::Model
  include Polychrome::Sequel::Loader

  load_one :author, get: :author_id do |ids, _|
    Author.where(id: ids).to_a.group_by(&:id)
  end
end

marc = Author[marc_id]
berg = Author[berg_id]
p marc.load(:books)
p berg.load(:books)
p berg.load(:books)[0].load(:chapters)
# a.load(:books)
