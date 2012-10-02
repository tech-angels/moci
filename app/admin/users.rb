ActiveAdmin.register User do
  filter :email

  index do
    selectable_column
    column :email
    column :admin
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :email
      f.input :admin
    end

    f.inputs "Password modification" do
      f.input :password
      f.input :password_confirmation
    end

    f.inputs "Permissions", :class => 'inputs permissions' do
      f.input :projects_can_view, :as => :select, :multiple => true, :collection => Project.all
      f.input :projects_can_manage, :as => :select, :multiple => true, :collection => Project.all
    end

    f.buttons
  end

  controller do
    def update
      @user = User.find params[:id]
     if params[:user][:password].blank?
        params[:user].delete :password
        params[:user].delete :password_confirmation
      end

      @user.assign_attributes params[:user], :without_protection => true
      update!
    end
  end
end
