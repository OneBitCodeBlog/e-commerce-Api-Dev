json.(product, :id, :name, :description, :status, :featured)
json.price product.price.to_f
json.image_url rails_blob_url(product.image)
json.productable product.productable_type.underscore
json.productable_id product.productable_id
json.categories product.categories
json.favorited_count product.wish_items.count
json.sells_count 0