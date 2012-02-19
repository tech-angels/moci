# Attributes:
# * id [integer, primary, not null] - primary key
# * class_name [string] - name of group of tests
# * created_at [datetime] - creation time
# * name [text]
# * test_suite_id [integer] - belongs_to TestSuite
# * updated_at [datetime] - last update time
class TestUnit < ActiveRecord::Base
  belongs_to :test_suite
end
