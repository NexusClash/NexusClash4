module Effect
	class CriticalHit

		attr_reader :parent, :chance, :base_bonus, :level_mult, :level_div

		def initialize(parent, chance = 30, base_bonus = 3, level_mult = 1, level_div = 4)
			@parent = parent
			@chance = chance
			@base_bonus = base_bonus
			@level_mult = level_mult
			@level_div = level_div
		end

		def name
			@parent.name
		end

		def alter_attack_intent(intent)

			intent.debug self
			roll = rand(1..100)
			if roll < chance
				intent.append_message(' This was a critical hit!')  if intent.hit?
				damage = base_bonus + (intent.entity.level * level_mult / level_div).floor
				intent.damage += damage
				intent.debug "#{chance}% crit roll... #{roll} = CRIT! Increasing damage by #{damage}."
			else
				intent.debug "#{chance}% crit roll... #{roll} = Not a crit."
			end
			return intent
		end

		def describe
			text = "#{chance}% of increasing damage by #{base_bonus} + (level"
			text << " * #{level_mult}" unless level_mult == 1
			text << " / #{level_div}" unless level_div == 1
			text << ')'
			return text
		end

		def save_state
			['CriticalHit', chance, base_bonus, level_mult, level_div]
		end
	end
end