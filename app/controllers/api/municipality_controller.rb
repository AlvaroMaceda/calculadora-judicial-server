class Api::MunicipalityController < ApplicationController
  def search()
    puts params
    render json: {
      :municipality => 'search'
    }.to_json
  end
end
