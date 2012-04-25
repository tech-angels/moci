# MOCI

  Continuous Integration that sucks less.

## What is MOCI?

  MOCI is a MOdular Continuous Integration.

  Main differences with other CIs:
  * it understands your test suites
    * you always know right away which test cases caused test suite to fail
    * if it's not the first commit when they started failing, you can easily do blame - that is, check who introduced these failing tests
  * it understands randomly failing test cases
    * when there are no new commits, test suites will be run again for existing ones to find test cases that may be failing randomly
  * it's really modular
    * adding another test suite runner, project handler or VCS is a matter of adding one file
  * it's fast
    * different test suites for given project can be run in parallel

## Project status

  We've been using it successfuly for some time, but it's still alpha. It's been mostly tested with Rails projcets with Git as VCS.

  You can run it successfuly, but setting it up sucks for now.

  Ah, and the look also sucks ;) Some CSS will come. [Screenshot](http://tesuji.pl/moci1.png)

## Getting started

So here's the "setting it up sucks" part.

    project = Project.create! :name => "MyProject", :vcs_type => "Git", :project_type => "Rails", :public => true
    project.instances.create! :working_directory => "/home/comboy/here_my_project_lives"
    project.test_suites.create! :name => 'units', :suite_type => 'RailsUnits'
    project.test_suites.create! :name => 'functionals', :suite_type => 'RailsFunctionals'

or maybe you like rspec:

    project.test_suites.create! :name => 'models', :suite_type => 'RailsSpec', :suite_options => {'specs' => 'models'}
    project.test_suites.create! :name => 'controllers', :suite_type => 'RailsSpec', :suite_options => {'specs' => 'controllers'}

Assuming you have properly configured rails project in *working_directory*, you can try:

    Moci::Worker.go

It will periodically poll for changes and run test suites. Moci::Worker is not here to stay, it's just used for testing. Alternatively you can manually trigger check on specific instance by:

    project.instances.first.ping

Plug in some notification:

    opts = { :room_id => 1234,  :room_url => 'https://EXAMPLE.campfirenow.com', :auth_token => 'yourcampfireauthtoken' }
    notif = Notification.create! :name => 'campfire', :notification_type => 'Campfire', :options => opts
    project.notifications << notif

You can see what's happening in log/build.log.

If you want to have live updates in your app, you'll need to run juggernaut.

## Extending and diving into moci

The core of moci is under [lib/moci](https://github.com/tech-angels/moci/tree/master/lib/moci). You'll find there API for implementing own [test runner](https://github.com/tech-angels/moci/blob/master/lib/moci/test_runner/base.rb), [VCS](https://github.com/tech-angels/moci/blob/master/lib/moci/vcs/base.rb) or [project handler](https://github.com/tech-angels/moci/blob/master/lib/moci/project_handler/base.rb)

There is still slight chance that this API may change, but these should not be dramatic changes.

In case of any questions or problems, just open an issue.

## AUTHOR

  Kacper Cieśla (comboy) @ Tech-angels
  http://www.tech-angels.com/


