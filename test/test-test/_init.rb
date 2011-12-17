require ::File.expand_path("../_init", ::File.dirname(__FILE__))

require 'stringio'

module Kernel

  def stdout
    stdout = StringIO.new
    $stdout = stdout
    yield
    stdout.rewind
    return stdout.read
  ensure
    $stdout = STDOUT
  end
end

class TestFrameworkTest < MiniTest::Unit::TestCase

  class App
    include Presto::Api
    http.map

    def label
    end

    def spec level
      level
    end

    def assert val
      val
    end

    node.test :label do
      label 'Testing #index'
    end

    node.test :spec do
      should 'pass level #0 spec' do

        rsp = get :spec, 0
        if rsp.body == '0'
          puts 'level #0 spec passed'
        end

        should 'pass level #1 spec' do

          rsp = get :spec, 1
          if rsp.body == '1'
            puts 'level #1 spec passed'
          end

          should 'pass level #2 spec' do

            rsp = get :spec, 2
            if rsp.body == '2'
              puts 'level #2 spec passed'
            end

            should 'pass level #3 spec' do

              rsp = get :spec, 3
              if rsp.body == '3'
                puts 'level #3 spec passed'
              end

              should 'pass level #4 spec' do

                rsp = get :spec, 4
                if rsp.body == '4'
                  puts 'level #4 spec passed'
                end

                should 'pass level #5 spec' do

                  rsp = get :spec, 5
                  if rsp.body.to_i == 5
                    puts 'level #5 spec passed'
                  end

                end

              end

            end

          end
        end
      end
    end

    node.test :assert do

      should 'pass equal' do
        rsp = get :assert, :val
        if rsp.status == 200 && assert(:==, rsp.status, 200) &&
            rsp.status.not == 0 && refute(:==, rsp.status, 0)
          puts 'equal passed'
        end
      end
      should 'pass match' do
        rsp = get :assert, :val
        if (rsp.body =~ /val/) && assert(:match, rsp.body, /val/) &&
            rsp.body.not =~ /some string/ && refute(:=~, rsp.body, /another string/)
          puts 'match passed'
        end
      end
      should 'pass gt' do
        rsp = get :assert, :val
        if (rsp.status > 0) && assert(:>, rsp.status, 0) &&
            rsp.status.not > 200 && refute(:>, rsp.status, 200)
          puts 'gt passed'
        end
      end
      should 'pass gte' do
        rsp = get :assert, :val
        if (rsp.status >= 200) && assert(:>=, rsp.status, 200) &&
            rsp.length.not >= 100 && refute(:>=, rsp.length, 100)
          puts 'gte passed'
        end
      end
      should 'pass lt' do
        rsp = get :assert, :val
        if (rsp.status < 300) && assert(:<, rsp.status, 300) &&
            rsp.status.not < 0 && refute(:<, rsp.status, 0)
          puts 'lt passed'
        end
      end
      should 'pass lte' do
        rsp = get :assert, :val
        if (rsp.status <= 300) && assert(:<=, rsp.status, 300) &&
            rsp.status.not <= 0 && refute(:<=, rsp.status, 0)
          puts 'lte passed'
        end
      end
      should 'pass nil' do
        rsp = get :assert, :val
        if (rsp.body.not.nil?) && refute(:nil?, rsp.status)
          puts 'nil passed'
        end
      end
      should 'pass instance_of' do
        rsp = get :assert, :val
        if rsp.body.instance_of?(String) && assert(:instance_of?, rsp.body, String) &&
            rsp.body.not.instance_of?(Integer) && refute(:instance_of?, rsp.body, Symbol)
          puts 'instance_of passed'
        end
      end
      should 'pass respond_to' do
        rsp = get :assert, :val
        if rsp.body.respond_to?(:length) && assert(:respond_to?, rsp.body, :length) &&
            rsp.body.not.respond_to?(:some_meth) && refute(:respond_to?, rsp.body, :another_meth)
          puts 'respond_to passed'
        end
      end
      should 'pass is_a' do
        rsp = get :assert, :val
        if rsp.body.is_a?(String) && assert(:is_a?, rsp.body, String) &&
            rsp.body.not.is_a?(Fixnum) && refute(:is_a?, rsp.body, Symbol)
          puts 'is_a passed'
        end
      end

    end

    def proxy

    end

    node.test :proxy do
      should 'proxify strings' do
        str = proxy 'someStr'
        if str == 'someStr' && str =~ /str/i && str.length == 7
          puts 'proxify strings passed'
        end
      end
      should 'proxify fixnums' do
        int = proxy 100
        if int == 100 && int <= 100 && int >= 100 && int > 0 && int < 1000
          puts 'proxify fixnums passed'
        end
      end
    end

  end

  APP = Presto::App.new
  APP.mount App
  OUTPUT = stdout do
    Presto::Test.run APP.map
  end
  puts OUTPUT

end
