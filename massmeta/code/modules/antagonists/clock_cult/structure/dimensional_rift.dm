/obj/effect/portal/wormhole/clockcult
	name = "размерная аномалия"
	desc = "Размерная аномалия. Она теплая на ощупь, и из неё выходит легкий клубок пара."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	mech_sized = TRUE
	density = TRUE

/obj/effect/portal/wormhole/clockcult/Bumped(atom/movable/AM)
	. = ..()
	teleport(AM)

/obj/effect/portal/wormhole/clockcult/teleport(atom/movable/M)
	if(iseffect(M))	//sparks don't teleport
		return
	if(M.anchored)
		if(!(ismecha(M) && mech_sized))
			return

	if(ismovable(M))
		if(GLOB.all_wormholes.len)
			var/obj/effect/portal/wormhole/P = pick(GLOB.all_wormholes)
			if(P && isturf(P.loc))
				hard_target = P.loc
		if(!hard_target)
			return
		if(ismob(M))
			to_chat(M, span_notice("Начинаю лезть в трещину."))
			if(do_after(M, 50, target=src))
				var/obj/effect/landmark/city_of_cogs/target_spawn = pick(GLOB.city_of_cogs_spawns)
				var/turf/T = get_turf(target_spawn)
				do_teleport(M, T, no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE, forced = TRUE)
				var/mob/living/M_mob = M
				if(istype(M_mob))
					if(M_mob.client)
						var/client_color = M_mob.client.color
						M_mob.client.color = "#BE8700"
						animate(M_mob.client, color = client_color, time = 25)
				var/prev_alpha = M.alpha
				M.alpha = 0
				animate(M, alpha=prev_alpha, time=10)
		else
			//So we can push crates in too
			var/obj/effect/landmark/city_of_cogs/target_spawn = pick(GLOB.city_of_cogs_spawns)
			var/turf/T = get_turf(target_spawn)
			do_teleport(M, T, no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE, forced = TRUE)
