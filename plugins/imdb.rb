#!/usr/bin/env ruby

require 'rubygems'
# http://github.com/ypetya/imdb
require 'imdb'

def imdb_search_by_title criteria
  s = Imdb::Search.new criteria

  return 'not found' if s.movies.empty?

  ret = "#{s.movies.size} result(s)"

  s.movies.each do |movie|
    movie_str = ""

    [ :title, :length, :genres, 
      :year, :director, :cast_members,
      :tagline, :plot, :url, :produced_by,
      :film_editing_by, :art_direction_by,
      :original_music_by, :music_department
    ].each do |prop|

      res = movie.send( prop )
      res_str = res.is_a?(Array) ? res.join(',') : res
      movie_str += "#{prop} : #{res_str}\n"
      
    end

    ret += "\n" + movie_str
  end
  ret
end

if defined? @@answer_bot
  @@answer_bot.filters[:on_new_message] << lambda do |who,what|
    if m = what.match(/^imdb\s(.*)/)
      @@answer_bot.im.deliver( who,imdb_search_by_title(m[1]))
    end
  end
end
