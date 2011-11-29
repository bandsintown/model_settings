class ModelSettingsMigrationGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template "model_settings_migration.rb", "db/migrate"
    end
  end
end