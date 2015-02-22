Dir.glob("./**/*").each do |file|
  if file != file.downcase
  	File.rename(file, file.downcase)
  end
end