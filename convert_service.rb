require 'sinatra'
require 'pry'
require 'tilt/erubis'
SOFFICE_PATH = 'soffice'

# FOR MAC TESTING:
# SOFFICE_PATH = '/Applications/LibreOffice.app/Contents/MacOS/soffice'

get '/' do
  erb :index
end

post '/convert' do
	File.open('uploads/' + params[:datafile][:filename], "w") do |f|
	 f.write(params[:datafile][:tempfile].read)
  end

  file_extention = File.extname( params[:datafile][:filename] )
  file_basename = File.basename( params[:datafile][:filename], file_extention)

  tmp_file_extention = File.extname( params[:datafile][:tempfile].path )
  tmp_file_basename = File.basename( params[:datafile][:tempfile].path, file_extention)

  system "#{SOFFICE_PATH} --headless --convert-to pdf #{params[:datafile][:tempfile].path} --outdir converted"
  File.rename("converted/#{tmp_file_basename}.pdf", "converted/#{file_basename}.pdf")

  send_file "converted/#{file_basename}.pdf", filename: "#{file_basename}.pdf"
end