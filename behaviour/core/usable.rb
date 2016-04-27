module Behaviour
	module Usable
		def activated_uses

			character = nil
			if self.is_a? Entity::Character
				character = self
				targets = [self, self.location]
				intent_type = Intent::ActivateAbilitySelf
			end
			if self.is_a? Entity::Item
				character = self.carrier
				targets = [self]
				intent_type = Intent::ActivateItemSelf
			end

			intents = Hash.new

			#Gather activated uses
			targets.each do |target|
				if target.respond_to? :statuses
					target.statuses.each do |status|
						status.effects.each do |effect|
							if effect.respond_to?(:activate_self_intent)
								intents[status.object_id] = intent_type.new character, target, effect
							end
						end
					end
				end
				if target.respond_to? :type_statuses
					target.type_statuses.each do |status|
						status.effects.each do |effect|
							if effect.respond_to?(:activate_self_intent)
								intents[status.object_id] = intent_type.new character, target, effect
							end
						end
					end
				end
			end

			return intents

		end

	end
end