class AddPhotoPublicIdToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :photo_public_id, :string
  end
end
