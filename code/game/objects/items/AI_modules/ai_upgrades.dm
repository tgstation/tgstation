///AI Upgrades

/// AI module which gives some specific malf ai ability when installed in a law rack
/obj/item/ai_module/upgrade
	name = "ai upgrade module"
	desc = "An AI Module for installing upgrades to an AI."
	icon_state = "mcontroller"

	///The upgrade that will be applied to the AI when installed
	var/upgrade_type = /datum/ai_module
	/// Actual upgrade datum that will be applied to the AI when installed
	VAR_PRIVATE/datum/ai_module/gift

/obj/item/ai_module/upgrade/Initialize(mapload)
	. = ..()
	gift = new upgrade_type()

/obj/item/ai_module/upgrade/Destroy()
	QDEL_NULL(gift)
	return ..()

/obj/item/ai_module/upgrade/silicon_linked_to_installed(mob/living/silicon/lawed)
	if(!isAI(lawed))
		return

	if(gift.unlock_text)
		to_chat(lawed, gift.unlock_text)
	if(gift.unlock_sound)
		lawed.playsound_local(lawed, gift.unlock_sound, 50, 0)

	if(gift.upgrade)
		gift.upgrade(lawed)
	else if(!(locate(gift.power_type) in lawed.actions))
		var/datum/action/gifted_action = new gift.power_type()
		gifted_action.Grant(lawed)

/obj/item/ai_module/upgrade/silicon_unlinked_from_installed(mob/living/silicon/lawed)
	if(!isAI(lawed))
		return
	if(gift.upgrade)
		// Can't un-upgrade (yet), so just return
		return
	if(IS_MALF_AI(lawed))
		// To prevent accidentally deleting a hard earned malf ability
		return

	var/datum/action/innate/ai/existing_action = locate(gift.power_type) in lawed.actions
	qdel(existing_action)

/// AI module which gives some ALL malf ai abilities when installed in a law rack
/obj/item/ai_module/combat
	name = "combat software upgrade"
	desc = "A highly illegal, highly dangerous upgrade for artificial intelligence units, granting them a variety of powers as well as the ability to hack APCs.<br>This upgrade does not override any active laws, and must be applied directly to an active AI core."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "secmodschematic"

/obj/item/ai_module/combat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/ai_module/combat/log_install(mob/living/user, obj/machinery/ai_law_rack/rack)
	. = ..()
	message_admins("[ADMIN_LOOKUPFLW(user)] has installed [src] into [ADMIN_VERBOSEJMP(rack)] ([rack.log_status()])")

/obj/item/ai_module/combat/log_uninstall(mob/living/user, obj/machinery/ai_law_rack/rack)
	. = ..()
	message_admins("[ADMIN_LOOKUPFLW(user)] has removed [src] from [ADMIN_VERBOSEJMP(rack)] ([rack.log_status()])")

/obj/item/ai_module/combat/silicon_linked_to_installed(mob/living/silicon/lawed)
	if(!isAI(lawed))
		return
	var/mob/living/silicon/ai/combatai = lawed
	if(combatai.malf_picker)
		return
	to_chat(combatai, span_userdanger("Your module rack has been upgraded with combat software!"))
	to_chat(combatai, span_danger("Your current laws and objectives remain unchanged.")) //this unlocks malf powers, but does not give the license to plasma flood
	combatai.add_malf_picker()
	combatai.hack_software = TRUE

/obj/item/ai_module/combat/silicon_unlinked_from_installed(mob/living/silicon/lawed)
	if(!isAI(lawed))
		return
	var/mob/living/silicon/ai/combatai = lawed
	// Don't delete a malf ai's malf picker please
	if(!combatai.malf_picker || IS_MALF_AI(combatai))
		return
	// Does not revert upgrades, no clean way of doing that (yet)
	// Though it makes sense that they'd stick around, so I'm fine with it (for now)
	QDEL_NULL(combatai.malf_picker)
	QDEL_NULL(combatai.modules_action)
	for(var/datum/action/innate/ai/leftover_action in combatai.actions)
		qdel(leftover_action)
	combatai.hack_software = FALSE

//Lipreading
/obj/item/ai_module/upgrade/surveillance
	name = "surveillance software upgrade"
	desc = "An illegal software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading and hidden microphones."
	upgrade_type = /datum/ai_module/malf/upgrade/eavesdrop

/obj/item/ai_module/upgrade/surveillance/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_CONTRABAND, INNATE_TRAIT)

/obj/item/ai_module/upgrade/power_transfer
	name = "power transfer upgrade"
	desc = "A legal upgrade that allows an artificial intelligence to directly provide power to APCs from a distance"
	upgrade_type = /datum/ai_module/power_apc
