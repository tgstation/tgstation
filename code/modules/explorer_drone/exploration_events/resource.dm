/// Simple event type that checks if you have a tool and after a retrieval delay adds loot to drone.
/datum/exploration_event/simple/resource
	name = "retrievable resource"
	root_abstract_type = /datum/exploration_event/simple/resource
	discovery_log = "Encountered recoverable resource."
	action_text = "Extract"
	/// Tool type required to recover this resource
	var/required_tool
	/// What you get out of it, either /obj path or adventure_loot_generator id
	var/loot_type = /obj/item/trash/chips
	/// Message logged on success
	var/success_log = "Retrieved something"
	/// Description shown when you don't have the tool
	var/no_tool_description = "You can't retrieve it without a drill."
	/// Description shown when you have the necessary tool
	var/has_tool_description = "You can get it out with your drill!"
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
	name = "concealed cache"
	band_values = list(EXOSCANNER_BAND_DENSITY=1)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "Discovered a concealed, locked cache."
	description = "You spot a cleverly hidden metal container."
	no_tool_description = "You see no way to open it without a welder."
	has_tool_description = "You can try and open it with your welder."
	action_text = "Weld open"
	delay_message = "Welding open the cache..."
	loot_type = /datum/adventure_loot_generator/maintenance

// EXPLORATION_SITE_RUINS 2/2
/datum/exploration_event/simple/resource/remnants
	name = "dessicated corpse"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Discovered a corpse of a humanoid."
	description = "You find a dessicated corpose of a humanoid, though it's too damaged to identify. A locked briefcase is lying nearby."
	no_tool_description = "You can't open it without a multiool."
	has_tool_description = "You can try to hack it open with your multitool!"
	action_text = "Hack open"
	delay_message = "Hacking..."
	loot_type = /datum/adventure_loot_generator/simple/cash

/datum/exploration_event/simple/resource/gunfight
	name = "gunfight leftovers"
	required_site_traits = list(EXPLORATION_SITE_RUINS)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a site of a past gunfight."
	description = "You find a site full of gun casings and scorched with laser marks. You notice something under some nearby rubble."
	no_tool_description = "You can't get to it without a drill."
	has_tool_description = "You can remove the rubble with your drill!"
	action_text = "Remove rubble"
	delay_message = "Drilling..."
	loot_type = /datum/adventure_loot_generator/simple/weapons

// EXPLORATION_SITE_TECHNOLOGY 2/2
/datum/exploration_event/simple/resource/maint_room
	name = "locked maintenance room"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Discovered a locked maintenance room."
	success_log = "Retrieved the contents of a locked maintenance room."
	description = "You discover a locked maintenance room. You can see marks from frequent movement nearby."
	no_tool_description = "You can't open it without a multitool."
	has_tool_description = "You can try to open it with your multitool!"
	action_text = "Hack"
	delay_message = "Hacking..."
	loot_type = /datum/adventure_loot_generator/maintenance
	amount = 3

/datum/exploration_event/simple/resource/storage
	name = "storage room"
	required_site_traits = list(EXPLORATION_SITE_TECHNOLOGY,EXPLORATION_SITE_STATION)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered a storage room full of crates."
	success_log = "Used a translated manifest to find a crate of medication."
	description = "You find a storage room full of unidentified crates. There's a manifest in an obscure language pinned near the entrance."
	no_tool_description = "All the crates around are devoid of useful contents, and the manifest is unreadable without a translator."
	has_tool_description = "You can translate the manifest with your translator!"
	action_text = "Translate"
	delay_message = "Translating manifest..."
	loot_type = /datum/adventure_loot_generator/simple/drugs

// EXPLORATION_SITE_ALIEN 2/2
/datum/exploration_event/simple/resource/alien_tools
	name = "alien sarcophagus"
	required_site_traits = list(EXPLORATION_SITE_ALIEN)
	band_values = list(EXOSCANNER_BAND_TECH=1,EXOSCANNER_BAND_RADIATION=1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered an alien sarcophagus covered in unknown glyphs."
	success_log = "Retrieved contents of an alien sarcophagus."
	description = "You find a giant sarcophagus of alien origin, covered in unknown script."
	no_tool_description = "You see no way to open the sarcophagus nor translate the glyphs without a multitool."
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
	success_log = "Retrieved contents of the alien pod."
	description = "You encounter an alien biopod full of strange sacks containing abducted lifeforms."
	no_tool_description = "You can't breach the biopod without a precise laser."
	has_tool_description = "You can try to cut one open with your laser!"
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
	description = "You find the ship's fuel storage. Unfortunately, it has an electronic lock."
	success_log = "Retrieved fuel from storage."
	no_tool_description = "You can't breach the lock without a multitool."
	has_tool_description = "You can try and short circuit the lock with your multitool!"
	delay_message = "Opening..."
	action_text = "Open"
	loot_type = /obj/item/fuel_pellet/exotic

/datum/exploration_event/simple/resource/navigation
	name = "navigation systems"
	required_site_traits = list(EXPLORATION_SITE_SHIP)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Discovered ship navigation systems."
	description = "You find the ship's navigation systems encoded in a strange language. You'll be able to use the data with a translator."
	success_log = "Retrieved shipping data from navigation systems."
	no_tool_description = "You'll need a translator to decipher the data."
	has_tool_description = "You can try and translate the navigation data with your multitool!"
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
	no_tool_description = "With a precise laser, you could slice off a sample for study."
	has_tool_description = "You can carefully cut a sample from the colony with your laser!"
	delay_message = "Taking samples..."
	action_text = "Take sample"
	loot_type = /obj/item/petri_dish/random

/datum/exploration_event/simple/resource/tcg_nerd
	name = "creepy stranger"
	required_site_traits = list(EXPLORATION_SITE_HABITABLE)
	band_values = list(EXOSCANNER_BAND_LIFE=1)
	required_tool = EXODRONE_TOOL_TRANSLATOR
	discovery_log = "Met a creepy stranger."
	description = "You meet an inhabitant of this site, looking ragged and clearly agitated about something."
	no_tool_description = "You can't tell what it's trying to convey without a translator."
	has_tool_description = "Your best translation dictates that it would like to share its hobby with you!"
	success_log = "Recieved a gift from a stranger."
	delay_message = "Enduring..."
	action_text = "Accept gift."
	loot_type = /obj/item/cardpack/series_one

// EXPLORATION_SITE_SPACE 2/2
/datum/exploration_event/simple/resource/comms_satellite
	name = "derelict comms satellite"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_MULTITOOL
	discovery_log = "Discovered a derelict communication satellite."
	description = "You discover a derelict communication satellite. Its encryption key is intact, but has a complicated electronic lock."
	no_tool_description = "You'll need a multiool to retrieve the encryption key."
	has_tool_description = "You can disable the lock to retrieve the key with your multitool!"
	success_log = "Retrieved an encryption key from a derelict satellite."
	delay_message = "Hacking..."
	action_text = "Hack lock"
	loot_type = /obj/item/encryptionkey/heads/captain

/datum/exploration_event/simple/resource/welded_locker
	name = "welded locker"
	required_site_traits = list(EXPLORATION_SITE_SPACE)
	required_tool = EXODRONE_TOOL_WELDER
	discovery_log = "Discovered a hastily welded locker."
	description = "You discover a welded locker floating through space. What could be inside...?"
	no_tool_description = "You'll need a welding tool to take the contents of the locker."
	success_log = "Retrieved... a severed head."
	delay_message = "Welding open..."
	action_text = "Weld open"
	loot_type = /obj/item/bodypart/head

/datum/exploration_event/simple/resource/welded_locker/dispense_loot(obj/item/exodrone/drone)
	var/mob/living/carbon/human/head_species_source = new
	head_species_source.set_species(/datum/species/skeleton)
	head_species_source.real_name = "spaced locker victim"
	var/obj/item/bodypart/head/skeleton_head = head_species_source.get_bodypart(BODY_ZONE_HEAD)
	skeleton_head.drop_limb(FALSE)
	qdel(head_species_source)
	drone.try_transfer(skeleton_head)

// EXPLORATION_SITE_SURFACE 2/2
/datum/exploration_event/simple/resource/plasma_deposit
	name = "Raw Plasma Deposit"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_PLASMA=3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a sizeable plasma deposit."
	success_log = "Extracted the plasma from the deposit."
	description = "You locate a rich surface deposit of plasma."
	no_tool_description = "You'll need a drill to take anything from the deposit."
	has_tool_description = "Your drill will allow you to extract the deposit!"
	action_text = "Mine"
	delay_message = "Mining..."
	loot_type = /obj/item/stack/sheet/mineral/plasma/thirty

/datum/exploration_event/simple/resource/mineral_deposit
	name = "MATERIAL Deposit"
	required_site_traits = list(EXPLORATION_SITE_SURFACE)
	band_values = list(EXOSCANNER_BAND_DENSITY=3)
	required_tool = EXODRONE_TOOL_DRILL
	discovery_log = "Discovered a sizeable MATRIAL deposit."
	success_log = "Extracted the MATERIAL from the deposit."
	description = "You locate a rich surface deposit of MATERIAL."
	no_tool_description = "You'll need a drill to take anything from the deposit."
	has_tool_description = "Your drill will allow you to extract the deposit!"
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
