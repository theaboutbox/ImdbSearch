require 'spec_helper'

describe IMDB::Importer do
  let(:importer)    { IMDB::Importer.new }
  let(:episode_row) { %q{"The Simpsons" (1989) {Moaning Lisa (#1.6)}             1990} }
  let(:movie_row)   { %q{Panic Room (2011)                                       2011} }
  let(:series_row)  { %q{"'80s Videos: A to Z" (2009)                            2009-????} }

  it "parses a movie row" do
    importer.parse_title_row(movie_row).should == {type: :movie, title: 'Panic Room', year: 2011 }
  end

  it "parses an episode row" do
    importer.parse_title_row(episode_row).should == {type: :episode, title: 'The Simpsons', episode: 'Moaning Lisa (#1.6)', year: 1990}
  end

  it "parses a series row" do
    importer.parse_title_row(series_row).should == {type: :series, title: "'80s Videos: A to Z", start_year: 2009, end_year: nil}
  end

  let(:episode_actor_row) { %Q{4, Joey\t\t\t"The Peter Austin Noto Show" (2012) {(#1.22)}  [Himself]} }
  let(:next_episode_row)  { %Q{\t\t\t"The Peter Austin Noto Show" (2012) {(#1.23)}  [Himself]} }
  let(:tricky_movie_row)  { %Q{Bacon, Daniel (I)\t\t2gether (2000) (TV)  [Steve Braun]  <28>} }
  let(:really_long_name_row) { %Q{'Koolaid' Taplin Jr., Gerald Dewayne\t\tNow Hiring (2013)  [Maximilian]} }
  let(:actor_test_1)          { %Q{$hort, Too\tAmerican Pimp (1999)  [Too $hort]} }
  it "Parses an episode row" do
    importer.parse_actor_row(episode_actor_row).should == {last_name: '4', first_name: 'Joey', type: :episode, title: 'The Peter Austin Noto Show', episode: '(#1.22)', role: 'Himself', year: 2012 }
  end

  it "keeps track of the last episode" do
    importer.parse_actor_row(episode_actor_row)
    importer.parse_actor_row(next_episode_row).should == {last_name: '4', first_name: 'Joey', type: :episode, title: 'The Peter Austin Noto Show', episode: '(#1.23)', role: 'Himself', year: 2012 }
  end
  
  it "Parses a movie row with a lot of stuff" do
    importer.parse_actor_row(tricky_movie_row).should == {first_name: 'Daniel', last_name: 'Bacon', type: :movie, title: '2gether', year: 2000, role: 'Steve Braun'}
  end

  it "can handle really long names" do
    importer.parse_actor_row(really_long_name_row).should == {
      first_name: 'Gerald Dewayne',
      last_name: "'Koolaid' Taplin Jr.",
      title: 'Now Hiring',
      type: :movie,
      year: 2013,
      role: 'Maximilian' }
  end

  it {
    importer.parse_actor_row(actor_test_1).should == {
      first_name: 'Too', last_name: '$hort',
      type: :movie, title: 'American Pimp', year: 1999,
      role: 'Too $hort'
    }
  }
end
