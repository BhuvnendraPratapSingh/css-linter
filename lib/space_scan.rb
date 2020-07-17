require_relative 'scan'
class SpaceScanner < Scan
  def initialize
    super('Format error')
  end

  def last_line_scan(lines)
    return ":Line #{lines.size + 1}: #{@error_type}final newline missing." unless lines.last.include? "\n"
    return ":Line #{lines.size + 1}: #{@error_type}trailing blank lines detected." unless lines[-1] == "}\n"
  end

  def trailing_space_scan(line, line_number)
    "Line #{line_number + 1}: #{@error_type}trailing space found." if line.end_with?("; \n")
  end

  def space_before_curly_bracket_scan(line, line_number)
    unless line.match(/[[:space:]]\{/)
      "Line #{line_number + 1}: #{@error_type}there should be a space before opening curly bracket"
    end
  end

  def indentation_scan(line, line_number)
    num_of_spaces_found = line[/\A */].size
    unless num_of_spaces_found == 2
      ":Line #{line_number + 1}: #{@error_type}Inconsistent indentation detected.
       Expected 2, but found #{num_of_spaces_found} spaces instead."
    end
  end
end
