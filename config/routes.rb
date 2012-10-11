Moci::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :users

  resources :test_suite_runs do
    member do
      get :blame
    end
  end

  resources :projects, path: '/p' do
    member do
      get :tr_last_run
      get :stats
    end
    collection do
      get :choose
    end
    resources :commits do
      post :rerun_all_children, :on => :member
    end
    resources :test_suite_runs
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "test_suite_runs#index"

  match 'c/:id', :controller => 'commits', :action => 'show'
end
