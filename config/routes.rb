Rails.application.routes.draw do
  root 'posts#index'                  # トップページは投稿一覧
  get :sign_up, to: 'users#new'      # サインアップ画面
  post :sign_up, to: 'users#create'  # サインアップ送信
  get 'login', to: 'sessions#new'    # ログイン画面
  post 'login', to: 'sessions#create' # ログイン送信
  delete 'logout', to: 'sessions#destroy' # ログアウト
  resources :posts do
    resources :comments, module: :posts # 投稿に紐付くコメント
  end


  if Rails.env.development? || Rails.env.test?
    get 'login_as/:user_id', to: 'development/sessions#login_as'
  end

end
