module AnypresenceExtension
  module Pageable
    
    DEFAULT_PER_PAGE = 20
    DEFAULT_PAGE = 1
      
    def current_page
      @page ||= DEFAULT_PAGE
    end
  
    def page(page = DEFAULT_PAGE)
      self.tap do
        @page ||= [page.to_i, 1].max - 1
      end
    end

    def next_page
      self.tap do
        @page = current_page + 1
      end
    end

    def prev_page
      self.tap do
        @page = current_page - 1
      end
    end

    def per_page(per_page = DEFAULT_PER_PAGE )
      @per_page ||= per_page
    end
    
  
  end

end