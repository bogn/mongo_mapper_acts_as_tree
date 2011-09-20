require 'test_helper'



# SETUP CLASSES

class Mixin
  include MongoMapper::Document
  plugin MongoMapper::Plugins::ActsAsTree
end

class TreeMixin < Mixin 
  acts_as_tree
end

class TreeMixinWithoutOrder < Mixin
  acts_as_tree
end

class RecursivelyCascadedTreeMixin < Mixin
  acts_as_tree
  has_one :first_child, :class_name => 'RecursivelyCascadedTreeMixin', :foreign_key => :parent_id
end

class Page < Mixin
  acts_as_tree :polymorphic => true

  key :name, String
end

class SubPage < Page
end



# TESTS

class TreeTest < ActiveSupport::TestCase
  
  def setup
    @root1 = TreeMixin.create!
    @root_child1 = TreeMixin.create! :parent_id => @root1.id
    @child1_child = TreeMixin.create! :parent_id => @root_child1.id
    @root_child2 = TreeMixin.create! :parent_id => @root1.id
    @root2 = TreeMixin.create!
    @root3 = TreeMixin.create!
  end

  def test_children
    assert_equal @root1.children, [@root_child1, @root_child2]
    assert_equal @root_child1.children, [@child1_child]
    assert_equal @child1_child.children, []
    assert_equal @root_child2.children, []
  end

  
  def test_parent
    assert_equal @root_child1.parent, @root1
    assert_equal @root_child1.parent, @root_child2.parent
    assert @root1.parent.nil?
  end
  
  def test_delete
    assert_equal 6, TreeMixin.count
    @root1.destroy
    assert_equal 2, TreeMixin.count
    @root2.destroy
    @root3.destroy
    assert_equal 0, TreeMixin.count
  end
  
  def test_insert
    @extra = @root1.children.create
  
    assert @extra
  
    assert_equal @extra.parent, @root1
  
    assert_equal 3, @root1.children.size
    assert @root1.children.include?(@extra)
    assert @root1.children.include?(@root_child1)
    assert @root1.children.include?(@root_child2)
  end
  
  def test_ancestors
    assert_equal [], @root1.ancestors
    assert_equal [@root1], @root_child1.ancestors
    assert_equal [@root_child1, @root1], @child1_child.ancestors
    assert_equal [@root1], @root_child2.ancestors
    assert_equal [], @root2.ancestors
    assert_equal [], @root3.ancestors
  end
  
  def test_descendants
    assert_equal [@root_child1, @child1_child, @root_child2], @root1.descendants
    assert_equal [@child1_child], @root_child1.descendants
    assert_equal [], @root_child2.descendants
    assert_equal [], @root2.descendants
    assert_equal [], @root3.descendants
  end

  def test_descendant_count
    @extra = @child1_child.children.create
    assert_equal 4, @root1.descendant_count
    assert_equal 2, @root_child1.descendant_count
    assert_equal 1, @child1_child.descendant_count
    assert_equal 0, @extra.descendant_count
    assert_equal 0, @root_child2.descendant_count
    assert_equal 0, @root2.descendant_count
    assert_equal 0, @root3.descendant_count
  end
  
  def test_root
    assert_equal @root1, TreeMixin.root
    assert_equal @root1, @root1.root
    assert_equal @root1, @root_child1.root
    assert_equal @root1, @child1_child.root
    assert_equal @root1, @root_child2.root
    assert_equal @root2, @root2.root
    assert_equal @root3, @root3.root
  end
  
  def test_roots
    assert_equal [@root1, @root2, @root3], TreeMixin.roots
  end
  
  def test_depth
    assert_equal 0, @root1.depth
    assert_equal 0, @root2.depth
    assert_equal 0, @root3.depth
    assert_equal 1, @root_child1.depth 
    assert_equal 1, @root_child2.depth 
    assert_equal 2, @child1_child.depth 
  end
  
  def test_siblings
    assert_equal [@root2, @root3], @root1.siblings
    assert_equal [@root_child2], @root_child1.siblings
    assert_equal [], @child1_child.siblings
    assert_equal [@root_child1], @root_child2.siblings
    assert_equal [@root1, @root3], @root2.siblings
    assert_equal [@root1, @root2], @root3.siblings
  end
  
  def test_self_and_siblings
    assert_equal [@root1, @root2, @root3], @root1.self_and_siblings
    assert_equal [@root_child1, @root_child2], @root_child1.self_and_siblings
    assert_equal [@child1_child], @child1_child.self_and_siblings
    assert_equal [@root_child1, @root_child2], @root_child2.self_and_siblings
    assert_equal [@root1, @root2, @root3], @root2.self_and_siblings
    assert_equal [@root1, @root2, @root3], @root3.self_and_siblings
  end
  
end



class TreeTestWithoutOrder < ActiveSupport::TestCase
  
  def setup                               
    @root1 = TreeMixinWithoutOrder.create!
    @root2 = TreeMixinWithoutOrder.create!
  end

  def test_root
    assert [@root1, @root2].include?(TreeMixinWithoutOrder.root)
  end
  
  def test_roots
    assert_equal [], [@root1, @root2] - TreeMixinWithoutOrder.roots
  end
end

class TreeTestWithInheritingModels < ActiveSupport::TestCase
  
  def setup                               
    @root      = Page.create(:name => "root")
    @child1    = @root.children.create(:name => "child1") # creates a page
    #TODO extend to allow the creation through the children association.
    #@subchild1 = @child1.children.create(:name => "subchild1", :_type => "SubPage")
    @subchild1 = SubPage.create(:name => "subchild1", :parent_id => @child1.id)
  end

  def test_parent
    assert_equal nil, @root.parent
    assert_equal @root, @child1.parent
    assert_equal @child1, @subchild1.parent
  end

  def test_children
    assert_equal [@child1], @root.children
    assert_equal @subchild1, @root.children.first.children.first
  end

  def test_ancestors
    assert_equal [@child1, @root], @subchild1.ancestors
  end

  def test_descendants
    assert_equal [@child1, @subchild1], @root.descendants
    assert_equal 2, @root.descendant_count
  end

  def test_for_expected_classes
    assert_equal Page, @child1.class
    assert_equal SubPage, @child1.children.first.class
  end
end  
