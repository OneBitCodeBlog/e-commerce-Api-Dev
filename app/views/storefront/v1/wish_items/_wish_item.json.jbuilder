json.id wish_item.id
json.(wish_item.product, :name, :description)
json.price wish_item.product.price.to_f
json.image_url rails_blob_url(wish_item.product.image)
json.categories wish_item.product.categories.pluck(:name)