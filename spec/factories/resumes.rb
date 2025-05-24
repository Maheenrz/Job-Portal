FactoryBot.define do
  factory :resume do
    user { nil }
    file_type { "MyString" }
    processed_text { "MyText" }
  end
end
