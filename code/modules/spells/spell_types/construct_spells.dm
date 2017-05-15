//////////////////////////////Construct Spells/////////////////////////

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser
	charge_max = 1800
	action_icon_state = "artificer"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser/cult
	cult_req = 1
	charge_max = 2500


/obj/effect/proc_holder/spell/aoe_turf/area_conversion
	name = "Area Conversion"
	desc = "This spell instantly converts a small area around you."

	school = "transmutation"
	charge_max = 50
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 2
	action_icon_state = "areaconvert"
	action_background_icon_state = "bg_cult"

/obj/effect/proc_holder/spell/aoe_turf/area_conversion/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/items/welder.ogg', 75, 1)
	for(var/turf/T in targets)
		T.narsie_act(FALSE, TRUE, 100 - (get_dist(user, T) * 25))


/obj/effect/proc_holder/spell/aoe_turf/conjure/floor
	name = "Summon Cult Floor"
	desc = "This spell constructs a cult floor"

	school = "conjuration"
	charge_max = 20
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/turf/open/floor/engine/cult)
	action_icon_state = "floorconstruct"
	action_background_icon_state = "bg_cult"


/obj/effect/proc_holder/spell/aoe_turf/conjure/wall
	name = "Summon Cult Wall"
	desc = "This spell constructs a cult wall"

	school = "conjuration"
	charge_max = 100
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	action_icon_state = "lesserconstruct"
	action_background_icon_state = "bg_cult"

	summon_type = list(/turf/closed/wall/mineral/cult/artificer) //we don't want artificer-based runed metal farms


/obj/effect/proc_holder/spell/aoe_turf/conjure/wall/reinforced
	name = "Greater Construction"
	desc = "This spell constructs a reinforced metal wall"

	school = "conjuration"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/turf/closed/wall/r_wall)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar-Sie's realm, summoning one of the legendary fragments across time and space"

	school = "conjuration"
	charge_max = 3000
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	action_icon_state = "summonsoulstone"
	action_background_icon_state = "bg_demon"

	summon_type = list(/obj/item/device/soulstone)

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/cult
	cult_req = 1
	charge_max = 4000

/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone/noncult
	summon_type = list(/obj/item/device/soulstone/anybody)



/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall
	name = "Shield"
	desc = "This spell creates a temporary forcefield to shield yourself and allies from incoming fire"

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0
	summon_type = list(/obj/effect/forcefield/cult)
	summon_lifespan = 200
	action_icon_state = "cultforcewall"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift
	name = "Phase Shift"
	desc = "This spell allows you to pass through walls"

	school = "transmutation"
	charge_max = 250
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	jaunt_duration = 50 //in deciseconds
	action_icon_state = "phaseshift"
	action_background_icon_state = "bg_demon"
	jaunt_in_time = 12
	jaunt_in_type = /obj/effect/overlay/temp/dir_setting/wraith
	jaunt_out_type = /obj/effect/overlay/temp/dir_setting/wraith/out

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/jaunt_steam(mobloc)
	return

/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser
	name = "Lesser Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 400
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	proj_lifespan = 10
	max_targets = 6
	action_icon_state = "magicm"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/targeted/smoke/disable
	name = "Paralysing Smoke"
	desc = "This spell spawns a cloud of paralysing smoke."

	school = "conjuration"
	charge_max = 200
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 3
	smoke_amt = 4
	action_icon_state = "parasmoke"
	action_background_icon_state = "bg_cult"


/obj/effect/proc_holder/spell/targeted/abyssal_gaze
	name = "Abyssal Gaze"
	desc = "This spell instills a deep terror in your target, temporarily chilling and blinding it."

	charge_max = 750
	range = 5
	include_user = FALSE
	selection_type = "range"
	stat_allowed = FALSE

	school = "evocation"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	action_background_icon_state = "bg_demon"
	action_icon_state = "abyssal_gaze"

/obj/effect/proc_holder/spell/targeted/abyssal_gaze/cast(list/targets, mob/user = usr)
	if(!LAZYLEN(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		revert_cast()
		return

	var/mob/living/carbon/target = targets[1]

	if(!(target in oview(range)))
		to_chat(user, "<span class='notice'>[target] is too far away!</span>")
		revert_cast()
		return

	to_chat(target, "<span class='userdanger'>A freezing darkness surrounds you...</span>")
	target.playsound_local(get_turf(target), 'sound/hallucinations/i_see_you1.ogg', 50, 1)
	user.playsound_local(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	target.adjust_blindness(5)
	addtimer(CALLBACK(src, .proc/cure_blindness, target), 40)
	target.bodytemperature -= 200

/obj/effect/proc_holder/spell/targeted/abyssal_gaze/proc/cure_blindness(mob/target)
	target.adjust_blindness(-5)

/obj/effect/proc_holder/spell/targeted/dominate
	name = "Dominate"
	desc = "This spell dominates the mind of a lesser creature, causing it to see you as an ally."

	charge_max = 600
	range = 7
	include_user = FALSE
	selection_type = "range"
	stat_allowed = FALSE

	school = "evocation"
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	action_background_icon_state = "bg_demon"
	action_icon_state = "dominate"

/obj/effect/proc_holder/spell/targeted/dominate/cast(list/targets, mob/user = usr)
	if(!LAZYLEN(targets))
		to_chat(user, "<span class='notice'>No target found in range.</span>")
		revert_cast()
		return

	var/mob/living/simple_animal/S = targets[1]

	if(S.ckey)
		to_chat(user, "<span class='warning'>[S] is too intelligent to dominate!</span>")
		revert_cast()
		return

	if(S.stat)
		to_chat(user, "<span class='warning'>[S] is dead!</span>")
		revert_cast()
		return

	if(S.sentience_type != SENTIENCE_ORGANIC)
		to_chat(user, "<span class='warning'>[S] cannot be dominated!</span>")
		revert_cast()
		return

	if(!(S in oview(range)))
		to_chat(user, "<span class='notice'>[S] is too far away!</span>")
		revert_cast()
		return

	S.add_atom_colour("#990000", FIXED_COLOUR_PRIORITY)
	S.faction = list("cult")
	playsound(get_turf(S), 'sound/effects/ghost.ogg', 100, 1)
	new /obj/effect/overlay/temp/cult/sac(get_turf(S))

/obj/effect/proc_holder/spell/targeted/dominate/can_target(mob/living/target)
	if(!isanimal(target) || target.stat)
		return FALSE
	if("cult" in target.faction)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/golem
	charge_max = 800
	jaunt_in_type = /obj/effect/overlay/temp/dir_setting/cult/phase
	jaunt_out_type = /obj/effect/overlay/temp/dir_setting/cult/phase/out