require 'open-uri'
require 'json'

class GamesController < ApplicationController

  def new
    @start_time = Time.now.to_i
    @string = create_word
    session[:score] = 0 unless session[:score]
    session[:score] == 0 ? @score = 0 : @score = session[:score]
  end

  def score
    end_time = Time.now.to_i
    @start_time = params[:start_time].to_i
    time_elapsed = end_time - @start_time
    @attempt = params[:attempt].downcase
    @string = params[:string].downcase
    new_score = (((1 / time_elapsed.to_f) * @attempt.length) * 100).to_i
    if english_word?(@attempt)
      if hand_sub(@string, @attempt)
        session[:score] += new_score
        @message = "Congratulations! #{@attempt} is a valid english word! Your score is #{session[:score]}"
      else
        @message = "Sorry but #{@attempt} can't be build out of #{@string}"
      end
    elsif hand_sub(@string, @attempt) == false
      @message = "Sorry but #{@attempt} can't be build out of #{@string}"
    else
      @message = "Sorry but #{@attempt} does not seem to be a valid englishword..."
    end
    # raise
  end

  private

  def create_word
    vowels = %w[A E I O U Y]
    choosen_vowels = []
    5.times do
      choosen_vowels << vowels.sample
    end
    ((('A'..'Z').to_a - vowels).sample(5) + choosen_vowels).shuffle
  end

  def english_word?(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    word_serialized = URI.open(url).read
    JSON.parse(word_serialized)["found"]
  end

  def hand_count(str)
    result = str.chars.group_by(&:itself).map { |l, a| [l, a.length] }
    result.to_h
  end

  def hand_sub(str, sub)
    hand = hand_count(str)
    hand_count(sub).each do |l, c|
      # Unless the letter is present in the hand...
      return false unless hand.key?(l)
      # ...this isn't possible.
      # Subtract letter count
      hand[l] -= c

      # If this resulted in a negative number of remaining letters...
      return false if hand[l].negative?
      # ...this isn't possible.
    end
    # Convert back into a string...
    hand.map do |l, c|
      # ...by repeating each letter count times.
      l * c
    end.join
  end
end

# The new action will be used to display a new random grid and a form.
# The form will be submitted (with POST) to the score action.
