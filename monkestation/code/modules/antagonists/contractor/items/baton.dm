#define CUFF_MAXIMUM 3
#define MUTE_APPLIED 10 SECONDS
#define MUTE_MAX 30 SECONDS
#define BONUS_STAMINA_DAM 25
#define BONUS_STUTTER 10 SECONDS
#define BATON_CUFF_UPGRADE (1<<0)
#define BATON_MUTE_UPGRADE (1<<1)
#define BATON_FOCUS_UPGRADE (1<<2)

/obj/item/melee/baton/telescopic/contractor_baton
	name = "contractor baton"
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electrical shocks to targets."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "contractor_baton"
	worn_icon_state = "contractor_baton"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NONE
	force = 5
	cooldown = 2.5 SECONDS
	force_say_chance = 80 //very high force say chance because it's funny
	stamina_damage = 170
	knockdown_time = 1.5 SECONDS
	clumsy_knockdown_time = 24 SECONDS
	affect_cyborg = TRUE
	on_stun_sound = 'sound/effects/contractorbatonhit.ogg'

	on_inhand_icon_state = "contractor_baton_on"
	on_sound = 'sound/weapons/contractorbatonextend.ogg'
	active_force = 16

	/// Ref to the baton holster, should the baton have one.
	var/obj/item/mod/module/baton_holster/holster
	/// Bitflags for what upgrades the baton has
	var/upgrade_flags

/obj/item/melee/baton/telescopic/contractor_baton/get_wait_description()
	return span_danger("The baton is still charging!")

/obj/item/melee/baton/telescopic/contractor_baton/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	target.set_jitter_if_lower(40 SECONDS)
	target.set_stutter_if_lower(40 SECONDS)
	target.Disorient(6 SECONDS, 5, paralyze = 3 SECONDS, stack_status = TRUE)
	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	if(upgrade_flags & BATON_MUTE_UPGRADE)
		carbon_target.adjust_silence_up_to(MUTE_APPLIED, MUTE_MAX)

	if(upgrade_flags & BATON_FOCUS_UPGRADE)
		var/datum/antagonist/traitor/traitor_datum = IS_TRAITOR(user)
		var/datum/uplink_handler/handler = traitor_datum?.uplink_handler
		if(handler)
			for(var/datum/traitor_objective/target_player/kidnapping/objective in handler.active_objectives)
				if(carbon_target == objective.target)
					carbon_target.stamina.adjust(-BONUS_STAMINA_DAM)
					carbon_target.adjust_timed_status_effect(BONUS_STUTTER, /datum/status_effect/speech/stutter)

/obj/item/melee/baton/telescopic/contractor_baton/attack_secondary(mob/living/victim, mob/living/user, params)
	if(!(upgrade_flags & BATON_CUFF_UPGRADE) || !active)
		return

	for(var/obj/item/restraints/handcuffs/cuff in contents)
		cuff.attack(victim, user)
		break
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/melee/baton/telescopic/contractor_baton/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/baton_upgrade))
		add_upgrade(attacking_item, user)

	if(!(upgrade_flags & BATON_CUFF_UPGRADE) || !istype(attacking_item, /obj/item/restraints/handcuffs/cable))
		return

	var/cuffcount = 0
	for(var/obj/item/restraints/handcuffs/cuff in contents)
		cuffcount++

	if(cuffcount >= CUFF_MAXIMUM)
		to_chat(user, span_warning("[src] is at maximum capacity for handcuffs!"))
		return

	attacking_item.forceMove(src)
	to_chat(user, span_notice("You insert [attacking_item] into [src]."))

/obj/item/melee/baton/telescopic/contractor_baton/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	for(var/obj/item/baton_upgrade/upgrade in src.contents)
		upgrade.forceMove(get_turf(src))
		upgrade_flags &= ~upgrade.upgrade_flag
	tool.play_tool_sound(src)

/obj/item/melee/baton/telescopic/contractor_baton/examine(mob/user)
	. = ..()
	if(upgrade_flags)
		. += "<br><br>[span_boldnotice("[src] has the following upgrades attached:")]"
	for(var/obj/item/baton_upgrade/upgrade in contents)
		. += "<br>[span_notice("[upgrade].")]"

/obj/item/melee/baton/telescopic/contractor_baton/proc/add_upgrade(obj/item/baton_upgrade/upgrade, mob/user)
	if(!(upgrade_flags & upgrade.upgrade_flag))
		upgrade_flags |= upgrade.upgrade_flag
		upgrade.forceMove(src)
		if(user)
			user.visible_message(span_notice("[user] inserts the [upgrade] into [src]."), span_notice("You insert [upgrade] into [src]."), span_hear("You hear a faint click."))
		return TRUE
	return FALSE

/obj/item/melee/baton/telescopic/contractor_baton/upgraded
	desc = "A compact, specialised baton assigned to Syndicate contractors. Applies light electrical shocks to targets. This one seems to have unremovable parts."

/obj/item/melee/baton/telescopic/contractor_baton/upgraded/Initialize(mapload)
	. = ..()
	for(var/upgrade in subtypesof(/obj/item/baton_upgrade))
		var/obj/item/baton_upgrade/the_upgrade = new upgrade()
		add_upgrade(the_upgrade)
	for(var/i in 1 to CUFF_MAXIMUM)
		new/obj/item/restraints/handcuffs/cable(src)

/obj/item/melee/baton/telescopic/contractor_baton/upgraded/wrench_act(mob/living/user, obj/item/tool)
	return

/obj/item/baton_upgrade
	icon = 'monkestation/icons/obj/items/baton_upgrades.dmi'
	var/upgrade_flag

/obj/item/baton_upgrade/cuff
	name = "handcuff baton upgrade"
	desc = "Allows the user to apply restraints to a target via baton, requires to be loaded with up to three prior."
	icon_state = "cuff_upgrade"
	upgrade_flag = BATON_CUFF_UPGRADE

/obj/item/baton_upgrade/mute
	name = "mute baton upgrade"
	desc = "Use of the baton on a target will mute them for a short period."
	icon_state = "mute_upgrade"
	upgrade_flag = BATON_MUTE_UPGRADE

/obj/item/baton_upgrade/focus
	name = "focus baton upgrade"
	desc = "Use of the baton on a target, should they be the subject of your contract, will be extra exhausted."
	icon_state = "focus_upgrade"
	upgrade_flag = BATON_FOCUS_UPGRADE

#undef CUFF_MAXIMUM
#undef MUTE_APPLIED
#undef MUTE_MAX
#undef BONUS_STAMINA_DAM
#undef BONUS_STUTTER
#undef BATON_CUFF_UPGRADE
#undef BATON_MUTE_UPGRADE
#undef BATON_FOCUS_UPGRADE
