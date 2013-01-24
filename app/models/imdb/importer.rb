# Reads the various IMDB files and yields data for
# each relevant piece of information.
class IMDB::Importer

  YEAR_PATTERN = '\(([?0-9]{4})(\/\w+)?\)'

  MOVIE_REGEX = /^(.*) #{YEAR_PATTERN}.+[0-9?]{4}$/
  SERIES_REGEX = /^"([^"]+)" #{YEAR_PATTERN}\s+([?0-9]+)-(.*)$/
  EPISODE_REGEX = /^"([^"]+)" #{YEAR_PATTERN} {([^}]+)}.+([?0-9]{4})$/

  ACTOR_MOVIE_REGEX   = /(.+) \(([0-9]+)(\/\w+)?\)/
  ACTOR_EPISODE_REGEX = /"(.+)" \(([0-9]+)(\/\w+)?\) {([^}]+)}/
  ACTOR_ROLE_REGEX = /\[([^\]]+)\]/
  ACTOR_FIRST_ROW_REGEX = /^([^,]+), (.+?)\t/
  ACTOR_NEXT_ROW_REGEX = /^\s+/

  def initialize

  end

  def read_titles(io, &block)
    # Read until we get to a line that starts with ===========
    # Then skip a row. Don't you love how inconsistent this formatting is?
    state = :preamble
    io.each_line do |line|
      line.chomp!
      case state
      when :preamble
        state = :header if line == '==========='
      when :header
        state = :body
      when :body
        row = parse_title_row(line)
        yield row unless row.nil?
      end
    end
  end

  def read_actors(io, &block)
    #read until we get to the line that starts with ----
    state = :preamble
    io.each_line do |line|
      line.chomp!
      case state
      when :preamble
        state = :header if line.index('Name') == 0
      when :header
        state = :body
      when :body
        row = parse_actor_row(line)
        yield row unless row.nil?
      end
    end
  end

  # Given an actor (or actress) row, get the movie or episode
  def parse_actor_row(row)
    # find actor name - scan until there are multiple spaces, or there
    # is a quotation mark. That's where the name ends and the title
    # information begins.

    return nil if row.blank?

    rest = ''
    if match = ACTOR_FIRST_ROW_REGEX.match(row)
      @current_last_name = match[1].strip
      @current_first_name = match[2].strip
      # Get rid of any parenthesis after the name
      if i = @current_first_name.index(' (')
        @current_first_name = @current_first_name[0..i-1].strip
      end
      rest = row[match[0].length-1..-1].strip
    else
      rest = row.strip
    end
    
    found = {first_name: @current_first_name, last_name: @current_last_name}

    # Match rest of row
    if match = ACTOR_EPISODE_REGEX.match(rest)
      found.merge!({ type: :episode, title: match[1], 
                     year: match[2].to_i, episode: match[4]})
    elsif match = ACTOR_MOVIE_REGEX.match(rest)
      found.merge!({ type: :movie, title: match[1], year: match[2].to_i})
    else
      puts "[IMDB::Importer] Cannot read actor row #{row}"
      return nil
    end

    if match = ACTOR_ROLE_REGEX.match(rest)
      found[:role] = match[1]
    else
      found[:role] = "#{@current_first_name} #{@current_last_name}"
    end

    return found
  end

  # Given a movie row, get the year, episode
  #
  # row - The row from the data file
  #       Example:
  #         "$40 a Day" (2002) {Durham and Chapel Hill, North Carolina (#3.3)}      2004
  #
  # Return Hash containing title, and possibly series and episode information
  #       
  def parse_title_row(row)
    if match = SERIES_REGEX.match(row)
      end_year = match[5].to_i
      end_year = nil if end_year == 0
      return { type: :series, title: match[1], start_year: match[4].to_i, end_year: end_year}
    elsif match = EPISODE_REGEX.match(row)
      return { type: :episode, title: match[1], episode: match[4], year: match[5].to_i }
    elsif match = MOVIE_REGEX.match(row)
      return { type: :movie, title: match[1], year: match[2].to_i }
    else
      puts "[IMDB::Importer] Cannot read row #{row}"
      return nil
    end
  end

end
