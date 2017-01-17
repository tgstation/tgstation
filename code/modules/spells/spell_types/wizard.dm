/obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	name = "Magic Missile"
	desc = "This spell fires several, slow moving, magic projectiles at nearby targets."

	school = "evocation"
	charge_max = 200
	clothes_req = 1
	invocation = "FORTI GY AMA"
	invocation_type = "shout"
	range = 7
	cooldown_min = 60 //35 deciseconds reduction per rank

	max_targets = 0

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

	action_icon_state = "magicm"
	sound = "sound/magic/MAGIC_MISSILE.ogg"

/obj/effect/proc_holder/spell/targeted/inflict_handler/magic_missile
	amt_weakened = 3
	sound = "sound/magic/MM_Hit.ogg"

/obj/effect/proc_holder/spell/targeted/genetic/mutate
	name = "Mutate"
	desc = "This spell causes you to turn into a hulk and gain laser vision for a short while."

	school = "transmutation"
	charge_max = 400
	clothes_req = 1
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	range = -1
	include_user = 1

	mutations = list(LASEREYES, HULK)
	duration = 300
	cooldown_min = 300 //25 deciseconds reduction per rank

	action_icon_state = "mutate"
	sound = "sound/magic/Mutate.ogg"


/obj/effect/proc_holder/spell/targeted/smoke
	name = "Smoke"
	desc = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."

	school = "conjuration"
	charge_max = 120
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	cooldown_min = 20 //25 deciseconds reduction per rank

	smoke_spread = 2
	smoke_amt = 4

	action_icon_state = "smoke"

/obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	charge_max = 400
	clothes_req = 1
	invocation = "NEC CANTIO"
	invocation_type = "shout"
	range = -1
	include_user = 1
	cooldown_min = 200 //50 deciseconds reduction per rank

	emp_heavy = 6
	emp_light = 10
	sound = "sound/magic/Disable_Tech.ogg"

/obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	name = "Blink"
	desc = "This spell randomly teleports you a short distance."

	school = "abjuration"
	charge_max = 20
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	range = -1
	include_user = 1
	cooldown_min = 5 //4 deciseconds reduction per rank


	smoke_spread = 1
	smoke_amt = 0

	inner_tele_radius = 0
	outer_tele_radius = 6

	action_icon_state = "blink"
	sound1="sound/magic/blink.ogg"
	sound2="sound/magic/blink.ogg"

/obj/effect/proc_holder/spell/targeted/turf_teleport/blink/cult
	name = "quickstep"

	charge_max = 100
	clothes_req = 0
	cult_req = 1

/obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	name = "Teleport"
	desc = "This spell teleports you to a type of area of your selection."

	school = "abjuration"
	charge_max = 600
	clothes_req = 1
	invocation = "SCYAR NILA"
	invocation_type = "shout"
	range = -1
	include_user = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

	smoke_spread = 1
	smoke_amt = 2
	sound1="sound/magic/Teleport_diss.ogg"
	sound2="sound/magic/Teleport_app.ogg"

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop
	name = "Stop Time"
	desc = "This spell stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	charge_max = 500
	clothes_req = 1
	invocation = "TOKI WO TOMARE"
	invocation_type = "shout"
	range = 0
	cooldown_min = 100
	summon_amt = 1
	action_icon_state = "time"

	summon_type = list(/obj/effect/timestop/wizard)

/obj/effect/proc_holder/spell/aoe_turf/conjure/carp
	name = "Summon Carp"
	desc = "This spell conjures a simple carp."

	school = "conjuration"
	charge_max = 1200
	clothes_req = 1
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"
	range = 1

	summon_type = list(/mob/living/simple_animal/hostile/carp)
	cast_sound = "sound/magic/Summon_Karp.ogg"


/obj/effect/proc_holder/spell/aoe_turf/conjure/construct
	name = "Artificer"
	desc = "This spell conjures a construct which may be controlled by Shades"

	school = "conjuration"
	charge_max = 600
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = 0

	summon_type = list(/obj/structure/constructshell)

	action_icon_state = "artificer"
	cast_sound = "sound/magic/SummonItems_generic.ogg"


/obj/effect/proc_holder/spell/aoe_turf/conjure/creature
	name = "Summon Creature Swarm"
	desc = "This spell tears the fabric of reality, allowing horrific daemons to spill forth"

	school = "conjuration"
	charge_max = 1200
	clothes_req = 0
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10
	range = 3

	summon_type = list(/mob/living/simple_animal/hostile/creature)
	cast_sound = "sound/magic/SummonItems_generic.ogg"

/obj/effect/proc_holder/spell/targeted/trigger/blind
	name = "Blind"
	desc = "This spell temporarily blinds a single person and does not require wizard garb."

	school = "transmutation"
	charge_max = 300
	clothes_req = 0
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Your eyes cry out in pain!</span>"
	cooldown_min = 50 //12 deciseconds reduction per rank

	starting_spells = list("/obj/effect/proc_holder/spell/targeted/inflict_handler/blind","/obj/effect/proc_holder/spell/targeted/genetic/blind")

	action_icon_state = "blind"

/obj/effect/proc_holder/spell/aoe_turf/conjure/creature/cult
	name = "Summon Creatures (DANGEROUS)"
	cult_req = 1
	charge_max = 5000
	summon_amt = 2



/obj/effect/proc_holder/spell/targeted/inflict_handler/blind
	amt_eye_blind = 10
	amt_eye_blurry = 20
	sound="sound/magic/Blind.ogg"

/obj/effect/proc_holder/spell/targeted/genetic/blind
	mutations = list(BLINDMUT)
	duration = 300
	sound="sound/magic/Blind.ogg"

/obj/effect/proc_holder/spell/fireball
	name = "Fireball"
	desc = "This spell fires a fireball at a target and does not require wizard garb."

	school = "evocation"
	charge_max = 60
	clothes_req = 0
	invocation = "ONI SOMA"
	invocation_type = "shout"
	range = 20
	cooldown_min = 20 //10 deciseconds reduction per rank
	var/fireball_type = /obj/item/projectile/magic/fireball
	action_icon_state = "fireball0"
	sound = "sound/magic/Fireball.ogg"

	active = FALSE


/obj/effect/proc_holder/spell/fireball/Click()
	var/mob/living/user = usr
	if(!istype(user))
		return

	var/msg

	if(!can_cast(user))
		msg = "<span class='warning'>You can no longer cast Fireball.</span>"
		remove_ranged_ability(msg)
		return

	if(active)
		msg = "<span class='notice'>You extinguish your fireball...for now.</span>"
		remove_ranged_ability(msg)
	else
		msg = "<span class='notice'>Your prepare to cast your fireball spell! <B>Left-click to cast at a target!</B></span>"
		add_ranged_ability(user, msg, TRUE)

/obj/effect/proc_holder/spell/fireball/update_icon()
	if(!action)
		return
	action.button_icon_state = "fireball[active]"
	action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/fireball/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return FALSE

	if(!cast_check(0, ranged_ability_user))
		remove_ranged_ability()
		return FALSE

	var/list/targets = list(target)
	perform(targets,user = ranged_ability_user)

	return TRUE

/obj/effect/proc_holder/spell/fireball/cast(list/targets, mob/living/user)
	var/target = targets[1] //There is only ever one target for fireball
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return 0

	var/obj/item/projectile/magic/fireball/FB = new fireball_type(user.loc)
	FB.current = get_turf(user)
	FB.preparePixelProjectile(target, get_turf(target), user)
	FB.fire()
	user.newtonian_move(get_dir(U, T))
	remove_ranged_ability() //Auto-disable the ability once successfully performed
	return 1

/obj/effect/proc_holder/spell/aoe_turf/repulse
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	charge_max = 400
	clothes_req = 1
	invocation = "GITTAH WEIGH"
	invocation_type = "shout"
	range = 5
	cooldown_min = 150
	selection_type = "view"
	sound = 'sound/magic/Repulse.ogg'
	var/maxthrow = 5
	var/sparkle_path = /obj/effect/overlay/temp/gravpush

	action_icon_state = "repulse"

/obj/effect/proc_holder/spell/aoe_turf/repulse/cast(list/targets,mob/user = usr, var/stun_amt = 2)
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	playMagSound()
	for(var/turf/T in targets) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == user || AM.anchored)
			continue

		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		if(distfromcaster == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(5)
				M.adjustBruteLoss(5)
				M << "<span class='userdanger'>You're slammed into the floor by [user]!</span>"
		else
			PoolOrNew(sparkle_path, list(get_turf(AM), get_dir(user, AM))) //created sparkles will disappear on their own
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(stun_amt)
				M << "<span class='userdanger'>You're thrown back by [user]!</span>"
			AM.throw_at(throwtarget, ((Clamp((maxthrow - (Clamp(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1,user)//So stuff gets tossed around at the same time.

/obj/effect/proc_holder/spell/aoe_turf/repulse/xeno //i fixed conflicts only to find out that this is in the WIZARD file instead of the xeno file?!
	name = "Tail Sweep"
	desc = "Throw back attackers with a sweep of your tail."
	sound = 'sound/magic/Tail_swing.ogg'
	charge_max = 150
	clothes_req = 0
	range = 2
	cooldown_min = 150
	invocation_type = "none"
	sparkle_path = /obj/effect/overlay/temp/dir_setting/tailsweep
	action_icon_state = "tailsweep"
	action_background_icon_state = "bg_alien"

/obj/effect/proc_holder/spell/aoe_turf/repulse/xeno/cast(list/targets,mob/user = usr)
	if(istype(user, /mob/living/carbon))
		var/mob/living/carbon/C = user
		playsound(C.loc, 'sound/voice/hiss5.ogg', 80, 1, 1)
		C.spin(6,1)
	..(targets, user, 3)

/obj/effect/proc_holder/spell/targeted/sacred_flame
	name = "Sacred Flame"
	desc = "Makes everyone around you more flammable, and lights yourself on fire."
	charge_max = 60
	clothes_req = 0
	invocation = "FI'RAN DADISKO"
	invocation_type = "shout"
	max_targets = 0
	range = 6
	include_user = 1
	selection_type = "view"
	action_icon_state = "sacredflame"
	sound = "sound/magic/Fireball.ogg"

/obj/effect/proc_holder/spell/targeted/sacred_flame/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		L.adjust_fire_stacks(20)
	if(isliving(user))
		var/mob/living/U = user
		U.IgniteMob()

/obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket
	name = "Thrown Lightning"
	desc = "Forged from eldrich energies, a packet of pure power, known as a spell packet will appear in your hand, that when thrown will stun the target."
	clothes_req = 1
	item_type = /obj/item/spellpacket/lightningbolt
	charge_max = 10

/obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket/cast(list/targets, mob/user = usr)
	..()
	for(var/mob/living/carbon/C in targets)
		C.throw_mode_on()

/obj/item/spellpacket/lightningbolt
	name = "\improper Lightning bolt Spell Packet"
	desc = "Some birdseed wrapped in cloth that somehow crackles with electricity."
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY

/obj/item/spellpacket/lightningbolt/throw_impact(atom/hit_atom)
	if(!..())
		if(isliving(hit_atom))
			var/mob/living/M = hit_atom
			M.electrocute_act(80, src, illusion = 1)
		qdel(src)

/obj/item/spellpacket/lightningbolt/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	. = ..()
	if(ishuman(thrower))
		var/mob/living/carbon/human/H = thrower
		H.say("LIGHTNINGBOLT!!")
