//SABAKU NO WA ORE stand DA

/datum/sutando_abilities
	var/name = "Ability Name"
	var/toggle = FALSE
	var/mob/living/simple_animal/hostile/sutando/stand = null
	var/mob/living/user = null
	var/cooldown = 0
	var/value = 0 //VALUE SYSTEM:
	var/battlecry = "ORA"
	var/list/initial_coeff
	//basically, the total value of abilities a stand can have is 10, and more powerful abilities have more value, this means that
	//randomized-ability stands can only have a set number of abilities both in quantity and quality, maintaining some form of balance.
	//CRUCIAL: only randomized stands are to use the value system.

/datum/sutando_abilities/proc/handle_stats()
	LAZYINITLIST(initial_coeff)
	initial_coeff = stand.damage_coeff

/datum/sutando_abilities/proc/life_act()


/datum/sutando_abilities/proc/ability_act()


/datum/sutando_abilities/proc/alt_ability_act() //ability to do on alt_click


/datum/sutando_abilities/proc/handle_mode()


/datum/sutando_abilities/proc/bump_reaction()


/datum/sutando_abilities/proc/ranged_attack()


/datum/sutando_abilities/proc/impact_act()


/datum/sutando_abilities/proc/recall_act()


/datum/sutando_abilities/proc/adjusthealth_act()


/datum/sutando_abilities/proc/light_switch()


/datum/sutando_abilities/proc/manifest_act()


/datum/sutando_abilities/proc/openfire_act()


/datum/sutando_abilities/proc/move_act()


/datum/sutando_abilities/proc/snapback_act()


/datum/sutando_abilities/proc/boom_act()

//ORA ORA ORA

/datum/sutando_abilities/punch
	name = "Close-Range Combat"
	value = 5


/datum/sutando_abilities/punch/handle_stats()
	. = ..()
	stand.melee_damage_lower += 10
	stand.melee_damage_upper += 10
	stand.obj_damage += 80
	stand.next_move_modifier -= 0.2 //attacks 20% faster
	stand.environment_smash = 2


/datum/sutando_abilities/punch/ability_act()
	if(isliving(stand.target))
		stand.attack_sound = pick('sound/magic/sutandopunch.ogg', 'sound/magic/sutandopunch1.ogg', 'sound/magic/sutandopunch2.ogg')
		stand.say("[battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry]!!")
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)
		playsound(stand.loc, stand.attack_sound, 50, 1, 1)

//killed queem u bad cat

/datum/sutando_abilities/bomb
	name = "Remote Explosives"
	var/bomb_cooldown = 0
	value = 6

/datum/sutando_abilities/bomb/handle_stats()
	. = ..()
	stand.melee_damage_lower += 7
	stand.melee_damage_upper += 7
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.2
	stand.range += 6

/datum/sutando_abilities/bomb/ability_act()
	if(prob(40))
		if(isliving(stand.target))
			var/mob/living/M = stand.target
			if(!M.anchored && M != user && !stand.hasmatchingsummoner(M))
				new /obj/effect/overlay/temp/sutando/phase/out(get_turf(M))
				do_teleport(M, M, 10)
				for(var/mob/living/L in range(1, M))
					if(stand.hasmatchingsummoner(L)) //if the user matches don't hurt them
						continue
					if(L != stand && L != user)
						L.apply_damage(15, BRUTE)
						stand.say("[battlecry]!!")
				new /obj/effect/overlay/temp/explosion(get_turf(M))


/datum/sutando_abilities/bomb/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(stand.loc == user)
		stand << "<span class='danger'><B>You must be manifested to create bombs!</span></B>"
		return
	if(isobj(A))
		if(bomb_cooldown <= world.time && !stand.stat)
			var/obj/sutando_bomb/B = new/obj/sutando_bomb(get_turf(A))
			stand << "<span class='danger'><B>Success! Bomb armed!</span></B>"
			stand.say("[battlecry]!!")
			bomb_cooldown = world.time + 200
			B.spawner = stand
			B.disguise(A)
		else
			stand << "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</span></B>"

//rore zone

/datum/sutando_abilities/ranged
	name = "Long-Range Ability"
	value = 4
	var/datum/action/innate/snare/plant/P = new
	var/datum/action/innate/snare/remove/R = new
	var/list/snares

/datum/sutando_abilities/ranged/Destroy()
	snares.Cut()
	QDEL_NULL(P)
	QDEL_NULL(R)
	QDEL_NULL(snares)
	return ..()

/datum/sutando_abilities/ranged/handle_stats()
	. = ..()
	LAZYINITLIST(snares)
	stand.has_mode = TRUE
	stand.melee_damage_lower += 5
	stand.melee_damage_upper += 5
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.05
	stand.projectiletype = /obj/item/projectile/sutando
	stand.ranged_cooldown_time = 1 //fast!
	stand.projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	stand.ranged = TRUE
	stand.range += 6
	stand.has_mode = TRUE

	stand.see_invisible = SEE_INVISIBLE_LIVING
	stand.see_in_dark += 4
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode
	P.Grant(stand)
	R.Grant(stand)



/datum/sutando_abilities/ranged/handle_mode()
	if(stand.loc == user)
		if(toggle)
			stand.ranged = initial(stand.ranged)
			stand.melee_damage_lower = initial(stand.melee_damage_lower)
			stand.melee_damage_upper = initial(stand.melee_damage_upper)
			stand.obj_damage = initial(stand.obj_damage)
			stand.environment_smash = initial(stand.environment_smash)
			stand.alpha = 255
			stand.range = initial(stand.range)
			stand.incorporeal_move = 0
			stand << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			stand.ranged = TRUE
			stand.melee_damage_lower = 0
			stand.melee_damage_upper = 0
			stand.obj_damage = 0
			stand.environment_smash = 0
			stand.alpha = 45
			stand.range = 255
			stand.incorporeal_move = 1
			stand << "<span class='danger'><B>You switch to scout mode.</span></B>"
			toggle = TRUE
	else
		stand << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"

/datum/sutando_abilities/ranged/light_switch()
	if(stand.see_invisible == SEE_INVISIBLE_MINIMUM)
		stand << "<span class='notice'>You deactivate your night vision.</span>"
		stand.see_invisible = SEE_INVISIBLE_LIVING
	else
		stand << "<span class='notice'>You activate your night vision.</span>"
		stand.see_invisible = SEE_INVISIBLE_MINIMUM

/datum/action/innate/snare
	background_icon_state = "bg_alien"


/datum/action/innate/snare/plant
	name = "Plant Snare"
	button_icon_state = "set_drop"

/datum/action/innate/snare/plant/Activate()
	var/mob/living/simple_animal/hostile/sutando/A = owner
	for(var/datum/sutando_abilities/ranged/I in A.current_abilities)
		if(I.snares.len <6)
			var/turf/snare_loc = get_turf(owner.loc)
			var/obj/effect/snare/S = new /obj/effect/snare(snare_loc)
			S.spawner = owner
			S.name = "[get_area(snare_loc)] snare ([rand(1, 1000)])"
			I.snares |= S
			owner << "<span class='danger'><B>Surveillance snare deployed!</span></B>"
		else
			owner << "<span class='danger'><B>You have too many snares deployed. Remove some first.</span></B>"

/datum/action/innate/snare/remove
	name = "Remove Snare"
	button_icon_state = "camera_off"

/datum/action/innate/snare/remove_snare/Activate()
	var/mob/living/simple_animal/hostile/sutando/A = owner
	for(var/datum/sutando_abilities/ranged/I in A.current_abilities)
		var/picked_snare = input(owner, "Pick which snare to remove", "Remove Snare") as null|anything in I.snares
		if(picked_snare)
			owner -= picked_snare
			qdel(picked_snare)
			owner << "<span class='danger'><B>Snare disarmed.</span></B>"



/datum/sutando_abilities/ranged/ranged_attack(atom/target_atom)
	if(istype(., /obj/item/projectile))
		var/obj/item/projectile/P = .
		stand.say("[battlecry][battlecry][battlecry]!!")
		if(stand.namedatum)
			P.color = stand.namedatum.colour

//magician's fried chicken
/datum/sutando_abilities/fire
	name = "Controlled Combustion"
	value = 7


/datum/sutando_abilities/fire/handle_stats()
	stand.melee_damage_lower += 4.5
	stand.melee_damage_upper += 4.5
	stand.attack_sound = 'sound/items/Welder.ogg'
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.3
	stand.range += 4.5
	stand.a_intent = INTENT_HELP

/datum/sutando_abilities/fire/bump_reaction(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(!stand.hasmatchingsummoner(M) && M != user && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/datum/sutando_abilities/fire/life_act()
	if(user)
		user.ExtinguishMob()
		user.adjust_fire_stacks(-20)


//lame

/datum/sutando_abilities/assassin
	name = "Undetected Elimination"
	value = 6
	var/stealthcooldown = 160
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/datum/sutando_abilities/assassin/Destroy()
	return ..()

/datum/sutando_abilities/assassin/handle_stats()
	stand.has_mode = TRUE
	stand.melee_damage_lower += 7
	stand.melee_damage_upper += 7
	stand.attacktext = "slashes"
	stand.attack_sound = 'sound/weapons/bladeslice.ogg'
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode/Assassin


/datum/sutando_abilities/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = stand.throw_alert("instealth", /obj/screen/alert/instealth)
				stand.clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = stand.throw_alert("canstealth", /obj/screen/alert/canstealth)
				stand.clear_alert("instealth")
				instealthalert = null
	else
		stand.clear_alert("instealth")
		instealthalert = null
		stand.clear_alert("canstealth")
		canstealthalert = null


/datum/sutando_abilities/assassin/life_act()
	updatestealthalert()
	if(stand.loc == user && toggle)
		stand.ToggleMode(0)

/datum/sutando_abilities/assassin/handle_mode(forced = 0)
	if(toggle)
		stand.melee_damage_lower = initial(stand.melee_damage_lower)
		stand.melee_damage_upper = initial(stand.melee_damage_upper)
		stand.armour_penetration = initial(stand.armour_penetration)
		stand.obj_damage = initial(stand.obj_damage)
		stand.environment_smash = initial(stand.environment_smash)
		stand.alpha = initial(stand.alpha)
		if(!forced)
			stand << "<span class='danger'><B>You exit stealth.</span></B>"
		else
			stand.visible_message("<span class='danger'>\The [stand] suddenly appears!</span>")
			stealthcooldown = world.time + initial(stealthcooldown) //we were forcedd out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(stand.loc == user)
			stand << "<span class='danger'><B>You have to be manifested to enter stealth!</span></B>"
			return
		stand.melee_damage_lower = 50
		stand.melee_damage_upper = 50
		stand.armour_penetration = 100
		stand.obj_damage = 0
		stand.environment_smash = 0
		new /obj/effect/overlay/temp/sutando/phase/out(get_turf(stand))
		stand.alpha = 15
		if(!forced)
			stand << "<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>"
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		stand << "<span class='danger'><B>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span></B>"

/datum/sutando_abilities/assassin/ability_act()
	if(toggle && (isliving(stand.target) || istype(stand.target, /obj/structure/window) || istype(stand.target, /obj/structure/grille)))
		stand.ToggleMode(1)


//red hot achilles peeper

/datum/sutando_abilities/lightning
	name = "Controlled Current"
	value = 7
	var/datum/beam/userchain
	var/list/enemychains
	var/successfulshocks = 0

/datum/sutando_abilities/lightning/handle_stats()

	stand.melee_damage_lower += 4
	stand.melee_damage_upper += 4
	stand.attacktext = "shocks"
	stand.melee_damage_type = BURN
	stand.attack_sound = 'sound/machines/defib_zap.ogg'
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.15
	stand.range += 4



/datum/sutando_abilities/lightning/recall_act()
	removechains()

/datum/sutando_abilities/lightning/ability_act()
	if(isliving(stand.target) && stand.target != stand && stand.target != user)
		cleardeletedchains()
		for(var/chain in enemychains)
			var/datum/beam/B = chain
			if(B.target == stand.target)
				return //oh this guy already HAS a chain, let's not chain again
		if(enemychains.len > 2)
			var/datum/beam/C = pick(enemychains)
			qdel(C)
			enemychains -= C
		enemychains += stand.Beam(stand.target, "lightning[rand(1,12)]", time=70, maxdistance=7, beam_type=/obj/effect/ebeam/chain)

/datum/sutando_abilities/lightning/Destroy()
	removechains()
	return ..()

/datum/sutando_abilities/lightning/manifest_act()
	if(.)
		if(user)
			userchain = stand.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		while(stand.loc != user)
			if(successfulshocks > 5)
				successfulshocks = 0
			if(shockallchains())
				successfulshocks++
			sleep(3)



/datum/sutando_abilities/lightning/proc/cleardeletedchains()
	if(userchain && QDELETED(userchain))
		userchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				enemychains -= chain

/datum/sutando_abilities/lightning/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(user)
		if(!userchain)
			userchain = stand.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		. += chainshock(userchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			. += chainshock(chain)

/datum/sutando_abilities/lightning/proc/removechains()
	QDEL_NULL(userchain)
	if(enemychains.len)
		enemychains.Cut()

/datum/sutando_abilities/lightning/proc/chainshock(datum/beam/B)
	. = 0
	var/list/turfs = list()
	for(var/E in B.elements)
		var/obj/effect/ebeam/chainpart = E
		if(chainpart && chainpart.x && chainpart.y && chainpart.z)
			var/turf/T = get_turf_pixel(chainpart)
			turfs |= T
			if(T != get_turf(B.origin) && T != get_turf(B.target))
				for(var/turf/TU in circlerange(T, 1))
					turfs |= TU
	for(var/turf in turfs)
		var/turf/T = turf
		for(var/mob/living/L in T)
			if(L.stat != DEAD && L != stand && L != user)
				if(stand.hasmatchingsummoner(L)) //if the user matches don't hurt them
					continue
				if(successfulshocks > 4)
					if(iscarbon(L))
						var/mob/living/carbon/C = L
						if(ishuman(C))
							var/mob/living/carbon/human/H = C
							H.electrocution_animation(20)
						C.jitteriness += 1000
						C.do_jitter_animation(stand.jitteriness)
						C.stuttering += 1
						spawn(20)
							if(C)
								C.jitteriness = max(C.jitteriness - 990, 10)
					L.visible_message(
						"<span class='danger'>[L] was shocked by the lightning chain!</span>", \
						"<span class='userdanger'>You are shocked by the lightning chain!</span>", \
						"<span class='italics'>You hear a heavy electrical crack.</span>" \
					)
				L.adjustFireLoss(1.2) //adds up very rapidly
				. = 1

//screeeeeeeeeeeeee
/datum/sutando_abilities/charge
	name = "Stampede Force"
	value = 7
	var/charging = FALSE
	var/obj/screen/alert/chargealert

/datum/sutando_abilities/charge/Destroy()
	QDEL_NULL(chargealert)
	return ..()

/datum/sutando_abilities/charge/proc/charging_end()
	charging = FALSE

/datum/sutando_abilities/charge/handle_stats()
	. = ..()
	stand.melee_damage_lower += 7
	stand.melee_damage_upper += 7
	stand.ranged = TRUE //technically
	stand.ranged_message = "charges"
	stand.ranged_cooldown_time += 20
	stand.speed -= 1
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.2

/datum/sutando_abilities/charge/openfire_act(atom/A)
	if(!charging)
		stand.visible_message("<span class='danger'><b>[stand]</b> [stand.ranged_message] at [A]!</span>")
		stand.ranged_cooldown = world.time + stand.ranged_cooldown_time
		stand.clear_alert("charge")
		chargealert = null
		stand.Shoot(A)

/datum/sutando_abilities/charge/life_act()
	if(stand.ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = stand.throw_alert("charge", /obj/screen/alert/cancharge)
	else
		stand.clear_alert("charge")
		chargealert = null

/datum/sutando_abilities/charge/ranged_attack(atom/targeted_atom)
	charging = 1
	stand.throw_at(targeted_atom, stand.range, 1, stand, 0, callback = CALLBACK(stand, .proc/charging_end))


/datum/sutando_abilities/charge/move_act()
	if(charging)
		new /obj/effect/overlay/temp/decoy/fading(stand.loc,stand)
	. = stand.Move()

/datum/sutando_abilities/charge/impact_act(atom/A)
	if(!charging)
		return

	else if(A)
		if(isliving(A) && A != user)
			var/mob/living/L = A
			var/blocked = FALSE
			if(stand.hasmatchingsummoner(A)) //if the user matches don't hurt them
				blocked = TRUE
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(90, "[stand.name]", stand, attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = TRUE
			if(!blocked)
				L.drop_all_held_items()
				L.visible_message("<span class='danger'>[stand] slams into [L]!</span>", "<span class='userdanger'>[stand] slams into you!</span>")
				L.apply_damage(20, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(stand, 2, 3)

		charging = FALSE

/datum/sutando_abilities/charge/snapback_act()
	if(!charging)
		. = stand.snapback()

//protector ability
/datum/sutando_abilities/protector
	name = "Impenetrable Defense"
	value = 4

/datum/sutando_abilities/protector/handle_stats()
	. = ..()
	stand.has_mode = TRUE
	stand.melee_damage_lower = 7
	stand.melee_damage_upper = 7
	stand.range = 7 //worse for it due to how it leashes
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.3
	stand.toggle_button_type = /obj/screen/sutando/ToggleMode

/datum/sutando_abilities/protector/boom_act(severity)
	if(severity == 1)
		stand.adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the user
	else
		. = stand.ex_act(severity)
	if(toggle)
		stand.visible_message("<span class='danger'>The explosion glances off [stand]'s energy shielding!</span>")

/datum/sutando_abilities/protector/adjusthealth_act(amount, updating_health = TRUE, forced = FALSE)
	. = stand.adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(. > 0 && toggle)
		var/image/I = new('icons/effects/effects.dmi', stand, "shield-flash", MOB_LAYER+0.01, dir = pick(cardinal))
		if(stand.namedatum)
			I.color = stand.namedatum.colour
		flick_overlay_view(I, stand, 5)

/datum/sutando_abilities/protector/handle_mode()
	if(cooldown > world.time)
		return FALSE
	cooldown = world.time + 10
	if(toggle)
		stand.cut_overlays()
		stand.melee_damage_lower = initial(stand.melee_damage_lower)
		stand.melee_damage_upper = initial(stand.melee_damage_upper)
		stand.speed = initial(stand.speed)
		stand.damage_coeff = initial_coeff
		stand << "<span class='danger'><B>You switch to combat mode.</span></B>"
		toggle = FALSE
	else
		var/image/I = new('icons/effects/effects.dmi', "shield-grey")
		if(stand.namedatum)
			I.color = stand.namedatum.colour
		stand.add_overlay(I)
		stand.melee_damage_lower = 2
		stand.melee_damage_upper = 2
		stand.speed = 1
		stand.damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		stand << "<span class='danger'><B>You switch to protection mode.</span></B>"
		toggle = TRUE

/datum/sutando_abilities/protector/snapback_act() //snap to what? snap to the stand!
	if(user)
		if(get_dist(get_turf(user),get_turf(stand)) <= stand.range)
			return
		else
			if(istype(user.loc, /obj/effect))
				stand << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [stand.range] meters from [user.real_name]!</span>"
				stand.visible_message("<span class='danger'>\The [stand] jumps back to its user.</span>")
				stand.Recall(TRUE)
			else
				user << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [stand.range] meters from <font color=\"[stand.namedatum.colour]\"><b>[stand.real_name]</b></font>!</span>"
				user.visible_message("<span class='danger'>\The [user] jumps back to [user.p_their()] protector.</span>")
				new /obj/effect/overlay/temp/sutando/phase/out(get_turf(user))
				user.forceMove(get_turf(stand))
				new /obj/effect/overlay/temp/sutando/phase(get_turf(user))

//healsluts

/datum/sutando_abilities/heal
	name = "Mending Properties"
	value = 3
	var/obj/structure/recieving_pad/beacon
	var/beacon_cooldown = 0
	var/datum/action/innate/beacon/B = new

/datum/sutando_abilities/heal/Destroy()
	QDEL_NULL(B)
	return ..()

/datum/sutando_abilities/heal/proc/plant_beacon()
	if(beacon_cooldown >= world.time)
		stand << "<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>"
		return

	var/turf/beacon_loc = get_turf(stand)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, stand)

	stand << "<span class='danger'><B>Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click.</span></B>"

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

	var/datum/atom_hud/medsensor = huds[DATA_HUD_MEDICAL_ADVANCED]
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
			stand << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			stand.a_intent = INTENT_HELP
			stand.speed = 1
			stand.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			stand.melee_damage_lower = 0
			stand.melee_damage_upper = 0
			stand << "<span class='danger'><B>You switch to healing mode.</span></B>"
			toggle = TRUE
	else
		stand << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"

/datum/sutando_abilities/heal/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(stand.loc == user)
		stand << "<span class='danger'><B>You must be manifested to warp a target!</span></B>"
		return
	if(!beacon)
		stand << "<span class='danger'><B>You need a beacon placed to warp things!</span></B>"
		return
	if(!stand.Adjacent(A))
		stand << "<span class='danger'><B>You must be adjacent to your target!</span></B>"
		return
	if(A.anchored)
		stand << "<span class='danger'><B>Your target cannot be anchored!</span></B>"
		return

	var/turf/T = get_turf(A)
	if(beacon.z != T.z)
		stand << "<span class='danger'><B>The beacon is too far away to warp to!</span></B>"
		return

	stand << "<span class='danger'><B>You begin to warp [A].</span></B>"
	A.visible_message("<span class='danger'>[A] starts to glow faintly!</span>", \
	"<span class='userdanger'>You start to glow faintly, and you feel strangely weightless!</span>")
	stand.do_attack_animation(A, null, 1)

	if(!do_mob(stand, A, 60)) //now start the channel
		stand << "<span class='danger'><B>You need to hold still!</span></B>"
		return

	new /obj/effect/overlay/temp/sutando/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message("<span class='danger'>[A] disappears in a flash of light!</span>", \
	"<span class='userdanger'>Your vision is obscured by a flash of light!</span>")
	do_teleport(A, beacon, 0)
	new /obj/effect/overlay/temp/sutando/phase(get_turf(A))

//metal pinky
/datum/sutando_abilities/dextrous
	name = "Dexterity"
	value = 4

/datum/sutando_abilities/dextrous/handle_stats()
	. = ..()
	stand.dextrous = TRUE
	stand.environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/rack,
	/obj/structure/barricade,
	/obj/machinery/camera)
	stand.melee_damage_lower += 5
	stand.melee_damage_upper += 5
	for(var/i in stand.damage_coeff)
		stand.damage_coeff[i] -= 0.15

/datum/sutando_abilities/dextrous/recall_act(forced)
	if(!user || stand.loc == user || (cooldown > world.time && !forced) && stand.dextrous)
		return FALSE
	stand.drop_all_held_items()
	return TRUE //lose items, then return

/datum/sutando_abilities/dextrous/snapback_act()
	if(user && !(get_dist(get_turf(user),get_turf(stand)) <= stand.range) && stand.dextrous)
		stand.drop_all_held_items()
		return TRUE //lose items, then return

//T   H   E      W   O   R   L   D   .   -   Z   A      W   A   R   U   D   O   .
//somebody once told me the world was gonna roll me
/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/sutando
	invocation = null
	summon_type = list(/obj/effect/timestop/wizard/sutando)
	clothes_req = 0

/datum/sutando_abilities/timestop
	value = 5

/datum/sutando_abilities/timestop/handle_stats()
	. = ..()
	var/obj/effect/proc_holder/spell/S = new/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/sutando
	stand.mind.AddSpell(S)
	stand.melee_damage_lower += 5
	stand.melee_damage_upper += 5
	stand.obj_damage += 40
	stand.next_move_modifier -= 0.1 //attacks 10% faster

//prop hunt

/datum/sutando_abilities/shapeshift
	name = "Chameleon Skin"
	value = 4
	var/obj/item/remembered = null
	var/obj/item/host = null

/datum/sutando_abilities/shapeshift/recall_act()
	QDEL_NULL(host)

/datum/sutando_abilities/shapeshift/handle_stats()
	. = ..()
	stand.has_mode = TRUE
	stand.range += 3
	stand.melee_damage_lower += 3
	stand.melee_damage_upper += 3

/datum/sutando_abilities/shapeshift/alt_ability_act(obj/item/A)
	if(!istype(A))
		return
	if(stand.loc == user)
		stand << "<span class='danger'><B>You must be manifested to remember an item!</span></B>"
		return
	remembered = A.type
	stand << "<span class='danger'><B>You remember \the [remembered.name]!</span></B>"

/datum/sutando_abilities/shapeshift/handle_mode()
	if(!toggle)
		if(remembered)
			host = new remembered(get_turf(stand))
			stand.forceMove(host)
			stand.visible_message("<span class='danger'>[stand] twists into the shape of [host.name]!</span>")
			playsound(stand.loc, 'sound/weapons/draw_bow.ogg', 50, 1, 1)
			remembered = null
		else
			stand << "<span class='danger'><B>You don't have a remembered item!</span></B>"
			return
		toggle = TRUE
	else
		stand.forceMove(get_turf(stand))
		QDEL_NULL(host)
		stand << "<span class='danger'><B>You twist back into your original form.</span></B>"
		toggle = FALSE

//ion man

/datum/sutando_abilities/ion
	value = 8 //you may think this is bullshit, but this ability is actually VERY strong.
	name = "Electronic Disruption"

/datum/sutando_abilities/ion/handle_stats()
	. = ..()
	stand.projectiletype = /obj/item/projectile/ion
	stand.ranged_cooldown_time = 5
	stand.ranged = TRUE
	stand.range += 3
	stand.melee_damage_lower += 3
	stand.melee_damage_upper += 3

/datum/sutando_abilities/ion/ability_act()
	empulse(stand.target, 1, 1)

//oingo boingo

/datum/sutando_abilities/bounce
	name = "Rubbery Skin"
	value = 1
	var/bounce_distance = 5

/datum/sutando_abilities/bounce/handle_stats()
	. = ..()
	stand.range += 3
	stand.melee_damage_lower += 3
	stand.melee_damage_upper += 3

/datum/sutando_abilities/bounce/ability_act(atom/movable/A)
	var/atom/throw_target = get_edge_target_turf(A, stand.dir)
	A.throw_at(throw_target, bounce_distance, 14, stand) //interesting

/datum/sutando_abilities/bounce/boom_act(severity)
	stand.visible_message("<span class='danger'>The explosive force bounces off [stand]'s rubbery surface!</span>")
	for(var/mob/M in range(7,stand))
		if(M != user)
			M.ex_act(severity)
