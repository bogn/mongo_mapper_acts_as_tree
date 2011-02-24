module MongoMapper
  module Plugins
    module ActsAsTree
      
      extend ActiveSupport::Concern
      
      
      
      # --------------------------------------------------------------------------------
      module ClassMethods
        def acts_as_tree(options = {})
          configuration = { :foreign_key => :parent_id, :order => nil }
          configuration.update(options) if options.is_a?(Hash)

          # automatically create needed keys if they don't already exist
          key configuration[:foreign_key], ObjectId unless keys.key?(configuration[:foreign_key])
          key configuration[:foreign_key].to_s.pluralize.to_sym, Array unless keys.key?(configuration[:foreign_key].to_s.pluralize.to_sym)

          belongs_to :parent, :class_name => name, :foreign_key => configuration[:foreign_key]
          many :children, :class_name => name, :foreign_key => configuration[:foreign_key], :order => configuration[:order], :dependent => :destroy

          before_save :set_parents

          class_eval <<-EOV
            def self.roots
              where("#{configuration[:foreign_key]}".to_sym => nil).sort("#{configuration[:order]}").all
            end

            def self.root
              where("#{configuration[:foreign_key]}".to_sym => nil).sort("#{configuration[:order]}").first
            end

            def set_parents
              self.#{configuration[:foreign_key].to_s.pluralize} = parent.#{configuration[:foreign_key].to_s.pluralize}.dup << #{configuration[:foreign_key]} if parent?
            end
            
            def ancestors
              self.class.where(:id => { '$in' => self.#{configuration[:foreign_key].to_s.pluralize} }).all.reverse || []
            end
            
            def root
              self.class.find(self.#{configuration[:foreign_key].to_s.pluralize}.first) || self
            end
            
            def descendants
              self.class.where('#{configuration[:foreign_key].to_s.pluralize}' => self.id).all
            end
            
            def depth
              self.#{configuration[:foreign_key].to_s.pluralize}.count
            end
            
          EOV
        end
      end
      
      
      
      # --------------------------------------------------------------------------------
      module InstanceMethods

        def siblings
          self_and_siblings - [self]
        end

        def self_and_siblings
          parent? ? parent.children : self.class.roots
        end

      end
      
    end
  end
end