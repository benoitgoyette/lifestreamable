class CreateLifestreams < ActiveRecord::Migration
  def self.up
    create_table :lifestreams do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :stream_type
      t.string :reference_type
      t.integer :reference_id
      t.text :object_data_hash
      t.timestamps
    end

    add_index(:lifestreams, [:owner_id, :owner_type], :name=>'lifestreams_profil_id' )
    add_index(:lifestreams, :stream_type, :name=>'lifestreams_stream_type' )
    add_index(:lifestreams, [:reference_id, :reference_type], :name=>'lifestreams_stream_object' )
  end

  def self.down
    drop_table :lifestreams
  end
end
