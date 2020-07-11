//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser/cult
	clothes_req = TRUE
	charge_max = 2500

/obj/effect/proc_holder/spell/aoe_turf/area_conversion
	name = "Area Conversion"
	desc = "This spell instantly converts a small area around you."

	school = "transmutation"
	charge_max = 50
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = 2
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "areaconvert"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/area_conversion/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/items/welder.ogg', 75, TRUE)
	for(var/turf/T in targets)
		T.narsie_act(FALSE, TRUE, 100 - (get_dist(user, T) * 25))


/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor."

	school = "conjuration"
	charge_max = 20
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/open/floor/engine/cult)
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"


/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall."

	school = "conjuration"
	charge_max = 100
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = 0
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "lesserconstruct"
	action_background_icon_state = "bg_cult"

	summon_type = list(/turf/closed/wall/mineral/cult/artificer) //we don't want artificer-based runed metal farms


/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall."

	school = "conjuration"
	charge_max = 300
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/turf/closed/wall/r_wall)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar'Sie's realm, summoning one of the legendary fragments across time and space."

	school = "conjuration"
	charge_max = 2400
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = 0
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_demon"

	summon_type = list(/obj/item/soulstone)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/cult
	clothes_req = TRUE
	charge_max = 3600

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/noncult
	summon_type = list(/obj/item/soulstone/anybody)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/noncult/purified
	summon_type = list(/obj/item/soulstone/anybody/purified)

/obj/effect/proc_holder/spell/targeted/forcewall/cult
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire."
	school = "transmutation"
	charge_max = 400
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	wall_type = /obj/effect/forcefield/cult
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_demon"



/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls."

	school = "transmutation"
	charge_max = 250
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = TRUE
	jaunt_duration = 50 //in deciseconds
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_demon"
	jaunt_in_time = 6
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/jaunt_steam(mobloc)
	return

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/angelic
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/wraith/angelic
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/wraith/out/angelic

/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 400
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	max_targets = 6
	action_icon_state = "magicm"
	action_background_icon_state = "bg_demon"
	proj_type = /obj/projectile/magic/spell/magic_missile/lesser

/obj/projectile/magic/spell/magic_missile/lesser
	color = "red" //Looks more culty this way
	range = 10

/obj/effect/proc_holder/spell/targeted/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."

	school = "conjuration"
	charge_max = 200
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = TRUE
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 3
	smoke_amt = 4
	action_icon_state = "smoke"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/pointed/abyssal_gaze
	name = "Abyssal Gaze"
	desc = "This spell instills a deep terror in your target, temporarily chilling and blinding it."
	charge_max = 750
	range = 5
	stat_allowed = FALSE
	school = "evocation"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_background_icon_state = "bg_demon"
	action_icon_state = "abyssal_gaze"
	active_msg = "You prepare to instill a deep terror in a target..."

/obj/effect/proc_holder/spell/pointed/abyssal_gaze/cast(list/targets, mob/user)
	if(!LAZYLEN(targets))
		to_chat(user, "<span class='warning'>No target found in range!</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/carbon/target = targets[1]
	if(target.anti_magic_check(TRUE, TRUE))
		to_chat(user, "<span class='warning'>The spell had no effect!</span>")
		to_chat(target, "<span class='warning'>You feel a freezing darkness closing in on you, but it rapidly dissipates.</span>")
		return FALSE

	to_chat(target, "<span class='userdanger'>A freezing darkness surrounds you...</span>")
	target.playsound_local(get_turf(target), 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	user.playsound_local(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	target.become_blind(ABYSSAL_GAZE_BLIND)
	addtimer(CALLBACK(src, .proc/cure_blindness, target), 40)
	target.adjust_bodytemperature(-200)

/**
  * cure_blidness: Cures Abyssal Gaze blindness from the target
  *
  * Arguments:
  * * target The mob that is being cured of the blindness.
  */
/obj/effect/proc_holder/spell/pointed/abyssal_gaze/proc/cure_blindness(mob/target)
	if(isliving(target))
		var/mob/living/L = target
		L.cure_blind(ABYSSAL_GAZE_BLIND)

/obj/effect/proc_holder/spell/pointed/abyssal_gaze/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!iscarbon(target))
		if(!silent)
			to_chat(user, "<span class='warning'>You can only target carbon based lifeforms!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/pointed/dominate
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature to the will of Nar'Sie, allying it only to her direct followers."
	charge_max = 600
	range = 7
	stat_allowed = FALSE
	school = "evocation"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_background_icon_state = "bg_demon"
	action_icon_state = "dominate"
	active_msg = "You prepare to dominate the mind of a target..."

/obj/effect/proc_holder/spell/pointed/dominate/cast(list/targets, mob/user)
	if(!LAZYLEN(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		return FALSE
	if(!can_target(targets[1], user))
		return FALSE

	var/mob/living/simple_animal/S = targets[1]
	S.add_atom_colour("#990000", FIXED_COLOUR_PRIORITY)
	S.faction = list("cult")
	playsound(get_turf(S), 'sound/effects/ghost.ogg', 100, TRUE)
	new /obj/effect/temp_visual/cult/sac(get_turf(S))

/obj/effect/proc_holder/spell/pointed/dominate/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!isanimal(target))
		if(!silent)
			to_chat(user, "<span class='warning'>Target is not a lesser creature!</span>")
		return FALSE

	var/mob/living/simple_animal/S = target
	if(S.mind)
		if(!silent)
			to_chat(user, "<span class='warning'>[S] is too intelligent to dominate!</span>")
		return FALSE
	if(S.stat)
		if(!silent)
			to_chat(user, "<span class='warning'>[S] is dead!</span>")
		return FALSE
	if(S.sentience_type != SENTIENCE_ORGANIC)
		if(!silent)
			to_chat(user, "<span class='warning'>[S] cannot be dominated!</span>")
		return FALSE
	if("cult" in S.faction)
		if(!silent)
			to_chat(user, "<span class='warning'>[S] is already serving Nar'Sie!</span>")
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/golem
	charge_max = 800
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out

/obj/effect/proc_holder/spell/targeted/projectile/dumbfire/juggernaut
	name = "Gauntlet Echo"
	desc = "Channels energy into your gauntlet - firing its essence forward in a slow moving, yet devastating, attack."
	proj_type = /obj/projectile/magic/spell/juggernaut
	charge_max = 350
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "cultfist"
	action_background_icon_state = "bg_demon"
	sound = 'sound/weapons/resonator_blast.ogg'

/obj/projectile/magic/spell/juggernaut
	name = "Gauntlet Echo"
	icon_state = "cultfist"
	alpha = 180
	damage = 30
	damage_type = BRUTE
	knockdown = 50
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	check_holy = TRUE
	ignored_factions = list("cult")
	range = 15
	speed = 7

/obj/projectile/magic/spell/juggernaut/on_hit(atom/target, blocked)
	. = ..()
	var/turf/T = get_turf(src)
	playsound(T, 'sound/weapons/resonator_blast.ogg', 100, FALSE)
	new /obj/effect/temp_visual/cult/sac(T)
	for(var/obj/O in range(src,1))
		if(O.density && !istype(O, /obj/structure/destructible/cult))
			O.take_damage(90, BRUTE, "melee", 0)
			new /obj/effect/temp_visual/cult/turf/floor(get_turf(O))
