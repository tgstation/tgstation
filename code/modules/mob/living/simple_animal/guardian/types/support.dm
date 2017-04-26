//healsluts

/datum/guardian_abilities/heal
	id = "heal"
	name = "Mending Properties"
	value = 5
	var/obj/structure/recieving_pad/beacon
	var/beacon_cooldown = 0

/datum/guardian_abilities/heal/Destroy()
	QDEL_NULL(B)
	return ..()

/datum/guardian_abilities/heal/proc/plant_beacon()
	if(beacon_cooldown >= world.time)
		to_chat(guardian,"<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>")
		return

	var/turf/beacon_loc = get_turf(guardian)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, guardian)

	to_chat(guardian,"<span class='danger'><B>Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click.</span></B>")

	beacon_cooldown = world.time + 3000


/datum/action/innate/beacon
	background_icon_state = "bg_alien"
	name = "Plant Beacon"
	button_icon_state = "set_drop"

/datum/action/innate/beacon/Activate()
	var/mob/living/simple_animal/hostile/guardian/A = owner
	for(var/datum/guardian_abilities/heal/I in A.current_abilities)
		I.plant_beacon()

/datum/guardian_abilities/heal
	only_on_return_true = FALSE

/datum/guardian_abilities/heal/handle_stats()
	. = ..()
	guardian.a_intent = INTENT_HARM
	guardian.friendly = "heals"
	guardian.speed -= 0.5
	for(var/i in guardian.damage_coeff)
		guardian.damage_coeff[i] -= 0.15
	guardian.melee_damage_lower += 7
	guardian.melee_damage_upper += 7
	guardian.toggle_button_type = /obj/screen/guardian/ToggleMode
	B.Grant(guardian)

	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(guardian)

/datum/guardian_abilities/heal/ability_act()
	if(toggle && iscarbon(guardian.target))
		var/mob/living/carbon/C = guardian.target
		C.adjustBruteLoss(-5)
		C.adjustFireLoss(-5)
		C.adjustOxyLoss(-5)
		C.adjustToxLoss(-5)
		var/obj/effect/overlay/temp/heal/H = new /obj/effect/overlay/temp/heal(get_turf(C))
		if(guardian.namedatum)
			H.color = guardian.namedatum.colour
		if(C == user)
			guardian.update_health_hud()
			guardian.med_hud_set_health()
			guardian.med_hud_set_status()

/datum/guardian_abilities/heal/handle_mode()
	if(guardian.loc == user)
		if(toggle)
			guardian.a_intent = initial(guardian.a_intent)
			guardian.speed = initial(guardian.speed)
			guardian.damage_coeff = initial_coeff
			guardian.melee_damage_lower = initial(guardian.melee_damage_lower)
			guardian.melee_damage_upper = initial(guardian.melee_damage_upper)
			to_chat(guardian,"<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			guardian.a_intent = INTENT_HELP
			guardian.speed = 1
			guardian.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			guardian.melee_damage_lower = 0
			guardian.melee_damage_upper = 0
			to_chat(guardian,"<span class='danger'><B>You switch to healing mode.</span></B>")
			toggle = TRUE
	else
		to_chat(guardian,"<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")

/datum/guardian_abilities/heal/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(guardian.loc == user)
		to_chat(guardian,"<span class='danger'><B>You must be manifested to warp a target!</span></B>")
		return
	if(!beacon)
		to_chat(guardian,"<span class='danger'><B>You need a beacon placed to warp things!</span></B>")
		return
	if(!guardian.Adjacent(A))
		to_chat(guardian,"<span class='danger'><B>You must be adjacent to your target!</span></B>")
		return
	if(A.anchored)
		to_chat(guardian,"<span class='danger'><B>Your target cannot be anchored!</span></B>")
		return

	var/turf/T = get_turf(A)
	if(beacon.z != T.z)
		to_chat(guardian,"<span class='danger'><B>The beacon is too far away to warp to!</span></B>")
		return

	to_chat(guardian,"<span class='danger'><B>You begin to warp [A].</span></B>")
	A.visible_message("<span class='danger'>[A] starts to glow faintly!</span>", \
	"<span class='userdanger'>You start to glow faintly, and you feel strangely weightless!</span>")
	guardian.do_attack_animation(A, null, 1)

	if(!do_mob(guardian, A, 60)) //now start the channel
		to_chat(guardian,"<span class='danger'><B>You need to hold still!</span></B>")
		return

	new /obj/effect/overlay/temp/guardian/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message("<span class='danger'>[A] disappears in a flash of light!</span>", \
	"<span class='userdanger'>Your vision is obscured by a flash of light!</span>")
	do_teleport(A, beacon, 0)
	new /obj/effect/overlay/temp/guardian/phase(get_turf(A))


/obj/structure/recieving_pad
	name = "bluespace recieving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A recieving zone for bluespace teleportations."
	icon_state = "light_on-w"
	light_range = 1
	density = FALSE
	anchored = TRUE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/recieving_pad/New(loc, mob/living/simple_animal/hostile/guardian/G)
	. = ..()
	if(G.namedatum)
		add_atom_colour(G.namedatum.colour, FIXED_COLOUR_PRIORITY)

/obj/structure/recieving_pad/proc/disappear()
	visible_message("[src] vanishes!")
	qdel(src)
