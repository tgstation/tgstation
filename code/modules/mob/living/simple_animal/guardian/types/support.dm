//Healer
/mob/living/simple_animal/hostile/guardian/healer
	combat_mode = TRUE
	friendly_verb_continuous = "heals"
	friendly_verb_simple = "heal"
	speed = 0
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = "<span class='holoparasite'>As a <b>support</b> type, you may toggle your basic attacks to a healing mode. In addition, Alt-Clicking on an adjacent object or mob will warp them to your bluespace beacon after a short delay.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the CMO, a potent force of life... and death.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught a support carp. It's a kleptocarp!</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Support modules active. Holoparasite swarm online.</span>"
	miner_fluff_string = "<span class='holoparasite'>You encounter... Bluespace, the master of support.</span>"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode
	var/obj/structure/receiving_pad/beacon
	var/beacon_cooldown = 0
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/healer/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.show_to(src)

/mob/living/simple_animal/hostile/guardian/healer/get_status_tab_items()
	. = ..()
	if(beacon_cooldown >= world.time)
		. += "Beacon Cooldown Remaining: [DisplayTimeText(beacon_cooldown - world.time)]"

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	. = ..()
	if(is_deployed() && toggle && iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(-5)
		C.adjustFireLoss(-5)
		C.adjustOxyLoss(-5)
		C.adjustToxLoss(-5)
		var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(C))
		if(guardiancolor)
			H.color = guardiancolor
		if(C == summoner)
			update_health_hud()
			med_hud_set_health()
			med_hud_set_status()

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			set_combat_mode(TRUE)
			speed = 0
			damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
			melee_damage_lower = 15
			melee_damage_upper = 15
			to_chat(src, "[span_danger("<B>You switch to combat mode.")]</B>")
			toggle = FALSE
		else
			set_combat_mode(FALSE)
			speed = 1
			damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, "[span_danger("<B>You switch to healing mode.")]</B>")
			toggle = TRUE
	else
		to_chat(src, "[span_danger("<B>You have to be recalled to toggle modes!")]</B>")


/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."

	if(beacon_cooldown >= world.time)
		to_chat(src, "[span_danger("<B>Your power is on cooldown. You must wait five minutes between placing beacons.")]</B>")
		return

	var/turf/beacon_loc = get_turf(src.loc)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, src)

	to_chat(src, "[span_danger("<B>Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click.")]</B>")

	beacon_cooldown = world.time + 3000

/obj/structure/receiving_pad
	name = "bluespace receiving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A receiving zone for bluespace teleportations."
	icon_state = "light_on-8"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/receiving_pad/New(loc, mob/living/simple_animal/hostile/guardian/healer/G)
	. = ..()
	if(G?.guardiancolor)
		add_atom_colour(G.guardiancolor, FIXED_COLOUR_PRIORITY)

/obj/structure/receiving_pad/proc/disappear()
	visible_message(span_notice("[src] vanishes!"))
	qdel(src)

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		to_chat(src, "[span_danger("<B>You must be manifested to warp a target!")]</B>")
		return
	if(!beacon)
		to_chat(src, "[span_danger("<B>You need a beacon placed to warp things!")]</B>")
		return
	if(!Adjacent(A))
		to_chat(src, "[span_danger("<B>You must be adjacent to your target!")]</B>")
		return
	if(A.anchored)
		to_chat(src, "[span_danger("<B>Your target cannot be anchored!")]</B>")
		return

	var/turf/T = get_turf(A)
	if(beacon.z != T.z)
		to_chat(src, "[span_danger("<B>The beacon is too far away to warp to!")]</B>")
		return

	to_chat(src, "[span_danger("<B>You begin to warp [A].")]</B>")
	A.visible_message(span_danger("[A] starts to glow faintly!"), \
	span_userdanger("You start to faintly glow, and you feel strangely weightless!"))
	do_attack_animation(A)

	if(!do_mob(src, A, 60)) //now start the channel
		to_chat(src, "[span_danger("<B>You need to hold still!")]</B>")
		return

	new /obj/effect/temp_visual/guardian/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message(span_danger("[A] disappears in a flash of light!"), \
	span_userdanger("Your vision is obscured by a flash of light!"))
	do_teleport(A, beacon, 0, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(A))
