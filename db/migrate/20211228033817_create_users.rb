# frozen_string_literal: true

#= CreateUsers
#
# Creates the table where the user information (email addess, identity platform
# id) will be stored:
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :name

      t.string :identity_platform_id, null: false, index: {
        unique: true, name: :UK_user_identity_platform
      }

      t.timestamps
    end
  end
end
