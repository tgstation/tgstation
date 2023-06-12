//Support
/mob/living/simple_animal/hostile/guardian/support
	speed = 0
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = span_holoparasite("As a <b>support</b> type, you may right-click to heal targets. In addition, alt-clicking on an adjacent object or mob will warp them to your bluespace beacon after a short delay.")
	magic_fluff_string = span_holoparasite("..And draw the Chief Medical Officer, a potent force of life... and death.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught a support carp. It's a kleptocarp!")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Support modules active. Holoparasite swarm online.")
	miner_fluff_string = span_holoparasite("You encounter... Bluespace, the master of support.")
	creator_name = "Support"
	creator_desc = "Does medium damage, but can heal its targets and create beacons to teleport people and things to."
	creator_icon = "support"
	/// Is it in healing mode?
	var/toggle = FALSE
	/// How much we heal per hit.
	var/healing_amount = 5
	/// Our teleportation beacon.
	var/obj/structure/receiving_pad/beacon
	/// Time it takes to teleport.
	var/teleporting_time = 6 SECONDS
	/// Time between creating beacons.
	var/beacon_cooldown_time = 5 MINUTES
	/// Cooldown between creating beacons.
	COOLDOWN_DECLARE(beacon_cooldown)

/mob/living/simple_animal/hostile/guardian/support/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.show_to(src)

/mob/living/simple_animal/hostile/guardian/support/get_status_tab_items()
	. = ..()
	if(!COOLDOWN_FINISHED(src, beacon_cooldown))
		. += "Beacon Cooldown Remaining: [DisplayTimeText(COOLDOWN_TIMELEFT(src, beacon_cooldown))]"

/mob/living/simple_animal/hostile/guardian/support/UnarmedAttack(atom/attack_target, proximity_flag, list/modifiers)
	if(LAZYACCESS(modifiers, RIGHT_CLICK) && proximity_flag && isliving(attack_target))
		heal_target(attack_target)
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/support/proc/heal_target(mob/living/target)
	do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	target.visible_message(span_notice("[src] heals [target]!"),\
		span_userdanger("[src] heals you!"), null, COMBAT_MESSAGE_RANGE, src)
	to_chat(src, span_notice("You heal [target]!"))
	playsound(target, attack_sound, 50, TRUE, TRUE, frequency = -1) //play punch in REVERSE
	target.adjustBruteLoss(-healing_amount)
	target.adjustFireLoss(-healing_amount)
	target.adjustOxyLoss(-healing_amount)
	target.adjustToxLoss(-healing_amount)
	var/obj/effect/temp_visual/heal/heal_effect = new /obj/effect/temp_visual/heal(get_turf(target))
	heal_effect.color = guardian_color

/mob/living/simple_animal/hostile/guardian/support/verb/Beacon()
	set name = "Place Bluespace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work at extreme distances."

	if(!COOLDOWN_FINISHED(src, beacon_cooldown))
		to_chat(src, span_bolddanger("Your power is on cooldown. You must wait five minutes between placing beacons."))
		return

	var/turf/beacon_loc = get_turf(src.loc)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, src)

	to_chat(src, span_bolddanger("Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click."))

	COOLDOWN_START(src, beacon_cooldown, beacon_cooldown_time)

/obj/structure/receiving_pad
	name = "bluespace receiving pad"
	icon = 'icons/turf/floors.dmi'
	desc = "A receiving zone for bluespace teleportations."
	icon_state = "light_on-8"
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	density = FALSE
	anchored = TRUE
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER

/obj/structure/receiving_pad/New(loc, mob/living/simple_animal/hostile/guardian/spawning_guardian)
	. = ..()
	add_atom_colour(spawning_guardian?.guardian_color, FIXED_COLOUR_PRIORITY)

/obj/structure/receiving_pad/proc/disappear()
	visible_message(span_notice("[src] vanishes!"))
	qdel(src)

/mob/living/simple_animal/hostile/guardian/support/AltClickOn(atom/movable/target)
	teleport_to_beacon(target)

/mob/living/simple_animal/hostile/guardian/support/proc/teleport_to_beacon(atom/movable/teleport_target)
	if(!istype(teleport_target))
		return
	if(!beacon)
		to_chat(src, span_bolddanger("You need a beacon placed to warp things!"))
		return
	if(!is_deployed())
		to_chat(src, span_bolddanger("You must be manifested to warp a target!"))
		return
	if(!Adjacent(teleport_target))
		to_chat(src, span_bolddanger("You must be adjacent to your target!"))
		return
	if(teleport_target.anchored)
		to_chat(src, span_bolddanger("Your target is anchored!"))
		return
	var/turf/target_turf = get_turf(teleport_target)
	if(beacon.z != target_turf.z)
		to_chat(src, span_bolddanger("The beacon is too far away to warp to!"))
		return
	to_chat(src, span_bolddanger("You begin to warp [teleport_target]."))
	teleport_target.visible_message(span_danger("[teleport_target] starts to glow faintly!"), \
	span_userdanger("You start to faintly glow, and you feel strangely weightless!"))
	do_attack_animation(teleport_target)
	playsound(teleport_target, attack_sound, 50, TRUE, TRUE, frequency = -1) //play punch in REVERSE
	if(!do_after(src, teleporting_time, teleport_target)) //now start the channel
		to_chat(src, span_bolddanger("You need to hold still!"))
		return
	new /obj/effect/temp_visual/guardian/phase/out(target_turf)
	if(isliving(teleport_target))
		var/mob/living/living_target = teleport_target
		living_target.flash_act()
	teleport_target.visible_message(
		span_danger("[teleport_target] disappears in a flash of light!"), \
		span_userdanger("Your vision is obscured by a flash of light!"), \
	)
	do_teleport(teleport_target, beacon, 0, channel = TELEPORT_CHANNEL_BLUESPACE)
	new /obj/effect/temp_visual/guardian/phase(get_turf(teleport_target))
