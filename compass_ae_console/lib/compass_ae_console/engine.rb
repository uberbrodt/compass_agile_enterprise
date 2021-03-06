module CompassAeConsole
  class Engine < Rails::Engine
    isolate_namespace CompassAeConsole
    
    initializer "compass_console.merge_public" do |app|
      app.middleware.insert_before Rack::Lock, ::ActionDispatch::Static, "#{root}/public"
    end

    ErpBaseErpSvcs.register_as_compass_ae_engine(config, self)
    
  end
end
