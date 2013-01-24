class Title
  include Mongoid::Document
  include Sunspot::Mongo
  
  field :name, type: String
  field :type, type: String
  field :year, type: Integer
  embeds_many :episodes

  index({name: 1})

  def self.create_from_row_data(row)
    case row[:type]
    when :movie
      title = Title.find_or_create_by(name: row[:title], type: 'movie')
      title.year = row[:year]
      title.save
    when :series
      title = Title.find_or_create_by(name: row[:title], type: 'series')
      title.year = row[:start_year]
      title.save
    when :episode
      title = Title.where(name: row[:title], type: 'series').first
      episode = title.episodes.create
      episode.name = row[:episode]
      episode.year = row[:year]
      episode.save
    end
  end

  searchable do
    text :name
    integer :year
    text :episodes do
      episodes.map(&:name).join('\t') unless episodes.empty?
    end
  end  

  def self.do_search(query, opts={})
    params = {page: 1, per_page: 50}.merge(opts)
    Title.search do
      fulltext query
      paginate page: params[:page], per_page: params[:per_page]
      facet :year
    end
  end
end
