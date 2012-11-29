class EvilPdf
  require 'open-uri'
  require 'pdfkit'
  attr_reader :file_handle
  
  def initialize(record, options = {})
    @record = record
    @options = options
    Dir.mkdir './tmp' unless Dir.exists? './tmp'
    self.class.handle_asynchronously :from_urls if options[:async]
  end
  
  def from_urls(urls)
    @tmp_files = []
    urls.each_with_index do |url, i|
      retrieve(url) and generate(i)
    end
    combine
    
    if @options[:async]
      @record.update_attributes :pdf => file_handle
    else
      file_handle
    end
  end
  
  def to_file(name)
    PDFKit.new(@html, @options).to_file name
  end
  
  def file_handle
    @file_handle ||= File.open file_path, 'r'
  end
  
  def file_path
    @file_path ||= "./tmp/#{@record.name.parameterize}-#{Time.now.to_i}.pdf"
  end
  
  private
  
  def retrieve(url)
    @html = open(url).read
  rescue OpenURI::HTTPError => e
    @record.errors.add :pdf, "HTTPError #{e.message}: #{url}"
    false
  end
  
  def generate(i)
    tmp = "./tmp/partial-#{Time.now.to_i}-#{i}.pdf"
    to_file tmp
    @tmp_files << tmp
  end
  
  # using ghostscript to combine multiple pdfs into 1
  def combine
    gs_opts = "-q -dNOPAUSE -sDEVICE=pdfwrite"
    gs_cmd = "gs #{gs_opts} -sOutputFile=#{file_path} -dBATCH #{@tmp_files.join(' ')}"
    Rails.logger.debug "Combining PDFs: #{gs_cmd}"
    system gs_cmd
  end
end
