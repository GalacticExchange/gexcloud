class FrameworkTemplates

  def self.process_template_trees(app_dir, processor, container)
    BashUtils.texec("mkdir -p /tmp/#{container}")
    process_template_tree('general/common', processor, container)
    process_template_tree(app_dir, processor, container)
  end

  def self.process_template_tree(app_dir, processor, container)
    puts "Processing tree  #{app_dir}"
    t_dir = File.join(GIT_DIR, app_dir, 'templates')
    processor.process_template_tree(t_dir, container)
  end

end


