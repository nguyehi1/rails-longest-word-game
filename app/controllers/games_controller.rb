require "open-uri"

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10).join
    @start_time = Time.now
  end

  def score
    @grid = params[:grid]
    @word = params[:word]
    start_time = Time.now
    end_time = Time.now
    @result = play_games(@word, @grid, start_time, end_time)
  end

  private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end

  def get_translation(word)
    result = open("https://wagon-dictionary.herokuapp.com/#{word}")
    json = JSON.parse(result.read.to_s)
  end

  def included?(guess, grid)
    guess.split("").all? { |letter| grid.include? letter}
  end

  def play_games(word, grid, start_time, end_time)
    result = { time: end_time - start_time } # time: number

    result[:translation] = get_translation(word) # translation: { found: true, etc.}
    result[:score], result[:message] = score_and_message(word, result[:translation], grid, result[:time])
    result
  end

  def score_and_message(word, translation, grid, time)
    if translation['found']
      if included?(word.upcase, grid)
        score = word.chars.length + (1 - time/60)
        [score, "Congratulations! #{word.upcase} is a valid English word"]
      else
        [0, "Sorry but #{word.upcase} can't be built out of the original grid"]
      end
    else
      [0, "Sorry but #{word.upcase} does not seem to be a valid English word"]
    end
  end
end
