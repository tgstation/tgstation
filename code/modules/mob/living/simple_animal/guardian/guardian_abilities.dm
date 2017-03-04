//SABAKU NO WA ORE STANDO DA

/datum/guardian_abilities
	var/toggle = FALSE
	var/mob/living/simple_animal/hostile/guardian/stando = null
	var/mob/living/user = null
	var/cooldown = 0
	var/value = 0 //VALUE SYSTEM:
	var/battlecry = "ORA"
	var/initial_coeff = list()
	//basically, the total value of abilities a stand can have is 10, and more powerful abilities have more value, this means that
	//randomized-ability stands can only have a set number of abilities both in quantity and quality, maintaining some form of balance.
	//CRUCIAL: only randomized stands are to use the value system.

/datum/guardian_abilities/proc/handle_stats()
	initial_coeff = stando.damage_coeff

/datum/guardian_abilities/proc/life_act()


/datum/guardian_abilities/proc/ability_act()


/datum/guardian_abilities/proc/alt_ability_act() //ability to do on alt_click


/datum/guardian_abilities/proc/handle_mode()


/datum/guardian_abilities/proc/bump_reaction()


/datum/guardian_abilities/proc/ranged_attack()


/datum/guardian_abilities/proc/impact_act()


/datum/guardian_abilities/proc/recall_act()


/datum/guardian_abilities/proc/adjusthealth_act()


/datum/guardian_abilities/proc/light_switch()


/datum/guardian_abilities/proc/destroy_act()


/datum/guardian_abilities/proc/manifest_act()


/datum/guardian_abilities/proc/openfire_act()


/datum/guardian_abilities/proc/move_act()


/datum/guardian_abilities/proc/snapback_act()


/datum/guardian_abilities/proc/boom_act()

//ORA ORA ORA

/datum/guardian_abilities/punch
	value = 5


/datum/guardian_abilities/punch/handle_stats()
	stando.melee_damage_lower += 10
	stando.melee_damage_upper += 10
	stando.obj_damage += 80
	stando.next_move_modifier -= 0.2 //attacks 20% faster
	stando.environment_smash = 2


/datum/guardian_abilities/punch/ability_act()
	if(isliving(stando.target))
		stando.attack_sound = pick('sound/magic/standopunch.ogg', 'sound/magic/standopunch1.ogg', 'sound/magic/standopunch2.ogg')
		stando.say("[battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry][battlecry]!!")
		playsound(stando.loc, stando.attack_sound, 50, 1, 1)
		playsound(stando.loc, stando.attack_sound, 50, 1, 1)
		playsound(stando.loc, stando.attack_sound, 50, 1, 1)
		playsound(stando.loc, stando.attack_sound, 50, 1, 1)

//killed queem u bad cat

/datum/guardian_abilities/bomb
	var/bomb_cooldown = 0
	value = 6

/datum/guardian_abilities/bomb/handle_stats()
	stando.melee_damage_lower += 7
	stando.melee_damage_upper += 7
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.2
	stando.range += 6

/datum/guardian_abilities/bomb/ability_act()
	if(prob(40))
		if(isliving(stando.target))
			var/mob/living/M = stando.target
			if(!M.anchored && M != user && !stando.hasmatchingsummoner(M))
				new /obj/effect/overlay/temp/guardian/phase/out(get_turf(M))
				do_teleport(M, M, 10)
				for(var/mob/living/L in range(1, M))
					if(stando.hasmatchingsummoner(L)) //if the user matches don't hurt them
						continue
					if(L != stando && L != user)
						L.apply_damage(15, BRUTE)
						stando.say("[battlecry]!!")
				new /obj/effect/overlay/temp/explosion(get_turf(M))


/datum/guardian_abilities/bomb/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(stando.loc == user)
		stando << "<span class='danger'><B>You must be manifested to create bombs!</span></B>"
		return
	if(isobj(A))
		if(bomb_cooldown <= world.time && !stando.stat)
			var/obj/guardian_bomb/B = new/obj/guardian_bomb(get_turf(A))
			stando << "<span class='danger'><B>Success! Bomb armed!</span></B>"
			stando.say("[battlecry]!!")
			bomb_cooldown = world.time + 200
			B.spawner = stando
			B.disguise(A)
		else
			stando << "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</span></B>"

//rore zone

/datum/guardian_abilities/ranged
	value = 4
	var/list/snares = list()
	var/datum/action/innate/snare/plant/P = new
	var/datum/action/innate/snare/remove/R = new

/datum/guardian_abilities/ranged/handle_stats()
	stando.has_mode = TRUE
	stando.melee_damage_lower += 5
	stando.melee_damage_upper += 5
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.05
	stando.projectiletype = /obj/item/projectile/guardian
	stando.ranged_cooldown_time = 1 //fast!
	stando.projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	stando.ranged = 1
	stando.range += 6
	stando.has_mode = TRUE

	stando.see_invisible = SEE_INVISIBLE_LIVING
	stando.see_in_dark += 4
	stando.toggle_button_type = /obj/screen/guardian/ToggleMode
	P.Grant(stando)
	R.Grant(stando)



/datum/guardian_abilities/ranged/handle_mode()
	if(stando.loc == user)
		if(toggle)
			stando.ranged = initial(stando.ranged)
			stando.melee_damage_lower = initial(stando.melee_damage_lower)
			stando.melee_damage_upper = initial(stando.melee_damage_upper)
			stando.obj_damage = initial(stando.obj_damage)
			stando.environment_smash = initial(stando.environment_smash)
			stando.alpha = 255
			stando.range = initial(stando.range)
			stando.incorporeal_move = 0
			stando << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			stando.ranged = 0
			stando.melee_damage_lower = 0
			stando.melee_damage_upper = 0
			stando.obj_damage = 0
			stando.environment_smash = 0
			stando.alpha = 45
			stando.range = 255
			stando.incorporeal_move = 1
			stando << "<span class='danger'><B>You switch to scout mode.</span></B>"
			toggle = TRUE
	else
		stando << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"

/datum/guardian_abilities/ranged/light_switch()
	if(stando.see_invisible == SEE_INVISIBLE_MINIMUM)
		stando << "<span class='notice'>You deactivate your night vision.</span>"
		stando.see_invisible = SEE_INVISIBLE_LIVING
	else
		stando << "<span class='notice'>You activate your night vision.</span>"
		stando.see_invisible = SEE_INVISIBLE_MINIMUM

/datum/action/innate/snare
	background_icon_state = "bg_alien"


/datum/action/innate/snare/plant
	name = "Plant Snare"
	button_icon_state = "set_drop"

/datum/action/innate/snare/plant/Activate()
	var/mob/living/simple_animal/hostile/guardian/A = owner
	for(var/datum/guardian_abilities/ranged/I in A.current_abilities)
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
	var/mob/living/simple_animal/hostile/guardian/A = owner
	for(var/datum/guardian_abilities/ranged/I in A.current_abilities)
		var/picked_snare = input(owner, "Pick which snare to remove", "Remove Snare") as null|anything in I.snares
		if(picked_snare)
			owner -= picked_snare
			qdel(picked_snare)
			owner << "<span class='danger'><B>Snare disarmed.</span></B>"



/datum/guardian_abilities/ranged/ranged_attack(atom/target_atom)
	. = stando.Shoot()
	if(istype(., /obj/item/projectile))
		var/obj/item/projectile/P = .
		stando.say("[battlecry][battlecry][battlecry]!!")
		if(stando.namedatum)
			P.color = stando.namedatum.colour

//magician's fried chicken

/datum/guardian_abilities/fire/handle_stats()
	stando.melee_damage_lower += 4.5
	stando.melee_damage_upper += 4.5
	stando.attack_sound = 'sound/items/Welder.ogg'
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.3
	stando.range += 4.5
	stando.a_intent = INTENT_HELP

/datum/guardian_abilities/fire/bump_reaction(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(!stando.hasmatchingsummoner(M) && M != user && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/datum/guardian_abilities/fire/life_act()
	if(user)
		user.ExtinguishMob()
		user.adjust_fire_stacks(-20)


//lame

/datum/guardian_abilities/assassin
	value = 6
	var/stealthcooldown = 160
	var/obj/screen/alert/canstealthalert
	var/obj/screen/alert/instealthalert

/datum/guardian_abilities/assassin/handle_stats()
	stando.has_mode = TRUE
	stando.melee_damage_lower += 7
	stando.melee_damage_upper += 7
	stando.attacktext = "slashes"
	stando.attack_sound = 'sound/weapons/bladeslice.ogg'
	stando.toggle_button_type = /obj/screen/guardian/ToggleMode/Assassin


/datum/guardian_abilities/assassin/proc/updatestealthalert()
	if(stealthcooldown <= world.time)
		if(toggle)
			if(!instealthalert)
				instealthalert = stando.throw_alert("instealth", /obj/screen/alert/instealth)
				stando.clear_alert("canstealth")
				canstealthalert = null
		else
			if(!canstealthalert)
				canstealthalert = stando.throw_alert("canstealth", /obj/screen/alert/canstealth)
				stando.clear_alert("instealth")
				instealthalert = null
	else
		stando.clear_alert("instealth")
		instealthalert = null
		stando.clear_alert("canstealth")
		canstealthalert = null


/datum/guardian_abilities/assassin/life_act()
	updatestealthalert()
	if(stando.loc == user && toggle)
		stando.ToggleMode(0)

/datum/guardian_abilities/assassin/handle_mode(forced = 0)
	if(toggle)
		stando.melee_damage_lower = initial(stando.melee_damage_lower)
		stando.melee_damage_upper = initial(stando.melee_damage_upper)
		stando.armour_penetration = initial(stando.armour_penetration)
		stando.obj_damage = initial(stando.obj_damage)
		stando.environment_smash = initial(stando.environment_smash)
		stando.alpha = initial(stando.alpha)
		if(!forced)
			stando << "<span class='danger'><B>You exit stealth.</span></B>"
		else
			stando.visible_message("<span class='danger'>\The [stando] suddenly appears!</span>")
			stealthcooldown = world.time + initial(stealthcooldown) //we were forcedd out of stealth and go on cooldown
			cooldown = world.time + 40 //can't recall for 4 seconds
		updatestealthalert()
		toggle = FALSE
	else if(stealthcooldown <= world.time)
		if(stando.loc == user)
			stando << "<span class='danger'><B>You have to be manifested to enter stealth!</span></B>"
			return
		stando.melee_damage_lower = 50
		stando.melee_damage_upper = 50
		stando.armour_penetration = 100
		stando.obj_damage = 0
		stando.environment_smash = 0
		new /obj/effect/overlay/temp/guardian/phase/out(get_turf(stando))
		stando.alpha = 15
		if(!forced)
			stando << "<span class='danger'><B>You enter stealth, empowering your next attack.</span></B>"
		updatestealthalert()
		toggle = TRUE
	else if(!forced)
		stando << "<span class='danger'><B>You cannot yet enter stealth, wait another [max(round((stealthcooldown - world.time)*0.1, 0.1), 0)] seconds!</span></B>"

/datum/guardian_abilities/assassin/ability_act()
	if(toggle && (isliving(stando.target) || istype(stando.target, /obj/structure/window) || istype(stando.target, /obj/structure/grille)))
		stando.ToggleMode(1)


//red hot achilles peeper

/datum/guardian_abilities/lightning
	value = 7
	var/datum/beam/userchain
	var/list/enemychains = list()
	var/successfulshocks = 0

/datum/guardian_abilities/lightning/handle_stats()
	stando.melee_damage_lower += 4
	stando.melee_damage_upper += 4
	stando.attacktext = "shocks"
	stando.melee_damage_type = BURN
	stando.attack_sound = 'sound/machines/defib_zap.ogg'
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.15
	stando.range += 4



/datum/guardian_abilities/lightning/recall_act()
	if(. = stando.Recall())
		removechains()

/datum/guardian_abilities/lightning/ability_act()
	if(. = stando.AttackingTarget())
		if(isliving(stando.target) && stando.target != stando && stando.target != user)
			cleardeletedchains()
			for(var/chain in enemychains)
				var/datum/beam/B = chain
				if(B.target == stando.target)
					return //oh this guy already HAS a chain, let's not chain again
			if(enemychains.len > 2)
				var/datum/beam/C = pick(enemychains)
				qdel(C)
				enemychains -= C
			enemychains += stando.Beam(stando.target, "lightning[rand(1,12)]", time=70, maxdistance=7, beam_type=/obj/effect/ebeam/chain)

/datum/guardian_abilities/lightning/destroy_act()
	removechains()
	return . = stando.Destroy()

/datum/guardian_abilities/lightning/manifest_act()
	. = stando.Manifest()
	if(.)
		if(user)
			userchain = stando.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		while(stando.loc != user)
			if(successfulshocks > 5)
				successfulshocks = 0
			if(shockallchains())
				successfulshocks++
			sleep(3)



/datum/guardian_abilities/lightning/proc/cleardeletedchains()
	if(userchain && QDELETED(userchain))
		userchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				enemychains -= chain

/datum/guardian_abilities/lightning/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(user)
		if(!userchain)
			userchain = stando.Beam(user, "lightning[rand(1,12)]", time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		. += chainshock(userchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			. += chainshock(chain)

/datum/guardian_abilities/lightning/proc/removechains()
	if(userchain)
		qdel(userchain)
		userchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			qdel(chain)
		enemychains = list()

/datum/guardian_abilities/lightning/proc/chainshock(datum/beam/B)
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
			if(L.stat != DEAD && L != stando && L != user)
				if(stando.hasmatchingsummoner(L)) //if the user matches don't hurt them
					continue
				if(successfulshocks > 4)
					if(iscarbon(L))
						var/mob/living/carbon/C = L
						if(ishuman(C))
							var/mob/living/carbon/human/H = C
							H.electrocution_animation(20)
						C.jitteriness += 1000
						C.do_jitter_animation(stando.jitteriness)
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
/datum/guardian_abilities/charge
	value = 7
	var/charging = 0
	var/obj/screen/alert/chargealert

/datum/guardian_abilities/charge/proc/charging_end()
	charging = 0

/datum/guardian_abilities/charge/handle_stats()
	. = ..()
	stando.melee_damage_lower += 7
	stando.melee_damage_upper += 7
	stando.ranged = 1 //technically
	stando.ranged_message = "charges"
	stando.ranged_cooldown_time += 20
	stando.speed -= 1
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.2

/datum/guardian_abilities/charge/openfire_act(atom/A)
	if(!charging)
		stando.visible_message("<span class='danger'><b>[stando]</b> [stando.ranged_message] at [A]!</span>")
		stando.ranged_cooldown = world.time + stando.ranged_cooldown_time
		stando.clear_alert("charge")
		chargealert = null
		stando.Shoot(A)

/datum/guardian_abilities/charge/life_act()
	if(stando.ranged_cooldown <= world.time)
		if(!chargealert)
			chargealert = stando.throw_alert("charge", /obj/screen/alert/cancharge)
	else
		stando.clear_alert("charge")
		chargealert = null

/datum/guardian_abilities/charge/ranged_attack(atom/targeted_atom)
	charging = 1
	stando.throw_at(targeted_atom, stando.range, 1, stando, 0, callback = CALLBACK(stando, .proc/charging_end))


/datum/guardian_abilities/charge/move_act()
	if(charging)
		new /obj/effect/overlay/temp/decoy/fading(stando.loc,stando)
	. = stando.Move()

/datum/guardian_abilities/charge/impact_act(atom/A)
	if(!charging)
		return . = stando.throw_impact(A)

	else if(A)
		if(isliving(A) && A != user)
			var/mob/living/L = A
			var/blocked = 0
			if(stando.hasmatchingsummoner(A)) //if the user matches don't hurt them
				blocked = 1
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(90, "[stando.name]", stando, attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = 1
			if(!blocked)
				L.drop_all_held_items()
				L.visible_message("<span class='danger'>[stando] slams into [L]!</span>", "<span class='userdanger'>[stando] slams into you!</span>")
				L.apply_damage(20, BRUTE)
				playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
				shake_camera(L, 4, 3)
				shake_camera(stando, 2, 3)

		charging = 0

/datum/guardian_abilities/charge/snapback_act()
	if(!charging)
		. = stando.snapback()

//protector ability
/datum/guardian_abilities/protector
	value = 4

/datum/guardian_abilities/protector/handle_stats()
	. = ..()
	stando.has_mode = TRUE
	stando.melee_damage_lower = 7
	stando.melee_damage_upper = 7
	stando.range = 7 //worse for it due to how it leashes
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.3
	stando.toggle_button_type = /obj/screen/guardian/ToggleMode

/datum/guardian_abilities/protector/boom_act(severity)
	if(severity == 1)
		stando.adjustBruteLoss(400) //if in protector mode, will do 20 damage and not actually necessarily kill the user
	else
		. = stando.ex_act(severity)
	if(toggle)
		stando.visible_message("<span class='danger'>The explosion glances off [stando]'s energy shielding!</span>")

/datum/guardian_abilities/protector/adjusthealth_act(amount, updating_health = TRUE, forced = FALSE)
	. = stando.adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(. > 0 && toggle)
		var/image/I = new('icons/effects/effects.dmi', stando, "shield-flash", MOB_LAYER+0.01, dir = pick(cardinal))
		if(stando.namedatum)
			I.color = stando.namedatum.colour
		flick_overlay_view(I, stando, 5)

/datum/guardian_abilities/protector/handle_mode()
	if(cooldown > world.time)
		return 0
	cooldown = world.time + 10
	if(toggle)
		stando.cut_overlays()
		stando.melee_damage_lower = initial(stando.melee_damage_lower)
		stando.melee_damage_upper = initial(stando.melee_damage_upper)
		stando.speed = initial(stando.speed)
		stando.damage_coeff = initial_coeff
		stando << "<span class='danger'><B>You switch to combat mode.</span></B>"
		toggle = FALSE
	else
		var/image/I = new('icons/effects/effects.dmi', "shield-grey")
		if(stando.namedatum)
			I.color = stando.namedatum.colour
		stando.add_overlay(I)
		stando.melee_damage_lower = 2
		stando.melee_damage_upper = 2
		stando.speed = 1
		stando.damage_coeff = list(BRUTE = 0.05, BURN = 0.05, TOX = 0.05, CLONE = 0.05, STAMINA = 0, OXY = 0.05) //damage? what's damage?
		stando << "<span class='danger'><B>You switch to protection mode.</span></B>"
		toggle = TRUE

/datum/guardian_abilities/protector/snapback_act() //snap to what? snap to the guardian!
	if(user)
		if(get_dist(get_turf(user),get_turf(stando)) <= stando.range)
			return
		else
			if(istype(user.loc, /obj/effect))
				stando << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [stando.range] meters from [user.real_name]!</span>"
				stando.visible_message("<span class='danger'>\The [stando] jumps back to its user.</span>")
				stando.Recall(TRUE)
			else
				user << "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [stando.range] meters from <font color=\"[stando.namedatum.colour]\"><b>[stando.real_name]</b></font>!</span>"
				user.visible_message("<span class='danger'>\The [user] jumps back to [user.p_their()] protector.</span>")
				new /obj/effect/overlay/temp/guardian/phase/out(get_turf(user))
				user.forceMove(get_turf(stando))
				new /obj/effect/overlay/temp/guardian/phase(get_turf(user))

//healsluts

/datum/guardian_abilities/heal
	value = 3
	var/obj/structure/recieving_pad/beacon
	var/beacon_cooldown = 0
	var/datum/action/innate/beacon/B = new


/datum/guardian_abilities/heal/proc/plant_beacon()
	if(beacon_cooldown >= world.time)
		stando << "<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>"
		return

	var/turf/beacon_loc = get_turf(stando.loc)
	if(!isfloorturf(beacon_loc))
		return

	if(beacon)
		beacon.disappear()
		beacon = null

	beacon = new(beacon_loc, stando)

	stando << "<span class='danger'><B>Beacon placed! You may now warp targets and objects to it, including your user, via Alt+Click.</span></B>"

	beacon_cooldown = world.time + 3000


/datum/action/innate/beacon
	background_icon_state = "bg_alien"
	name = "Plant Beacon"
	button_icon_state = "set_drop"

/datum/action/innate/beacon/Activate()
	var/mob/living/simple_animal/hostile/guardian/A = owner
	for(var/datum/guardian_abilities/heal/I in A.current_abilities)
		I.plant_beacon()

/datum/guardian_abilities/heal/handle_stats()
	. = ..()
	stando.a_intent = INTENT_HARM
	stando.friendly = "heals"
	stando.speed -= 0.5
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.15
	stando.melee_damage_lower += 7
	stando.melee_damage_upper += 7
	stando.toggle_button_type = /obj/screen/guardian/ToggleMode
	B.Grant(stando)

	var/datum/atom_hud/medsensor = huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(stando)

/datum/guardian_abilities/heal/ability_act()
	if(..())
		if(toggle == TRUE)
			if(iscarbon(stando.target))
				var/mob/living/carbon/C = stando.target
				C.adjustBruteLoss(-5)
				C.adjustFireLoss(-5)
				C.adjustOxyLoss(-5)
				C.adjustToxLoss(-5)
				var/obj/effect/overlay/temp/heal/H = new /obj/effect/overlay/temp/heal(get_turf(C))
				if(stando.namedatum)
					H.color = stando.namedatum.colour
				if(C == user)
					stando.update_health_hud()
					stando.med_hud_set_health()
					stando.med_hud_set_status()

/datum/guardian_abilities/heal/handle_mode()
	if(stando.loc == user)
		if(toggle)
			stando.a_intent = initial(stando.a_intent)
			stando.speed = initial(stando.speed)
			stando.damage_coeff = initial_coeff
			stando.melee_damage_lower = initial(stando.melee_damage_lower)
			stando.melee_damage_upper = initial(stando.melee_damage_upper)
			stando << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			stando.a_intent = INTENT_HELP
			stando.speed = 1
			stando.damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			stando.melee_damage_lower = 0
			stando.melee_damage_upper = 0
			stando << "<span class='danger'><B>You switch to healing mode.</span></B>"
			toggle = TRUE
	else
		stando << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"

/datum/guardian_abilities/heal/alt_ability_act(atom/movable/A)
	if(!istype(A))
		return
	if(stando.loc == user)
		stando << "<span class='danger'><B>You must be manifested to warp a target!</span></B>"
		return
	if(!beacon)
		stando << "<span class='danger'><B>You need a beacon placed to warp things!</span></B>"
		return
	if(!stando.Adjacent(A))
		stando << "<span class='danger'><B>You must be adjacent to your target!</span></B>"
		return
	if(A.anchored)
		stando << "<span class='danger'><B>Your target cannot be anchored!</span></B>"
		return

	var/turf/T = get_turf(A)
	if(beacon.z != T.z)
		stando << "<span class='danger'><B>The beacon is too far away to warp to!</span></B>"
		return

	stando << "<span class='danger'><B>You begin to warp [A].</span></B>"
	A.visible_message("<span class='danger'>[A] starts to glow faintly!</span>", \
	"<span class='userdanger'>You start to glow faintly, and you feel strangely weightless!</span>")
	stando.do_attack_animation(A, null, 1)

	if(!do_mob(stando, A, 60)) //now start the channel
		stando << "<span class='danger'><B>You need to hold still!</span></B>"
		return

	new /obj/effect/overlay/temp/guardian/phase/out(T)
	if(isliving(A))
		var/mob/living/L = A
		L.flash_act()
	A.visible_message("<span class='danger'>[A] disappears in a flash of light!</span>", \
	"<span class='userdanger'>Your vision is obscured by a flash of light!</span>")
	do_teleport(A, beacon, 0)
	new /obj/effect/overlay/temp/guardian/phase(get_turf(A))

//metal pinky
/datum/guardian_abilities/dextrous
	value = 4

/datum/guardian_abilities/dextrous/handle_stats()
	. = ..()
	stando.dextrous = 1
	stando.environment_target_typecache = list(
	/obj/machinery/door/window,
	/obj/structure/window,
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/grille,
	/obj/structure/rack,
	/obj/structure/barricade,
	/obj/machinery/camera)
	stando.melee_damage_lower += 5
	stando.melee_damage_upper += 5
	for(var/i in stando.damage_coeff)
		stando.damage_coeff[i] -= 0.15

/datum/guardian_abilities/dextrous/recall_act(forced)
	if(!user || stando.loc == user || (cooldown > world.time && !forced) && stando.dextrous)
		return FALSE
	stando.drop_all_held_items()
	return 1 //lose items, then return

/datum/guardian_abilities/dextrous/snapback_act()
	if(user && !(get_dist(get_turf(user),get_turf(stando)) <= stando.range) && stando.dextrous)
		stando.drop_all_held_items()
		return 1 //lose items, then return

//T   H   E      W   O   R   L   D   .   -   Z   A      W   A   R   U   D   O   .
//somebody once told me the world was gonna roll me
/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian
	invocation = null
	summon_type = list(/obj/effect/timestop/wizard/guardian)
	clothes_req = 0

/datum/guardian_abilities/timestop
	value = 5

/datum/guardian_abilities/timestop/handle_stats()
	. = ..()
	var/obj/effect/proc_holder/spell/S = new/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian
	stando.mind.AddSpell(S)
	stando.melee_damage_lower += 5
	stando.melee_damage_upper += 5
	stando.obj_damage += 40
	stando.next_move_modifier -= 0.1 //attacks 10% faster

//prop hunt

/datum/guardian_abilities/shapeshift
	value = 4
	var/obj/item/remembered = null
	var/obj/item/host = null

/datum/guardian_abilities/shapeshift/recall_act()
	if(. = stando.Recall())
		if(host)
			qdel(host)

/datum/guardian_abilities/shapeshift/handle_stats()
	. = ..()
	stando.has_mode = TRUE
	stando.range += 3
	stando.melee_damage_lower += 3
	stando.melee_damage_upper += 3

/datum/guardian_abilities/shapeshift/alt_ability_act(obj/item/A)
	if(!istype(A))
		return
	if(stando.loc == user)
		stando << "<span class='danger'><B>You must be manifested to remember an item!</span></B>"
		return
	remembered = A.type
	stando << "<span class='danger'><B>You remember \the [remembered.name]!</span></B>"

/datum/guardian_abilities/shapeshift/handle_mode()
	if(!toggle)
		if(remembered)
			host = new remembered(get_turf(stando))
			stando.forceMove(host)
			stando.visible_message("<span class='danger'>[stando] twists into the shape of [host.name]!</span>")
			playsound(stando.loc, 'sound/weapons/draw_bow.ogg', 50, 1, 1)
			remembered = null
		else
			stando << "<span class='danger'><B>You don't have a remembered item!</span></B>"
			return
		toggle = TRUE
	else
		stando.forceMove(get_turf(stando))
		if(host)
			qdel(host)
		stando << "<span class='danger'><B>You twist back into your original form.</span></B>"
		toggle = FALSE

//ion man

/datum/guardian_abilities/ion/handle_stats()
	. = ..()
	stando.projectiletype = /obj/item/projectile/ion
	stando.ranged_cooldown_time = 5
	stando.ranged = 1
	stando.range += 3
	stando.melee_damage_lower += 3
	stando.melee_damage_upper += 3

/datum/guardian_abilities/ion/ability_act()
	empulse(stando.target, 1, 1)

//oingo boingo

/datum/guardian_abilities/bounce
	value = 1
	var/bounce_distance = 5

/datum/guardian_abilities/bounce/handle_stats()
	stando.range += 3
	stando.melee_damage_lower += 3
	stando.melee_damage_upper += 3

/datum/guardian_abilities/bounce/ability_act(atom/movable/A)
	var/atom/throw_target = get_edge_target_turf(A, stando.dir)
	A.throw_at(throw_target, bounce_distance, 14, stando) //interesting

/datum/guardian_abilities/bounce/boom_act(severity)
	stando.visible_message("<span class='danger'>The explosive force bounces off [stando]'s rubbery surface!</span>")
	for(var/mob/M in range(7,stando))
		if(M != user)
			M.ex_act(severity)
	return . = stando.ex_act()



