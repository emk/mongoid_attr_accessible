WORK IN PROGRESS!  This doesn't do anything yet.

## The problem(s)

Mongoid's built-in `:accessible` support suffers from a number of severe
limitations that can get you in quite a bit of trouble if you do this:

    # Don't do this with standard Mongoid!
    Player.create(params[:player])

    # Don't do this, either.
    player.update_attributes(params[:player])

When you do either of these, you take unsanitized user input from `params`
and use it to directly modify a player object.  For example:

    # An item carried by a player in an online game.
    class Item
      include Mongoid::Document

      embedded_in :player, :inverse_of => :items
      field :name, String
    end

    # A player in an online game.
    class Player
      include Mongoid::Document

      # This field should be editable by the user.
      field :name, :accessible => true

      embeds_many :items
    
      def authenticated_as_admin=(value)
        @authenticated_as_admin = value
      end
    end

    # Some very malicious form data parsed out by Rack.
    form_data = {
      :items => {
        '_id' => "4bee89c6aea6ec4457000005",
        '_type' => "Item",
        'name' => "Master Sword"
      },
      :authenticated_as_admin => "Yup!"
    }

    # Get some nice equipment upgrades and pretend to be an admin.
    player.update_attributes(form_data)

Of course, you could just avoid bulk assignment of untrusted data (an
excellent idea in and of itself).  But there are some Rails engine plugin
which call `update_attributes` with untrusted data, leading to potentially
disasterous consequences.

## Why it fails

Here are the problematic bits of code from Mongoid.  This function will
bulk update any attributes where `write_allowed?` returns true:

    # From Mongoid::Attributes::InstanceMethods.
    def process(attrs = nil)
      (attrs || {}).each_pair do |key, value|
        if set_allowed?(key)
          @attributes[key.to_s] = value
        elsif write_allowed?(key)
          send("#{key}=", value)
        end
      end
      setup_modifications
    end

And `write_allowed?` returns true for anything which isn't explicitly
listed as a field:

    def write_allowed?(key)
      name = key.to_s
      existing = fields[name]
      return true unless existing
      existing.accessible?
    end

## The fix

We replace `write_allowed?` with a much stricter policy, making it possible
to use `attr_accesible` in a fashion similar to that of ActiveRecord.

    class Player
      include Mongoid::Document

      field :name

      embeds_many :items
    
      def authenticated_as_admin=(value)
        @authenticated_as_admin = value
      end

      # Only explicitly-listed fields should be bulk updatable.
      attr_accessible :name
    end

We also attempt to disable `Mongoid.allow_dynamic_fields` for classes where
`attr_accessible` is used.

## Why don't you support `attr_protected`?

The Mongoid codebase has lots of tricky corner cases like `_type=` that
would need to be extensively audited and carefully tested before supporting
something like `attr_protected`.  And `attr_protected` only offers
black-list based security, which relies on programmer caution and
exhaustive listing of anything which might be problematic.
