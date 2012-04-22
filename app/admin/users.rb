ActiveAdmin.register User do
  filter :email

  index do
    column :email
    column :admin
    column :created_at
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :email
    end

    f.inputs "New password" do
      f.input :password
      f.input :password_confirmation
    end

    f.buttons
  end
end
