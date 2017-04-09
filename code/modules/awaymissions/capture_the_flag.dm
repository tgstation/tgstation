#define WHITE_TEAM "white"
#define RED_TEAM "red"
#define BLUE_TEAM "blue"
#define FLAG_RETURN_TIME 200 // 20 seconds
#define INSTAGIB_RESPAWN 50 //5 seconds
#define DEFAULT_RESPAWN 150 //15 seconds
#define AMMO_DROP_LIFETIME 300



/obj/item/weapon/twohanded/ctf
	name = "banner"
	icon = 'icons/obj/items.dmi'
	icon_state = "banner"
	item_state = "banner"
	desc = "A banner with Nanotrasen's logo on it."
	slowdown = 2
	throw_speed = 0
	throw_range = 1
	force = 200
	armour_penetration = 1000
	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE
	var/team = WHITE_TEAM
	var/reset_cooldown = 0
	var/obj/effect/ctf/flag_reset/reset
	var/reset_path = /obj/effect/ctf/flag_reset

/obj/item/weapon/twohanded/ctf/Destroy()
	if(reset)
		qdel(reset)
		reset = null
	. = ..()

/obj/item/weapon/twohanded/ctf/Initialize()
	..()
	SET_SECONDARY_FLAG(src, SLOWS_WHILE_IN_HAND)
	if(!reset)
		reset = new reset_path(get_turf(src))

/obj/item/weapon/twohanded/ctf/process()
	if(world.time > reset_cooldown)
		forceMove(get_turf(src.reset))
		for(var/mob/M in player_list)
			var/area/mob_area = get_area(M)
			if(istype(mob_area, /area/ctf))
				to_chat(M, "<span class='userdanger'>\The [src] has been returned to base!</span>")
		STOP_PROCESSING(SSobj, src)

/obj/item/weapon/twohanded/ctf/attack_hand(mob/living/user)
	if(!is_ctf_target(user))
		to_chat(user, "Non players shouldn't be moving the flag!")
		return
	if(team in user.faction)
		to_chat(user, "You can't move your own flag!")
		return
	if(loc == user)
		if(!user.dropItemToGround(src))
			return
	anchored = FALSE
	pickup(user)
	if(!user.put_in_active_hand(src))
		dropped(user)
		return
	user.anchored = TRUE
	for(var/mob/M in player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, /area/ctf))
			to_chat(M, "<span class='userdanger'>\The [src] has been taken!</span>")
	STOP_PROCESSING(SSobj, src)

/obj/item/weapon/twohanded/ctf/dropped(mob/user)
	..()
	user.anchored = FALSE
	reset_cooldown = world.time + 200 //20 seconds
	START_PROCESSING(SSobj, src)
	for(var/mob/M in player_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, /area/ctf))
			to_chat(M, "<span class='userdanger'>\The [src] has been dropped!</span>")
	anchored = TRUE


/obj/item/weapon/twohanded/ctf/red
	name = "red flag"
	icon_state = "banner-red"
	item_state = "banner-red"
	desc = "A red banner used to play capture the flag."
	team = RED_TEAM
	reset_path = /obj/effect/ctf/flag_reset/red


/obj/item/weapon/twohanded/ctf/blue
	name = "blue flag"
	icon_state = "banner-blue"
	item_state = "banner-blue"
	desc = "A blue banner used to play capture the flag."
	team = BLUE_TEAM
	reset_path = /obj/effect/ctf/flag_reset/blue

/obj/effect/ctf/flag_reset
	name = "banner landmark"
	icon = 'icons/obj/items.dmi'
	icon_state = "banner"
	desc = "This is where a banner with Nanotrasen's logo on it would go."
	layer = LOW_ITEM_LAYER

/obj/effect/ctf/flag_reset/red
	name = "red flag landmark"
	icon_state = "banner-red"
	desc = "This is where a red banner used to play capture the flag \
		would go."

/obj/effect/ctf/flag_reset/blue
	name = "blue flag landmark"
	icon_state = "banner-blue"
	desc = "This is where a blue banner used to play capture the flag \
		would go."

/proc/toggle_all_ctf(mob/user)
	var/ctf_enabled = FALSE
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		ctf_enabled = CTF.toggle_ctf()
	message_admins("[key_name_admin(user)] has [ctf_enabled? "enabled" : "disabled"] CTF!")
	notify_ghosts("CTF has been [ctf_enabled? "enabled" : "disabled"]!",'sound/effects/ghost2.ogg')

/obj/machinery/capture_the_flag
	name = "CTF Controller"
	desc = "Used for running friendly games of capture the flag."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"
	anchored = 1
	resistance_flags = INDESTRUCTIBLE
	var/team = WHITE_TEAM
	//Capture the Flag scoring
	var/points = 0
	var/points_to_win = 3
	var/respawn_cooldown = DEFAULT_RESPAWN
	//Capture Point/King of the Hill scoring
	var/control_points = 0
	var/control_points_to_win = 180
	var/list/team_members = list()
	var/list/spawned_mobs = list()
	var/list/recently_dead_ckeys = list()
	var/ctf_enabled = FALSE
	var/ctf_gear = /datum/outfit/ctf
	var/instagib_gear = /datum/outfit/ctf/instagib

	var/list/dead_barricades = list()

	var/static/ctf_object_typecache
	var/static/arena_reset = FALSE

/obj/machinery/capture_the_flag/Initialize()
	..()
	if(!ctf_object_typecache)
		ctf_object_typecache = typecacheof(list(
			/turf,
			/mob,
			/area,
			/obj/machinery,
			/obj/structure,
			/obj/effect/ctf,
			/obj/item/weapon/twohanded/ctf
		))
	poi_list |= src

/obj/machinery/capture_the_flag/Destroy()
	poi_list.Remove(src)
	..()

/obj/machinery/capture_the_flag/process()
	for(var/i in spawned_mobs)
		if(!i)
			spawned_mobs -= i
			continue
		// Anyone in crit, automatically reap
		var/mob/living/M = i
		if(M.InCritical() || M.stat == DEAD)
			ctf_dust_old(M)
		else
			// The changes that you've been hit with no shield but not
			// instantly critted are low, but have some healing.
			M.adjustBruteLoss(-5)
			M.adjustFireLoss(-5)

/obj/machinery/capture_the_flag/red
	name = "Red CTF Controller"
	icon_state = "syndbeacon"
	team = RED_TEAM
	ctf_gear = /datum/outfit/ctf/red
	instagib_gear = /datum/outfit/ctf/red/instagib

/obj/machinery/capture_the_flag/blue
	name = "Blue CTF Controller"
	icon_state = "bluebeacon"
	team = BLUE_TEAM
	ctf_gear = /datum/outfit/ctf/blue
	instagib_gear = /datum/outfit/ctf/blue/instagib

/obj/machinery/capture_the_flag/attack_ghost(mob/user)
	if(ctf_enabled == FALSE)
		if(user.client && user.client.holder)
			var/response = alert("Enable CTF?", "CTF", "Yes", "No")
			if(response == "Yes")
				toggle_all_ctf(user)
		return

	if(SSticker.current_state < GAME_STATE_PLAYING)
		return
	if(user.ckey in team_members)
		if(user.ckey in recently_dead_ckeys)
			to_chat(user, "It must be more than [respawn_cooldown/10] seconds from your last death to respawn!")
			return
		var/client/new_team_member = user.client
		if(user.mind && user.mind.current)
			ctf_dust_old(user.mind.current)
		spawn_team_member(new_team_member)
		return

	for(var/obj/machinery/capture_the_flag/CTF in machines)
		if(CTF == src || CTF.ctf_enabled == FALSE)
			continue
		if(user.ckey in CTF.team_members)
			to_chat(user, "No switching teams while the round is going!")
			return
		if(CTF.team_members.len < src.team_members.len)
			to_chat(user, "[src.team] has more team members than [CTF.team]. Try joining [CTF.team] to even things up.")
			return
	team_members |= user.ckey
	var/client/new_team_member = user.client
	if(user.mind && user.mind.current)
		ctf_dust_old(user.mind.current)
	spawn_team_member(new_team_member)

/obj/machinery/capture_the_flag/proc/ctf_dust_old(mob/living/body)
	if(isliving(body) && (team in body.faction))
		var/turf/T = get_turf(body)
		new /obj/effect/ctf/ammo(T)
		recently_dead_ckeys += body.ckey
		addtimer(CALLBACK(src, .proc/clear_cooldown, body.ckey), respawn_cooldown, TIMER_UNIQUE)
		body.dust()

/obj/machinery/capture_the_flag/proc/clear_cooldown(var/ckey)
	recently_dead_ckeys -= ckey

/obj/machinery/capture_the_flag/proc/spawn_team_member(client/new_team_member)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(get_turf(src))
	new_team_member.prefs.copy_to(M)
	M.key = new_team_member.key
	M.faction += team
	M.equipOutfit(ctf_gear)
	spawned_mobs += M

/obj/machinery/capture_the_flag/Topic(href, href_list)
	if(href_list["join"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/obj/machinery/capture_the_flag/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/twohanded/ctf))
		var/obj/item/weapon/twohanded/ctf/flag = I
		if(flag.team != src.team)
			user.transferItemToLoc(flag, get_turf(flag.reset), TRUE)
			points++
			for(var/mob/M in player_list)
				var/area/mob_area = get_area(M)
				if(istype(mob_area, /area/ctf))
					to_chat(M, "<span class='userdanger'>[user.real_name] has captured \the [flag], scoring a point for [team] team! They now have [points]/[points_to_win] points!</span>")
		if(points >= points_to_win)
			victory()

/obj/machinery/capture_the_flag/proc/victory()
	for(var/mob/M in mob_list)
		var/area/mob_area = get_area(M)
		if(istype(mob_area, /area/ctf))
			to_chat(M, "<span class='narsie'>[team] team wins!</span>")
			to_chat(M, "<span class='userdanger'>The game has been reset! Teams have been cleared. The machines will be active again in 30 seconds.</span>")
			for(var/obj/item/weapon/twohanded/ctf/W in M)
				M.dropItemToGround(W)
			M.dust()
	for(var/obj/machinery/control_point/control in machines)
		control.icon_state = "dominator"
		control.controlling = null
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		if(CTF.ctf_enabled == TRUE)
			CTF.points = 0
			CTF.control_points = 0
			CTF.ctf_enabled = FALSE
			CTF.team_members = list()
			CTF.arena_reset = FALSE
			addtimer(CALLBACK(CTF, .proc/start_ctf), 300)

/obj/machinery/capture_the_flag/proc/toggle_ctf()
	if(!ctf_enabled)
		start_ctf()
		. = TRUE
	else
		stop_ctf()
		. = FALSE

/obj/machinery/capture_the_flag/proc/start_ctf()
	ctf_enabled = TRUE
	for(var/d in dead_barricades)
		var/obj/effect/ctf/dead_barricade/D = d
		D.respawn()

	dead_barricades.Cut()

	notify_ghosts("[name] has been activated!", enter_link="<a href=?src=\ref[src];join=1>(Click to join the [team] team!)</a> or click on the controller directly!", source = src, action=NOTIFY_ATTACK)

	if(!arena_reset)
		reset_the_arena()
		arena_reset = TRUE

/obj/machinery/capture_the_flag/proc/reset_the_arena()
	var/area/A = get_area(src)
	for(var/atm in A)
		if(!is_type_in_typecache(atm, ctf_object_typecache))
			qdel(atm)
		if(istype(atm, /obj/structure))
			var/obj/structure/S = atm
			S.obj_integrity = S.max_integrity

/obj/machinery/capture_the_flag/proc/stop_ctf()
	ctf_enabled = FALSE
	arena_reset = FALSE
	var/area/A = get_area(src)
	for(var/i in mob_list)
		var/mob/M = i
		if((get_area(A) == A) && (M.ckey in team_members))
			M.dust()
	team_members.Cut()
	spawned_mobs.Cut()
	recently_dead_ckeys.Cut()

/obj/machinery/capture_the_flag/proc/instagib_mode()
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		if(CTF.ctf_enabled == TRUE)
			CTF.ctf_gear = CTF.instagib_gear
			CTF.respawn_cooldown = INSTAGIB_RESPAWN

/obj/machinery/capture_the_flag/proc/normal_mode()
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		if(CTF.ctf_enabled == TRUE)
			CTF.ctf_gear = initial(ctf_gear)
			CTF.respawn_cooldown = DEFAULT_RESPAWN

/obj/item/weapon/gun/ballistic/automatic/pistol/deagle/ctf
	desc = "This looks like it could really hurt in melee."
	force = 75
	mag_type = /obj/item/ammo_box/magazine/m50/ctf

/obj/item/weapon/gun/ballistic/automatic/pistol/deagle/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/weapon/gun/ballistic/automatic/pistol/deagle/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/m50/ctf
	ammo_type = /obj/item/ammo_casing/a50/ctf

/obj/item/ammo_casing/a50/ctf
	projectile_type = /obj/item/projectile/bullet/ctf

/obj/item/projectile/bullet/ctf
	damage = 0

/obj/item/projectile/bullet/ctf/prehit(atom/target)
	if(is_ctf_target(target))
		damage = 60
	. = ..()

/obj/item/weapon/gun/ballistic/automatic/laser/ctf
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf
	desc = "This looks like it could really hurt in melee."
	force = 50

/obj/item/weapon/gun/ballistic/automatic/laser/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/weapon/gun/ballistic/automatic/laser/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_box/magazine/recharge/ctf
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf

/obj/item/ammo_box/magazine/recharge/ctf/dropped()
	. = ..()
	addtimer(CALLBACK(src, .proc/floor_vanish), 1)

/obj/item/ammo_box/magazine/recharge/ctf/proc/floor_vanish()
	if(isturf(loc))
		qdel(src)

/obj/item/ammo_casing/caseless/laser/ctf
	projectile_type = /obj/item/projectile/beam/ctf

/obj/item/projectile/beam/ctf
	damage = 0
	icon_state = "omnilaser"

/obj/item/projectile/beam/ctf/prehit(atom/target)
	if(is_ctf_target(target))
		damage = 150
	. = ..()

/proc/is_ctf_target(atom/target)
	. = FALSE
	if(istype(target, /obj/structure/barricade/security/ctf))
		. = TRUE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit/shielded/ctf))
			. = TRUE

// RED TEAM GUNS

/obj/item/weapon/gun/ballistic/automatic/laser/ctf/red
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/red

/obj/item/ammo_box/magazine/recharge/ctf/red
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/red

/obj/item/ammo_casing/caseless/laser/ctf/red
	projectile_type = /obj/item/projectile/beam/ctf/red

/obj/item/projectile/beam/ctf/red
	icon_state = "laser"
	impact_effect_type = /obj/effect/overlay/temp/impact_effect/red_laser

// BLUE TEAM GUNS

/obj/item/weapon/gun/ballistic/automatic/laser/ctf/blue
	mag_type = /obj/item/ammo_box/magazine/recharge/ctf/blue

/obj/item/ammo_box/magazine/recharge/ctf/blue
	ammo_type = /obj/item/ammo_casing/caseless/laser/ctf/blue

/obj/item/ammo_casing/caseless/laser/ctf/blue
	projectile_type = /obj/item/projectile/beam/ctf/blue

/obj/item/projectile/beam/ctf/blue
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/overlay/temp/impact_effect/blue_laser

/datum/outfit/ctf
	name = "CTF"
	ears = /obj/item/device/radio/headset
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf
	toggle_helmet = FALSE // see the whites of their eyes
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/weapon/card/id/syndicate
	belt = /obj/item/weapon/gun/ballistic/automatic/pistol/deagle/ctf
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf
	r_hand = /obj/item/weapon/gun/ballistic/automatic/laser/ctf

/datum/outfit/ctf/post_equip(mob/living/carbon/human/H, visualsOnly=FALSE)
	if(visualsOnly)
		return
	var/list/no_drops = list()
	var/obj/item/weapon/card/id/W = H.wear_id
	no_drops += W
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

	// The shielded hardsuit is already NODROP
	no_drops += H.get_item_by_slot(slot_gloves)
	no_drops += H.get_item_by_slot(slot_shoes)
	no_drops += H.get_item_by_slot(slot_w_uniform)
	no_drops += H.get_item_by_slot(slot_ears)
	for(var/i in no_drops)
		var/obj/item/I = i
		I.flags |= NODROP

/datum/outfit/ctf/instagib
	r_hand = /obj/item/weapon/gun/energy/laser/instakill
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/red
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/red
	r_hand = /obj/item/weapon/gun/ballistic/automatic/laser/ctf/red
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/red
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/red

/datum/outfit/ctf/red/instagib
	r_hand = /obj/item/weapon/gun/energy/laser/instakill/red
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/blue
	suit = /obj/item/clothing/suit/space/hardsuit/shielded/ctf/blue
	r_hand = /obj/item/weapon/gun/ballistic/automatic/laser/ctf/blue
	l_pocket = /obj/item/ammo_box/magazine/recharge/ctf/blue
	r_pocket = /obj/item/ammo_box/magazine/recharge/ctf/blue

/datum/outfit/ctf/blue/instagib
	r_hand = /obj/item/weapon/gun/energy/laser/instakill/blue
	shoes = /obj/item/clothing/shoes/jackboots/fast

/datum/outfit/ctf/red/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(REDTEAM_FREQ)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0

/datum/outfit/ctf/blue/post_equip(mob/living/carbon/human/H)
	..()
	var/obj/item/device/radio/R = H.ears
	R.set_frequency(BLUETEAM_FREQ)
	R.freqlock = TRUE
	R.independent = TRUE
	H.dna.species.stunmod = 0



/obj/structure/trap/ctf
	name = "Spawn protection"
	desc = "Stay outta the enemy spawn!"
	icon_state = "trap"
	resistance_flags = INDESTRUCTIBLE
	var/team = WHITE_TEAM
	time_between_triggers = 1
	anchored = TRUE
	alpha = 255

/obj/structure/trap/examine(mob/user)
	return

/obj/structure/trap/ctf/trap_effect(mob/living/L)
	if(!is_ctf_target(L))
		return
	if(!(src.team in L.faction))
		to_chat(L, "<span class='danger'><B>Stay out of the enemy spawn!</B></span>")
		L.death()

/obj/structure/trap/ctf/red
	team = RED_TEAM
	icon_state = "trap-fire"

/obj/structure/trap/ctf/blue
	team = BLUE_TEAM
	icon_state = "trap-frost"

/obj/structure/barricade/security/ctf
	name = "barrier"
	desc = "A barrier. Provides cover in fire fights."
	deploy_time = 0
	deploy_message = 0

/obj/structure/barricade/security/ctf/make_debris()
	new /obj/effect/ctf/dead_barricade(get_turf(src))

/obj/effect/ctf
	density = FALSE
	anchored = TRUE
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100
	resistance_flags = INDESTRUCTIBLE

/obj/effect/ctf/ammo
	name = "ammo pickup"
	desc = "You like revenge, right? Everybody likes revenge! Well, \
		let's go get some!"
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield1"
	layer = ABOVE_MOB_LAYER
	alpha = 255
	invisibility = 0

/obj/effect/ctf/ammo/Initialize(mapload)
	..()
	QDEL_IN(src, AMMO_DROP_LIFETIME)

/obj/effect/ctf/ammo/Crossed(atom/movable/AM)
	reload(AM)

/obj/effect/ctf/ammo/Bump(atom/movable/AM)
	reload(AM)

/obj/effect/ctf/ammo/Bumped(atom/movable/AM)
	reload(AM)

/obj/effect/ctf/ammo/proc/reload(mob/living/M)
	if(!ishuman(M))
		return
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		if(M in CTF.spawned_mobs)
			var/outfit = CTF.ctf_gear
			var/datum/outfit/O = new outfit
			for(var/obj/item/weapon/gun/G in M)
				qdel(G)
			O.equip(M)
			to_chat(M, "<span class='notice'>Ammunition reloaded!</span>")
			playsound(get_turf(M), 'sound/weapons/shotgunpump.ogg', 50, 1, -1)
			qdel(src)
			break

/obj/effect/ctf/dead_barricade
	name = "dead barrier"
	desc = "It provided cover in fire fights. And now it's gone."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"

/obj/effect/ctf/dead_barricade/Initialize(mapload)
	..()
	for(var/obj/machinery/capture_the_flag/CTF in machines)
		CTF.dead_barricades += src

/obj/effect/ctf/dead_barricade/proc/respawn()
	if(!QDELETED(src))
		new /obj/structure/barricade/security/ctf(get_turf(src))
		qdel(src)


//Control Point

/obj/machinery/control_point
	name = "control point"
	desc = "You should capture this."
	icon = 'icons/obj/machines/dominator.dmi'
	icon_state = "dominator"
	anchored = 1
	resistance_flags = INDESTRUCTIBLE
	var/obj/machinery/capture_the_flag/controlling
	var/team = "none"
	var/point_rate = 1

/obj/machinery/control_point/process()
	if(controlling)
		controlling.control_points += point_rate
		if(controlling.control_points >= controlling.control_points_to_win)
			controlling.victory()

/obj/machinery/control_point/attackby(mob/user, params)
	capture(user)

/obj/machinery/control_point/attack_hand(mob/user)
	capture(user)

/obj/machinery/control_point/proc/capture(mob/user)
	if(do_after(user, 30, target = src))
		for(var/obj/machinery/capture_the_flag/CTF in machines)
			if(CTF.ctf_enabled && (user.ckey in CTF.team_members))
				controlling = CTF
				icon_state = "dominator-[CTF.team]"
				for(var/mob/M in player_list)
					var/area/mob_area = get_area(M)
					if(istype(mob_area, /area/ctf))
						to_chat(M, "<span class='userdanger'>[user.real_name] has captured \the [src], claiming it for [CTF.team]! Go take it back!</span>")
				break

#undef WHITE_TEAM
#undef RED_TEAM
#undef BLUE_TEAM
#undef FLAG_RETURN_TIME
#undef INSTAGIB_RESPAWN
#undef DEFAULT_RESPAWN
#undef AMMO_DROP_LIFETIME
