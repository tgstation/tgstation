/// Simple event type that checks if you have a tool and after a retrieval delay adds loot to drone.
/datum/exploration_event/simple/resource
	name = "Retrievable resource"
	root_abstract_type = /datum/exploration_event/simple/resource
	discovery_log = "Encountered recoverable resource"
	action_text = "Extract"
	/// Tool type required to recover this resource
	var/required_tool
	/// What you get out of it, either /obj path or adventure_loot_generator id
	var/loot_type = /obj/item/trash/chips
	/// Message logged on success
	var/success_log = "Retrieved something"
	/// Description shown when you don't have the tool
	var/no_tool_description = "You can't retrieve it without a tool"
	/// Description shown when you have the necessary tool
	var/has_tool_description = "You can get it out with that tool."
	var/delay = 30 SECONDS
	var/delay_message = "Recovering resource..."
	/// How many times can this be extracted
	var/amount = 1

/// Description shown below image
/datum/exploration_event/simple/resource/get_description(obj/item/exodrone/drone)
	. = ..()
	var/list/desc_list = list(.)
	if(!required_tool || drone.has_tool(required_tool))
		desc_list += has_tool_description
	else
		desc_list += no_tool_description
	return desc_list.Join("\n")

/datum/exploration_event/simple/resource/action_enabled(obj/item/exodrone/drone)
	return (amount > 0) && (!required_tool || drone.has_tool(required_tool))

/datum/exploration_event/simple/resource/fire(obj/item/exodrone/drone)
	if(!action_enabled(drone)) //someone used it up or we lost the tool while we were looking at ui
		end()
		return
	amount--
	if(delay > 0)
		drone.set_busy(delay_message,delay)
		addtimer(CALLBACK(src, PROC_REF(delay_finished),WEAKREF(drone)),delay)
	else
		finish_event(drone)

/datum/exploration_event/simple/resource/is_targetable()
	return visited && amount > 0 ///Can go back if something is left.

/datum/exploration_event/simple/resource/proc/delay_finished(datum/weakref/drone_ref)
	var/obj/item/exodrone/drone = drone_ref.resolve()
	if(QDELETED(drone)) //drone blown up in the meantime
		return
	drone.unset_busy(EXODRONE_EXPLORATION)
	finish_event(drone)

/datum/exploration_event/simple/resource/proc/finish_event(obj/item/exodrone/drone)
	drone.drone_log(success_log)
	dispense_loot(drone)
	end(drone)

/datum/exploration_event/simple/resource/proc/dispense_loot(obj/item/exodrone/drone)
	if(ispath(loot_type,/datum/adventure_loot_generator))
		var/datum/adventure_loot_generator/generator = new loot_type
		generator.transfer_loot(drone)
	else
		var/obj/loot = new loot_type()
		drone.try_transfer(loot)


/// Resource Events

// All
/datum/exploration_event/simple/resource/concealed_cache
	name = "Concealed Cache"
	band_values = list(EXOSCANNER_BAND_DENSITY=1)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "Discovered concealed and locked cache."
	description = "You spot a cleverly hidden metal container."
	no_tool_description = "You see no way to open it without a welder."
	has_tool_description = "You can try to open it with your welder"
	action_text = "Weld open"
	delay_message = "Welding open the cache..."
	loot_type = /datum/adventure_loot_generator/maintenance

// EXPLORATION_SITE_RUINS 2/2
/datum/exploration_event/simple/resource/remnants
	name = "dessicated corpse"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "You discovered a corpse of a humanoid."
	description = "You find a dessicated corpose of a humanoid, it's too damaged to identify. A locked briefcase is lying nearby."
	no_tool_description = "You can't open it without a multiool"
	has_tool_description = "You can try to hack it open"
	action_text = "Hack open"
	delay_message = "Hacking..."
	loot_type = /datum/adventure_loot_generator/simple/cash

/datum/exploration_event/simple/resource/gunfight
	name = "gunfight leftovers"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "You discovered a site of some past gunfight."
	description = "You find a site full of gun casing and scorched with laser marks. You notice something under rubble nearby."
	no_tool_description = "You can't get to it without a drill"
	action_text = "Remove rubble"
	delay_message = "Drilling..."
	loot_type = /datum/adventure_loot_generator/simple/weapons

// EXPLORATION_SITE_TECHNOLOGY 2/2
/datum/exploration_event/simple/resource/maint_room
	name = "locked maintenance room"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "You discovered a locked maintenance room."
	success_log = "Retrieved contents of maintenance room."
	description = "You discover a locked maintenance room. You can see marks of something being moved often from it nearby."
	no_tool_description = "You can't open it without a multitool"
	action_text = "Hack"
	delay_message = "Hacking..."
	loot_type = /datum/adventure_loot_generator/maintenance
	amount = 3

/datum/exploration_event/simple/resource/storage
	name = "storage room"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "You discovered a storage room full of crates."
	success_log = "Used translated manifest to find a crate with double bottom."
	description = "You find a storage room full of empty crates. There's a manifest in some obscure language pinned near the entrance."
	no_tool_description = "You can only see empty crates, and can't understand the manifest without a translator."
	action_text = "Translate"
	delay_message = "Translating manifest..."
	loot_type = /datum/adventure_loot_generator/simple/drugs

// EXPLORATION_SITE_ALIEN 2/2
/datum/exploration_event/simple/resource/alien_tools
	name = "alien sarcophagus"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_TECH=1,EXOSCANNER_BAND_RADIATION=1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered a alien sarcophagus covered in unknown glyphs"
	success_log = "Retrieved contents of alien sarcophagus"
	description = "You find an giant sarcophagus of alien origin covered in unknown script."
	no_tool_description = "You see no way to open the sarcophagus or translate the glyphs without a tool."
	has_tool_description = "You translate the glyphs and find a description of a hidden mechanism for unlocking the tomb."
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /obj/item/scalpel/alien

/datum/exploration_event/simple/resource/pod
	name = "alien biopod"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_tool = EXODRONE_TOOL_LASER
	discovery_log = "Discovered an alien pod."
	success_log = "Retrieved contents of the alien pod"
	description = "You encounter an alien biomachinery full of sacks containing some lifeform."
	no_tool_description = "You can't open them without precise laser."
	has_tool_description = "You can try to cut one open with a laser."
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /datum/adventure_loot_generator/pet

// EXPLORATION_SITE_SHIP 2/2
/datum/exploration_event/simple/resource/fuel_storage
	name = "fuel storage"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	band_values = list(EXOSCANNER_BAND_PLASMA=1)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Discovered ship fuel storage."
	description = "You find the ship fuel storage. Unfortunately it's locked with electronic lock."
	success_log = "Retrieved fuel from storage."
	no_tool_description = "You'll need multitool to open it."
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /obj/item/fuel_pellet/exotic

/datum/exploration_event/simple/resource/navigation
	name = "navigation systems"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered ship navigation systems."
	description = "You find the ship navigation systems. With proper tools you can retrieve any data stored here."
	success_log = "Retrieved shipping data from navigation systems."
	no_tool_description = "You'll need a translator to decipher the data."
	delay_message = "Retrieving data..."
	action_text = "Retrieve data"
	loot_type = /datum/adventure_loot_generator/cargo

// EXPLORATION_SITE_HABITABLE 2/2
/datum/exploration_event/simple/resource/unknown_microbiome
	name = "unknown microbiome"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered a isolated microbiome."
	description = "You discover a giant fungus colony."
	success_log = "Retrieved samples of the fungus for future study."
	no_tool_description = "With a laser tool you could slice off a sample for study."
	delay_message = "Taking samples..."
	action_text = "Take sample"
	loot_type = /obj/item/petri_dish/random

/datum/exploration_event/simple/resource/tcg_nerd
	name = "creepy stranger"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Met a creepy stranger."
	description = "You meet an inhabitant of this site. Smelling horribly and clearly agitated about something."
	no_tool_description = "You have no idea what it wants from you without a translator."
	has_tool_description = "Your best translation is that it wants to share its hobby with you. "
	success_log = "Recieved a gift from a stranger."
	delay_message = "Enduring..."
	action_text = "Accept gift."
	loot_type = /obj/item/cardpack/series_one

// EXPLORATION_SITE_SPACE 2/2
/datum/exploration_event/simple/resource/comms_satellite
	name = "derelict comms satellite"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "You discovered a derelict communication satellite."
	description = "You discover a derelict communication satellite. Its encryption module seem intact and can be retrieved."
	no_tool_description = "You'll need a multiool to crack open the lock."
	success_log = "Retrieved encryption keys from derelict satellite"
	delay_message = "Hacking..."
	action_text = "Hack lock"
	loot_type = /obj/item/encryptionkey/heads/captain

/datum/exploration_event/simple/resource/welded_locker
	name = "welded locker"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "You discovered a welded shut locker."
	description = "You discover a welded shut locker floating through space. What could be inside ?"
	success_log = "Retrieved bones of unfortunate spaceman from a welded locker."
	delay_message = "Welding open..."
	action_text = "Weld open"
	loot_type = /obj/item/bodypart/head

/datum/exploration_event/simple/resource/welded_locker/dispense_loot(obj/item/exodrone/drone)
	var/mob/living/carbon/human/head_species_source = new
	head_species_source.set_species(/datum/species/skeleton)
	head_species_source.real_name = "spaced locker victim"
	var/obj/item/bodypart/head/skeleton_head = new
	skeleton_head.update_limb(FALSE,head_species_source)
	qdel(head_species_source)
	drone.try_transfer(skeleton_head)

// EXPLORATION_SITE_SURFACE 2/2
/datum/exploration_event/simple/resource/plasma_deposit
	name = "Raw Plasma Deposit"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_PLASMA=3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a sizeable plasma deposit"
	success_log = "Extracted plasma."
	description = "You locate a rich surface deposit of plasma."
	no_tool_description = "You'll need to come back with a drill to mine it."
	has_tool_description = ""
	action_text = "Mine"
	delay_message = "Mining..."
	loot_type = /obj/item/stack/sheet/mineral/plasma/thirty

/datum/exploration_event/simple/resource/mineral_deposit
	name = "MATERIAL Deposit"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_DENSITY=3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a sizeable MATRIAL deposit"
	success_log = "Extracted MATERIAL."
	description = "You locate a rich surface deposit of MATERIAL."
	no_tool_description = "You'll need to come back with a drill to mine it."
	has_tool_description = ""
	action_text = "Mine"
	delay_message = "Mining..."
	var/static/list/possible_materials = list(/datum/material/silver,/datum/material/bananium,/datum/material/pizza) //only add materials with sheet type here
	var/loot_amount = 30
	var/chosen_material_type

/datum/exploration_event/simple/resource/mineral_deposit/New()
	. = ..()
	chosen_material_type = pick(possible_materials)
	var/datum/material/chosen_mat = GET_MATERIAL_REF(chosen_material_type)
	name = "[chosen_mat.name] Deposit"
	discovery_log = "Discovered a sizeable [chosen_mat.name] deposit"
	success_log = "Extracted [chosen_mat.name]."
	description = "You locate a rich surface deposit of [chosen_mat.name]."

/datum/exploration_event/simple/resource/mineral_deposit/dispense_loot(obj/item/exodrone/drone)
	var/datum/material/chosen_mat = GET_MATERIAL_REF(chosen_material_type)
	var/obj/loot = new chosen_mat.sheet_type(loot_amount)
	drone.try_transfer(loot)
