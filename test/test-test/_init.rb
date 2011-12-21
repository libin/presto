require ::File.expand_path("../_init", ::File.dirname(__FILE__))

require 'json'
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
        t { rsp.body == '0' } && puts('level #0 spec passed')

        should 'pass level #1 spec' do

          rsp = get :spec, 1
          t { rsp.body == '1' } && puts('level #1 spec passed')

          should 'pass level #2 spec' do

            rsp = get :spec, 2
            t { rsp.body == '2' } && puts('level #2 spec passed')

            should 'pass level #3 spec' do

              rsp = get :spec, 3
              t { rsp.body == '3' } && puts('level #3 spec passed')

              should 'pass level #4 spec' do

                rsp = get :spec, 4
                t { rsp.body == '4' } && puts('level #4 spec passed')

                should 'pass level #5 spec' do

                  rsp = get :spec, 5
                  t { rsp.body.to_i == 5 } && puts('level #5 spec passed')

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
        t { rsp.status == 200 } && puts('equal passed')
      end

      should 'pass match' do
        rsp = get :assert, :val
        t { rsp.body =~ /val/ } && puts('match passed')
      end

      should 'pass gt' do
        rsp = get :assert, :val
        t { rsp.status > 0 } && puts('gt passed')
      end

      should 'pass gte' do
        rsp = get :assert, :val
        t { rsp.status >= 200 } && puts('gte passed')
      end

      should 'pass lt' do
        rsp = get :assert, :val
        t { rsp.status < 300 } && puts('lt passed')
      end

      should 'pass lte' do
        rsp = get :assert, :val
        t { rsp.status <= 300 } && puts('lte passed')
      end

      should 'pass nil' do
        rsp = get :assert, :val
        t { nil.nil? && !rsp.body.nil? } && puts('nil passed')
      end

      should 'pass instance_of' do
        rsp = get :assert, :val
        t { rsp.body.instance_of?(String) } && puts('instance_of passed')
      end

      should 'pass respond_to' do
        rsp = get :assert, :val
        t { rsp.body.respond_to?(:length) } && puts('respond_to passed')
      end

      should 'pass is_a' do
        rsp = get :assert, :val
        t { rsp.body.is_a?(String) } && puts('is_a passed')
      end

    end

    def json
      hash = {
          '1' => {
              '1.1' => {
                  '1.1.1' => '1.1.1'
              }
          },
          '2' => '2'
      }
      ::JSON.generate hash
    end

    node.test :json do
      should 'return recursively proxified json object' do
        rsp, json = get_json :json
        t do
          json['1'].is_a?(Hash) && json['1']['1.1'].is_a?(Hash) &&
              json['1']['1.1']['1.1.1'] == '1.1.1' && json['2'] == '2'

        end && puts('json proxy test passed')
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
