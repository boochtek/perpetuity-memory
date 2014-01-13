require_relative '../../lib/perpetuity/memory'

describe 'Full Perpetuity stack using in-memory adapter' do

  before do
    Perpetuity.data_source :memory
    class User
      attr_reader :name, :age
      def initialize(name, age)
        @name = name
        @age = age
      end
    end
    Perpetuity.generate_mapper_for(User) do
      attribute :name
      attribute :age
    end
  end

  let(:mapper) { Perpetuity[User] }
  let(:user) { User.new(name, age) }
  let(:name) { 'Craig' }
  let(:age) { 43 }

  it 'can store an object' do
    mapper.insert(user)
    expect(mapper.count).to eq(1)
  end

  it 'can retrieve a stored object by ID' do
    id = mapper.insert(user)
    expect(mapper.count).to eq(1)
    expect(mapper.find(id).name).to eq(name)
    expect(mapper.find(id).age).to eq(age)
  end

  it 'can retrieve a stored object by attribute' do
    mapper.insert(user)
    expect(mapper.count).to eq(1)
    expect(mapper.find{|u| u.name == 'Craig'}.age).to eq(age)
  end
end
