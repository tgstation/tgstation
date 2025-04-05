
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	icon = 'icons/effects/holosigns.dmi'
	anchored = TRUE
	max_integrity = 1
	armor_type = /datum/armor/structure_holosign
	// How can you freeze a trick of the light?
	resistance_flags = FREEZE_PROOF
	var/obj/item/holosign_creator/projector
	var/use_vis_overlay = TRUE

/datum/armor/structure_holosign
	bullet = 50
	laser = 50
	energy = 50
	fire = 20
	acid = 20

/obj/structure/holosign/Initialize(mapload, source_projector)
	. = ..()
	AddComponent(/datum/component/holographic_nature)
	create_vis_overlay()
	if(source_projector)
		projector = source_projector
		LAZYADD(projector.signs, src)

/obj/structure/holosign/Destroy()
	if(projector)
		LAZYREMOVE(projector.signs, src)
		projector = null
	return ..()

/obj/structure/holosign/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	attack_holosign(user, modifiers)

/obj/structure/holosign/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!. && isprojectile(mover)) // Its short enough to be shot over
		return TRUE

/obj/structure/holosign/proc/attack_holosign(mob/living/user, list/modifiers)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, MELEE, 1)
	log_combat(user, src, "swatted")

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/items/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/weapons/egloves.ogg', 80, TRUE)

/obj/structure/holosign/proc/create_vis_overlay()
	var/turf/our_turf = get_turf(src)
	if(use_vis_overlay)
		alpha = 0
		SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
		SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, MUTATE_PLANE(GAME_PLANE, our_turf), dir, add_appearance_flags = RESET_ALPHA) //you see mobs under it, but you hit them like they are above it

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "The words flicker as if they mean nothing."
	icon_state = "holosign"

/obj/structure/holosign/barrier
	name = "security holobarrier"
	desc = "A strong short security holographic barrier used for crowd control and blocking crime scenes. Can only be passed by walking."
	icon_state = "holosign_sec"
	base_icon_state = "holosign_sec"
	pass_flags_self = PASSTABLE | PASSGRILLE | PASSGLASS | LETPASSTHROW
	density = TRUE
	max_integrity = 20
	COOLDOWN_DECLARE(cooldown_open)
	///Can we pass through it on walk intent?
	var/allow_walk = TRUE
	///Can it be temporarily opened with the holosign projector?
	var/openable = TRUE
	///Is it opened?
	var/opened = FALSE
	///What is the icon of opened holobarrier?
	var/pass_icon_state = "holosign_pass"

/obj/structure/holosign/barrier/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(opened)
		return TRUE

	if(iscarbon(mover))
		var/mob/living/carbon/moving_carbon = mover
		if(moving_carbon.stat) // Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && moving_carbon.move_intent == MOVE_INTENT_WALK)
			return TRUE

/obj/structure/holosign/barrier/ranged_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(tool != projector)
		return
	if(openable)
		open(user)

/obj/structure/holosign/barrier/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(tool != projector)
		return
	qdel(src)

/obj/structure/holosign/barrier/update_icon_state()
	if(!opened)
		icon_state = base_icon_state
	else
		icon_state = pass_icon_state

	create_vis_overlay()
	. = ..()

/obj/structure/holosign/barrier/proc/open(user)
	if(!openable)
		balloon_alert(user, "unable!")
		return

	if(!COOLDOWN_FINISHED(src, cooldown_open))
		balloon_alert(user, "on cooldown!")
		return

	if(!opened)
		density = FALSE
		opened = TRUE
		playsound(src, 'sound/machines/door/door_open.ogg', 50, TRUE)
	else
		density = TRUE
		opened = FALSE
		playsound(src, 'sound/machines/door/door_close.ogg', 50, TRUE)

	update_icon_state()
	COOLDOWN_START(src, cooldown_open, 1 SECONDS)

/obj/structure/holosign/barrier/wetsign
	name = "wet floor holobarrier"
	desc = "When it says walk it means <b>WALK!</b>"
	icon_state = "holosign_dense"
	max_integrity = 1
	openable = FALSE

/obj/structure/holosign/barrier/wetsign/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(iscarbon(mover))
		var/mob/living/carbon/C = mover
		if(C.stat) // Lets not prevent dragging unconscious/dead people.
			return TRUE
		if(allow_walk && C.move_intent != MOVE_INTENT_WALK)
			return FALSE

/obj/structure/holosign/barrier/engineering
	name = "engineering holobarrier"
	desc = "A short engineering holographic barrier used for designating hazardous zones, slightly blocks radiation. Can only be passed by walking."
	icon_state = "holosign_engi"
	base_icon_state = "holosign_engi"
	rad_insulation = RAD_LIGHT_INSULATION
	max_integrity = 1

/obj/structure/holosign/barrier/atmos
	name = "holofirelock"
	desc = "A holographic barrier resembling a firelock. Though it does not prevent solid objects from passing through, gas is kept out."
	icon_state = "holo_firelock"
	openable = FALSE
	density = FALSE
	anchored = TRUE
	can_atmos_pass = ATMOS_PASS_NO
	alpha = 150
	rad_insulation = RAD_LIGHT_INSULATION
	resistance_flags = FIRE_PROOF | FREEZE_PROOF

/obj/structure/holosign/barrier/atmos/proc/clearview_transparency()
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 25
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	var/turf/our_turf = get_turf(src)
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, MUTATE_PLANE(GAME_PLANE, our_turf), dir)

/obj/structure/holosign/barrier/atmos/proc/reset_transparency()
	mouse_opacity = initial(mouse_opacity)
	alpha = initial(alpha)
	SSvis_overlays.remove_vis_overlay(src, managed_vis_overlays)
	var/turf/our_turf = get_turf(src)
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, ABOVE_MOB_LAYER, MUTATE_PLANE(GAME_PLANE, our_turf), dir, add_appearance_flags = RESET_ALPHA)

/obj/structure/holosign/barrier/atmos/sturdy
	name = "sturdy holofirelock"
	max_integrity = 150
	openable = FALSE

/obj/structure/holosign/barrier/atmos/tram
	name = "tram atmos barrier"
	max_integrity = 150
	icon_state = "holo_tram"
	openable = FALSE

/obj/structure/holosign/barrier/atmos/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE, TRUE)
	var/static/list/turf_traits = list(TRAIT_FIREDOOR_STOP)
	AddElement(/datum/element/give_turf_traits, turf_traits)

/obj/structure/holosign/barrier/atmos/block_superconductivity() //Didn't used to do this, but it's "normal", and will help ease heat flow transitions with the players.
	return TRUE

/obj/structure/holosign/barrier/atmos/Destroy()
	air_update_turf(TRUE, FALSE)
	return ..()

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "A fragile energy field that blocks movement. Excels at blocking lethal projectiles."
	density = TRUE
	max_integrity = 10
	allow_walk = FALSE
	armor_type = /datum/armor/structure_holosign/cyborg_barrier // Gets a special armor subtype which is extra good at defense.

/datum/armor/structure_holosign/cyborg_barrier
	bullet = 80
	laser = 80
	energy = 80
	melee = 20

/obj/structure/holosign/barrier/medical
	name = "\improper PENLITE holobarrier"
	desc = "A holobarrier that uses biometrics to detect human viruses. Denies passing to personnel with easily-detected, malicious viruses. Good for quarantines."
	icon_state = "holo_medical"
	base_icon_state = "holo_medical"
	max_integrity = 1
	openable = FALSE
	COOLDOWN_DECLARE(virus_detected)

/obj/structure/holosign/barrier/medical/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(istype(mover, /obj/vehicle/ridden))
		for(var/M in mover.buckled_mobs)
			if(ishuman(M))
				if(!CheckHuman(M))
					return FALSE
	if(ishuman(mover))
		return CheckHuman(mover)
	return TRUE

/obj/structure/holosign/barrier/medical/Bumped(atom/movable/AM)
	. = ..()
	icon_state = base_icon_state
	update_icon_state()
	if(!ishuman(AM) && CheckHuman(AM))
		return

	if(!COOLDOWN_FINISHED(src, virus_detected))
		return

	playsound(get_turf(src),'sound/machines/buzz/buzz-sigh.ogg', 65, TRUE, 4)
	COOLDOWN_START(src, virus_detected, 1 SECONDS)
	icon_state = "holo_medical-deny"
	update_icon_state()

/obj/structure/holosign/barrier/medical/proc/CheckHuman(mob/living/carbon/human/sickboi)
	var/threat = sickboi.check_virus()
	if(get_disease_severity_value(threat) > get_disease_severity_value(DISEASE_SEVERITY_MINOR))
		return FALSE
	return TRUE

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "A powerful energy field that blocks movement. Energy arcs off it."
	max_integrity = 20
	armor_type = /datum/armor/structure_holosign //Yeah no this doesn't get projectile resistance.
	var/shockcd = 0

/obj/structure/holosign/barrier/cyborg/hacked/proc/cooldown()
	shockcd = FALSE

/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!shockcd)
		if(ismob(user))
			var/mob/living/M = user
			M.electrocute_act(15,"Energy Barrier")
			shockcd = TRUE
			addtimer(CALLBACK(src, PROC_REF(cooldown)), 0.5 SECONDS)

/obj/structure/holosign/barrier/cyborg/hacked/Bumped(atom/movable/AM)
	if(shockcd)
		return

	if(!ismob(AM))
		return

	var/mob/living/M = AM
	M.electrocute_act(15,"Energy Barrier")
	shockcd = TRUE
	addtimer(CALLBACK(src, PROC_REF(cooldown)), 0.5 SECONDS)
