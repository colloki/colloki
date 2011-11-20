# See: http://thewebfellas.com/blog/2010/8/22/revisited-roll-your-own-pagination-links-with-will_paginate-and-rails-3
class PaginationListLinkRenderer < WillPaginate::ActionView::LinkRenderer
  protected

    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page))
      else
        tag(:li, link(page, "#"), :class => "active")
      end
    end

    def previous_or_next_page(page, text, classname)
      if page
        tag(:li, link(text, page), :class => classname)
      else
        tag(:li, link(text, '#'), :class => classname + ' disabled')
      end
    end

    def html_container(html)
      tag(:div, tag(:ul, html), container_attributes)
    end

    def previous_page
      num = @collection.current_page > 1 && @collection.current_page - 1
      previous_or_next_page(num, @options[:previous_label], 'prev')
    end

    def next_page
      num = @collection.current_page < @collection.total_pages && @collection.current_page + 1
      previous_or_next_page(num, @options[:next_label], 'next')
    end

    def gap
      text = @template.will_paginate_translate('views.will_paginate.page_gap') { '&hellip;' }
      %(<li class="disabled"><a href="#">...</a></li>)
    end
end