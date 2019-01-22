get "/blog/	?*" do
	authorized?
  jekyll_blog(request.path) {404}
end

def jekyll_blog(path, &missing_file_block)
  file_path = File.join(File.dirname(__FILE__), '../jekyll/_site',  path.gsub('/blog',''))
  file_path = File.join(file_path, 'index.html') unless file_path =~ /\.[a-z]+$/i  

  if File.exist?(file_path)
    file = File.open(file_path, "rb")
    contents = file.read
    file.close

    if (file_path.include?('.xml') || file_path.include?('.css'))
      erb contents, :content_type => 'text/xml', :layout => false
    else
      erb contents, :layout_engine => :erb, :layout => true
    end
  else
      erb "#{contents} " , :layout => false
  end
end
