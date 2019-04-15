/obj/structure/infection
	name = "infection"
	icon = 'icons/mob/blob.dmi'
	light_color = LIGHT_COLOR_FIRE
	light_range = 4
	desc = "A thick wall of writhing tendrils."
	density = FALSE
	opacity = 0
	anchored = TRUE
	layer = BELOW_OBJ_LAYER
	CanAtmosPass = ATMOS_PASS_NO
	var/point_return = 0 //How many points the commander gets back when it removes an infection of that type. If less than 0, structure cannot be removed.
	max_integrity = 30
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 70)
	var/health_regen = 2 //how much health this blob regens when pulsed
	var/next_pulse = 0
	var/pulse_cooldown = 20
	var/brute_resist = 0.5 //multiplies brute damage by this
	var/fire_resist = 1 //multiplies burn damage by this
	var/atmosblock = FALSE //if the infection blocks atmos and heat spread
	var/mob/camera/commander/overmind
	var/list/angles = list() // possible angles for the node to expand on
	var/timecreated
	var/list/upgrade_list = list() // unlockable upgrades
	var/list/upgrade_types = list() // the types of upgrades

/obj/structure/infection/Initialize(mapload, owner_overmind)
	. = ..()
	if(owner_overmind)
		overmind = owner_overmind
	GLOB.infections += src //Keep track of the structure in the normal list either way
	setDir(pick(GLOB.cardinals))
	update_icon()
	if(atmosblock)
		air_update_turf(1)
	ConsumeTile()
	timecreated = world.time
	if(upgrade_types.len > 0)
		for(var/upgrade_type in upgrade_types)
			upgrade_list += new upgrade_type()

/obj/structure/infection/proc/creation_action() //When it's created by the overmind, do this.
	return

/obj/structure/infection/proc/show_infection_menu(var/mob/camera/commander/C)
	if(C != overmind)
		return
	var/list/choices = list(
		"Upgrade Structure" = image(icon = 'icons/mob/blob.dmi', icon_state = "ui_increase"),
		"Structure Overview" = image(icon = 'icons/mob/blob.dmi', icon_state = "ui_help_radial")
	)
	var/choice = show_radial_menu(overmind, src, choices, tooltips = TRUE)
	if(choice == choices[1])
		upgrade_menu(overmind)
	if(choice == choices[2])
		to_chat(overmind, show_description())
	return

/obj/structure/infection/proc/upgrade_menu(var/mob/camera/commander/C)
	var/list/choices = list()
	var/list/upgrades_temp = list()
	for(var/datum/infection/upgrade/U in upgrade_list)
		if(U.times == 0)
			continue
		var/upgrade_index = "[U.name] ([U.cost])"
		choices[upgrade_index] = image(icon = U.radial_icon, icon_state = U.radial_icon_state)
		upgrades_temp += U
	if(!choices.len)
		to_chat(overmind, "<span class='warning'>You have already bought every upgrade for this structure!</span>")
		return
	var/choice = show_radial_menu(overmind, src, choices, tooltips = TRUE)
	var/upgrade_index = choices.Find(choice)
	if(!upgrade_index)
		return
	var/datum/infection/upgrade/Chosen = upgrades_temp[upgrade_index]
	if(overmind.can_buy(Chosen.cost))
		Chosen.do_upgrade(src)
	return

/obj/structure/infection/proc/show_description()
	to_chat(overmind, "<span class='cultlarge'>Upgrades List</span>")
	for(var/datum/infection/upgrade/U in upgrade_list)
		to_chat(overmind, "<span class='notice'>[U.name]: [U.description]</span>")
	return

/obj/structure/infection/Destroy()
	if(atmosblock)
		atmosblock = FALSE
		air_update_turf(1)
	GLOB.infections -= src //it's no longer in the all infections list either
	return ..()

/obj/structure/infection/blob_act()
	return

/obj/structure/infection/singularity_act()
	return

/obj/structure/infection/singularity_pull()
	return

/obj/structure/infection/Adjacent(var/atom/neighbour)
	. = ..()
	if(.)
		var/result = 0
		var/direction = get_dir(src, neighbour)
		var/list/dirs = list("[NORTHWEST]" = list(NORTH, WEST), "[NORTHEAST]" = list(NORTH, EAST), "[SOUTHEAST]" = list(SOUTH, EAST), "[SOUTHWEST]" = list(SOUTH, WEST))
		for(var/A in dirs)
			if(direction == text2num(A))
				for(var/B in dirs[A])
					var/C = locate(/obj/structure/infection) in get_step(src, B)
					if(C)
						result++
		. -= result - 1

/obj/structure/infection/BlockSuperconductivity()
	return atmosblock

/obj/structure/infection/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return 1
	return 0

/obj/structure/infection/CanAtmosPass(turf/T)
	// override for shield blobs etc
	if(atmosblock)
		return FALSE
	// atmos can pass if there's an infection structure the other turf as well (atmos can only pass between other infections like a cell wall)
	var/obj/structure/infection/INF = locate(/obj/structure/infection) in T
	if(INF && !isspaceturf(T))
		return TRUE
	return FALSE

/obj/structure/infection/CanAStarPass(ID, dir, caller)
	. = 0
	if(ismovableatom(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSBLOB)

/obj/structure/infection/update_icon() //Updates color based on overmind color if we have an overmind.
	if(overmind)
		add_atom_colour(overmind.infection_color, FIXED_COLOUR_PRIORITY)
	else
		remove_atom_colour(FIXED_COLOUR_PRIORITY)

/obj/structure/infection/process()
	Life()

/obj/structure/infection/proc/Life()
	return

/obj/structure/infection/proc/reset_angles()
	angles = list(0,15,30,45,60,75,90,105,120,135,150,165,180,195,210,225,240,255,270,285,300,315,330,345) // this is aids but you cant use initial() on lists so :shrug: i'd rather not loop

/obj/structure/infection/proc/Pulse_Area(mob/camera/commander/pulsing_overmind, var/claim_range = 6, var/count = 6)
	if(QDELETED(pulsing_overmind))
		pulsing_overmind = overmind
	Be_Pulsed()
	ConsumeTile()
	next_pulse = world.time + pulse_cooldown // increases cooldown based on greater time alive
	for(var/i = 1 to count)
		if(!angles.len)
			reset_angles()
		var/angle = pick(angles)
		angles -= angle
		angle += rand(-7, 7)
		var/turf/check = src
		for(var/j = 1 to claim_range)
			check = locate(src.x + cos(angle) * j, src.y + sin(angle) * j, src.z)
			if(!check || check.is_transition_turf())
				check = locate(src.x + cos(angle) * (j - 1), src.y + sin(angle) * (j - 1), src.z)
				break
		var/list/toaffect = getline(src, check)
		var/obj/structure/infection/previous = src
		for(var/j = 2 to toaffect.len)
			var/obj/structure/infection/INF = locate(/obj/structure/infection) in toaffect[j]
			if(!INF)
				previous.expand(toaffect[j])
				break
			INF.ConsumeTile()
			INF.air_update_turf(1)
			INF.Be_Pulsed()
			previous = INF

/obj/structure/infection/proc/Be_Pulsed()
	ConsumeTile()
	obj_integrity = min(max_integrity, obj_integrity+health_regen)
	update_icon()

/obj/structure/infection/proc/ConsumeTile()
	for(var/atom/A in loc)
		if(isliving(A) || ismecha(A))
			continue
		A.blob_act(src)
	if(iswallturf(loc))
		loc.blob_act(src) //don't ask how a wall got on top of the core, just eat it

/obj/structure/infection/proc/infection_attack_animation(atom/A = null) //visually attacks an atom
	var/obj/effect/temp_visual/blob/O = new /obj/effect/temp_visual/blob(src.loc)
	O.setDir(dir)
	if(overmind)
		O.color = overmind.infection_color
	if(A)
		O.do_attack_animation(A) //visually attack the whatever
	return O //just in case you want to do something to the animation.

/obj/structure/infection/proc/expand(turf/T = null, controller = null)
	var/area/turfArea = T.loc
	// do not expand to areas that were space at roundstart
	if(istype(turfArea, /area/space))
		return null
	infection_attack_animation(T)
	if(locate(/obj/structure/beacon_wall) in T.contents || locate(/obj/structure/infection) in T.contents)
		return
	var/obj/structure/infection/I = new /obj/structure/infection/normal(src.loc, (controller || overmind))
	I.density = TRUE
	if(T.Enter(I,src))
		I.density = initial(I.density)
		I.forceMove(T)
		I.update_icon()
		I.ConsumeTile()
		if(T.dynamic_lighting == 0)
			T.dynamic_lighting = 1
			T.lighting_build_overlay()
		return I
	else
		T.blob_act(src)
		for(var/atom/A in T)
			A.blob_act(src) //also hit everything in the turf
		qdel(I)
		return null

/obj/structure/infection/emp_act(severity)
	. = ..()
	return

/obj/structure/infection/ex_act(severity)
	take_damage(rand(30/severity, 60/severity), BRUTE, "bomb", 0)

/obj/structure/infection/tesla_act(power)
	..()
	return 0

/obj/structure/infection/extinguish()
	..()
	return

/obj/structure/infection/hulk_damage()
	return 15

/obj/structure/infection/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_ANALYZER)
		user.changeNext_move(CLICK_CD_MELEE)
		to_chat(user, "<b>The analyzer beeps once, then reports:</b><br>")
		SEND_SOUND(user, sound('sound/machines/ping.ogg'))
		if(!overmind)
			to_chat(user, "<b>Infection core neutralized. Critical mass no longer attainable.</b>")
		typereport(user)
	else
		return ..()

/obj/structure/infection/proc/typereport(mob/user)
	to_chat(user, "<b>Infection Type:</b> <span class='notice'>[uppertext(initial(name))]</span>")
	to_chat(user, "<b>Health:</b> <span class='notice'>[obj_integrity]/[max_integrity]</span>")
	to_chat(user, "<b>Effects:</b> <span class='notice'>[scannerreport()]</span>")

/obj/structure/infection/attack_animal(mob/living/simple_animal/M)
	if(ROLE_INFECTION in M.faction) //sorry, but you can't kill the infection as a sentient infection
		return
	..()

/obj/structure/infection/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src.loc, 'sound/effects/attackblob.ogg', 50, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, 1)

/obj/structure/infection/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	switch(damage_type)
		if(BRUTE)
			damage_amount *= brute_resist
		if(BURN)
			damage_amount *= fire_resist
		if(CLONE)
		else
			return 0
	var/armor_protection = 0
	if(damage_flag)
		armor_protection = armor.getRating(damage_flag)
	damage_amount = round(damage_amount * (100 - armor_protection)*0.01, 0.1)
	return damage_amount

/obj/structure/infection/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		update_icon()

/obj/structure/infection/obj_destruction(damage_flag)
	..()

/obj/structure/infection/proc/change_to(type, controller)
	if(!ispath(type))
		throw EXCEPTION("change_to(): invalid type for infection")
		return
	var/obj/structure/infection/I = new type(src.loc, controller)
	I.creation_action()
	I.update_icon()
	I.setDir(dir)
	qdel(src)
	return I

/obj/structure/infection/examine(mob/user)
	..()
	var/datum/atom_hud/hud_to_check = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	if(user.research_scanner || hud_to_check.hudusers[user])
		to_chat(user, "<b>Your HUD displays an extensive report...</b><br>")
		if(!overmind)
			to_chat(user, "<b>Core neutralized. Critical mass no longer attainable.</b>")
		typereport(user)
	else
		to_chat(user, "It seems to radiate light.")

/obj/structure/infection/proc/scannerreport()
	return "An infection. Looks like someone forgot to override this proc, adminhelp this."

/obj/structure/infection/normal
	name = "normal infection"
	icon_state = "blob"
	//layer = TURF_LAYER
	light_range = 2
	obj_integrity = 25
	max_integrity = 25
	health_regen = 1
	brute_resist = 0.25

/obj/structure/infection/normal/show_infection_menu(var/mob/camera/commander/C)
	return

/obj/structure/infection/normal/CanPass(atom/movable/mover, turf/target)
	. = ..()
	if(. || !istype(mover, /obj/item/projectile))
		return TRUE
	return FALSE

/obj/structure/infection/normal/Crossed(atom/movable/mover)
	if(istype(mover) && (mover.pass_flags & PASSBLOB))
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		M.add_movespeed_modifier(MOVESPEED_ID_INFECTION_STRUCTURE, update=TRUE, priority=100, multiplicative_slowdown=3)
	// ambience, would use area code but fairly certain you cant change areas in runtime properly, if you can just use that for tons of this stuff tbh
	if(isliving(mover))
		var/mob/living/L = mover
		if(prob(35))
			if(L.client && (L.client.prefs.toggles & SOUND_AMBIENCE))
				var/sound = pick(MINING)
				if(!L.client.played)
					SEND_SOUND(L, sound(sound, repeat = 0, wait = 0, volume = 25, channel = CHANNEL_AMBIENCE))
					L.client.played = TRUE
					addtimer(CALLBACK(L.client, /client/proc/ResetAmbiencePlayed), 600)

/obj/structure/infection/normal/Uncrossed(atom/movable/mover)
	if(ismob(mover))
		var/mob/M = mover
		M.remove_movespeed_modifier(MOVESPEED_ID_INFECTION_STRUCTURE, update = TRUE)

/obj/structure/infection/normal/scannerreport()
	return "N/A"

/obj/structure/infection/normal/update_icon()
	..()
	if(obj_integrity <= 15)
		icon_state = "blob_damaged"
		name = "fragile infection"
		desc = "A thin lattice of slightly twitching tendrils."
	else if (overmind)
		icon_state = "blob"
		name = "infection"
		desc = "A thick wall of writhing tendrils."
	else
		icon_state = "blob"
		name = "dead infection"
		desc = "A thick wall of lifeless tendrils."
		light_range = 0
