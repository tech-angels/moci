//= require active_admin/base

UserForm =
  update_permission_view: ->
    if $('form.user #user_admin_input input').is(':checked')
      $('fieldset.permissions').hide()
    else
      $('fieldset.permissions').show()

TestSuiteForm =
  update_options: (suite_type)->
    url = '/admin/test_suites/option_fields?type='+suite_type
    url += '&id='+$('form.test_suite .inputs.options').attr('data-object-id')
    $('form.test_suite .inputs.options').load(url + ' .inputs.options')

NotificationForm =
  update_options: (notification_type)->
    url = '/admin/notifications/option_fields?type='+notification_type
    url += '&id='+$('form.notification .inputs.options').attr('data-object-id')
    $('form.notification .inputs.options').load(url + ' .inputs.options')

ProjectForm =
  update_options: ->
    url = '/admin/projects/option_fields?'
    url += 'vcs_type='+$('#project_vcs_type').val()
    url += '&project_type='+$('#project_project_type').val()
    url += '&id='+$('form.project .inputs.options').attr('data-object-id')
    $('form.project .inputs.options').load(url + ' .inputs.options')

$().ready ->
  UserForm.update_permission_view()
  $('form.user #user_admin_input input').on 'change', () ->
    UserForm.update_permission_view()

  $('form.test_suite #test_suite_suite_type').on 'change', () ->
    TestSuiteForm.update_options($(this).val())

  $('form.notification #notification_notification_type').on 'change', () ->
    NotificationForm.update_options($(this).val())

  $('form.project #project_project_type, form.project #project_vcs_type').on 'change', () ->
    ProjectForm.update_options()

