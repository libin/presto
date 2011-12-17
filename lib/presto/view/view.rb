module Presto
  module View

    #
    # supported engines
    #
    ENGINES = {
        String: Tilt::StringTemplate,
        ERB: Tilt::ERBTemplate,
        Erubis: Tilt::ErubisTemplate,
        Haml: Tilt::HamlTemplate,
        Sass: Tilt::SassTemplate,
        Scss: Tilt::ScssTemplate,
        Less: Tilt::LessTemplate,
        CoffeeScript: Tilt::CoffeeScriptTemplate,
        Nokogiri: Tilt::NokogiriTemplate,
        Builder: Tilt::BuilderTemplate,
        Liquid: Tilt::LiquidTemplate,
        RDiscount: Tilt::RDiscountTemplate,
        BlueCloth: Tilt::BlueClothTemplate,
        RedCloth: Tilt::RedClothTemplate,
        RDoc: Tilt::RDocTemplate,
        Radius: Tilt::RadiusTemplate,
        Markaby: Tilt::MarkabyTemplate,
    }

    def register label, engine
      ENGINES[label] = engine
    end

    module_function :register

  end
end

wd = ::File.expand_path(::File.dirname(__FILE__)) + '/'

%w[
utils
config
partition
].each { |f| require File.join(wd, f) }

%w[
api/shared/
api/class/
api/instance/
].each { |dir| Dir[wd + dir + '*.rb'].each { |f| require f } }

module Presto::View
  Config.freeze
  Api.freeze
  InstanceApi.freeze
  SharedApi.freeze
  InternalUtils.freeze
  Partition.freeze
end
