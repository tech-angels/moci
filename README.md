# MOCI

  Continuous Integration that sucks less.

## Architecture overview

  MOCI - MOdular Continuous Integration.

  Project aims to be as flexible as possible, enclosing all project type or version control system specific functionalties in modules.

  * each *Project* have one or more *Project Instances*
  * each *Project* have one or more *Test Suites*

  So when new commit arrives, and you have 3 test suites in project, they can be run all simultanuesly if you have set up 3 or more project instances. Project *Notifications* will be fired when all test suites are run for given commit.

## TODOS

  Currently focused on making it work with rails tests and git as VCS.

  Planned features that made me start this project (to keep in my mind while developing):
  * ability to tell on which commit given error appeared for the first time (and associated
    with this be able to tell if commit was OK even if some tests are still failing if they
    were failing already before)
  * randomness awareness (possibility to run test more times when there are no new commits
    to be able to tell if some of encountered errors are random, mark them properly then)
  * be able to also run on branches (would be cool, of course may be tricky when config
    files changes and so on)

  Assumptions:
  * even though it's gonna be ruby & git only for now, make it modular so that either test
    runner or VCS can be added without rewrites

## Playing with it at the moment

It's still in quite early stage on development. Some things works, but no freezing yet.
API can change completely. Here's how can you start playing:

    project = Project.create! :name => "MyProject", :vcs_branch_name => "master", :project_type => "Rails"
    project.instances.create! :working_directory => "/home/comboy/here_my_project_lives"
    project.test_suites.create! :name => 'units', :suite_tye => 'RailsUnits'
    project.test_suites.create! :name => 'functionals', :suite_tye => 'RailsFuctionals'

Assuming you have properly configured rails project in *working_directory*, you can try:

    Moci::Worker.go

It will periodically poll for changes and run test suites. Moci::Worker is not here to stay, it's just used for testing. Alternatively you can manually trigger check on specific instance by:

    project.instances.first.ping

Plug in some notification:

    opts = { :room_id => 1234,  :room_url => 'https://EXAMPLE.campfirenow.com', :auth_token => 'yourcampfireauthtoken' }
    notif = Notification.create! :name => 'campfire', :notification_type => 'Campfire', :options => opts
    project.notifications << notif


## AUTHOR

  Kacper Cieśla (comboy) @ Tech-angels
  http://www.tech-angels.com/


