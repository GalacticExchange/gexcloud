module AssertUtils
  extend self

  def assert(expression, string = 'Assert failed')
    unless expression
      throw Exception.new string
    end
  end

  def assert_file(file)
    assert (File.exist? file), "File #{file} does not exist"
    file
  end

  def assert_dir(dir)
    assert (Dir.exist?(dir) && !dir.end_with?('/')), "Dir #{dir} does not exist"
    dir
  end

  #TODO !!!
  def assert_nnil(*objects)
    #objects.each do |object|
    #  assert (!object.nil?), "Nil parameter, #{objects.inspect}"
    #end
    #objects[0]
    'NOT_NIL_TEST'
  end

end