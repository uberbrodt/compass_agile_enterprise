module ErpApp
	module Shared
		class ConfigurationController < ErpApp::ApplicationController

      def setup_categories
        configuration = ::Configuration.find(params[:id])
        tree_array = [].tap do |array|
          configuration.item_types.collect{|item| item.category_classifications.first.category}.uniq.each do |category|
            array << category.to_tree_hash(:only => [], :methods => [{:id => :categoryId}], :icon_cls => 'icon-index')
          end
        end
        render :json => tree_array
      end

		  def setup
        category_id = params[:category_id]
        configuration = ::Configuration.find(params[:id])

        render :json => {:success => true, :configurationItemTypes => configuration.item_types.by_category(Category.find(category_id)).collect(&:to_js_hash)}
      end

      def load
        category_id = params[:category_id]
        configuration = ::Configuration.find(params[:id])

        render :json => {:success => true, :configurationItems => configuration.items.by_category(Category.find(category_id)).collect(&:to_js_hash)}
      end

      def update
        configuration = ::Configuration.find(params[:id])

        begin
          params.each do |k,v|
            #v.split(',').each do |option|
            #  configuration.update_configuration_item(ConfigurationItemType.find_by_internal_identifier(k), option) unless (k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'id' or k.to_s == 'authenticity_token')
            #end
            #options_array = v.split(',')
            #if options_array.length > 1
            #  configuration.item_types.where("internal_identifier = ?", k).first.configuration_items.first.set_options(options_array) unless (k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'id' or k.to_s == 'authenticity_token')
            #else
              configuration.update_configuration_item(ConfigurationItemType.find_by_internal_identifier(k), v) unless (k.to_s == 'action' or k.to_s == 'controller' or k.to_s == 'id' or k.to_s == 'authenticity_token')
            #end
            
          end

          render :json => {:success => true, :configurationItems => configuration.items.collect(&:to_js_hash)}
        rescue Exception=>ex
          logger.error(ex.message)
          logger.error(ex.backtrace)
          render :json => {:success => false, :message => ex.message}
        end
      end

    end#ConfigurationController
  end#Shared
end#ErpApp
