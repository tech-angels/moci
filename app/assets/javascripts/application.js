// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.simplemodal
//= require moci
//= require webs

function fetchBlame(el, tsr_id, tu_id) {
  console.log(el);
  el.parent('.blame').css('display','inline');
  el.parent('.blame').html('<img src="/images/ajax_inline.gif">').load('/test_suite_runs/blame?id='+tsr_id+'&test_unit_id='+tu_id);
}

