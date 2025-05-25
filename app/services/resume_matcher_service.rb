# app/services/resume_matcher_service.rb
class ResumeMatcherService
  attr_reader :job, :resume_text, :debug_info

  def initialize(job, resume)
    @job = job
    @resume = resume
    @resume_text = extract_text_from_resume(resume)
    @debug_info = {}

    # Add debugging information
    @debug_info[:resume_text_length] = @resume_text.length
    @debug_info[:resume_text_preview] = @resume_text[0..200]
    @debug_info[:job_description_length] = @job&.description&.length || 0
    @debug_info[:job_description_preview] = @job&.description&.[](0..200) || ""
  end

  def match_score
    return 0 if @resume_text.blank? || @job.description.blank?

    # Enhanced keyword matching with weighted scoring
    job_keywords = extract_keywords(@job.description.downcase)
    resume_keywords = extract_keywords(@resume_text.downcase)

    # Debug information
    @debug_info[:job_keywords] = job_keywords[0..10] # First 10 for debugging
    @debug_info[:resume_keywords] = resume_keywords[0..10] # First 10 for debugging
    @debug_info[:job_keywords_count] = job_keywords.size
    @debug_info[:resume_keywords_count] = resume_keywords.size

    return 0 if job_keywords.empty?

    # Calculate basic keyword match
    matching_keywords = job_keywords & resume_keywords
    matching_count = matching_keywords.size
    basic_match = (matching_count.to_f / job_keywords.size * 100).round

    # Debug information
    @debug_info[:matching_keywords] = matching_keywords[0..10]
    @debug_info[:matching_count] = matching_count
    @debug_info[:basic_match] = basic_match

    # Add bonus for skill matches
    skill_bonus = calculate_skill_bonus

    # Add bonus for experience keywords
    experience_bonus = calculate_experience_bonus

    # Debug information
    @debug_info[:skill_bonus] = skill_bonus
    @debug_info[:experience_bonus] = experience_bonus

    # Calculate final score with bonuses
    final_score = basic_match + skill_bonus + experience_bonus

    # Cap at 100%
    result = [ final_score, 100 ].min
    @debug_info[:final_score] = result

    result
  end

  def skill_matches
    return { matching: [], missing: [] } if @resume_text.blank? || @job.description.blank?

    # Extract skills from job description and resume
    job_skills = extract_skills(@job.description)
    resume_skills = extract_skills(@resume_text)

    # Debug information
    @debug_info[:job_skills] = job_skills
    @debug_info[:resume_skills] = resume_skills

    # Find matching and missing skills
    matching_skills = job_skills & resume_skills
    missing_skills = job_skills - resume_skills

    {
      matching: matching_skills.sort,
      missing: missing_skills.sort
    }
  end

  def detailed_analysis
    return {} if @resume_text.blank? || @job.description.blank?

    {
      match_score: match_score,
      skill_matches: skill_matches,
      keyword_density: calculate_keyword_density,
      experience_indicators: find_experience_indicators,
      recommendations: generate_recommendations,
      debug_info: @debug_info # Include debug info in detailed analysis
    }
  end

  private

  def extract_text_from_resume(resume)
    return "" if resume.nil?

    begin
      # Handle different types of file inputs
      if resume.respond_to?(:attached?) && resume.attached?
        # Active Storage attachment
        extract_text_from_attached_file(resume)
      elsif resume.respond_to?(:content_type)
        # Direct file upload (ActionDispatch::Http::UploadedFile)
        extract_text_from_uploaded_file(resume)
      elsif resume.is_a?(String)
        # Handle string input directly
        clean_text(resume)
      else
        ""
      end
    rescue => e
      Rails.logger.error "Error extracting resume text: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @debug_info[:extraction_error] = e.message
      ""
    end
  end

  def extract_text_from_attached_file(attachment)
    case attachment.content_type
    when "application/pdf"
      extract_text_from_pdf_blob(attachment)
    when "application/msword"
      extract_text_from_doc_blob(attachment)
    when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      extract_text_from_docx_blob(attachment)
    when "text/plain"
      text = attachment.download.force_encoding("UTF-8")
      clean_text(text)
    else
      Rails.logger.warn "Unsupported file type: #{attachment.content_type}"
      ""
    end
  end

  def extract_text_from_uploaded_file(file)
    case file.content_type
    when "application/pdf"
      extract_text_from_pdf_file(file.tempfile)
    when "application/msword"
      extract_text_from_doc_file(file.tempfile)
    when "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
      extract_text_from_docx_file(file.tempfile)
    when "text/plain"
      text = file.read.force_encoding("UTF-8")
      clean_text(text)
    else
      Rails.logger.warn "Unsupported file type: #{file.content_type}"
      ""
    end
  end

  def clean_text(text)
    return "" if text.nil?
    # Remove extra whitespace, normalize, and handle encoding issues
    text.to_s
        .gsub(/[^\x00-\x7F\u00A0-\u024F\u1E00-\u1EFF]/, "") # Keep basic Latin chars
        .gsub(/\s+/, " ")
        .strip
  end

  def extract_text_from_pdf_blob(pdf_blob)
    begin
      require "pdf-reader"

      # Download the blob content
      pdf_content = pdf_blob.download

      # Create a StringIO object for PDF::Reader
      pdf_io = StringIO.new(pdf_content)
      reader = PDF::Reader.new(pdf_io)

      text = ""
      reader.pages.each do |page|
        page_text = page.text
        text += page_text + "\n" if page_text
      end

      Rails.logger.info "Extracted #{text.length} characters from PDF blob"
      clean_text(text)
    rescue => e
      Rails.logger.error "PDF parsing error (blob): #{e.message}"
      @debug_info[:pdf_error] = e.message
      "PDF parsing failed: #{e.message}"
    end
  end

  def extract_text_from_pdf_file(pdf_file)
    begin
      require "pdf-reader"

      reader = PDF::Reader.new(pdf_file.path)
      text = ""
      reader.pages.each do |page|
        page_text = page.text
        text += page_text + "\n" if page_text
      end

      Rails.logger.info "Extracted #{text.length} characters from PDF file"
      clean_text(text)
    rescue => e
      Rails.logger.error "PDF parsing error (file): #{e.message}"
      @debug_info[:pdf_error] = e.message
      "PDF parsing failed: #{e.message}"
    end
  end

  def extract_text_from_docx_blob(docx_blob)
    begin
      require "docx"

      # Download the blob content to a temporary file
      temp_file = Tempfile.new([ "resume", ".docx" ])
      temp_file.binmode
      temp_file.write(docx_blob.download)
      temp_file.close

      doc = Docx::Document.open(temp_file.path)
      text = doc.paragraphs.map(&:text).join("\n")

      temp_file.unlink # Clean up temp file

      Rails.logger.info "Extracted #{text.length} characters from DOCX blob"
      clean_text(text)
    rescue => e
      Rails.logger.error "DOCX parsing error (blob): #{e.message}"
      @debug_info[:docx_error] = e.message
      "DOCX parsing failed: #{e.message}. Please try uploading as PDF or TXT."
    end
  end

  def extract_text_from_docx_file(docx_file)
    begin
      require "docx"

      doc = Docx::Document.open(docx_file.path)
      text = doc.paragraphs.map(&:text).join("\n")

      Rails.logger.info "Extracted #{text.length} characters from DOCX file"
      clean_text(text)
    rescue => e
      Rails.logger.error "DOCX parsing error (file): #{e.message}"
      @debug_info[:docx_error] = e.message
      "DOCX parsing failed: #{e.message}. Please try uploading as PDF or TXT."
    end
  end

  def extract_text_from_doc_blob(doc_blob)
    begin
      # For older DOC files, we'll use a simple approach or suggest alternatives
      Rails.logger.warn "DOC file detected - limited support"
      @debug_info[:doc_warning] = "DOC files have limited support"
      "DOC file detected. For better analysis, please convert to PDF, DOCX, or TXT format."
    rescue => e
      Rails.logger.error "DOC parsing error (blob): #{e.message}"
      @debug_info[:doc_error] = e.message
      "DOC parsing failed: #{e.message}. Please convert to PDF, DOCX, or TXT format."
    end
  end

  def extract_text_from_doc_file(doc_file)
    begin
      # For older DOC files, we'll use a simple approach or suggest alternatives
      Rails.logger.warn "DOC file detected - limited support"
      @debug_info[:doc_warning] = "DOC files have limited support"
      "DOC file detected. For better analysis, please convert to PDF, DOCX, or TXT format."
    rescue => e
      Rails.logger.error "DOC parsing error (file): #{e.message}"
      @debug_info[:doc_error] = e.message
      "DOC parsing failed: #{e.message}. Please convert to PDF, DOCX, or TXT format."
    end
  end

  def extract_keywords(text)
    return [] if text.blank?

    # Enhanced stopword list
    stopwords = %w[
      the and or but in on at to for of with by from a an is are was were
      be been being have has had do does did will would could should may might
      must can cannot this that these those i me my we us our you your he him
      his she her it its they them their there where when what who which how
      why very much many some any all both each every no not only also just
      then than so if because while since after before during through about
      above below between among within without across along around behind
      beside beyond inside outside over under upon against toward towards
      into onto off away back up down left right here now today yesterday
      tomorrow always never often sometimes usually rarely seldom already
      still yet again ever more most less least quite rather really actually
      certainly probably possibly perhaps maybe definitely absolutely
      completely entirely totally exactly precisely specifically particularly
      am pm inc ltd llc corp company years year month months week weeks day
      days email phone address street city state zip code www http https com
      org net edu gov parsing failed please try convert format upload
    ].to_set

    # Extract words and clean them - improved regex
    words = text.gsub(/[^\w\s+#.-]/, " ")
                .split(/\s+/)
                .map(&:strip)
                .reject(&:blank?)
                .map(&:downcase)
                .reject { |word| word.length < 2 || stopwords.include?(word) }
                .reject { |word| word.match?(/^\d+$/) } # Remove pure numbers
                .reject { |word| word.match?(/^[^\w]+$/) } # Remove non-word characters

    # Also extract common tech phrases
    tech_phrases = extract_tech_phrases(text)

    (words + tech_phrases).uniq
  end

  def extract_tech_phrases(text)
    # Common multi-word technical terms
    phrases = [
      "machine learning", "artificial intelligence", "data science", "web development",
      "software development", "full stack", "front end", "back end", "ui/ux",
      "user experience", "user interface", "project management", "agile development",
      "test driven development", "continuous integration", "continuous deployment",
      "version control", "database design", "system architecture", "cloud computing",
      "mobile development", "responsive design", "cross platform", "real time",
      "big data", "data analysis", "business intelligence", "quality assurance",
      "software engineering", "computer science", "information technology",
      "digital marketing", "social media", "content management", "e commerce",
      "ruby on rails", "node js", "react js", "vue js", "angular js"
    ]

    found_phrases = []
    phrases.each do |phrase|
      if text.downcase.include?(phrase.downcase)
        found_phrases << phrase.gsub(" ", "_") # Replace spaces with underscores for consistency
      end
    end

    found_phrases
  end

  def extract_skills(text)
    return [] if text.blank?

    # Skip skill extraction if text indicates parsing failure
    if text.downcase.include?("parsing failed") || text.downcase.include?("please convert")
      @debug_info[:skill_extraction_skipped] = "Skipped due to parsing failure"
      return []
    end

    # Comprehensive and updated skill list - organized by category
    programming_languages = [
      "ruby", "rails", "javascript", "html", "css", "sql", "python", "java",
      "c++", "c#", "php", "swift", "kotlin", "go", "rust", "typescript", "scala",
      "r", "matlab", "perl", "dart", "elixir", "haskell", "clojure", "objective-c"
    ]

    frontend_skills = [
      "react", "vue", "angular", "svelte", "ember", "backbone", "jquery",
      "bootstrap", "tailwind", "material-ui", "ant-design", "chakra-ui",
      "sass", "less", "webpack", "parcel", "vite", "next.js", "nuxt.js"
    ]

    backend_skills = [
      "node", "nodejs", "express", "django", "flask", "fastapi", "spring",
      "laravel", "symfony", "codeigniter", "asp.net", "sinatra", "koa",
      "nestjs", "ruby on rails", "rails"
    ]

    database_skills = [
      "postgresql", "mysql", "mongodb", "redis", "sqlite", "oracle",
      "cassandra", "elasticsearch", "neo4j", "dynamodb", "firestore",
      "mariadb", "couchdb", "influxdb"
    ]

    cloud_devops = [
      "aws", "azure", "google cloud", "gcp", "docker", "kubernetes",
      "jenkins", "gitlab", "github", "devops", "ci/cd", "terraform",
      "ansible", "puppet", "chef", "vagrant", "serverless", "lambda",
      "heroku", "netlify", "vercel"
    ]

    testing_qa = [
      "rspec", "jest", "mocha", "selenium", "cypress", "unit testing",
      "tdd", "bdd", "integration testing", "end-to-end testing",
      "pytest", "junit", "testng", "karma", "jasmine"
    ]

    tools_platforms = [
      "git", "jira", "confluence", "slack", "figma", "sketch", "photoshop",
      "illustrator", "invision", "zeplin", "notion", "trello", "asana",
      "linear", "clickup", "monday", "basecamp"
    ]

    technical_concepts = [
      "api", "rest", "graphql", "microservices", "responsive design",
      "ui/ux", "machine learning", "artificial intelligence", "data analysis",
      "data science", "blockchain", "web3", "cryptography", "security",
      "oauth", "jwt", "websockets", "grpc", "soap"
    ]

    mobile_skills = [
      "ios", "android", "react native", "flutter", "xamarin", "cordova",
      "ionic", "phonegap", "swift", "kotlin", "objective-c"
    ]

    data_analytics = [
      "tableau", "power bi", "excel", "google analytics", "sql server",
      "data visualization", "statistical analysis", "pandas", "numpy",
      "matplotlib", "seaborn", "plotly", "d3.js", "looker"
    ]

    soft_skills = [
      "leadership", "teamwork", "communication", "problem solving",
      "analytical", "creative", "detail oriented", "time management",
      "project management", "customer service", "sales", "marketing"
    ]

    # Combine all skills
    all_skills = programming_languages + frontend_skills + backend_skills +
                 database_skills + cloud_devops + testing_qa + tools_platforms +
                 technical_concepts + mobile_skills + data_analytics + soft_skills

    # Find skills mentioned in the text with improved matching
    found_skills = []

    all_skills.each do |skill|
      # Handle multi-word skills and variations
      skill_variations = [ skill ]

      # Add common variations
      case skill
      when "javascript"
        skill_variations += [ "js", "ecmascript" ]
      when "typescript"
        skill_variations += [ "ts" ]
      when "ruby on rails"
        skill_variations += [ "rails", "ror" ]
      when "node", "nodejs"
        skill_variations += [ "node.js", "node", "nodejs" ]
      when "react"
        skill_variations += [ "reactjs", "react.js" ]
      when "vue"
        skill_variations += [ "vuejs", "vue.js" ]
      when "angular"
        skill_variations += [ "angularjs" ]
      end

      # Check each variation
      skill_variations.each do |variation|
        if variation.include?(" ")
          # Multi-word skill - check for phrase
          if text.downcase.include?(variation.downcase)
            found_skills << skill
            break
          end
        else
          # Single word - check with word boundaries
          if text.downcase.match?(/\b#{Regexp.escape(variation.downcase)}\b/)
            found_skills << skill
            break
          end
        end
      end
    end

    found_skills.uniq
  end

  def calculate_skill_bonus
    skill_data = skill_matches
    matching_count = skill_data[:matching].size

    # Award bonus points for skill matches
    case matching_count
    when 0
      0
    when 1..2
      3
    when 3..5
      8
    when 6..8
      15
    when 9..12
      20
    else
      25
    end
  end

  def calculate_experience_bonus
    experience_keywords = [
      "years experience", "years of experience", "year experience", "year of experience",
      "experienced", "expert", "senior", "lead", "manager", "director",
      "architect", "principal", "staff", "specialist", "professional"
    ]

    bonus = 0
    experience_keywords.each do |keyword|
      if @resume_text.downcase.include?(keyword.downcase)
        bonus += 2
      end
    end

    # Additional bonus for specific experience mentions
    years_matches = @resume_text.scan(/(\d+)\+?\s*years?\s*(of\s*)?(experience|exp)/i)
    unless years_matches.empty?
      bonus += 5
    end

    # Cap experience bonus
    [ bonus, 15 ].min
  end

  def calculate_keyword_density
    job_keywords = extract_keywords(@job.description.downcase)
    resume_keywords = extract_keywords(@resume_text.downcase)

    return 0 if resume_keywords.empty?

    matching_count = (job_keywords & resume_keywords).size
    (matching_count.to_f / resume_keywords.size * 100).round(2)
  end

  def find_experience_indicators
    indicators = []

    # Look for years of experience with improved regex
    years_matches = @resume_text.scan(/(\d+)\+?\s*years?\s*(of\s*)?(experience|exp)/i)
    years_matches.each do |match|
      indicators << "#{match[0]} years of experience mentioned"
    end

    # Look for education
    education_keywords = [ "degree", "bachelor", "master", "phd", "diploma", "certification", "certified" ]
    education_keywords.each do |keyword|
      if @resume_text.downcase.include?(keyword)
        indicators << "Education: #{keyword} mentioned"
      end
    end

    # Look for job titles
    title_keywords = [ "developer", "engineer", "analyst", "manager", "director",
                     "lead", "senior", "junior", "associate", "specialist", "architect" ]
    found_titles = title_keywords.select { |title| @resume_text.downcase.include?(title) }
    found_titles.each do |title|
      indicators << "Job title: #{title} mentioned"
    end

    indicators.uniq
  end

  def generate_recommendations
    recommendations = []
    score = match_score
    skill_data = skill_matches

    # Handle cases where file parsing failed
    if @resume_text.downcase.include?("parsing failed") || @resume_text.downcase.include?("please convert")
      recommendations << "Unable to analyze resume content. Please try uploading as PDF or TXT format."
      recommendations << "Ensure your file is under 5MB and not password protected."
      return recommendations
    end

    if score >= 70
      recommendations << "Excellent match! Your resume aligns well with the job requirements."
      recommendations << "Consider applying soon as you're a strong candidate."
    elsif score >= 50
      recommendations << "Good match! You have relevant skills for this position."
      if skill_data[:missing].any?
        missing_skills = skill_data[:missing].first(3).join(", ")
        recommendations << "Consider highlighting experience with: #{missing_skills} in your cover letter."
      end
    elsif score >= 30
      recommendations << "Moderate match. Focus on transferable skills and relevant experience."
      if skill_data[:matching].any?
        matching_skills = skill_data[:matching].first(3).join(", ")
        recommendations << "Emphasize your experience with: #{matching_skills}"
      end
    else
      recommendations << "This role may be challenging, but transferable skills can be valuable."
      recommendations << "Focus on highlighting your adaptability and willingness to learn."
      if skill_data[:matching].any?
        recommendations << "Emphasize your experience with: #{skill_data[:matching].join(', ')}"
      end
    end

    # Additional specific recommendations
    if skill_data[:missing].size > skill_data[:matching].size * 2
      recommendations << "Consider taking online courses to build missing technical skills."
    end

    if @resume_text.length < 500 && !@resume_text.downcase.include?("parsing failed")
      recommendations << "Your resume appears brief. Consider adding more detail about your experience and achievements."
    end

    # Debug recommendation for development
    if Rails.env.development? && @debug_info[:matching_count] == 0
      recommendations << "[DEBUG] No keyword matches found. Check if resume text is being extracted properly."
    end

    recommendations
  end
end
