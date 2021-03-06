require 'autoinc'
module Entity
	class TileType
		include Mongoid::Document
		include Unobservable::Support
		include Mongoid::Autoinc
		include IndefiniteArticle

		field :tile_type_id, type: Integer

		field :name, type: String
		field :description, type: String
		field :colour, type: String

		field :css, type: String

		field :search_rate, as: :s_rate, type: Integer, default: 0
		field :hide_rate, as: :h_rate, type: Integer, default: 0
		field :search_table, as: :s_table, type: Array, default: []

		field :statuses, type: Array, default: []

		field :daytime_inside_message, type: String
		field :daytime_outside_message, type: String
		field :nighttime_inside_message, type: String
		field :nighttime_outside_message, type: String

		@@types = ThreadSafe::Cache.new do |hash, typeident|
			if Entity::TileType.where({tile_type_id: typeident}).exists? then
				eff = Entity::TileType.find_by({tile_type_id: typeident})
				hash[typeident] = eff
			else
				Entity::VoidTileType
			end
		end

		def self.find(type)
			type = type.to_i
			if type == -1
				Entity::VoidTileType
			else
				@@types[type]
			end
		end

		def search_roll_item
			rnd_max = self.search_table.inject(0) { |sum, itm| sum + itm[1] }
			return nil unless rnd_max > 0

			roll = rand(1..rnd_max)

			self.search_table.each do |possibility|
				roll -= possibility[1]
				return Entity::Item.source_from(possibility[0]) unless roll > 0
			end

			return nil
		end

		def traversible?
			true
		end

		def self.purge_cache
			@@types.clear
		end

		def self.load_types
			TileType.each do |type|
				@@types[type.id] = type
			end
		end

		def self.reload_types
			@@types.keys.each do |k|
				@@types[k].reload
			end
		end

		def to_s
			self.name
		end

		after_find do |document|
			document.search_table = [] if document.search_table === nil
		end
		after_initialize do |document|
			document.search_table = [] if document.search_table === nil
		end
	end
end
