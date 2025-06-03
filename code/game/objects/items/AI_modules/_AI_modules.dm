///defined truthy result for `handle_unique_ai()`, which makes initialize return INITIALIZE_HINT_QDEL
#define SHOULD_QDEL_MODULE 1

/obj/item/ai_module
	name = "\improper AI module"
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "std_mod"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	desc = "An AI Module for programming laws to an AI."
	obj_flags = CONDUCTS_ELECTRICITY
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.5)
	/// This is where our laws get put at for the module
	var/list/laws = list()
	/// The laws list last time save_laws() was called
	VAR_PRIVATE/list/saved_laws
	/// If TRUE, this board has sustained damage and must be repaired
	VAR_FINAL/ioned = FALSE

/obj/item/ai_module/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI) && is_station_level(z))
		var/delete_module = handle_unique_ai()
		if(delete_module)
			return INITIALIZE_HINT_QDEL

/obj/item/ai_module/examine(mob/user as mob)
	. = ..()
	var/examine_laws = display_laws()
	if(examine_laws)
		. += "\n" + examine_laws
	if(ioned)
		. += "\nThis module has been damaged and should be repaired with a [EXAMINE_HINT("multitool")]."

/// Updates the "ioned" stat of the module
/obj/item/ai_module/proc/set_ioned(new_ioned)
	var/old_ioned = ioned
	ioned = new_ioned
	if(old_ioned != ioned)
		update_appearance()

/// Saves whatever laws are currently programmed into the module, so they can be restored later.
/obj/item/ai_module/proc/save_laws()
	saved_laws = laws.Copy()

/obj/item/ai_module/update_overlays()
	. = ..()
	if(ioned)
		. += "damaged"

/// Called before being installed into a law rack. Return FALSE to block installation.
/obj/item/ai_module/proc/can_install_to(mob/living/user, obj/machinery/ai_law_rack/rack)
	return TRUE

/// Called after a module is installed into a law rack.
/obj/item/ai_module/proc/on_install(mob/living/user, obj/machinery/ai_law_rack/rack)
	return

/obj/item/ai_module/multitool_act(mob/living/user, obj/item/tool)
	if(!ioned)
		return NONE
	balloon_alert(user, "repairing ion damage...")
	if(!tool.use_tool(user, 4 SECONDS, volume = 10))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "module repaired")
	set_ioned(FALSE)
	laws = saved_laws
	saved_laws = null
	return ITEM_INTERACT_SUCCESS

/obj/item/ai_module/attack_self(mob/user)
	. = ..()
	if(.)
		return

	var/displayed = display_laws()
	if(displayed)
		to_chat(user, boxed_message(displayed))
		. = TRUE
	if(!ioned && user.is_holding(src))
		. = configure(user)

/// Allows users to configure aspects of the module, if applicable.
/obj/item/ai_module/proc/configure(mob/user)
	return FALSE

/// Returns a text display of the laws for the module.
/obj/item/ai_module/proc/display_laws()
	// Used to assemble the laws to show to an examining user.
	var/assembled_laws = ""

	if(laws.len)
		assembled_laws += "<B>Programmed Law[(laws.len > 1) ? "s" : ""]:</B><br>"
		for(var/law in laws)
			assembled_laws += "\"[law]\"<br>"

	return assembled_laws

///what this module should do if it is mapload spawning on a unique AI station trait round.
/obj/item/ai_module/proc/handle_unique_ai()
	return SHOULD_QDEL_MODULE //instead of the roundstart bid to un-unique the AI, there will be a research requirement for it.

/obj/item/ai_module/proc/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	return

/obj/item/ai_module/core
	desc = "An AI Module for programming core laws to an AI."

/obj/item/ai_module/core/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	for(var/law in laws)
		combined_lawset.add_inherent_law(law)

/obj/item/ai_module/core/full
	var/law_id // if non-null, loads the laws from the ai_laws datums

/obj/item/ai_module/core/full/Initialize(mapload)
	. = ..()
	if(!law_id)
		return
	var/lawtype = lawid_to_type(law_id)
	if(!lawtype)
		return
	var/datum/ai_laws/core_laws = new lawtype
	laws = core_laws.inherent

/obj/item/ai_module/core/full/handle_unique_ai()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	if(law_id == initial(default_laws.id))
		return
	return SHOULD_QDEL_MODULE

/obj/effect/spawner/round_default_module
	name = "ai default lawset spawner"
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	color = COLOR_VIBRANT_LIME

/obj/effect/spawner/round_default_module/Initialize(mapload)
	. = ..()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	//try to spawn a law board, since they may have special functionality (asimov setting subjects)
	for(var/obj/item/ai_module/core/full/potential_lawboard as anything in subtypesof(/obj/item/ai_module/core/full))
		if(initial(potential_lawboard.law_id) != initial(default_laws.id))
			continue
		potential_lawboard = new potential_lawboard(loc)
		return
	//spawn the fallback instead
	new /obj/item/ai_module/core/round_default_fallback(loc)

///When the default lawset spawner cannot find a module object to spawn, it will spawn this, and this sets itself to the round default.
///This is so /datum/lawsets can be picked even if they have no module for themselves.
/obj/item/ai_module/core/round_default_fallback

/obj/item/ai_module/core/round_default_fallback/Initialize(mapload)
	. = ..()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	default_laws = new default_laws()
	name = "'[default_laws.name]' Core AI Module"
	laws = default_laws.inherent

/obj/item/ai_module/core/round_default_fallback/handle_unique_ai()
	return

#undef SHOULD_QDEL_MODULE
