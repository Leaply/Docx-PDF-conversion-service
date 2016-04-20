require 'sinatra'
require 'pry'
require 'tilt/erubis'
SOFFICE_PATH = 'soffice'

set :bind, '0.0.0.0'
set :port, 8080
set :logging, true
set :dump_errors, true
set :raise_errors, true
# FOR MAC TESTING:
# SOFFICE_PATH = '/Applications/LibreOffice.app/Contents/MacOS/soffice'

configure do
  enable :logging
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

get '/' do
  erb :index
end

post '/convert' do
  pwd = `pwd`[0..-2]
  puts 'starting conversion'
	File.open('uploads/' + params[:datafile][:filename], "w") do |f|
	 f.write(params[:datafile][:tempfile].read)
  end

  file_extention = File.extname( params[:datafile][:filename] )
  file_basename = File.basename( params[:datafile][:filename], file_extention)

  tmp_file_extention = File.extname( params[:datafile][:tempfile].path )
  tmp_file_basename = File.basename( params[:datafile][:tempfile].path, file_extention)

  in_pdf = params[:datafile][:tempfile].path

  logger.info 'temp path is '+in_pdf

  tmp_file_name = libreoffice_instance = rand(36**8).to_s(36)

  if file_extention.downcase === 'pdf' || file_extention.downcase === '.pdf'
    logger.info 'Ghostscript PDF to PDF conversion started'
    # If we receive a PDF, it's probably because it's encrypted or has layers. Ghostscript can decrypt it for us.

    system "gs -sDEVICE=pdfwrite -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sColorConversionStrategy=/LeaveColorUnchanged -dAutoFilterColorImages=true -dAutoFilterGrayImages=true -dDownsampleMonoImages=true -dDownsampleGrayImages=true -dDownsampleColorImages=true -sOutputFile=#{pwd}/converted/#{tmp_file_basename}.pdf #{params[:datafile][:tempfile].path}"
    # system "gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/Users/constantmeiring/Desktop/#{tmp_file_name}.pdf -c .setpdfwrite -f #{params[:datafile][:tempfile].path}"

    in_pdf = "#{pwd}/converted/#{tmp_file_name}.pdf"
    logger.info 'temp path updated to '+in_pdf
  end

  system "#{SOFFICE_PATH} soffice --headless  -env:UserInstallation=file:///tmp/#{libreoffice_instance} --convert-to pdf:writer_pdf_Export #{in_pdf} --outdir converted"

  File.rename("converted/#{tmp_file_basename}.pdf", "converted/#{file_basename}.pdf")
  send_file "converted/#{file_basename}.pdf", filename: "#{file_basename}.pdf", type: 'application/pdf', disposition: 'inline'#, :disposition => 'attachment'
end
