# frozen_string_literal: true
require "logger"
require "open-uri"
require "sqlite3"
require "tmpdir"

module AoC
  VERSION = "0.1.0"
  LOG = Logger.new(STDERR)
  LOG.level = Logger::INFO

  class << self
    def firefox_cookie
      # TODO: Support Linux and Windows
      profile_dir = File.expand_path("~/Library/Application Support/Firefox/Profiles")
      Dir.glob("#{profile_dir}/*").each do |dir|
        cookie_jar = File.join(dir, "cookies.sqlite")
        if File.file?(cookie_jar)
          Dir.mktmpdir do |tmpdir|
            FileUtils.cp(cookie_jar, tmpdir)
            db = SQLite3::Database.new(File.join(tmpdir, "cookies.sqlite"))
            rows = db.execute <<~SQL
              SELECT value from moz_cookies WHERE
                name = 'session' AND
                host like '%adventofcode.com'
              SQL
            session = rows[0][0]
            LOG.debug("Using session cookie #{session} from Firefox")
            return session
          end
        end
      end
    end

    def chrome_cookie
      profile_dir = File.expand_path("~/Library/Application Support/Google/Chrome")
      Dir.glob("#{profile_dir}/*").each do |dir|
        cookie_jar = File.join(dir, "Cookies")
        if File.file?(cookie_jar)
          Dir.mktmpdir do |tmpdir|
            FileUtils.cp(cookie_jar, tmpdir)
            db = SQLite3::Database.new(File.join(tmpdir, "cookies.sqlite"))
            # TODO: Chrome encrypts its cookies, we need a way to decrypt it
            rows = db.execute <<~SQL
              SELECT value from cookies WHERE
                name = 'session' AND
                host_key like '%adventofcode.com'
              SQL
            session = rows[0][0]
            LOG.debug("Using session cookie #{session} from Chrome #{cookie_jar}")
            return session
          end
        end
      end
    end

    def get_session_cookie
      if ENV['AOC_SESSION']
        return ENV['AOC_SESSION']
      end

      files = ['.aoc-session', '~/.config/aoc-session']
      files.each do |f|
        if File.file?(f)
          return File.read(f)
        end
      end

      # Check Browser profiles
      firefox_cookie || chrome_cookie
    end

    def get_year
      if ENV['AOC_YEAR']
        return ENV['AOC_YEAR'].to_i
      end
      files = ['.aoc-year']
      files.each do |f|
        if File.file?(f)
          return File.read(f).to_i
        end
      end
      # Check the current directory to see if we can guess the year
      if m = /(20\d{2})/.match(Dir.pwd)
        year = m[1].to_i
        if year >= 2015 and year <= Time.now.year
          LOG.debug("Guessing year #{year} from #{Dir.pwd}")
          return year
        end
      end
      nil
    end

    def download_input(year, day)
      session = get_session_cookie
      # TODO: Handle nil session, or when we get an error downloading
      url = "https://adventofcode.com/#{year}/day/#{day}/input"
      LOG.info("Downloading #{url}")
      URI.open(url, "Cookie" => "session=#{session}").read
    end

    def get_input(year, day)
      cache_path = "inputs/#{year}/#{day}.txt"
      if File.file?(cache_path)
        File.read(cache_path)
      else
        data = download_input(year, day)
        FileUtils.makedirs(File.dirname(cache_path))
        File.write(cache_path, data)
        data
      end
    end

    def get_input_lines(year, day)
      get_input(year, day).lines(chomp: true)
    end

    def get_input_text(year, day)
      get_input(year, day).chomp
    end

    def get_input_raw(year, day)
      get_input(year, day)
    end

    def get_input_numbers(year, day)
      get_input(year, day).lines.map { |line| line.to_i }
    end

    def get_input_number(year, day)
      get_input_numbers(year, day).first
    end

    def handle_name(year, name)
      if m = /^day(\d+)_(lines|text|raw|number|numbers)$/i.match(name)
        day = m[1].to_i
        meth = "get_input_#{m[2]}"
        method(meth).call(year, day)
      end
    end

    def Object.const_missing(name)
      LOG.debug("Looking for #{name}")
      rv = AoC.handle_name(AoC.get_year, name)
      raise NameError.new("uninitialized constant #{name}") if rv.nil?
      rv
    end
  end
end
