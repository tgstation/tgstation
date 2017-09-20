//Ocular warden: Low-damage, low-range turret. Applies Belligerent in an area.
/obj/structure/destructible/clockwork/ocular_warden
	name = "ocular warden"
	desc = "A large, eyelike construct that floats in place, giving off an impression of great weight."
	clockwork_desc = "A turret which will automatically apply Belligerent to nearby non-Servants and produce Vitality."
	icon_state = "ocular_warden"
	unanchored_icon = "ocular_warden_unwrenched"
	max_integrity = 60
	construction_value = 10
	layer = WALL_OBJ_LAYER
	break_message = "<span class='warning'>The warden's lens flickers madly before the entire construct shatters!</span>"
	debris = list(/obj/item/clockwork/alloy_shards/small = 3, \
	/obj/item/clockwork/alloy_shards/medium = 1, \
	/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/component/belligerent_eye/suppression_lens = 1)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/sight_range = 3
	var/damage_per_tick = 0.8
	var/mech_damage_per_tick = 5

/obj/structure/destructible/clockwork/ocular_warden/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/structure/destructible/clockwork/ocular_warden/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/structure/destructible/clockwork/ocular_warden/can_be_unfasten_wrench(mob/user, silent)
	if(!anchored)
		for(var/obj/structure/destructible/clockwork/ocular_warden/W in orange(OCULAR_WARDEN_EXCLUSION_RANGE, src))
			if(W.anchored)
				if(!silent)
					to_chat(user, "<span class='neovgre'>You sense another ocular warden too near this location. Activating this one this close would cause them to fight.</span>")
				return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/structure/destructible/clockwork/ocular_warden/ratvar_act()
	..()
	if(GLOB.ratvar_awakens)
		sight_range = 6
	else
		sight_range = initial(sight_range)

/obj/structure/destructible/clockwork/ocular_warden/process()
	if(!anchored)
		return
	for(var/mob/living/L in hearers(sight_range, src))
		if(L.stat != CONSCIOUS || is_servant_of_ratvar(L) || L.null_rod_check())
			continue //shortcut this a bit so we aren't doing checks we don't need to
		var/datum/status_effect/belligerent/B = L.has_status_effect(STATUS_EFFECT_BELLIGERENT)
		var/needs_sound = FALSE
		if(!QDELETED(B)) //they have the effect already, play a sound
			if(prob(50))
				L.playsound_local(null, 'sound/machines/clockcult/ocularwarden-dot1.ogg', 30, 1)
			else
				L.playsound_local(null, 'sound/machines/clockcult/ocularwarden-dot2.ogg', 30, 1)
			new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(L))
			GLOB.clockwork_vitality += damage_per_tick
			L.apply_damage(damage_per_tick * 0.5, BURN, "l_leg")
			L.apply_damage(damage_per_tick * 0.5, BURN, "r_leg")
		else //they don't have the effect yet, try to play a sound
			needs_sound = TRUE
			B = L.apply_status_effect(STATUS_EFFECT_BELLIGERENT, FALSE)
		if(!QDELETED(B))
			if(needs_sound) //hey we need to play a sound
				playsound(src, 'sound/machines/clockcult/ocularwarden-target.ogg', 50, 1)
				B.duration = world.time + 10
			B.duration = max(world.time + 10, B.duration)
	for(var/N in GLOB.mechas_list)
		var/obj/mecha/M = N
		if(M.z == z && get_dist(M, src) <= sight_range && M.occupant && !is_servant_of_ratvar(M.occupant) && (M in view(sight_range, src)))
			M.take_damage(mech_damage_per_tick * get_efficiency_mod(), BURN, "melee", 1, get_dir(src, M))
			new /obj/effect/temp_visual/ratvar/ocular_warden(get_turf(M))
