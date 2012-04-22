//= require active_admin/base

UserForm =
  update_permission_view: ->
    if $('form.user #user_admin_input input').is(':checked')
      $('fieldset.permissions').hide()
    else
      $('fieldset.permissions').show()


$().ready ->
  UserForm.update_permission_view()
  $('form.user #user_admin_input input').on 'change', () ->
    UserForm.update_permission_view()

