# frozen_string_literal: true

require "sequel"
require_relative "lib/polychrome"

DB = Sequel.connect("postgresql://pc:pcpc@localhost:5432/polychrome")

DB.drop_table? :authors
DB.drop_table? :books

DB.create_table :authors do
  primary_key :id
  String :name
end

DB.create_table :books do
  primary_key :id
  String :title
  Integer :author_id
end

marc_id = DB[:authors].insert(name: "marc")
berg_id = DB[:authors].insert(name: "berg")

DB[:books].insert(author_id: berg_id, title: "berg is the best")
DB[:books].insert(author_id: berg_id, title: "berg is the worlds best")
DB[:books].insert(author_id: marc_id, title: "marc is the best")
DB[:books].insert(author_id: marc_id, title: "marc is the worlds best")

class Author < Sequel::Model
  include Polychrome::Loader

  load_many :books, get: :id do |ids, _|
    Book.where(author_id: ids).to_a.group_by(&:author_id)
  end
end

class Book < Sequel::Model
  include Polychrome::Loader

  load_one :author, get: :author_id do |ids, _|
    Author.where(id: ids).to_a.group_by(&:id)
  end
end

marc = Author[marc_id]
berg = Author[berg_id]
p marc.load(:books)
p berg.load(:books)

# a.load(:books)
