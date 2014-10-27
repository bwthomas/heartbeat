class AddTagsToSubmissionsAndUsers < ActiveRecord::Migration
  def change
    add_column :submissions, :tags, :string, array: true, default: '{}'
    add_index  :submissions, :tags, using: 'gin'

    add_column :users, :tags, :string, array: true, default: '{}'
    add_index  :users, :tags, using: 'gin'

    reversible do |direction|
      direction.up do
        {
          # Insert values here
        }.each do |tag, emails|
          User.where(email: emails).update_all tags: ['rnd', tag]
        end

        User.active.untagged.update_all tags: ['rnd']

        User.tagged.each do |user|
          user.submissions.update_all tags: user.tags
        end
      end
    end
  end
end
