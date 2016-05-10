class WordGameController < ApplicationController
  def game
    @grid = generate_grid(9)
  end

  def score
    @attempt = params[:attempt]
    @start = params[:start].to_i
    @end = Time.now.to_i
    @grid = params[:grid]
    @result = run_game(@attempt, @grid, @start, @end)
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    grid = []
    grid_size.times do
      grid << ('a'..'z').to_a.shuffle[1]
    end
    return grid
  end

  def run_game(attempt, grid, start_time, end_time)
    score = 0
    result = {}
    uri = URI.parse("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    # attempt.upcase!

    if response.code == "200"
      api_result = JSON.parse(response.body)
      if api_result["term0"]
        split_word = attempt.split""
        split_grid = grid.split""
        if (split_word & split_grid).count < split_word.count
          score = 0
          message = "not in the grid"
        elsif split_word.all? { |e| grid.include?(e) }
          translation = api_result["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
          message = "well done"
          score = attempt.length / (end_time - start_time)
        else
          score = 0
          message = "not in the grid A"
        end
      else
        score = 0
        message = "not an english word"
      end
    else
      message = "ERROR!!!"
    end
    result = {translation: translation, time: (end_time - start_time), score: score, message: message}
  end

end
