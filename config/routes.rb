IMDBSearch::Application.routes.draw do
  resource :home, controller: 'home'
  root to: 'home#show'
end
