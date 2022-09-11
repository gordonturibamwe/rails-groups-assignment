require 'faker'
name = Faker::Name.name.gsub(' ', '')
10.times do |num|
  u = User.create!(
    year: 2022,
    month: 9,
    month_in_words: "SEPT",
    username: name + SecureRandom.hex(1),
    email: "#{name}@#{SecureRandom.hex(2)}.com",
    password: '1111',
    logged_in_ips: ['1'],
    login_count: 1
  )
  puts u.inspect
end
