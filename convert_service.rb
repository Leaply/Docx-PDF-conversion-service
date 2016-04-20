require 'sinatra'
require 'pry'
require 'tilt/erubis'
SOFFICE_PATH = 'soffice'

set :bind, '0.0.0.0'
set :port, 8080

# FOR MAC TESTING:
# SOFFICE_PATH = '/Applications/LibreOffice.app/Contents/MacOS/soffice'

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

  puts 'temp path is '+in_pdf
  # /var/folders/tm/w_dnm6b92cv2rpb3hykdxksm0000gn/T/RackMultipart20160331-50669-1l0wp4z.pdf
  # binding.pry
  tmp_file_name = libreoffice_instance = rand(36**8).to_s(36)

  if file_extention.downcase == 'pdf'
    # If we receive a PDF, it's probably because it's encrypted or has layers. Ghostscript can decrypt it for us.


    # pry

    system "gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=#{pwd}/converted/#{tmp_file_name}.pdf #{params[:datafile][:tempfile].path}"
    # system "gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=/Users/constantmeiring/Desktop/#{tmp_file_name}.pdf -c .setpdfwrite -f #{params[:datafile][:tempfile].path}"

    in_pdf = "#{pwd}/converted/#{tmp_file_name}.pdf"
    puts 'temp path updated to '+in_pdf
  end

  # system "#{SOFFICE_PATH} --headless --convert-to pdf #{in_pdf} --outdir converted"

  system "#{SOFFICE_PATH} --headless \"-env:UserInstallation=file:///tmp/LibreOffice_Conversion_${libreoffice_instance}\" --convert-to pdf:writer_pdf_Export #{in_pdf} --outdir converted"

  File.rename(in_pdf, "converted/#{file_basename}.pdf")
  send_file "converted/#{file_basename}.pdf", filename: "#{file_basename}.pdf", type: 'application/pdf', disposition: 'inline'#, :disposition => 'attachment'
end
