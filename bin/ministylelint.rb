require_relative '../lib/reader.rb'
require_relative '../lib/scanner.rb'
require_relative '../lib/reporter.rb'
require 'byebug'


class MiniLint
  def initialize(file)
    puts 'Initializing Mini Style Lint... '
    puts ''
    show_progress("Reading file(s) from working directory:")
    
    puts
    @file = file
    if file.nil?
      @errors_hash = Hash.new
      @files_to_scan = read_files
      show_progress("Scanning file(s) for possible errors:")
      puts
      fetch_errors_dir_files
    else
      @file_to_scan = read
      show_progress("Scanning file(s) for possible errors:")
      puts
      puts ''
      @errors = fetch_errors
      report_errors
    end
  end

  def read
    if @file.nil? 
      read_files
    else
      if File.exist?(@file)
        read_file  
      else
        puts "Invalid file, please input valid file." unless @valid_path.match?(@files)
      end
    end
  end

  def read_file
    reader = Reader.new(@file)
    lines = reader.buffer_arr
  end

  def fetch_errors
    scanner = Scanner.new(@file_to_scan)
    scanner.errors
  end

  def report_errors
    reporter = Reporter.new
    reporter.report(@errors, @file)
  end

  def show_progress(message=nil)
    0.step(100, 20) do |i|
      printf("\r#{message} %-20s", "." * (i/5))
      sleep(0.1)
    end
    puts
  end

  def read_files
    current_dir = Dir.pwd
    files = Dir["#{current_dir}/**/*.css"]
  end

  def fetch_errors_dir_files
    @files_to_scan.each {|file|
      temp_file_name = file.split("/")
      file_name = temp_file_name[-2] + "/" +  temp_file_name[-1]
      @file = file
      lines = read_file
      @file_to_scan = lines
      errors = fetch_errors
      errors.delete(nil)
      @file = file_name
      @errors_hash[@file] = errors
    }

    file_count = 0  
    errors_count = 0
    @errors_hash.each{|file, errors|
      @file = file
      @errors = errors
      report_errors
      file_count += 1
      errors_count += @errors.size
    }
   
    puts
    puts
    formatter = Formatter.new
    errors_count = formatter.format_message(errors_count.to_s + " offenses")

    puts "#{file_count} files scanned, #{errors_count} detected"
  end
end






file = ARGV[0]
# files = ARGV
# files.each_with_index  {|f, index|
#   p "#{index}::#{f}"
# }
p file
# debugger
mini_lint = MiniLint.new(file)


