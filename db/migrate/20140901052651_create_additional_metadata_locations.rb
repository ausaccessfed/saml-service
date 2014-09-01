Sequel.migration do
  change do

    create_table :additional_metadata_locations do
      primary_key :id
      String :uri
      String :namespace

      DateTime :created_at
      DateTime :updated_at
    end

  end
end
