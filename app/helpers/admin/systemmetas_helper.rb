module Admin::SystemmetasHelper
  def get_setting(name)
    setting = Systemmeta.find_or_initialize_by_meta_key(name)
    return setting.meta_value
  end
end
