resources = []

# Rename for Unix compatibility and add files to list of resources
Dir.glob('**/*').each do |file|
  if file == 'prep_resources.rb'
    next
  end

  if file != file.downcase
    File.rename(file, file.downcase)
  end

  if not File.directory?(file)
    resources.push(file)
  end
end

File.open('../gamemode/gmcmodules/_gen/sv_resources.lua', 'w') { |file|
  file.puts '-- Automatically generated resource file. See content/prep_resources.rb'
  resources.each do |res|
    file.puts 'resource.AddFile("' + res + '")'
  end
}