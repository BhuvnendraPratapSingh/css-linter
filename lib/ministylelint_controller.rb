require_relative '../lib/reader.rb'
require_relative '../lib/scanner.rb'
require_relative '../lib/reporter.rb'

class MinStyleiLintController
  def initialize(file)
    show_progress('Reading file(s) from working directory:')
    @file = file
    if file.nil?
      @errors_hash = {}
      @files_to_scan = read_files
      show_progress('Scanning file(s) for possible errors:')
      puts
      fetch_errors_dir_files
      report_multiple_files_errors
    else
      @file_lines_array = read
      show_progress('Scanning file(s) for possible errors:')
      puts
      puts ''
      @errors = fetch_errors
      report_errors
    end
  end

  private
  def read
    if @file.nil?
      read_files
    elsif File.exist?(@file)
      read_file
    else
      puts 'Invalid file, please input valid file.' unless @valid_path.match?(@files)
    end
  end

  def read_file
    reader = Reader.new(@file)
    reader.buffer_arr
  end

  def fetch_errors
    scanner = Scanner.new(@file_lines_array)
    scanner.errors
  end

  def report_errors(multiple = nil)
    reporter = Reporter.new
    reporter.report(@errors, @file)
    summarize_report(1, @errors.size) if multiple.nil?
  end

  def report_multiple_files_errors
    file_count = 0
    errors_count = 0
    @errors_hash.each do |file, errors|
      @file = file
      @errors = errors
      report_errors('multiple_files')
      file_count += 1
      errors_count += @errors.size
    end
    summarize_report(file_count, errors_count)
  end

  def read_files
    current_dir = Dir.pwd
    Dir["#{current_dir}/**/*.css"]
  end

  def fetch_errors_dir_files
    @files_to_scan.each do |file|
      temp_file_name = file.split('/')
      file_name = temp_file_name[-2] + '/' + temp_file_name[-1]
      @file = file
      @file_lines_array = read_file
      errors = fetch_errors
      errors.delete(nil)
      @file = file_name
      @errors_hash[@file] = errors
    end
  end

  def show_progress(message = nil)
    0.step(100, 20) do |i|
      printf("\r#{message} %-20s", '.' * (i / 5))
      sleep(0.1)
    end
    puts
  end

  def summarize_report(file_count, errors_count)
    puts
    puts
    formatter = Formatter.new
    errors_count = formatter.format_message(errors_count, errors_count.to_s + ' offenses')

    puts "#{file_count} file(s) scanned, #{errors_count} detected"
  end
end
