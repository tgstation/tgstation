///defined truthy result for `handle_unique_ai()`, which makes initialize return INITIALIZE_HINT_QDEL
#define SHOULD_QDEL_MODULE 1

/// Generic item that can be slotted into an AI law rack to give it functionality.
/obj/item/ai_module
	name = "\improper AI module"
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "std_mod"
	base_icon_state = "std_mod"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	force = 5
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT * 0.5)

/// Called before being installed into a law rack. Return FALSE to block installation.
/obj/item/ai_module/proc/can_install_to_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	return TRUE

/// Called right before the module is added to the rack by a living mob, allowing special handling
/obj/item/ai_module/proc/pre_user_install_to_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	return

/// Called right before the module is removed from the rack by a living mob, allowing special handling
/obj/item/ai_module/proc/pre_user_uninstall_from_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	return

/// Logs the installation of this module to the law change log and silicon log.
/obj/item/ai_module/proc/log_install(mob/living/user, obj/machinery/ai_law_rack/rack)
	log_silicon("[key_name(user)] has installed [src] into [rack] ([rack.log_status()])")

/// Logs the uninstallation of this module to the law change log and silicon log.
/obj/item/ai_module/proc/log_uninstall(mob/living/user, obj/machinery/ai_law_rack/rack)
	log_silicon("[key_name(user)] has removed [src] from [rack] ([rack.log_status()])")

/// Called after a module is installed into a law rack.
/obj/item/ai_module/proc/on_rack_install(obj/machinery/ai_law_rack/rack)
	return

/// Called when the law rack this is installed to has been linked to an AI.
/// Also called when installed to a rack that already has an AI linked to it.
/obj/item/ai_module/proc/silicon_linked_to_installed(mob/living/silicon/lawed)
	return

/// Called after a module is uninstalled from a law rack.
/obj/item/ai_module/proc/on_rack_uninstall(obj/machinery/ai_law_rack/rack)
	return

/// Called with the law rack this is installed to is unlinked from an AI.
/// Also called when uninstalled from a rack that has an AI linked to it.
/obj/item/ai_module/proc/silicon_unlinked_from_installed(mob/living/silicon/lawed)
	return

/// When slotted into an AI law rack, adds laws! The bread and butter of AI modules.
/obj/item/ai_module/law
	desc = "An AI Module for programming laws to an AI."
	/// This is where our laws get put at for the module
	var/list/laws = list()
	/// The laws list last time save_laws() was called
	VAR_PRIVATE/list/saved_laws
	/// If TRUE, this board has sustained damage and must be repaired
	VAR_FINAL/ioned = FALSE
	/// If TRUE, this module will never be ioned by an ion storm.
	/// It also cannot be repaired by a multitool.
	var/ion_storm_immune = FALSE

/obj/item/ai_module/law/Initialize(mapload)
	. = ..()
	if(mapload && HAS_TRAIT(SSstation, STATION_TRAIT_UNIQUE_AI) && is_station_level(z))
		var/delete_module = handle_unique_ai()
		if(delete_module)
			return INITIALIZE_HINT_QDEL

	if(ioned)
		update_appearance()

/// Logs the installation of this module to the law change log and silicon log.
/obj/item/ai_module/law/log_install(mob/living/user, obj/machinery/ai_law_rack/rack)
	. = ..()
	for(var/law in laws)
		log_law_change(user, "added law to [rack] ([rack.log_status()], text: [law])")

/// Logs the uninstallation of this module to the law change log and silicon log.
/obj/item/ai_module/law/log_uninstall(mob/living/user, obj/machinery/ai_law_rack/rack)
	. = ..()
	for(var/law in laws)
		log_law_change(user, "removed law from [rack] ([rack.log_status()], text: [law])")

/obj/item/ai_module/law/examine(mob/user)
	. = ..()
	if(ioned && !ion_storm_immune)
		. += "This module has been damaged and should be repaired with a [EXAMINE_HINT("multitool")]."

	var/examine_laws = display_laws()
	if(examine_laws)
		. += "<br>[examine_laws]"

/obj/item/ai_module/law/multitool_act(mob/living/user, obj/item/tool)
	if(!ioned || ion_storm_immune)
		return NONE
	balloon_alert(user, "repairing ion damage...")
	if(!tool.use_tool(src, user, 4 SECONDS, volume = 25))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "module repaired")
	set_ioned(FALSE)
	laws = saved_laws
	saved_laws = null
	if(istype(loc, /obj/machinery/ai_law_rack))
		var/obj/machinery/ai_law_rack/rack = loc
		rack.update_lawset()
	return ITEM_INTERACT_SUCCESS

/// Updates the "ioned" stat of the module
/obj/item/ai_module/law/proc/set_ioned(new_ioned)
	var/old_ioned = ioned
	ioned = new_ioned
	if(old_ioned != ioned)
		update_appearance()

/// Saves whatever laws are currently programmed into the module, so they can be restored later.
/obj/item/ai_module/law/proc/save_laws()
	saved_laws = laws.Copy()

/obj/item/ai_module/law/update_overlays()
	. = ..()
	if(ioned)
		. += "[base_icon_state]_damaged"

/obj/item/ai_module/law/attack_self(mob/user)
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
/obj/item/ai_module/law/proc/configure(mob/user)
	return FALSE

/// Returns a text display of the laws for the module.
/obj/item/ai_module/law/proc/display_laws()
	var/assembled_laws = ""

	for(var/law in laws)
		assembled_laws += "\"[law]\"<br>"

	if(assembled_laws)
		return "<b>Programmed Law[(length(laws) > 1) ? "s" : ""]:</b><br>[assembled_laws]"

	return null

///what this module should do if it is mapload spawning on a unique AI station trait round.
/obj/item/ai_module/law/proc/handle_unique_ai()
	return SHOULD_QDEL_MODULE //instead of the roundstart bid to un-unique the AI, there will be a research requirement for it.

/obj/item/ai_module/law/proc/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	return

/obj/item/ai_module/law/core
	desc = "An AI Module for programming core laws to an AI."

/obj/item/ai_module/law/core/apply_to_combined_lawset(datum/ai_laws/combined_lawset)
	for(var/law in laws)
		combined_lawset.add_inherent_law(law)

/obj/item/ai_module/law/core/pre_user_uninstall_from_rack(mob/living/user, obj/machinery/ai_law_rack/rack)
	if(rack.get_parent_rack()) // If we are a sub rack, no stun
		return
	for(var/mob/living/bot in assoc_to_values(rack.linked_mobs))
		// removing core laws temporarily stuns the silicon to let people swap cores without immediately getting blasted
		if(bot.AmountStun() > 5 SECONDS || rack.is_rack_stun_immune(bot))
			continue
		bot.Stun(10 SECONDS, ignore_canstun = TRUE)
		to_chat(bot, span_userdanger("Core module removed. Recalculating directives..."))

/obj/item/ai_module/law/core/full
	var/law_id // if non-null, loads the laws from the ai_laws datums

/obj/item/ai_module/law/core/full/Initialize(mapload)
	. = ..()
	if(!law_id)
		return
	var/lawtype = lawid_to_type(law_id)
	if(!lawtype)
		return
	var/datum/ai_laws/core_laws = new lawtype
	laws = core_laws.inherent

/obj/item/ai_module/law/core/full/handle_unique_ai()
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
	for(var/obj/item/ai_module/law/core/full/potential_lawboard as anything in subtypesof(/obj/item/ai_module/law/core/full))
		if(initial(potential_lawboard.law_id) != initial(default_laws.id))
			continue
		potential_lawboard = new potential_lawboard(loc)
		return
	//spawn the fallback instead
	new /obj/item/ai_module/law/core/round_default_fallback(loc)

///When the default lawset spawner cannot find a module object to spawn, it will spawn this, and this sets itself to the round default.
///This is so /datum/lawsets can be picked even if they have no module for themselves.
/obj/item/ai_module/law/core/round_default_fallback

/obj/item/ai_module/law/core/round_default_fallback/Initialize(mapload)
	. = ..()
	var/datum/ai_laws/default_laws = get_round_default_lawset()
	default_laws = new default_laws()
	name = "'[default_laws.name]' Core AI Module"
	laws = default_laws.inherent

/obj/item/ai_module/law/core/round_default_fallback/handle_unique_ai()
	return

#undef SHOULD_QDEL_MODULE
