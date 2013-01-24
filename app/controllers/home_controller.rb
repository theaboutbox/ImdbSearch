class HomeController < ApplicationController
  def show
    if params[:query]
      @query = params[:query]
      @results = Title.do_search(params[:query])
    end
  end
end
