require 'perpetuity/memory'
require 'date'

module Perpetuity
  describe Memory do
    let(:klass) { String }

    it 'inserts' do
      expect { subject.insert klass, { name: 'foo' }, [] }.to change { subject.count klass }.by 1
    end

    it 'inserts multiple objects' do
      expect { subject.insert klass, [{name: 'foo'}, {name: 'bar'}], [] }
        .to change { subject.count klass }.by 2
    end

    it 'removes all objects' do
      subject.insert klass, {}, []
      subject.delete_all klass
      subject.count(klass).should == 0
    end

    it 'counts the number of objects' do
      subject.delete_all klass
      3.times do
        subject.insert klass, {}, []
      end
      subject.count(klass).should == 3
    end

    it 'counts the objects matching a query' do
      subject.delete_all klass
      1.times { subject.insert klass, { name: 'bar' }, [] }
      3.times { subject.insert klass, { name: 'foo' }, [] }
      subject.count(klass) { |o| o[:name] == 'foo' }.should == 3
    end

    it 'gets the first object' do
      value = {value: 1}
      subject.insert klass, value, []
      subject.first(klass)[:value].should == value['value']
    end

    it 'gets all objects' do
      values = [{value: 1}, {value: 2}]
      subject.insert klass, values, []
      subject.all(klass).should == values
    end

    it 'retrieves by ID if the ID is a string' do
      time = Time.now.utc
      id = subject.insert Object, {inserted: time}, []

      object = subject.retrieve(Object, subject.query{|o| o[:id] == id.to_s }).first
      retrieved_time = object["inserted"]
      retrieved_time.to_f.should be_within(0.001).of time.to_f
    end

    describe 'serialization' do
    end

    describe 'indexing' do
      it 'keeps track of what attributes were indexed' do
        subject.index(klass, Perpetuity::Attribute.new('name'))
        subject.indexes(klass).map{|a| a.name}.should include('name')
      end
    end

    describe 'atomic operations' do
      after(:all) { subject.delete_all klass }

      it 'increments the value of an attribute' do
        id = subject.insert klass, { count: 1 }, []
        subject.increment klass, id, :count
        subject.increment klass, id, :count, 10
        query = subject.query { |o| o[:id] == id }
        subject.retrieve(klass, query).first['count'].should be == 12
        subject.increment klass, id, :count, -1
        subject.retrieve(klass, query).first['count'].should be == 11
      end
    end
  end
end
