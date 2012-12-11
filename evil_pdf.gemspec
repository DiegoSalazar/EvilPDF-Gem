Gem::Specification.new do |s|
  s.name = %q{evil_pdf}
  s.version = "0.0.3"
  s.has_rdoc = true
  s.required_ruby_version = "~> 1.9.2"
  s.platform = "ruby"
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 0"
  s.add_dependency 'pdfkit'
  s.add_dependency 'pdfkit-heroku'
  s.author = "Diego Salazar"
  s.email = %q{diego@pixelheadstudio.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.summary = %q{Generate a PDF from an array of URLs}
  s.homepage = %q{https://github.com/DiegoSalazar/EvilPDF-Gem/}
  s.description = %q{Generate a PDF from an array of URLs}
  s.files = ["lib/evil_pdf.rb"]
end