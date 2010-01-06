#!/usr/bin/env ruby

require 'rubygems'
#http://github.com/ariejan/imdb
require 'imdb'

def imdb_search_by_title criteria
  s = Imdb::Search.new criteria

  return 'not found' if s.movies.empty?

  ret = "#{s.movies.size} result(s)"

  s.movies.each do |movie|
    movie_str = ""

    [ :title, :length, :genres, 
      :year, :director, :cast_members, :poster,
      :tagline, :plot, :rating, :url].each do |prop|

      movie_str += "#{prop} : #{movie.send( prop )}\n"
      
    end

    ret += "\n" + movie_str
  end
  ret
end
