class Editor
  attr_reader :lines

  def initialize(lines)
    @lines = lines.to_a.clone
  end

  def append_line_after(search, line_to_append)
    lines = []

    @lines.each do |line|
      lines << line
      lines << line_to_append if line.match(search)
    end

    (lines.length - @lines.length).tap { @lines = lines }
  end

  def append_line_if_missing(search, line_to_append)
    count = 0

    unless @lines.find { |line| line.match(search) }
      count = 1
      @lines << line_to_append
    end

    count
  end

  def remove_lines(search)
    count = 0

    @lines.delete_if do |line|
      count += 1 if line.match(search)
    end

    count
  end

  def replace(search, replace)
    count = 0

    @lines.map! do |line|
      if line.match(search)
        count += 1
        line.gsub!(search, replace)
      else
        line
      end
    end

    count
  end

  def replace_lines(search, replace)
    count = 0

    @lines.map! do |line|
      if line.match(search)
        count += 1
        replace
      else
        line
      end
    end

    count
  end
end

class FileEdit

  private

  attr_reader :editor, :original_pathname

  public

  def initialize(filepath)
    raise ArgumentError, "File '#{filepath}' does not exist" unless File.exist?(filepath)
    @editor = Editor.new(File.open(filepath, &:readlines))
    @original_pathname = filepath
    @file_edited = false
  end

  # return if file has been edited
  def file_edited?
    @file_edited
  end

  #search the file line by line and match each line with the given regex
  #if matched, replace the whole line with newline.
  def search_file_replace_line(regex, newline)
    @changes = (editor.replace_lines(regex, newline) > 0) || @changes
  end

  #search the file line by line and match each line with the given regex
  #if matched, replace the match (all occurrences)  with the replace parameter
  def search_file_replace(regex, replace)
    @changes = (editor.replace(regex, replace) > 0) || @changes
  end

  #search the file line by line and match each line with the given regex
  #if matched, delete the line
  def search_file_delete_line(regex)
    @changes = (editor.remove_lines(regex) > 0) || @changes
  end

  #search the file line by line and match each line with the given regex
  #if matched, delete the match (all occurrences) from the line
  def search_file_delete(regex)
    search_file_replace(regex, '')
  end

  #search the file line by line and match each line with the given regex
  #if matched, insert newline after each matching line
  def insert_line_after_match(regex, newline)
    @changes = (editor.append_line_after(regex, newline) > 0) || @changes
  end

  #search the file line by line and match each line with the given regex
  #if not matched, insert newline at the end of the file
  def insert_line_if_no_match(regex, newline)
    @changes = (editor.append_line_if_missing(regex, newline) > 0) || @changes
  end

  def unwritten_changes?
    !!@changes
  end

  #Make a copy of old_file and write new file out (only if file changed)
  def write_file
    if @changes
      backup_pathname = original_pathname + '.old'
      FileUtils.cp(original_pathname, backup_pathname, :preserve => true)
      File.open(original_pathname, 'w') do |newfile|
        editor.lines.each do |line|
          newfile.puts(line)
        end
        newfile.flush
      end
      @file_edited = true
    end
    @changes = false
  end
end

def delete_string_matches (file, match)
  FileEdit.new(file).search_file_delete("^.*#{match}.*$")
end


def create_file_with_lines(filename, lines)
  assert_nnil lines
  assert_path(filename)
  File.open(filename, 'w+') do |file|
    lines.each do |line|
      file.puts line
    end
  end
end

def append_file_with_lines(filename, *lines)
  assert_nnil filename, lines
  assert_path(filename)
  File.open(filename, 'a+') do |file|
    lines.each do |line|
      file.puts line
    end
  end
end

def echo_create (s, file_name)
  texec %Q(echo "#{s}" > #{file_name})
end

def echo_append (s, file_name)
  texec %Q(echo "#{s}" >> #{file_name})
end

def save_info (index, file_name)
  save_general_info ARGV[index], file_name
end

def save_general_info (s, file_name)
  texec %Q(echo "#{s}" > #{NODE_INFO_DIR}/#{file_name})
end

def save_container_info(info, file_name, c)
  texec %Q(echo "#{info}" > #{CONTAINER_DIR}/#{c}/#{file_name})
end

def get_info (file_name)
  IO.read("#{NODE_INFO_DIR}/#{file_name}").strip
end

def get_container_info(file_name, c)
  return IO.read("#{CONTAINER_DIR}/#{c}/#{file_name}").strip
end

def get_version_from_file(file_contents)
  file_contents.each_line do |line1|
    cleaned = line1.delete(' ')
    if cleaned.index('version=') >= 0
      version = cleaned['version='.length .. cleaned.length - 2]
      return version
    end
  end
  nil
end