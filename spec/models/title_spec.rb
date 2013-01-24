require 'spec_helper'

describe Title do
  let(:movie_row)  { {type: :movie, title: 'Panic Room', year: 2011 } }
  let(:series_row) { {type: :series, title: 'The Simpsons', start_year: 1989, end_year: nil } }
  let(:episode_row) { {type: :episode, title: 'The Simpsons', episode: 'Moaning Lisa (#1.6)', year: 1990} }

  it "creates data from a row" do
    lambda { Title.create_from_row_data(movie_row) }.should change { Title.count }.by(1)
  end

  it "Adds episodes" do
    Title.create_from_row_data(series_row)
    Title.create_from_row_data(episode_row)

    t = Title.first
    t.episodes.should_not be_empty
  end
end
