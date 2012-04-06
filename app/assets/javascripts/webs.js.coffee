
$(document).ready ->
  window.WEB_SOCKET_SWF_LOCATION = '/WebSocketMain.swf'
  jug = new Juggernaut
  jug.subscribe "moci", (data) ->
    console.log("Got data: " + JSON.stringify(data))

  if $('h1.project').length != 0
    project_id = $('h1.project').attr('data-project-id')
    project_name = $('h1.project').attr('data-project-name')
    channel = 'moci_project_' + project_id
    console.log("Subsribing to project channel " + channel)
    jug.subscribe channel, (data) ->
      console.log("Got project data: " + JSON.stringify(data))
      d = data['data']
      switch data['event']
        when 'test_suite_run'
          if $('.last_runs .test_suite_run_'+d['id']).length == 0
            q = $.ajax
              # FIXME: find better way (routes)
              url: '/projects/tr_last_run?'+$.param({project_name: project_name, test_suite_run_id: d['id']})
              dataType: 'html'
              async: false
              success: (d,t,j) ->
                $(d).prependTo('.last_runs')
          else
            tr = $('.last_runs .test_suite_run_'+d['id'])
            console.log(tr)
            tr.find('td.state').html(d['state'])
            tr.removeClass('state_running')
            tr.removeClass('state_finished')
            tr.addClass('state_'+d['state'])
         when 'test_unit_run'
           tsr_id = d['test_suite_run']['id']
           tr_details = $('.last_runs .details.test_suite_run_'+tsr_id)
           if tr_details.length != 0
             tr_details.find('.current_test_unit').html(d['test_unit']['class_name'] + ' :: ' + d['test_unit']['name'])
           else

     if $('.last_runs tr').length > 12
       $('.last_runs tr.state_finished').slice(-6).hide()



