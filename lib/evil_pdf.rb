class EvilPdf
  require 'open-uri'
  attr_reader :file_handle
  
  def initialize(name, options = {})
    @record = PdfRecord.create :name => name
    @options = options
    Dir.mkdir './tmp' unless Dir.exists? './tmp'
  end
  
  def from_urls(urls)
    if @options[:async]
      delay.from_urls_without_delay
    else
      from_urls_without_delay
    end
  end
  
  def from_urls_without_delay
    @tmp_files = []
    urls.each_with_index do |url, i|
      retrieve(url) and generate(i)
    end
    combine
    @record.update_attributes :pdf => file_handle
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
    Rails.logger.debug "Combining PDFs: #{gs_cmd}" if defined? Rails
    system gs_cmd
  end
  
  def self.enable_delayed
    class_eval do
      handle_asynchronously :from_urls
    end
  end
end
