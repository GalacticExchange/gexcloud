
#todo this is not good..

def get_editor(filename)
  tmpfile = xpull(filename, $container)
  editor = FileEdit.new tmpfile
  $editors.push([editor, filename])
  editor
end

def xpull(filename, container = nil)
  return filename if container.nil?

  tmpfile = BashUtils.get_tmp_name(filename, container)
  BashUtils.dcp_reverse(container, filename, tmpfile)
  tmpfile
end

def dexec(command, c = nil)
  c = $container if c == nil
  assert_nnil c, 'Nil container'
  assert_nnil command, 'Nil command '
  texec "docker exec -t #{c}  #{command}", true
end

def get_value(name)
  'get_value_test'
end

class Object
  include AssertUtils
  include BashUtils
end