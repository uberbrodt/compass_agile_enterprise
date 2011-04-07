class ErpApp::Desktop::Knitkit::VersionsController < ErpApp::Desktop::Knitkit::BaseController
  #content

  def content_versions
    Content::Version.include_root_in_json = false

    content = Content.find(params[:id])
    website = Website.find(params[:site_id])
    sort  = params[:sort] || 'version'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 15
    start = params[:start] || 0

    versions = content.versions.find(:all, :order => "#{sort} #{dir}", :offset => start, :limit => limit)

    Content::Version.class_exec(website) do
      @@website = website
      def published
        published_site_id = @@website.active_publication.id
        !PublishedElement.find(:first,
          :include => [:published_website],
          :conditions => ['published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.content_id, 'Content', self.version]).nil?
      end
    end

    render :inline => "{\"totalCount\":#{content.versions.count},data:#{versions.to_json(:only => [:id, :version, :title, :body_html, :excerpt_html, :created_at], :methods => [:published])}}"
  end

  def publish_content
    content = Content.find(Content::Version.find(params[:id]).content_id)
    website = Website.find(params[:site_id])
    version = params[:version]
    comment = params[:comment]

    content.publish(website, comment, version)

    render :inline => {:success => true}.to_json
  end

  def revert_content
    content = Content.find(Content::Version.find(params[:id]).content_id)
    version = params[:version]
    content.revert_to(version)
    content.save!

    render :inline => {:success => true}.to_json
  end

  #website section layouts

  def website_section_layout_versions
    WebsiteSection::Version.include_root_in_json = false

    website_section = WebsiteSection.find(params[:id])
    website = Website.find(params[:site_id])
    sort  = params[:sort] || 'version'
    dir   = params[:dir] || 'DESC'
    limit = params[:limit] || 15
    start = params[:start] || 0

    versions = website_section.versions.find(:all, :order => "#{sort} #{dir}", :offset => start, :limit => limit)

    WebsiteSection::Version.class_exec(website) do
      @@website = website
      def published
        published_site_id = @@website.active_publication.id
        !PublishedElement.find(:first,
          :include => [:published_website],
          :conditions => ['published_websites.id = ? and published_element_record_id = ? and published_element_record_type = ? and published_elements.version = ?', published_site_id, self.website_section_id, 'WebsiteSection', self.version]).nil?
      end
    end

    render :inline => "{\"totalCount\":#{website_section.versions.count},data:#{versions.to_json(:only => [:id, :version, :title, :created_at], :methods => [:published])}}"
  end

  def get_website_section_version
    render :text => WebsiteSection::Version.find(params[:id]).layout
  end

  def publish_website_section
    website_section = WebsiteSection.find(WebsiteSection::Version.find(params[:id]).website_section_id)
    website = Website.find(params[:site_id])
    version = params[:version]
    comment = params[:comment]

    website_section.publish(website, comment, version)

    render :inline => {:success => true}.to_json
  end

  def revert_website_section
    website_section = WebsiteSection.find(WebsiteSection::Version.find(params[:id]).website_section_id)
    version = params[:version]
    website_section.revert_to(version)
    website_section.save!

    render :inline => {:success => true}.to_json
  end
end