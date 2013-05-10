class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name
      t.text :description
      t.references :operator

      t.timestamps
    end
    add_index :skills, :operator_id
    create_table(:operators_skills, :id => false) do |t|
      t.references :operator
      t.references :skill
    end    
    add_index(:operators_skills, [ :operator_id, :skill_id ])
  end
end
