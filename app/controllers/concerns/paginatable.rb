module Paginatable
  extend ActiveSupport::Concern

  private

  def paginate(collection)
    collection = collection.page(params[:page] || 1).per(params[:per_page] || 25)

    response.headers['X-Total-Count'] = collection.total_count.to_s
    response.headers['X-Total-Pages'] = collection.total_pages.to_s
    response.headers['X-Current-Page'] = collection.current_page.to_s
    response.headers['X-Per-Page'] = collection.limit_value.to_s

    collection
  end
end
