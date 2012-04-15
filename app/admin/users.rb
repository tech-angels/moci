ActiveAdmin.register User do
  filter :email

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
