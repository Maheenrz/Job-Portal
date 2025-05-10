FactoryBot.define do
  factory :job do
    title { "MyString" }
    description { "MyText" }
    location { "MyString" }
    company_name { "MyString" }
    employment_type { "MyString" }
    salary { "MyString" }
    user { nil }
  end
end
