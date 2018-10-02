class ApprovalToUserartist < ActiveRecord::Migration[5.0]
  def change
      add_column(:user_artists, :approval, :boolean)
  end
end
