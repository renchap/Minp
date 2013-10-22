module ApplicationHelper
  def set_layout_type(type)
    @layout_type = type
  end

  def layout_type
    if @layout_type
      @layout_type
    else
      :normal
    end
  end

  def set_page_title(title,options = {},&block)
    content_for(:page_title, title)
    @page_title_options = options
    content_for(:page_title_details, &block) if block_given?
  end

  def page_title
    if content_for?(:page_title)
      content_for(:page_title) + ' - Minp'
    else
      'Minp'
    end
  end
end
