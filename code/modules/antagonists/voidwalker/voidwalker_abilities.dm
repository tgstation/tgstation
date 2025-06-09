/// Remain in someones view without breaking line of sight
/datum/action/cooldown/spell/pointed/unsettle
	name = "Unsettle"
	desc = "Stare directly into someone who doesn't see you. Remain in their view for a bit to stun them for 2 seconds and announce your presence to them. "
	button_icon_state = "terrify"
	background_icon_state = "bg_void"
	panel = null
	spell_requirements = NONE
	cooldown_time = 12 SECONDS
	cast_range = 9
	active_msg = "You prepare to stare down a target..."
	deactive_msg = "You refocus your eyes..."

	/// how long we need to stare at someone to unsettle them (woooooh)
	var/stare_time = 8 SECONDS
	/// how long we stun someone on successful cast
	var/stun_time = 2 SECONDS
	/// stamina damage we doooo
	var/stamina_damage = 80

/datum/action/cooldown/spell/pointed/unsettle/is_valid_target(atom/cast_on)
	. = ..()

	if(!isliving(cast_on))
		cast_on.balloon_alert(owner, "cannot be targeted!")
		return FALSE

	if(!check_if_in_view(cast_on))
		owner.balloon_alert(owner, "cannot see you!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/cast(mob/living/carbon/human/cast_on)
	. = ..()

	if(do_after(owner, stare_time, cast_on, IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_if_in_view), cast_on), hidden = TRUE))
		spookify(cast_on)
		return
	owner.balloon_alert(owner, "line of sight broken!")
	return SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/unsettle/proc/check_if_in_view(mob/living/carbon/human/target)
	SIGNAL_HANDLER

	if(target.is_blind() || !(owner in view(target, world.view)))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/proc/spookify(mob/living/carbon/human/target)
	target.Paralyze(stun_time)
	target.adjustStaminaLoss(stamina_damage)
	target.apply_status_effect(/datum/status_effect/speech/slurring/generic)
	target.emote("scream")

	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(owner))
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(target))
	SEND_SIGNAL(owner, COMSIG_ATOM_REVEAL)

/obj/effect/temp_visual/circle_wave/unsettle
	color = COLOR_PURPLE

/datum/action/cooldown/spell/list_target/telepathy/voidwalker
	name = "Transmit"
	background_icon_state = "bg_void"
	button_icon = 'icons/mob/actions/actions_voidwalker.dmi'
	button_icon_state = "voidwalker_telepathy"
	panel = null

/datum/action/cooldown/spell/list_target/telepathy/voidwalker/sunwalker
	background_icon_state = "bg_star"

/datum/action/cooldown/mob_cooldown/charge/sunwalker
	name = "Stellar Charge"
	background_icon_state = "bg_star"
	charge_past = 1
	charge_damage = 30
	cooldown_time = 8 SECONDS
	destroy_objects = FALSE

/datum/action/cooldown/mob_cooldown/charge/sunwalker/on_move(atom/source, atom/new_loc, atom/target)
	. = ..()

	new /obj/effect/hotspot(get_turf(owner))

/datum/action/cooldown/mob_cooldown/charge/sunwalker/charge_end(datum/source)
	. = ..()

	for(var/turf/open/tile in range(1, owner))
		new /obj/effect/hotspot(tile)

/datum/action/cooldown/mob_cooldown/charge/sunwalker/do_charge_indicator(atom/charger, atom/charge_target)
	return

