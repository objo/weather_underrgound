Rails.application.routes.draw do
  get 'welcome/test'

  get 'welcome/index'
  post 'welcome/index', as: :index

end
