module Effect
	class CastSpellsWell

		attr_reader :parent

		def initialize(parent)
			@parent = parent
			unserialise
		end

		def unserialise
			character = @parent
			character = @parent.stateful if character.is_a? Entity::Status
			character = @parent.carrier if character.is_a? Entity::Item
			character.casts_at_normal_damage = true if character.respond_to? :casts_at_normal_damage=
		end

		def describe
			'Combat spells no longer roll an extra die and drop highest.'
		end

		def save_state
			['CastSpellsWell']
		end
	end
end
