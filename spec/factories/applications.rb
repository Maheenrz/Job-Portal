FactoryBot.define do
  factory :application do
    user { nil }
    job { nil }
    cover_letter { "MyText" }
    status { "MyString" }
  end
end
