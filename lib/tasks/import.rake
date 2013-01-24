require 'zlib'

def list_reader(base_path, list_name)
  file_name = File.join base_path, "#{list_name}.list.gz"
  io = open(file_name)
  Zlib::GzipReader.new(io, external_encoding: 'ISO-8859-1')
end

namespace :imdb do
  namespace :import do
    desc 'Import actors (and actresses!)' 
    task :actors, [:base_path] => :environment do |t, args|
      gzip_io = list_reader(args[:base_path], 'actors')
      importer = IMDB::Importer.new
      importer.read_actors(gzip_io) do |row|
        #puts "#{row[:first_name]} #{row[:last_name]} in #{row[:type].to_s} #{row[:title]} #{row[:episode]}"
      end
    end

    desc 'Import movies'
    task :movies, [:base_path] => :environment do |t,args|
      gzip_io = list_reader(args[:base_path], 'movies')
      importer = IMDB::Importer.new
      count = 0
      importer.read_titles(gzip_io) do |row|
        begin
          Title.create_from_row_data(row)
        rescue => e
          puts "Error processing row #{count+1} (#{e.message}): #{row.to_s}"
        end
        print '.' if count % 100 == 0
        count += 1
      end
    end
  end
end
