module BashUtils
  extend self

  def texec(cmd, checkreturn = true)
    puts cmd
    result = `#{cmd}`
    if $?.success? || $?.exitstatus == 129
      return result;
    else
      if checkreturn
        throw Exception.new "#{cmd} returned status #{$?.exitstatus}, #{result}"
      end
    end
  end


  def dcp(src, dst, container, checkreturn = true)
    AssertUtils.assert !dst.include?('hadoop-master')
    AssertUtils.assert !dst.include?('hue-master')
    texec "docker cp '#{src}' '#{container}:#{dst}'", checkreturn
  end


  def xpush(filename, container = nil)
    return filename if container.nil?

    tmpfile = get_tmp_name(filename, container)
    AssertUtils.assert_file(tmpfile)
    dcp(tmpfile, filename, container)

  end

  def xexec(command, container = nil)
    if container
      command = command.split(' ')
      Docker::Container.get(container).exec(command)
    else
      texec command
    end
  end

  def xcp(src, dst, container = nil)
    if container
      texec "docker cp #{src} #{container}:#{dst}"
    else
      return if src == dst
      texec "cp -f #{src} #{dst}"
    end
  end

  def get_tmp_name(filename, container)
    AssertUtils.assert (!filename.end_with? '/'), "Path ends with slash #{filename}"
    File.join("/tmp/#{container}", filename.gsub('/', '_'))
  end

  def dcp_reverse(container, src, dst)
    texec "docker cp #{container}:#{src} #{dst}"
  end

end