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

      res = movie.send( prop )
      res_str = res.is_a?(Array) ? res.join(',') : res
      movie_str += "#{prop} : #{res_str}\n"
      
    end

    ret += "\n" + movie_str
  end
  ret
end

@@answer_bot.filters[:on_new_message] << lambda do |who,what|
  if what =~ /^imdb \w+/
    @im.deliver( who,imdb_search_by_title( what[5.. (what.length-1)]))
  end
end
