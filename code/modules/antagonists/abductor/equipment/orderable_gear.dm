GLOBAL_LIST_INIT(abductor_gear, subtypesof(/datum/abductor_gear))

/datum/abductor_gear
	/// Name of the gear
	var/name = "Generic Abductor Gear"
	/// Description of the gear
	var/description = "Generic description."
	/// Unique ID of the gear
	var/id = "abductor_generic"
	/// Credit cost of the gear
	var/cost = 1
	/// Build path of the gear itself
	var/build_path = null
	/// Category of the gear
	var/category = "Basic Gear"

/datum/abductor_gear/agent_helmet
	name = "Agent Helmet"
	description = "Abduct with style - spiky style. Prevents digital tracking."
	id = "agent_helmet"
	build_path = /obj/item/clothing/head/helmet/abductor

/datum/abductor_gear/agent_vest
	name = "Agent Vest"
	description = "A vest outfitted with advanced stealth technology. It has two modes - combat and stealth."
	id = "agent_vest"
	build_path = /obj/item/clothing/suit/armor/abductor/vest

/datum/abductor_gear/radio_silencer
	name = "Radio Silencer"
	description = "A compact device used to shut down communications equipment."
	id = "radio_silencer"
	build_path = /obj/item/abductor/silencer

/datum/abductor_gear/science_tool
	name = "Science Tool"
	description = "A dual-mode tool for retrieving specimens and scanning appearances. Scanning can be done through cameras."
	id = "science_tool"
	build_path = /obj/item/abductor/gizmo

/datum/abductor_gear/advanced_baton
	name = "Advanced Baton"
	description = "A quad-mode baton used for incapacitation and restraining of specimens."
	id = "advanced_baton"
	cost = 2
	build_path = /obj/item/melee/baton/abductor

/datum/abductor_gear/superlingual_matrix
	name = "Superlingual Matrix"
	description = "A mysterious structure that allows for instant communication between users. Pretty impressive until you need to eat something."
	id = "superlingual_matrix"
	build_path = /obj/item/organ/tongue/abductor
	category = "Advanced Gear"

/datum/abductor_gear/mental_interface
	name = "Mental Interface Device"
	description = "A dual-mode tool for directly communicating with sentient brains. It can be used to send a direct message to a target, \
				or to send a command to a test subject with a charged gland."
	id = "mental_interface"
	cost = 2
	build_path = /obj/item/abductor/mind_device
	category = "Advanced Gear"

/datum/abductor_gear/reagent_synthesizer
	name = "Reagent Synthesizer"
	description = "Synthesizes a variety of reagents using proto-matter."
	id = "reagent_synthesizer"
	cost = 2
	build_path = /obj/item/abductor_machine_beacon/chem_dispenser
	category = "Advanced Gear"

/datum/abductor_gear/shrink_ray
	name = "Shrink Ray Blaster"
	description = "This is a piece of frightening alien tech that enhances the magnetic pull of atoms in a localized space to temporarily make an object shrink. \
				That or it's just space magic. Either way, it shrinks stuff."
	id = "shrink_ray"
	cost = 2
	build_path = /obj/item/gun/energy/shrink_ray
	category = "Advanced Gear"
