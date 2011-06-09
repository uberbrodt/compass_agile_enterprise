class BlogsController < ArticlesController
  def index
    @blog = Blog.find(params[:section_id])
    @contents = @blog.find_published_blog_posts(@active_publication).paginate(:page => params[:page], :per_page => 2)
  end

  def tag
    @blog = Blog.find(params[:section_id])
    @tag = ActsAsTaggableOn::Tag.find(params[:tag_id])
    @contents = @blog.find_published_blog_posts_with_tag(@active_publication, @tag).paginate(:page => params[:page], :per_page => 2)
    
    render :index
  end

  def show
    @blog = Blog.find(params[:section_id])
    @published_content = @blog.find_published_blog_post(@active_publication, params[:id])
  end
end
