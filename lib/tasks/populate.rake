require 'faker'

namespace :db do
  desc 'Fill database with sample data'
  task populate: :environment do
    puts 'Recreating the database...'

    # recreate the database
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke

    puts 'Creating sample users...'

    User.create!(
      name: 'test',
      email: 'testuser@test.com',
      password: 'password',
      confirmed_at: Time.now
    )

    # create sample users
    5.times do
      User.create!(
        name: Faker::Name.name,
        email: Faker::Internet.email,
        password: 'password'
      )

      puts 'Creating sample foods...'

      # create sample foods
      5.times do
        Food.create!(
          name: Faker::Food.vegetables,
          measurement_unit: Faker::Food.metric_measurement,
          price: Faker::Number.number(digits: 2),
          user_id: User.all.sample.id
        )
      end

      puts 'Creating sample recipes...'

      # create sample recipes
      3.times do
        Recipe.create!(
          name: Faker::Food.dish,
          preparation_time: Faker::Number.number(digits: 2),
          cooking_time: Faker::Number.number(digits: 2),
          description: Faker::Lorem.sentence,
          public: Faker::Boolean.boolean,
          user_id: User.all.sample.id
        )
      end

      puts 'Creating sample recipe foods...'

      # create sample recipe foods
      3.times do
        RecipeFood.create!(
          quantity: Faker::Number.non_zero_digit,
          recipe_id: Recipe.all.sample.id,
          food_id: Food.all.sample.id
        )
      end
    end
  end
end
