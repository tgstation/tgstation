/datum/martial_art/spiders_bite
	name = "Spider's Bite"
	id = MARTIALART_SPIDERSBITE
	help_verb = /mob/living/proc/spiders_bite_help
	grab_damage_modifier = 10
	grab_escape_chance_modifier = -20
	/// REF() to the last mob we kicked
	var/last_hit_ref
	/// Counts the number of sequential kicks the user has landed on a target
	var/last_hit_count = 0
	/// Reference to the tackling component applied
	var/datum/component/tackler/tackle_comp

/datum/martial_art/spiders_bite/activate_style(mob/living/new_holder)
	. = ..()
	RegisterSignal(new_holder, COMSIG_HUMAN_PUNCHED, PROC_REF(kick_disarm))
	tackle_comp = new_holder.AddComponent(/datum/component/tackler, \
		stamina_cost = 20, \
		base_knockdown = 0.2 SECONDS, \
		range = 5, \
		speed = 1.5, \
		skill_mod = 6, \
		min_distance = 1, \
		silent_gain = TRUE, \
	)

/datum/martial_art/spiders_bite/deactivate_style(mob/living/old_holder)
	. = ..()
	UnregisterSignal(old_holder, COMSIG_HUMAN_PUNCHED)
	QDEL_NULL(tackle_comp)

/datum/martial_art/spiders_bite/proc/kick_disarm(mob/living/source, mob/living/target, damage, attack_type, obj/item/bodypart/affecting, final_armor_block, kicking, limb_sharpness)
	SIGNAL_HANDLER

	if(!kicking)
		last_hit_ref = null
		return
	var/new_hit_ref = REF(target)
	if(last_hit_ref == new_hit_ref)
		last_hit_count++
	else
		last_hit_count = 1
		last_hit_ref = new_hit_ref

	if(!prob(33 * last_hit_count))
		return

	var/obj/item/weapon = target.get_active_held_item()
	if(isnull(weapon) || !target.dropItemToGround(weapon))
		return
	source.visible_message(
		span_warning("[source] knocks [target]'s [weapon.name] out of [target.p_their()] hands with a kick!"),
		span_notice("You channel the flow of gravity and knock [target]'s [weapon.name] out of [target.p_their()] hands with a kick!"),
		span_hear("You hear a thud, followed by a clatter."),
	)

/datum/martial_art/spiders_bite/get_prefered_attacking_limb(mob/living/martial_artist, mob/living/target)
	if(!target.has_status_effect(/datum/status_effect/staggered))
		return null

	return IS_LEFT_INDEX(martial_artist.active_hand_index) ? BODY_ZONE_L_LEG : BODY_ZONE_R_LEG

/mob/living/proc/spiders_bite_help()
	set name = "Recall Teachings"
	set desc = "Remember the Spider Bite technique used by the Spider Clan."
	set category = "Spider's Bite"

	to_chat(usr, span_info("<b><i>You retreat inward and recall the Spider Clan's techniques...</i></b>\n\
		&bull; Remember, <b>Many Legged Spider</b>: Unarmed attacks against staggered opponents will always be kicks - granting you greater accuracy and damage.\n\
		&bull; Remember, <b>Jump and Climb</b>: Right clicking on throw mode will perform a tackle which is far far less likely to fail.\n\
		&bull; Remember, <b>Flow of Gravity</b>: Kicking opponents will have a chance to knock their weapons to the floor. The chance increases for each sequential kick.\n\
		&bull; Remember, <b>Wrap in Web</b>: Your grabs will be harder to escape from."))
