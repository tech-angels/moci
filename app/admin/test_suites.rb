ActiveAdmin.register TestSuite do
  filter :project
  filter :name

  index do
    column :id
    column :project
    column :name
    default_actions
  end

  form do |f|
    f.inputs "General" do
      f.input :project
      f.input :name
      f.input :suite_type, :as => :select, :collection => Moci::TestRunner.types
    end

    dynamic_options f

    f.buttons

  end

  show do
    attributes_table do
      row :project
      row :name
      row :suite_type
      row :options do
        raw display_options(resource)
      end
    end
  end

  # Used when changing test_runner to dynamically render apropriate option fields
  collection_action :option_fields do
    @test_suite = TestSuite.find_by_id(params[:id]) || TestSuite.new
    @test_suite.suite_type = params[:type]
    render :inline => "<%= raw(form_for(@test_suite, :url => '', :builder => ActiveAdmin::FormBuilder) {|f| dynamic_options(f) } ) %>"
  end


end
