FactoryGirl.define do
  factory :user do
    email 'test@fake.local'
    password 'password'
    password_confirmation 'password'
  end
end