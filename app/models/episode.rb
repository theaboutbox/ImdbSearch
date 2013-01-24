class Episode
  include Mongoid::Document

  field :name, type: String
  field :year, type: Integer
  embedded_in :title, inverse_of: :episodes

end
