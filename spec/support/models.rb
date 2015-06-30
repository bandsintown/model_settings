class ModelSettingsClientTest < ActiveRecord::Base
  include ModelSettings

  has_many :users, class_name: 'ModelSettingsUserTest', foreign_key: 'client_id'

  model_settings :flags do |f|
    f.define :default_through_test_1, default: 'client default'
  end
end

class ModelSettingsUserTest < ActiveRecord::Base
  include ModelSettings

  belongs_to :client, class_name: 'ModelSettingsClientTest', foreign_key: 'client_id'

  cattr_accessor :count1, :count2

  @@count1, @@count2 = 0, 0

  model_settings :preferences, alias: :prefs do |p|
    p.define :color
    p.define :theme, type_check: String
    p.define :validate_test_1, validate: [true, 'true', 1, 't']
    p.define :validate_test_2, validate: Proc.new { |value|
      [true, 'true', 1, 't'].include?(value)
    }
    p.define :validate_test_3, validate: Proc.new { |value|
      raise ModelSettings::ValidationError unless [true, 'true', 1, 't'].include?(value)
    }
    p.define :validate_test_4, validate: :validate_test_4
    p.define :preprocess_test_1, preprocess: Proc.new { |value| [true, 'true', 1, 't'].include?(value) ? true : false }
    p.define :postprocess_test_1, postprocess: Proc.new { |value| [true, 'true', 1, 't'].include?(value) ? true : false }
    p.define :form_usage_test, default: false,
                               type_check: [TrueClass, FalseClass],
                               preprocess: Proc.new{ |value| value == 'true' },
                               postprocess: Proc.new{ |value| value ? 'true' : 'false' }
  end

  model_settings :flags do |f|
    f.define :admin
    f.define :default_test_1, default: 'funky town'
    f.define :default_through_test_1, default: 'user default', default_through: :client
    f.define :default_dynamic_test_1, default_dynamic: :default_dynamic_test_1
    f.define :default_dynamic_test_2, default_dynamic: Proc.new{ |user| user.class.count2 += 1 }
    f.define :default_reference, default: [1, 2, 3] # demonstrates a bug found by swaltered
  end

  def validate_test_4(value)
    ['1one', '2two']
  end

  def default_dynamic_test_1
    self.class.count1 += 1
  end
end