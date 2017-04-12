//healsluts

/datum/sutando_abilities/heal
	id = "heal"
	name = "Mending Properties"
	value = 5
	var/obj/structure/recieving_pad/beacon
	var/beacon_cooldown = 0
	var/datum/action/innate/beacon/B = new

/datum/sutando_abilities/heal/Destroy()
	QDEL_NULL(B)
	return ..()

/datum/sutando_abilities/heal/proc/plant_beacon()
	if(beacon_cooldown >= world.time)
		to_chat(stand,"<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>")
		return

	var/turf/beacon_loc = get_turf(stand)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, stand)

	to_chat(stand,"<span class='danger'><B>Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click.</span></B>")

	beacon_cooldown = world.time + 3000


/datum/action/innate/beacon
	background_icon_state = "bg_alien"
	name = "Plant Beacon"
	button_icon_state = "set_drop"

/datum/action/innate/beacon/Activate()
	var/mob/living/simple_animal/hostile/sutando/A = owner
	for(var/datum/sutando_abilities/heal/I in A.current_abilities)
		I.plant_beacon()

/datum/sutando_abilities/heal/handle_stats()
	. = ..()
	stand.a_intent = INTENT_HARM
	stand.friendly = "heals"
	stand.speed -= 0.5
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.15
	stand.melee_damage_lower += 7
	stand.melee_damage_upper += 7
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode
	B.Grant(stand)

	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(stand)

/datum/sutando_abilities/heal/ability_act()
	if(toggle)
		if(iscarbon(stand.target))
			var/mob/living/carbon/C = stand.target
			C.adjustBruteLoss(-5)
			C.adjustFireLoss(-5)
			C.adjustOxyLoss(-5)
			C.adjustToxLoss(-5)
			var/obj/effect/overlay/temp/heal/H = new /obj/effect/overlay/temp/heal(get_turf(C))
			if(stand.namedatum)
				H.color = stand.namedatum.colour
			if(C == user)
				stand.update_health_hud()
				stand.med_hud_set_health()
				stand.med_hud_set_status()

/datum/sutando_abilities/heal/handle_mode()
	if(stand.loc == user)
		if(toggle)
			stand.a_intent = initial(stand.a_intent)
			stand.speed = initial(stand.speed)
			stand.damage_coeff = initial_coeff
			stand.melee_damage_lower = initial(stand.melee_damage_lower)
			stand.melee_damage_upper = initial(stand.melee_damage_upper)
			to_chat(stand,"<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			stand.a_intent = INTENT_HELP
			stand.speed = 1
			stand.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			stand.melee_damage_lower = 0
			stand.melee_damage_upper = 0
			to_chat(stand,"<span class='danger'><B>You switch to healing mode.</span></B>")
			toggle = TRUE
	else
		to_chat(stand,"<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")

/datum/sutando_abilities/heal/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(stand.loc == user)
		to_chat(stand,"<span class='danger'><B>You must be manifested to warp a target!</span></B>")
		return
	if(!beacon)
		to_chat(stand,"<span class='danger'><B>You need a beacon placed to warp things!</span></B>")
		return
	if(!stand.Adjacent(A))
		to_chat(stand,"<span class='danger'><B>You must be adjacent to your target!</span></B>")
		return
	if(A.anchored)
		to_chat(stand,"<span class='danger'><B>Your target cannot be anchored!</span></B>")
		return

	var/turf/T = get_turf(A)
	if(beacon.z != T.z)
		to_chat(stand,"<span class='danger'><B>The beacon is too far away to warp to!</span></B>")
		return

	to_chat(stand,"<span class='danger'><B>You begin to warp [A].</span></B>")
	A.visible_message("<span class='danger'>[A] starts to glow faintly!</span>", \
	"<span class='userdanger'>You start to glow faintly, and you feel strangely weightless!</span>")
	stand.do_attack_animation(A, null, 1)

	if(!do_mob(stand, A, 60)) //now start the channel
		to_chat(stand,"<span class='danger'><B>You need to hold still!</span></B>")
		return

	new /obj/effect/overlay/temp/sutando/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message("<span class='danger'>[A] disappears in a flash of light!</span>", \
	"<span class='userdanger'>Your vision is obscured by a flash of light!</span>")
	do_teleport(A, beacon, 0)
	new /obj/effect/overlay/temp/sutando/phase(get_turf(A))


/obj/structure/recieving_pad
	name = "bluespace recieving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A recieving zone for bluespace teleportations."
	icon_state = "light_on-w"
	light_range = 1
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/recieving_pad/New(loc, mob/living/simple_animal/hostile/sutando/G)
	. = ..()
	if(G.namedatum)
		add_atom_colour(G.namedatum.colour, FIXED_COLOUR_PRIORITY)

/obj/structure/recieving_pad/proc/disappear()
	visible_message("[src] vanishes!")
	qdel(src)
