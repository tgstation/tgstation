///Your favourite Jojoke. Used for the gloves of the north star.
/datum/component/wearertargeting/punchcooldown
	signals = list(COMSIG_LIVING_ATTACK_STYLE_PROCESSED, COMSIG_LIVING_SLAP_MOB)
	mobtype = /mob/living/carbon
	proctype = PROC_REF(reducecooldown)
	valid_slots = list(ITEM_SLOT_GLOVES)
	///The warcry this generates
	var/warcry = "AT"

/datum/component/wearertargeting/punchcooldown/Initialize()
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(changewarcry))

/datum/component/wearertargeting/punchcooldown/proc/reducecooldown(mob/living/carbon/source, obj/item/weapon_used, attack_result, datum/attack_style/used)
	SIGNAL_HANDLER

	var/slapping_dudes = istype(source.get_active_held_item(), /obj/item/hand_item/slapper)
	var/punching_dudes = !(attack_result & ATTACK_SWING_CANCEL) && istype(used, /datum/attack_style/unarmed)
	if(slapping_dudes || punching_dudes)
		INVOKE_ASYNC(src, PROC_REF(engage_turbo), source)

/datum/component/wearertargeting/punchcooldown/proc/engage_turbo(mob/living/attacker)
	attacker.changeNext_move(CLICK_CD_RAPID)
	if(warcry)
		attacker.say(warcry, ignore_spam = TRUE, forced = "north star warcry")

/// Called on COMSIG_ITEM_ATTACK_SELF. Allows you to change the warcry.
/datum/component/wearertargeting/punchcooldown/proc/changewarcry(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(do_changewarcry), user)

/datum/component/wearertargeting/punchcooldown/proc/do_changewarcry(mob/user)
	var/input = tgui_input_text(user, "What do you want your battlecry to be?", "Battle Cry", max_length = 6)
	if(!QDELETED(src) && !QDELETED(user) && !user.Adjacent(parent))
		return
	if(input)
		warcry = input
