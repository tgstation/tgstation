/// Remain in someones view without breaking line of sight
/datum/action/cooldown/spell/pointed/unsettle
	name = "Unsettle"
	desc = "Stare directly into someone who doesn't see you. Remain in their view for a bit to stun them for 2 seconds and announce your presence to them. "
	button_icon = 'icons/mob/actions/actions_voidwalker.dmi'
	button_icon_state = "unsettle"
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
	/// Speed buff that we get when we use a spell.
	var/give_speed_modifier = FALSE
	/// If > 0 then rest of crewmambers in aoe range recive half of unsettle effects.
	var/aoe_range = 0

/datum/action/cooldown/spell/pointed/unsettle/is_valid_target(atom/cast_on)
	. = ..()

	if(!isliving(cast_on))
		cast_on.balloon_alert(owner, "cannot be targeted!")
		return FALSE

	if(!check_if_in_view(cast_on))
		owner.balloon_alert(owner, "cannot see you!")
		return FALSE

	return TRUE

/datum/action/cooldown/spell/pointed/unsettle/before_cast(atom/cast_on)
	. = ..()

	if(!do_after(owner, stare_time, cast_on, IGNORE_TARGET_LOC_CHANGE | IGNORE_USER_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_if_in_view), cast_on), hidden = TRUE))
		owner.balloon_alert(owner, "line of sight broken!")
		return ..() | SPELL_CANCEL_CAST | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/unsettle/cast(mob/living/carbon/human/cast_on)
	. = ..()

	spookify(cast_on)

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

	if(!isnull(aoe_range))
		INVOKE_ASYNC(src, PROC_REF(aoe_spookify), target)
	if(give_speed_modifier)
		owner.add_movespeed_modifier(/datum/movespeed_modifier/voidwalker_unsettle)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, remove_movespeed_modifier), /datum/movespeed_modifier/voidwalker_unsettle), 6 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)

	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(owner))
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(target))
	SEND_SIGNAL(owner, COMSIG_ATOM_REVEAL)

/datum/action/cooldown/spell/pointed/unsettle/proc/aoe_spookify(mob/living/carbon/human/target)
	for(var/mob/living/carbon/human/victim in view(aoe_range, get_turf(target)))
		if(IS_VOIDWALKER(victim) || IS_VOID_BLESSED(victim))
			continue
		victim.Knockdown(stun_time/2)
		victim.adjustStaminaLoss(stamina_damage/2)

/obj/effect/temp_visual/circle_wave/unsettle
	color = COLOR_PURPLE

/datum/action/cooldown/spell/list_target/telepathy/voidwalker
	name = "Transmit"
	background_icon_state = "bg_void"
	button_icon = 'icons/mob/actions/actions_voidwalker.dmi'
	button_icon_state = "voidwalker_telepathy"
	panel = null

/datum/action/cooldown/spell/pointed/void_symbol
	name = "Void Symbol"
	desc = "Used for two purposes: Use Void Symbol on voided crewmambers to make them void blessed. \
		Void Blessed peoples obey you, get a weak version of void eater and also cease to be pacifists and lose cosmophobia. You can communicate with them via transmit. \
		Use Void Symbol on normal crewmember and all void blessed friends will gain objective to kill this crewmember."
	button_icon = 'icons/mob/actions/actions_voidwalker.dmi'
	button_icon_state = "void_symbol"
	background_icon_state = "bg_void"
	panel = null
	check_flags = null
	spell_requirements = NONE
	cooldown_time = 5 SECONDS
	cast_range = 9
	/// How many blessed voided crewmambers can we have.
	var/max_blessed = 1
	/// All people that we blessed with antag datum.
	var/list/blessed_peoples = list()
	/// All people that we curse with our spell.
	var/list/cursed_peoples = list()

/datum/action/cooldown/spell/pointed/void_symbol/is_valid_target(atom/cast_on)
	if(cast_on == owner)
		return FALSE
	if(!ishuman(cast_on))
		cast_on.balloon_alert(owner, "need human!")
		return FALSE
	var/mob/living/carbon/human/has_mind = cast_on
	if(isnull(has_mind.mind))
		cast_on.balloon_alert(owner, "no mind!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/void_symbol/cast(mob/living/carbon/human/human_target)
	. = ..()
	if(human_target.has_trauma_type(/datum/brain_trauma/voided))
		symbol_on_voided_person(human_target)
	else
		symbol_on_normal_person(human_target)

/datum/action/cooldown/spell/pointed/void_symbol/proc/symbol_on_voided_person(mob/living/carbon/human/human_target)
	if(human_target.mind.has_antag_datum(/datum/antagonist/void_blessed))
		human_target.mind.remove_antag_datum(/datum/antagonist/void_blessed)
		blessed_peoples -= human_target
		to_chat(owner, span_purple("[human_target] no longer serves you."))
	else
		var/datum/antagonist/void_blessed/blessed_datum = new(human_target)
		blessed_datum.our_friend = owner
		human_target.mind.add_antag_datum(blessed_datum)
		blessed_peoples += human_target
		if(length(cursed_peoples))
			search_for_targets(human_target)
		to_chat(owner, span_purple("You blessed [human_target]."))

	if(blessed_peoples.len > max_blessed)
		var/mob/living/carbon/human/bye_blessed = blessed_peoples[1] /// Remove first blessed void blessed on limit.
		blessed_peoples -= bye_blessed
		bye_blessed.mind.remove_antag_datum(/datum/antagonist/void_blessed)
		to_chat(owner, span_purple("blessed persons reached the limit. [bye_blessed.real_name] no longer subject to you."))

/datum/action/cooldown/spell/pointed/void_symbol/proc/search_for_targets(mob/living/carbon/human/voidfriend)
	var/datum/antagonist/void_blessed/my_blessed_friend = locate() in voidfriend.mind.antag_datums
	for(var/mob/living/carbon/human/cursed_human in cursed_peoples)
		if(!cursed_human.has_status_effect(/datum/status_effect/void_symbol_mark))
			cursed_peoples -= voidfriend
			return
		var/datum/objective/void_blessed_kidnap_objective/give_target = new()
		give_target.my_target = cursed_human
		give_target.explanation_text = "Your master wants you to deal with [cursed_human.real_name]."
		give_target.owner = voidfriend.mind
		my_blessed_friend.objectives += give_target
		voidfriend.mind.announce_objectives()
		give_navigator()

/datum/action/cooldown/spell/pointed/void_symbol/proc/give_navigator()
	if(!length(blessed_peoples))
		return
	for(var/mob/living/carbon/human/my_voided_friend in blessed_peoples)
		for(var/mob/living/carbon/human/my_cursed_friend in cursed_peoples)
			var/datum/status_effect/agent_pinpointer/scan/voidwalker/scan_pinpointer = my_voided_friend.apply_status_effect(/datum/status_effect/agent_pinpointer/scan/voidwalker)
			scan_pinpointer.scan_target = my_cursed_friend

/datum/action/cooldown/spell/pointed/void_symbol/proc/symbol_on_normal_person(mob/living/carbon/human/human_target)
	if(human_target.has_status_effect(/datum/status_effect/void_symbol_mark))
		remove_curse(human_target)
		return
	var/datum/status_effect/void_symbol_mark/my_symbol = human_target.apply_status_effect(/datum/status_effect/void_symbol_mark)
	my_symbol.voidwalker_mind = owner.mind
	if(length(cursed_peoples))
		remove_curse(cursed_peoples[1])
	cursed_peoples += human_target
	for(var/mob/living/carbon/human/blessed_friend in blessed_peoples)
		search_for_targets(blessed_friend)
	to_chat(owner, span_purple("You cursed [human_target]."))

/datum/action/cooldown/spell/pointed/void_symbol/proc/remove_curse(mob/living/carbon/human/human_target)
	human_target.remove_status_effect(/datum/status_effect/void_symbol_mark)
	to_chat(owner, span_purple("[human_target] no longer cursed."))

/datum/action/cooldown/spell/space_relocation
	name = "Space Relocation"
	desc = "Temporarily creates a 3x3 tiles of space around you."
	button_icon = 'icons/mob/actions/actions_voidwalker.dmi'
	button_icon_state = "space_relocation"
	background_icon_state = "bg_void"
	panel = null
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	/// Can be activated to end spell earlier and return unspent time.
	var/can_refund = FALSE
	/// Remember if we need to refund spell in cast and refund it after cast.
	var/refund_check_success = FALSE
	/// Coverage radius.
	var/aoe_range = 1
	/// Timer var.
	var/timer
	/// Is spell is currently working or not.
	var/created = FALSE
	/// Have we Dissolution upgrade. Makes walls of doors and windows translucent.
	var/dissolution = FALSE
	/// Remembers turf center where we make space relocation to clean this up when spell is end.
	var/turf/remember_turf
	/// Rememebers all turfs types that we convert into space tiles to transformate it back when spell is end.
	var/list/turf/turfs_array = list()
	/// List of doors and windows that we make translucent.
	var/list/other_array = list()

/datum/action/cooldown/spell/space_relocation/IsAvailable(feedback)
	if(!(can_refund && created))
		return ..()
	return TRUE

/datum/action/cooldown/spell/space_relocation/cast(atom/cast_on)
	. = ..()
	if(can_refund && created)
		refund_check_success = TRUE
		return
	if(turfs_array.len > 0)
		end_effect()
		return
	remember_turf = get_turf(owner)
	var/lazy_counter = 1
	for(var/turf/just_a_turf in range(aoe_range, remember_turf))
		turfs_array += "this could be your turf"
		if(dissolution)
			do_dissolution(just_a_turf)
		if(isclosedturf(just_a_turf))
			continue
		turfs_array[lazy_counter] = just_a_turf.type
		lazy_counter++
		just_a_turf.TerraformTurf(/turf/open/space)
	created = TRUE
	timer = addtimer(CALLBACK(src, PROC_REF(end_effect)), cooldown_time * 0.5, TIMER_STOPPABLE) //spell lifetime = half of cooldown.

/datum/action/cooldown/spell/space_relocation/proc/do_dissolution(turf/just_a_turf)
	if(isclosedturf(just_a_turf))
		just_a_turf.density = FALSE
		just_a_turf.alpha = 125
		return
	var/obj/machinery/door/void_door = locate() in just_a_turf
	if(void_door)
		void_door.density = FALSE
		void_door.alpha = 125
		other_array += void_door
	var/obj/structure/window/void_window = locate() in just_a_turf
	if(void_window)
		void_window.density = FALSE
		void_window.alpha = 125
		other_array += void_window

/datum/action/cooldown/spell/space_relocation/proc/end_effect()
	if(!created)
		return
	var/lazy_counter = 1
	for(var/turf/just_a_turf in range(aoe_range, remember_turf))
		if(isclosedturf(just_a_turf))
			if(dissolution)
				just_a_turf.density = TRUE
				just_a_turf.alpha = 255
			continue
		if(ispath(turfs_array[lazy_counter]))
			just_a_turf.TerraformTurf(turfs_array[lazy_counter])
			lazy_counter++
	for(var/obj/in_array in other_array)
		if(QDELETED(in_array))
			continue
		in_array.density = TRUE
		in_array.alpha = 255
	other_array = list()
	if(turfs_array.len > 0)
		turfs_array = list()
	created = FALSE

/datum/action/cooldown/spell/space_relocation/after_cast(atom/cast_on)
	. = ..()
	if(refund_check_success)
		refund_spell()

/datum/action/cooldown/spell/space_relocation/proc/refund_spell()
	next_use_time -= cooldown_time * 0.5
	refund_check_success = FALSE
	deltimer(timer)
	build_all_button_icons()
	end_effect()

/datum/action/cooldown/spell/pointed/through_the_void
	name = "Through The Void"
	desc = "After 3 seconds teleports you behind the target."
	button_icon = 'icons/mob/actions/actions_voidwalker.dmi'
	button_icon_state = "through_the_void"
	background_icon_state = "bg_void"
	panel = null
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	cast_range = 9
	/// How many time we need before we teleport to target after cast the spell.
	var/cast_delay = 3 SECONDS
	/// Gives slowdown for victim on cast.
	var/give_slowdown_modifier = FALSE
	/// Makes illusions around caster.
	var/make_illusions = FALSE

/datum/action/cooldown/spell/pointed/through_the_void/is_valid_target(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		cast_on.balloon_alert(owner, "need living!")
		return FALSE
	return TRUE

/datum/action/cooldown/spell/pointed/through_the_void/before_cast(atom/cast_on)
	. = ..()
	if(isnull(cast_delay))
		return

	if(!do_after(owner, cast_delay, cast_on, IGNORE_TARGET_LOC_CHANGE))
		cast_on.balloon_alert(owner, "stand still!")
		return ..() | SPELL_CANCEL_CAST | SPELL_NO_IMMEDIATE_COOLDOWN

/datum/action/cooldown/spell/pointed/through_the_void/cast(mob/living/cast_on)
	. = ..()

	owner.forceMove(get_step(cast_on, REVERSE_DIR(cast_on.dir)))
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(owner))
	if(give_slowdown_modifier)
		cast_on.add_movespeed_modifier(/datum/movespeed_modifier/voidwalker_through_the_void_slowdown)
		addtimer(CALLBACK(cast_on, TYPE_PROC_REF(/mob/living, remove_movespeed_modifier), /datum/movespeed_modifier/voidwalker_through_the_void_slowdown), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(make_illusions)
		INVOKE_ASYNC(src, PROC_REF(make_illusions), cast_on, owner)
	SEND_SIGNAL(owner, COMSIG_ATOM_REVEAL)

/datum/action/cooldown/spell/pointed/through_the_void/proc/make_illusions(mob/living/cast_on, mob/owner)
	var/only_three = 3
	for(var/mob/living/carbon/human/nearby_human in range(5, get_turf(cast_on)))
		if(only_three < 1)
			break
		if(nearby_human == owner)
			continue
		if(nearby_human == cast_on)
			continue
		var/mob/living/simple_animal/hostile/illusion/voidfriend = new(get_turf(owner))
		voidfriend.Copy_Parent(owner, 15 SECONDS, 1, 10)
		voidfriend.faction |= FACTION_VOIDWALKER
		voidfriend.move_to_delay = owner.cached_multiplicative_slowdown
		voidfriend.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, STAMINA = 0, OXY = 0)
		only_three--
