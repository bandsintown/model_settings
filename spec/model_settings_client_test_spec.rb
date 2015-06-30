require 'spec_helper'

describe ModelSettingsClientTest, type: :model do
  before(:each) do
    @client = ModelSettingsClientTest.create
    @user   = @client.users.create!
  end

  context 'setter and getter' do
    it 'sets preferences' do
      @user.set_model_setting(:preferences, :color, 'red')

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.get_model_setting(:preferences, :color)).to eq 'red'
      expect(settings_count.count).to eq 1
    end

    it 'sets flags' do
      @user.set_model_setting(:flags, :admin, true)

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.get_model_setting(:flags, :admin)).to be_truthy
      expect(settings_count.count).to eq 1
    end
  end

  context 'array access' do
    it 'should work for preferences' do
      @user.set_model_setting(:preferences, :color, 'red')
      @user.preferences[:color] = 'red'

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.preferences[:color]).to eq 'red'
      expect(settings_count.count).to eq 1
    end

    it 'should work for flags' do
      @user.flags[:admin] = true

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.flags[:admin]).to be_truthy
      expect(settings_count.count).to eq 1
    end
  end

  context 'object access' do
    it 'should work for preferences' do
      @user.preferences.color = 'red'

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.preferences.color).to eq 'red'
      expect(settings_count.count).to eq 1
    end

    it 'should work for flags' do
      @user.flags.admin = true

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.flags.admin).to be_truthy
      expect(settings_count.count).to eq 1
    end
  end

  context 'easy access' do
    it 'should work for preferences' do
      @user.preferences_color = 'red'

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.preferences_color).to eq 'red'
      expect(@user.preferences_color?).to be_truthy
      expect(settings_count.count).to eq 1
    end

    it 'should work for flags' do
      @user.flags_admin = true

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.flags_admin).to be_truthy
      expect(@user.flags_admin?).to be_truthy
      expect(settings_count.count).to eq 1
    end
  end

  context 'overwrite' do
    it 'should be able to override a preference' do
      @user.preferences[:color] = 'red'

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.preferences[:color]).to eq 'red'
      expect(settings_count.count).to eq 1

      @user.preferences[:color] = 'blue'

      settings_count = ModelSetting.where(model_type: @user.class.name, model_id: @user.id)

      expect(@user.preferences[:color]).to eq 'blue'
      expect(settings_count.count).to eq 1
    end
  end

  context 'alias' do
    it 'should work with different alias' do
      @user.preferences.theme = 'savage thunder'

      expect(@user.prefs[:theme]).to eq @user.preferences[:theme]
      expect(@user.prefs.theme).to eq @user.preferences.theme
      expect(@user.prefs_theme).to eq @user.preferences_theme
      expect(@user.prefs_theme?).to eq @user.preferences_theme?
    end
  end

  context 'type check' do
    it 'should raise exception if we try to change the setting type' do
      @user.preferences.theme = "savage thunder"
      expect(@user.preferences.save).to be_truthy

      @user.preferences.theme = 1

      expect { @user.preferences.save! }.to raise_error(ActiveRecord::RecordInvalid)
      expect(@user.preferences.save).to be_falsy
      expect(@user.errors).not_to be_empty
    end
  end

  context 'validation' do
    it 'should validate validate_test_1 accepted values' do
      @user.preferences.validate_test_1 = 1

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_1 = true

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_1 = 'true'

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_1 = false

      expect(@user.preferences.save!).to raise_error(ActiveRecord::RecordInvalid)
      expect(@user.preferences.save).to be_falsy
      expect(@user.errors).not_to be_empty
    end

    it 'should validate validate_test_2 accepted values' do
      @user.preferences.validate_test_2 = 1

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_2 = true

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_2 = 'true'

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_2 = false

      expect(@user.preferences.save!).to raise_error(ActiveRecord::RecordInvalid)
      expect(@user.preferences.save).to be_falsy
      expect(@user.errors).not_to be_empty
    end

    it 'should validate validate_test_3 accepted values' do
      @user.preferences.validate_test_3 = 1

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_3 = true

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_3 = 'true'

      expect(@user.preferences.save).to be_truthy

      @user.preferences.validate_test_3 = false

      expect(@user.preferences.save!).to raise_error(ActiveRecord::RecordInvalid)
      expect(@user.preferences.save).to be_falsy
      expect(@user.errors).not_to be_empty
    end

    it 'should validate validate_test_4 accepted values' do
      @user.preferences.validate_test_4 = 'blah'

      expect(@user.preferences.save!).to raise_error(ActiveRecord::RecordInvalid)
      expect(@user.preferences.save).to be_falsy
      expect(@user.errors.on(:preferences).length).to eq 2
      expect(@user.errors.on(:preferences)[0]).to eq '1one'
      expect(@user.errors.on(:preferences)[1]).to eq '2two'

      # nasty bug when the parent is a new record
      user = @user.class.new(preferences_validate_test_4: 'blah')

      expect(@user.preferences.save).to be_falsy
      expect(@user.errors.on(:preferences).length).to eq 2
      expect(@user.errors.on(:preferences)[0]).to eq '1one'
      expect(@user.errors.on(:preferences)[1]).to eq '2two'
    end

    it 'should add the errors to base' do
      @user.preferences.validate_test_4 = 'blah'
      @user.preferences.save
      @preference = @user.preferences.detect { |pref|  !pref.errors.empty? }

      expect(@preference.errors.full_messages).to eq ['1one','2two']
    end
  end

  describe 'preprocess_test_1' do
    it 'should be able to preprocess' do
      @user.preferences.preprocess_test_1 = 'blah'

      expect(@user.preferences.preprocess_test_1).to eq 'blah'
      expect(@user.preferences_preprocess_test_1).to eq 'blah'

      @user.preferences_preprocess_test_1 = 'blah'

      expect(@user.preferences.preprocess_test_1).to be_falsy
      expect(@user.preferences_preprocess_test_1).to be_falsy

      @user.preferences.preprocess_test_1 = 'true'

      expect(@user.preferences.preprocess_test_1).to eq 'true'
      expect(@user.preferences_preprocess_test_1).to eq 'true'

      @user.preferences_preprocess_test_1 = 'true'

      expect(@user.preferences.preprocess_test_1).to be_truthy
      expect(@user.preferences_preprocess_test_1).to be_truthy
    end
  end

  describe 'postprocess_test_1' do
    it 'should be able to postprocess' do
      @user.preferences.postprocess_test_1 = 'blah'

      expect(@user.preferences.postprocess_test_1).to eq 'blah'
      expect(@user.preferences_postprocess_test_1).to be_falsy

      @user.preferences.postprocess_test_1 = 'true'

      expect(@user.preferences.postprocess_test_1).to eq 'true'
      expect(@user.preferences_postprocess_test_1).to be_truthy
    end
  end

  describe 'default_test_1' do
    it 'should be able to handle defaults' do
      expect(ModelSettingsUserTest.new.flags.default_test_1).to eq 'funky town'
      expect(@user.flags.default_test_1).to eq 'funky town'

      @user.flags.default_test_1 = 'stupid town'

      expect(@user.flags.default_test_1).to eq 'stupid town'

      @user.flags.save
      @user = ModelSettingsUserTest.find(@user.id)

      expect(@user.flags.default_test_1).to eq 'stupid town'
    end
  end

  describe 'default_through_test_1' do
    it 'should be able to handle defaults' do
      client = ModelSettingsClientTest.create
      user   = client.users.create

      expect(user.flags.default_through_test_1).to eq 'client default'

      client.flags.default_through_test_1 = 'not client default'
      client.flags.save
      user.client(true)

      expect(user.flags.default_through_test_1).to eq 'not client default'

      user.flags.default_through_test_1 = 'not user default'

      expect(user.flags.default_through_test_1).to eq 'not user default'

      expect(ModelSettingsUserTest.new.flags.default_through_test_1).to eq 'user default'
    end
  end

  describe 'default_dynamic_test_1' do
    it 'should be able to handle dynamic defaults' do
      expect(@user.flags.default_dynamic_test_1).to eq 1
      expect(@user.flags.default_dynamic_test_1).to eq 2
    end
  end

  describe 'default_dynamic_test_2' do
    it 'should be able to handle dynamic defaults' do
      expect(@user.flags.default_dynamic_test_2).to eq 1
      expect(@user.flags.default_dynamic_test_2).to eq 2
    end
  end

  # This is from a bug that swalterd found that has to do with how model_settings assigns default values.
  # Each thing shares the same default value, so changing it for one will change it for everyone.
  # The fix is to clone (if possible) the default value when a new ModelSetting is created.
  describe 'default_reference' do
    # Silly I know but I'm just copying from the repo and translating to RSpec
    it 'demonstrates a bug found by swaltered' do
      value = @user.flags.default_reference[0]
      @user.flags.default_reference[0] = rand(10) + 10
      new_user = ModelSettingsUserTest.new

      expect(new_user.flags_default_reference[0]).to eq(value)
    end
  end

  describe 'form_usage_test' do
    it 'should work with default, type_check, preprocess and postprocess' do
      expect(@user.prefs.form_usage_test).to be_falsy
      expect(@user.prefs_form_usage_test).to eq 'false'

      params = { :person => { prefs_form_usage_test: 'true' } }

      expect(@user.update_attributes(params[:person])).to be_truthy
      expect(@user.prefs.form_usage_test).to be_truthy
      expect(@user.prefs_form_usage_test).to eq 'true'

      @user.preferences.save!
      @user = @user.class.find(@user.id)

      expect(@user.prefs.form_usage_test).to be_truthy
      expect(@user.prefs_form_usage_test).to eq 'true'

      params = { :person => { prefs_form_usage_test: 'false' } }

      expect(@user.update_attributes(params[:person])).to be_truthy
      expect(@user.prefs.form_usage_test).to be_truthy
      expect(@user.prefs_form_usage_test).to eq 'false'

      @user.preferences.save!
      @user = @user.class.find(@user.id)

      expect(@user.prefs.form_usage_test).to be_falsy
      expect(@user.prefs_form_usage_test).to eq 'false'
    end
  end
end