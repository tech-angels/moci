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
    $.get url, (data) ->
      $('form.test_suite .inputs.options').replaceWith(data)

ProjectForm =
  update_options: ->
    url = '/admin/projects/option_fields?'
    url += 'vcs_type='+$('#project_vcs_type').val()
    url += '&project_type='+$('#project_project_type').val()
    url += '&id='+$('form.project .inputs.options').attr('data-object-id')
    $.get url, (data) ->
      $('form.project .inputs.options').replaceWith(data)

$().ready ->
  UserForm.update_permission_view()
  $('form.user #user_admin_input input').on 'change', () ->
    UserForm.update_permission_view()

  $('form.test_suite #test_suite_suite_type').on 'change', () ->
    TestSuiteForm.update_options($(this).val())

  $('form.project #project_project_type, form.project #project_vcs_type').on 'change', () ->
    ProjectForm.update_options()
