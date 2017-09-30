require 'erb'
require 'fileutils'


# $Id$

# Global processor
$processor = nil

# File editors

$editors = []

BOOTSTRAP = '/etc/bootstrap.sh'


def get_editor(filename)
  tmpfile = xpull(filename, $container)
  editor = FileEdit.new tmpfile
  $editors.push([editor, filename])
  editor
end


def get_processor
  return ERBProcessor.new($vars)
end


def commit_edits
  $editors.each do |entry|
    entry[0].write_file
    xpush entry[1], $container
  end
  $editors = []
end

class ERBProcessor

  def initialize(hash)
    raise ArgumentError, 'hash must be a Hash object' unless hash.is_a?(::Hash)
    hash.each do |key, value|
      unless key.to_s.include? '.'
        instance_variable_set :"@#{key}", value
      end
    end
  end

  def erb_process_string(template)
    unless template.include? '<'
      return template
    end

    begin
      processor = ERB.new(template, nil, '-')
      return processor.result(binding)
    rescue Exception => e
      rethrow e, "Could not process template #{template}"
    end
  end


  def erb_process_file(dest_file, contents)
    begin
      final = erb_process_string(contents)
    rescue Exception => e
      rethrow e, "Could not process file #{dest_file} \n #{contents}"
    end
    IO.write(dest_file, final)
    return final
  end


  def iterate_over_tree(template_dir, extension, parallel = false)
    assert extension.include? '.'
    assert_dir template_dir

    entries = Dir.glob(template_dir + "/**/*#{extension}").sort

    if parallel
      Parallel.each(entries) do
      |entry|
        yield(entry)
      end
    else
      entries.each do |entry|
        yield(entry)
      end
    end
  end


  def process_remove_file(file, container: nil)
    #dest_file = process_erb_filename file
    dest_file = erb_process_string(file)
    xexec "rm -f #{dest_file}", container
  end

  def process_remove_plain(file, container: nil)
    xexec "rm -f #{file}", container
  end


  def process_remove_dir(dir, container: nil)
    dir = erb_process_string dir
    xexec "rm -rf #{dir}"
  end


  def process_template_file(file, t_dir, container = nil, contents: nil, is_plain: false, destination: nil)

    dest_file = get_destination_file_name(file, t_dir)

    if is_plain

      destination.nil? ? dest_file = dest_file.chomp('.plain') :
          dest_file = destination

      copy_plain_file_and_set_permissions(file, dest_file, container)
    else
      destination.nil? ? dest_file = dest_file.chomp('.erb') :
          dest_file = destination

      transform_erb_file_and_set_permissions(file, dest_file, contents, container)
    end
  end

  def transform_erb_file_and_set_permissions(file, dest_file, contents, container)

    contents = IO.read(file) if contents.nil?


    container.nil? ? target_file = dest_file :
        target_file = get_tmp_name(dest_file)

    erb_process_file target_file, contents


    xcp target_file, dest_file, container

    set_permissions dest_file, contents, container
  end

  def copy_plain_file_and_set_permissions(file, dest_file, container)
    dest_file = dest_file.chomp('.plain')
    xcp file, dest_file, container

    perm_file = file.chomp('.plain') + '.acl'
    File.exists?(perm_file) ? contents = IO.read(perm_file) :
        contents = ''
    set_permissions dest_file, contents, container, plain: true
    return contents, dest_file
  end

  def get_destination_file_name(file, t_dir)
    relative_file = file.dup

    relative_file.slice!(t_dir)

    return erb_process_string relative_file
  end

  def process_template_plain(dest_file, t_dir, container = nil, contents: nil)
    process_template_file(dest_file, t_dir, container, contents: contents, is_plain: true)
  end

  def process_template_dir(dir, t_dir, container = nil, contents: nil)

    if contents.nil?
      contents = IO.read(dir)
    end

    dir = dir.chomp('/_dir.erb')

    dest_dir = get_destination_file_name(dir, t_dir)

    xexec "mkdir -p #{dest_dir}", container

    set_permissions(dest_dir, contents, container)
  end

  def process_template_iterate (template_file, t_dir, container = nil, contents: nil)

    if contents.nil?
      contents = IO.read(template_file)
    end

    puts "Processing iteration #{template_file}"

    template_file = template_file.chomp(".iterate")

    ext = File.extname(template_file)

    file = template_file.chomp(ext)

    unless var_exists?(ext)
      return
    end


    get_array(ext).each do |item|
      instance_variable_set :'@item', item
      e = file.extname(f)

      if e == 'erb'
        (file.end_with? '/_dir.erb') ?
            process_template_dir(file.chomp('/dir'), t_dir, container, contents: contents) :
            process_template_file(file, t_dir, container, contents: contents)
      elsif e == 'plain'
        process_plain_file template_file, t_dir, container, contents: contents
      elsif e != 'erb'
        throw Exception.new 'Illegal file name item'
      end
      remove_instance_variable :'@item'
    end
  end

  def process_remove_iterate (file, t_dir, container: nil)
    puts "Processing remove iterate #{file}"

    ext = File.extname(file)

    file = s.chomp('.' + ext)

    unless var_exists?(ext)
      return
    end

    get_array(ext).each do |item|
      instance_variable_set :'@item', item
      e = file.extname(f)
      file = file.chomp ('.' + ext)

      if e == 'erb'
        (file.end_with? '/_dir') ?
            process_remove_dir(file.chomp('/dir'), container) :
            process_remove_file(file, container)
      elsif e == 'plain'
        process_remove_plain file, container
      elsif e != 'erb'
        throw Exception.new 'Illegal file name item'
      end
      remove_instance_variable :'@item'
    end
  end


  ERB_L = '<%#'
  ERB_R = '%>'
  ERB_COMMENT_MATCH = /<%#.*%>/

  $perms = ""

  def commit_perms

  end

  def set_permissions(file, contents, container = nil, plain: false)
    if plain
      if contents == ''
        return
      end
      permissions = contents.strip
    else
      p = contents.lines.first
      return if p.nil?
      comment = p[ERB_COMMENT_MATCH]
      return if comment.nil?
      permissions = comment[ERB_L.length .. -(ERB_R.length + 1)].strip
    end

    tokens = permissions.split(':')
    unless tokens[0]== "root" && tokens[1] == "root"
      xexec "chown #{tokens[0]}:#{tokens[1]} #{file}", container
    end

    xexec "chmod #{tokens[2]} #{file}", container
  end


  def process_configure_scripts(t_dir, container = nil)


    configure = "#{t_dir}/configure.rb"

    if File.exists? configure
      puts "Processing configure for #{$container}"
      require configure
      commit_edits
    else
      puts "No configure for #{$container}"
    end

    first_run_script = "#{t_dir}/first_run.rb"

    if File.exists? first_run_script
      puts "Processing first run for #{$container}"
      require first_run_script
    else
      puts "No first run for #{$container}"
    end
  end

  def process_template_trees(t_dirs, container = nil)
    t_dirs.each do |t_dir|
      process_template_tree(t_dir, container)
    end
  end

  def process_template_tree(t_dir, container = nil)

    assert_dir t_dir

    puts "\n\n Processing template tree #{t_dir} \n\n"

    puts "\n\n Processing directories\n\n"

    iterate_over_tree(t_dir, '/_dir.erb', true) do |entry|
      process_template_dir entry, t_dir, container
    end

    puts "\n\n Processing iteration files\n\n"

    iterate_over_tree(t_dir, '.iterate') do |entry|
      process_template_iterate entry, t_dir, container
    end


    puts "\n\n Processing ERB files\n\n"

    iterate_over_tree(t_dir, '.erb', true) do |entry|
      process_template_file(entry, t_dir, container) unless entry.end_with?('_dir.erb')
    end

    puts "\n\n Processing plain files\n\n"

    iterate_over_tree(t_dir, '.plain', true) do |entry|
      process_template_plain entry, t_dir, container
    end


    process_configure_scripts(t_dir, container)

  end


  def remove_template_tree(t_dir, container: nil)
    assert_dir t_dir

    iterate_over_tree(t_dir, '.iterate') do |entry|
      process_remove_iterate entry, t_dir, container
    end

    iterate_over_tree(t_dir, '.erb') do |target|
      #container = 'nil' if container.nil?
      target.slice! t_dir
      process_remove_file target, container: container unless target.end_with? '/_dir.erb' #, container
    end

    iterate_over_tree(t_dir, '.plain') do |target|
      target.slice! t_dir
      process_remove_plain target, container
    end

    iterate_over_tree(t_dir, '/_dir.erb') do |target|
      target.slice! t_dir
      process_remove_dir target, container: container
    end
  end

end


