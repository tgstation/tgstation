/datum/armament_entry/assault_operatives/implants
	category = "Cybernetic Implants"
	category_item_limit = 3

/datum/armament_entry/assault_operatives/implants/deathrattle
	name = "Deathrattle Implant Kit"
	description = "A collection of implants (and one reusable implanter) that should be injected into the team. When one of the team \
	dies, all other implant holders receive a mental message informing them of their teammates' name \
	and the location of their death. Unlike most implants, these are designed to be implanted \
	in any creature, biological or mechanical."
	item_type = /obj/item/storage/box/syndie_kit/imp_deathrattle
	cost = 1

/datum/armament_entry/assault_operatives/implants/microbomb
	name = "Microbomb Implant"
	description = "A small bomb implanted into the body. It can be activated manually, or automatically activates on death. WARNING: Permenantly destroys your body and everything you might be carrying."
	item_type = /obj/item/implanter/explosive
	cost = 2

/datum/armament_entry/assault_operatives/implants/storage
	name = "Storage Implant"
	description = "Implanted into the body and activated at will, this covert implant will open a small pocket of bluespace capable of holding two regular sized items within."
	item_type = /obj/item/implanter/storage
	cost = 2

/datum/armament_entry/assault_operatives/implants/radio
	name = "Radio Implant"
	description = "Implanted into the body and activated at will, this covert implant will allow you to speak over the radio without the need of a headset."
	item_type = /obj/item/implanter/radio/syndicate
	cost = 1

/datum/armament_entry/assault_operatives/implants/freedom
	name = "Freedom Implant"
	description = "Releases the user from common restraints like handcuffs and legcuffs. Comes with four charges."
	item_type = /obj/item/storage/box/syndie_kit/imp_freedom
	cost = 3

/datum/armament_entry/assault_operatives/implants/thermal
	name = "Thermal Vision Implant"
	description = "These cybernetic eyes will give you thermal vision."
	item_type = /obj/item/autosurgeon/syndicate/thermal_eyes
	cost = 5

/datum/armament_entry/assault_operatives/implants/nodrop
	name = "Anti-Drop Implant"
	description = "When activated forces your hand muscles to tightly grip the object you are holding, preventing you from dropping it involuntarily."
	item_type = /obj/item/autosurgeon/syndicate/nodrop
	cost = 5
