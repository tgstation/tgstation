#define BUNNY_HOP "bunny_hop"

/datum/action/cooldown/spell/bunny_hop
	name = "Bunny Hop"
	desc = "Hop a distance with your bunny leg(s)! Go further the more bunny limbs you've got."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	cooldown_time = 7 SECONDS
	spell_requirements = NONE
	var/mob/living/carbon/human/last_caster

/datum/action/cooldown/spell/bunny_hop/cast(mob/living/cast_on)
	. = ..()
	last_caster = cast_on
	var/bunny_multiplier = 0
	var/mob/living/carbon/human/bunny = cast_on
	for(var/obj/item/bodypart/bodypart in bunny.bodyparts)
		if(bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE)
			bunny_multiplier++
	if(bunny.getStaminaLoss() > 0 || bunny.legcuffed) // cannot reach maximum jump if you have any stamina loss or are legcuffed(bola, bear trap, etc.)
		bunny_multiplier = min(bunny_multiplier, 5)
		cast_on.visible_message(span_warning("[cast_on] weakly hops with their genetically-engineered rabbit legs, hampered by their lack of stamina!"))
		cast_on.balloon_alert_to_viewers("weakly hops")
	else
		cast_on.visible_message(span_warning("[cast_on] hops with their genetically-engineered rabbit legs!"))
		cast_on.balloon_alert_to_viewers("hops")
	playsound(cast_on, 'sound/effects/arcade_jump.ogg', 75, vary=TRUE)


	cast_on.layer = ABOVE_MOB_LAYER
	if(bunny_multiplier >= 6) // they have committed to the bit, so we will reward it
		cast_on.pass_flags |= PASSTABLE|PASSGRILLE|PASSGLASS|PASSMACHINE|PASSSTRUCTURE
		RegisterSignal(cast_on, COMSIG_MOVABLE_MOVED, PROC_REF(break_glass))
	else
		cast_on.pass_flags |= PASSTABLE|PASSGRILLE|PASSMACHINE|PASSSTRUCTURE
	ADD_TRAIT(cast_on, TRAIT_SILENT_FOOTSTEPS, BUNNY_HOP)
	ADD_TRAIT(cast_on, TRAIT_MOVE_FLYING, BUNNY_HOP)

	cast_on.add_filter(BUNNY_HOP, 2, drop_shadow_filter(color = "#03020781", size = 0.9))
	var/shadow_filter = cast_on.get_filter(BUNNY_HOP)
	var/jump_height = 8 * bunny_multiplier
	var/jump_duration = 0.25 SECONDS * bunny_multiplier
	new /obj/effect/temp_visual/mook_dust(get_turf(cast_on))
	animate(cast_on, pixel_y = cast_on.pixel_y + jump_height, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT)
	animate(pixel_y = initial(owner.pixel_y), time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	animate(shadow_filter, y = -jump_height, size = 4, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_OUT)
	animate(y = 0, size = 0.9, time = jump_duration / 2, easing = CIRCULAR_EASING|EASE_IN)

	addtimer(CALLBACK(src, PROC_REF(end_jump), cast_on), jump_duration)

/datum/action/cooldown/spell/bunny_hop/proc/break_glass(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER
	for(var/obj/structure/window/window in get_turf(mover))
		window.deconstruct(disassembled = FALSE)
		mover.balloon_alert_to_viewers("smashed through!")
		var/mob/living/carbon/human/bunny = mover
		bunny.apply_damage(damage = rand(10,25), damagetype = BRUTE, spread_damage = TRUE, wound_bonus = 15, bare_wound_bonus = 25, sharpness = SHARP_EDGED, attack_direction = get_dir(window, oldloc))
		new /obj/effect/decal/cleanable/glass(get_step(bunny, bunny.dir))
///Ends the jump
/datum/action/cooldown/spell/bunny_hop/proc/end_jump(mob/living/jumper)
	jumper.remove_filter(BUNNY_HOP)
	jumper.layer = initial(jumper.layer)
	jumper.pass_flags = initial(jumper.pass_flags)
	REMOVE_TRAIT(jumper, TRAIT_SILENT_FOOTSTEPS, BUNNY_HOP)
	REMOVE_TRAIT(jumper, TRAIT_MOVE_FLYING, BUNNY_HOP)
	new /obj/effect/temp_visual/mook_dust(get_turf(jumper))
	UnregisterSignal(jumper, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/spell/bunny_hop/GetCooldown()
	var/cooldown = 7 SECONDS
	for(var/obj/item/bodypart/bodypart in last_caster.bodyparts)
		if(bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE)
			cooldown -= 1 SECONDS
	return cooldown

/obj/item/bodypart/leg/left/digitigrade/bunny
	name = "rabbit left leg"
	desc = "Helps you jump!"
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	base_limb_id = BODYPART_ID_RABBIT
	var/datum/action/cooldown/spell/bunny_hop/jumping_power

/obj/item/bodypart/leg/left/digitigrade/bunny/try_attach_limb(mob/living/carbon/new_head_owner, special)
	. = ..()
	if(!.)
		return
	var/potential_action = locate(/datum/action/cooldown/spell/bunny_hop) in new_head_owner.actions
	if(potential_action)
		jumping_power = potential_action
	else
		jumping_power = new(src)
		jumping_power.background_icon_state = "bg_tech_blue"
		jumping_power.base_background_icon_state = jumping_power.background_icon_state
		jumping_power.active_background_icon_state = "[jumping_power.base_background_icon_state]_active"
		jumping_power.overlay_icon_state = "bg_tech_blue_border"
		jumping_power.active_overlay_icon_state = null
		jumping_power.panel = "Genetic"
		jumping_power.Grant(new_head_owner)
	new_head_owner.AddElement(/datum/element/waddling/hopping)

/obj/item/bodypart/leg/left/digitigrade/bunny/on_removal()
	var/mob/living/carbon/human/bnuuy = owner
	var/has_rabbit_leg_still = FALSE
	for(var/obj/item/bodypart/leg/bodypart in bnuuy.bodyparts)
		if(bodypart == src)
			continue
		if(bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE)
			has_rabbit_leg_still = TRUE
			break
	if(!has_rabbit_leg_still)
		jumping_power.Remove(owner)
		owner.RemoveElement(/datum/element/waddling/hopping)
	return ..()

/obj/item/bodypart/leg/right/digitigrade/bunny
	name = "rabbit right leg"
	desc = "Helps you jump!"
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	base_limb_id = BODYPART_ID_RABBIT
	var/datum/action/cooldown/spell/bunny_hop/jumping_power

/obj/item/bodypart/leg/right/digitigrade/bunny/try_attach_limb(mob/living/carbon/new_head_owner, special)
	. = ..()
	if(!.)
		return
	var/potential_action = locate(/datum/action/cooldown/spell/bunny_hop) in new_head_owner.actions
	if(potential_action)
		jumping_power = potential_action
	else
		jumping_power = new(src)
		jumping_power.background_icon_state = "bg_tech_blue"
		jumping_power.base_background_icon_state = jumping_power.background_icon_state
		jumping_power.active_background_icon_state = "[jumping_power.base_background_icon_state]_active"
		jumping_power.overlay_icon_state = "bg_tech_blue_border"
		jumping_power.active_overlay_icon_state = null
		jumping_power.panel = "Genetic"
		jumping_power.Grant(new_head_owner)
	new_head_owner.AddElement(/datum/element/waddling/hopping)

/obj/item/bodypart/leg/right/digitigrade/bunny/on_removal()
	var/mob/living/carbon/human/bnuuy = owner
	var/has_rabbit_leg_still = FALSE
	for(var/obj/item/bodypart/leg/bodypart in bnuuy.bodyparts)
		if(bodypart == src)
			continue
		if(bodypart.limb_id == BODYPART_ID_RABBIT || bodypart.limb_id == BODYPART_ID_DIGITIGRADE)
			has_rabbit_leg_still = TRUE
			break
	if(!has_rabbit_leg_still)
		jumping_power.Remove(owner)
		owner.RemoveElement(/datum/element/waddling/hopping)
	return ..()

/obj/item/bodypart/head/bunny
	name = "rabbit head"
	desc = "Comes with a sniffer for carrots."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	is_dimorphic = TRUE
	limb_id = BODYPART_ID_RABBIT
	head_flags = HEAD_HAIR|HEAD_LIPS|HEAD_EYESPRITES|HEAD_EYECOLOR|HEAD_EYEHOLES|HEAD_DEBRAIN
	var/datum/action/cooldown/spell/olfaction/sniffing_power

/obj/item/bodypart/head/bunny/try_attach_limb(mob/living/carbon/new_head_owner, special)
	. = ..()
	if(!.)
		return
	var/obj/item/organ/external/snout/bunny/bunny_snout = new
	bunny_snout.transfer_to_limb(src, new_head_owner)

	sniffing_power = new(src)
	sniffing_power.background_icon_state = "bg_tech_blue"
	sniffing_power.base_background_icon_state = sniffing_power.background_icon_state
	sniffing_power.active_background_icon_state = "[sniffing_power.base_background_icon_state]_active"
	sniffing_power.overlay_icon_state = "bg_tech_blue_border"
	sniffing_power.active_overlay_icon_state = null
	sniffing_power.panel = "Genetic"
	sniffing_power.Grant(new_head_owner)

/obj/item/bodypart/head/bunny/on_removal()
	sniffing_power.Remove(owner)
	return ..()

/obj/item/bodypart/chest/bunny
	name = "rabbit chest"
	desc = "Ensures the fluffiest hugs are possible."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	limb_id = BODYPART_ID_RABBIT
	is_dimorphic = TRUE
	bodypart_traits = list(TRAIT_FRIENDLY)

/obj/item/bodypart/arm/left/bunny
	name = "rabbit left arm"
	desc = "Ensures the fluffiest hugs are possible."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	limb_id = BODYPART_ID_RABBIT
	bodypart_traits = list(TRAIT_FRIENDLY)

/obj/item/bodypart/arm/right/bunny
	name = "rabbit right arm"
	desc = "Ensures the fluffiest hugs are possible."
	icon_greyscale = 'icons/mob/human/species/misc/genetics_limbs.dmi'
	limb_id = BODYPART_ID_RABBIT
	bodypart_traits = list(TRAIT_FRIENDLY)

#undef BUNNY_HOP
