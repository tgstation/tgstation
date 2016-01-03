/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by it's charge, ever vigilant."
	speak_emote = list("hisses")
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "guardianorange"
	icon_living = "guardianorange"
	icon_dead = "stand"
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	floating = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	environment_smash = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	butcher_results = list(/obj/item/weapon/ectoplasm = 1)
	AIStatus = AI_OFF
	var/cooldown = 0
	var/damage_transfer = 1 //how much damage from each attack we transfer to the owner
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/playstyle_string = "You are a standard Guardian. You shouldn't exist!"
	var/magic_fluff_string = " You draw the Coder, symbolizing bugs and errors. This shouldn't happen! Submit a bug report!"
	var/tech_fluff_string = "BOOT SEQUENCE COMPLETE. ERROR MODULE LOADED. THIS SHOULDN'T HAPPEN. Submit a bug report!"

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	..()
	if(summoner)
		if(summoner.stat == DEAD)
			src << "<span class='danger'>Your summoner has died!</span>"
			visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
			summoner.visible_message("<span class='danger'><B>[summoner]'s body is completely consumed by the strain of sustaining [src]!</B></span>")
			for(var/obj/item/W in summoner)
				if(!summoner.unEquip(W))
					qdel(W)
			summoner.dust()
			ghostize()
			qdel(src)
	else
		src << "<span class='danger'>Your summoner has died!</span>"
		visible_message("<span class='danger'><B>The [src] dies along with its user!</B></span>")
		ghostize()
		qdel(src)
	if(summoner)
		if (get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]"
			visible_message("<span class='danger'>The [src] jumps back to its user.</span>")
			loc = get_turf(summoner)

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	..()
	if(summoner)
		if (get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]"
			visible_message("<span class='danger'>The [src] jumps back to its user.</span>")
			loc = get_turf(summoner)

/mob/living/mob/living/simple_animal/hostile/guardian/canSuicide()
	return 0

/mob/living/simple_animal/hostile/guardian/death()
	..()
	summoner << "<span class='danger'><B>Your [name] died somehow!</span></B>"
	summoner.death()

/mob/living/simple_animal/hostile/guardian/adjustBruteLoss(amount) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * damage_transfer
	if (summoner)
		if(loc == summoner)
			return
		summoner.adjustBruteLoss(damage)
		if(damage)
			summoner << "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>"
			summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
		if(summoner.stat == UNCONSCIOUS)
			summoner << "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>"
			summoner.adjustCloneLoss(damage/2)

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch (severity)
		if (1)
			gib()
			return
		if (2)
			adjustBruteLoss(60)

		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		summoner << "<span class='danger'><B>Your [src] was blown up!</span></B>"
		summoner.gib()
	ghostize()
	qdel(src)

//Manifest, Recall, Communicate

/mob/living/simple_animal/hostile/guardian/proc/Manifest()
	if(cooldown > world.time)
		return
	if(loc == summoner)
		loc = get_turf(summoner)
		cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Recall()
	if(cooldown > world.time)
		return
	loc = summoner
	buckled = null
	cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
	if(!input) return

	for(var/mob/M in mob_list)
		if(M == summoner || (M in dead_mob_list))
			M << "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	src << "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	log_say("[src.real_name]/[src.key] : [input]")

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	src << "<span class='danger'><B>You dont have another mode!</span></B>"


/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input) return

	for(var/mob/M in mob_list)
		if(istype (M, /mob/living/simple_animal/hostile/guardian))
			var/mob/living/simple_animal/hostile/guardian/G = M
			if(G.summoner == src)
				G << "<span class='boldannounce'><i>[src]:</i> [input]</span>"
		else if (M in dead_mob_list)
			M << "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	src << "<span class='boldannounce'><i>[src]:</i> [input]</span>"
	log_say("[src.real_name]/[src.key] : [text]")


/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use."

	src.verbs -= /mob/living/proc/guardian_reset
	for(var/mob/living/simple_animal/hostile/guardian/G in mob_list)
		if(G.summoner == src)
			var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [G.real_name]?", "pAI", null, FALSE, 100)
			var/mob/dead/observer/new_stand = null
			if(candidates.len)
				new_stand = pick(candidates)
				G << "Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance."
				src << "Your guardian has been successfully reset."
				message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(G)])")
				G.ghostize(0)
				G.key = new_stand.key
			else
				src << "There were no ghosts willing to take control. Looks like you're stuck with your Guardian for now."
				verbs += /mob/living/proc/guardian_reset

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(!luminosity)
		SetLuminosity(3)
	else
		SetLuminosity(0)


//////////////////////////TYPES OF GUARDIANS


//Fire. Low damage, low resistance, sets mobs on fire when bumping

/mob/living/simple_animal/hostile/guardian/fire
	a_intent = "help"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/Welder.ogg'
	attacktext = "sears"
	damage_transfer = 0.8
	range = 10
	playstyle_string = "As a Chaos type, you have only light damage resistance, but will ignite any enemy you bump into. In addition, your melee attacks will randomly teleport enemies."
	environment_smash = 1
	magic_fluff_string = "..And draw the Wizard, bringer of endless chaos!"
	tech_fluff_string = "Boot sequence complete. Crowd control modules activated. Holoparasite swarm online."

/mob/living/simple_animal/hostile/guardian/fire/Life() //Dies if the summoner dies
	..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	..()
	if(prob(45))
		if(istype(target, /atom/movable))
			var/atom/movable/M = target
			if(!M.anchored && M != summoner)
				do_teleport(M, M, 10)

/mob/living/simple_animal/hostile/guardian/fire/Crossed(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(AM as mob|obj)
	if(istype(AM, /mob/living/))
		var/mob/living/M = AM
		if(AM != summoner && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)
//Standard

/mob/living/simple_animal/hostile/guardian/punch
	melee_damage_lower = 20
	melee_damage_upper = 20
	damage_transfer = 0.5
	playstyle_string = "As a standard type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls."
	environment_smash = 2
	magic_fluff_string = "..And draw the Assistant, faceless and generic, but never to be underestimated."
	tech_fluff_string = "Boot sequence complete. Standard combat modules loaded. Holoparasite swarm online."
	var/battlecry = "AT"

/mob/living/simple_animal/hostile/guardian/punch/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch"
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 5 characters.", ,"", 6)
	if(input)
		battlecry = input



/mob/living/simple_animal/hostile/guardian/punch/AttackingTarget()
	..()
	if(istype(target, /mob/living))
		src.say("[src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry]\
		[src.battlecry][src.battlecry][src.battlecry][src.battlecry][src.battlecry]")
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)
		playsound(loc, src.attack_sound, 50, 1, 1)

//Healer

/mob/living/simple_animal/hostile/guardian/healer
	a_intent = "harm"
	friendly = "heals"
	speed = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	playstyle_string = "As a Support type, you may toggle your basic attacks to a healing mode. In addition, Alt-Clicking on an adjacent mob will warp them to your bluespace beacon after a short delay."
	magic_fluff_string = "..And draw the CMO, a potent force of life...and death."
	tech_fluff_string = "Boot sequence complete. Medical modules active. Bluespace modules activated. Holoparasite swarm online."
	var/turf/simulated/floor/beacon
	var/beacon_cooldown = 0
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/healer/New()
	..()
	var/datum/atom_hud/medsensor = huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	..()
	if(toggle == TRUE)
		if(src.loc == summoner)
			src << "<span class='danger'><B>You must be manifested to heal!</span></B>"
			return
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			C.adjustBruteLoss(-5)
			C.adjustFireLoss(-5)
			C.adjustOxyLoss(-5)
			C.adjustToxLoss(-5)

/mob/living/simple_animal/hostile/guardian/healer/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			a_intent = "harm"
			speed = 0
			damage_transfer = 0.7
			melee_damage_lower = 15
			melee_damage_upper = 15
			src << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			a_intent = "help"
			speed = 1
			damage_transfer = 1
			melee_damage_lower = 0
			melee_damage_upper = 0
			src << "<span class='danger'><B>You switch to healing mode.</span></B>"
			toggle = TRUE
	else
		src << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"


/mob/living/simple_animal/hostile/guardian/healer/verb/Beacon()
	set name = "Place Bluespsace Beacon"
	set category = "Guardian"
	set desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon will not work in unfavorable atmospheric conditions."
	if(beacon_cooldown<world.time)
		var/turf/beacon_loc = get_turf(src.loc)
		if(istype(beacon_loc, /turf/simulated/floor))
			var/turf/simulated/floor/F = beacon_loc
			F.icon = 'icons/turf/floors.dmi'
			F.name = "bluespace recieving pad"
			F.desc = "A recieving zone for bluespace teleportations. Building a wall over it should disable it."
			F.icon_state = "light_on-w"
			src << "<span class='danger'><B>Beacon placed! You may now warp targets to it, including your user, via Alt+Click. </span></B>"
			if(beacon)
				beacon.ChangeTurf(/turf/simulated/floor/plating)
			beacon = F
			beacon_cooldown = world.time+3000

	else
		src << "<span class='danger'><B>Your power is on cooldown. You must wait five minutes between placing beacons.</span></B>"

/mob/living/simple_animal/hostile/guardian/healer/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		src << "<span class='danger'><B>You must be manifested to warp a target!</span></B>"
		return
	if(!beacon)
		src << "<span class='danger'><B>You need a beacon placed to warp things!</span></B>"
		return
	if(!Adjacent(A))
		src << "<span class='danger'><B>You must be adjacent to your target!</span></B>"
		return
	if((A.anchored))
		src << "<span class='danger'><B>Your target can not be anchored!</span></B>"
		return
	src << "<span class='danger'><B>You begin to warp [A]</span></B>"
	if(do_mob(src, A, 50))
		if(!A.anchored)
			if(src.beacon) //Check that the beacon still exists and is in a safe place. No instant kills.
				if(beacon.air)
					var/datum/gas_mixture/Z = beacon.air
					var/list/Z_gases = Z.gases
					var/trace_gases = FALSE

					for(var/id in Z_gases)
						if(id in hardcoded_gases)
							continue
						trace_gases = TRUE
						break
					if((Z_gases["o2"] && Z_gases["o2"][MOLES] >= 16) && !Z_gases["plasma"] && (!Z_gases["co2"] || Z_gases["co2"][MOLES] < 10) && !trace_gases)
						if((Z.temperature > 270) && (Z.temperature < 360))
							var/pressure = Z.return_pressure()
							if((pressure > 20) && (pressure < 550))
								do_teleport(A, beacon, 0)
						else
							src << "<span class='danger'><B>The beacon isn't in a safe location!</span></B>"
					else
						src << "<span class='danger'><B>The beacon isn't in a safe location!</span></B>"
			else
				src << "<span class='danger'><B>You need a beacon to warp things!</span></B>"
	else
		src << "<span class='danger'><B>You need to hold still!</span></B>"


///////////////////Ranged

/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100

/mob/living/simple_animal/hostile/guardian/ranged
	a_intent = "help"
	friendly = "quietly assesses"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 0.9
	projectiletype = /obj/item/projectile/guardian
	ranged_cooldown_cap = 0
	projectilesound = 'sound/effects/hit_on_shattered_glass.ogg'
	ranged = 1
	range = 13
	playstyle_string = "As a ranged type, you have only light damage resistance, but are capable of spraying shards of crystal at incredibly high speed. You can also deploy surveillance snares to monitor enemy movement. Finally, you can switch to scout mode, in which you can't attack, but can move without limit."
	magic_fluff_string = "..And draw the Sentinel, an alien master of ranged combat."
	tech_fluff_string = "Boot sequence complete. Ranged combat modules active. Holoparasite swarm online."
	var/list/snares = list()
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/ranged/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			ranged = 1
			melee_damage_lower = 10
			melee_damage_upper = 10
			alpha = 255
			range = 13
			incorporeal_move = 0
			src << "<span class='danger'><B>You switch to combat mode.</span></B>"
			toggle = FALSE
		else
			ranged = 0
			melee_damage_lower = 0
			melee_damage_upper = 0
			alpha = 60
			range = 255
			incorporeal_move = 1
			src << "<span class='danger'><B>You switch to scout mode.</span></B>"
			toggle = TRUE
	else
		src << "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>"

/mob/living/simple_animal/hostile/guardian/ranged/verb/Snare()
	set name = "Set Surveillance Trap"
	set category = "Guardian"
	set desc = "Set an invisible trap that will alert you when living creatures walk over it. Max of 5"
	if(src.snares.len <6)
		var/turf/snare_loc = get_turf(src.loc)
		var/obj/item/effect/snare/S = new /obj/item/effect/snare(snare_loc)
		S.spawner = src
		S.name = "[get_area(snare_loc)] trap ([rand(1, 1000)])"
		src.snares |= S
		src << "<span class='danger'><B>Surveillance trap deployed!</span></B>"
	else
		src << "<span class='danger'><B>You have too many traps deployed. Delete some first.</span></B>"

/mob/living/simple_animal/hostile/guardian/ranged/verb/DisarmSnare()
	set name = "Remove Surveillance Trap"
	set category = "Guardian"
	set desc = "Disarm unwanted surveillance traps."
	var/picked_snare = input(src, "Pick which trap to disarm", "Disarm Trap") as null|anything in src.snares
	if(picked_snare)
		src.snares -= picked_snare
		qdel(picked_snare)
		src << "<span class='danger'><B>Snare disarmed.</span></B>"

/obj/item/effect/snare
	name = "snare"
	desc = "You shouldn't be seeing this!"
	var/mob/living/spawner
	invisibility = 1


/obj/item/effect/snare/Crossed(AM as mob|obj)
	if(istype(AM, /mob/living/))
		var/turf/snare_loc = get_turf(src.loc)
		if(spawner)
			spawner << "<span class='danger'><B>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span></B>"
			if(istype(spawner, /mob/living/simple_animal/hostile/guardian))
				var/mob/living/simple_animal/hostile/guardian/G = spawner
				if(G.summoner)
					G.summoner << "<span class='danger'><B>[AM] has crossed your surveillance trap at [get_area(snare_loc)].</span></B>"

////Bomb

/mob/living/simple_animal/hostile/guardian/bomb
	melee_damage_lower = 15
	melee_damage_upper = 15
	damage_transfer = 0.6
	range = 13
	playstyle_string = "As an explosive type, you have only moderate close combat abilities, but are capable of converting any adjacent item into a disguised bomb via alt click."
	magic_fluff_string = "..And draw the Scientist, master of explosive death."
	tech_fluff_string = "Boot sequence complete. Explosive modules active. Holoparasite swarm online."
	var/bomb_cooldown = 0

/mob/living/simple_animal/hostile/guardian/bomb/AltClickOn(atom/movable/A)
	if(!istype(A))
		return
	if(src.loc == summoner)
		src << "<span class='danger'><B>You must be manifested to create bombs!</span></B>"
		return
	if(istype(A, /obj/))
		if(bomb_cooldown <= world.time && !stat)
			var/obj/item/weapon/guardian_bomb/B = new /obj/item/weapon/guardian_bomb(get_turf(A))
			src << "<span class='danger'><B>Success! Bomb armed!</span></B>"
			bomb_cooldown = world.time + 200
			B.spawner = src
			B.disguise (A)
		else
			src << "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</span></B>"

/obj/item/weapon/guardian_bomb
	name = "bomb"
	desc = "You shouldn't be seeing this!"
	var/obj/stored_obj
	var/mob/living/spawner


/obj/item/weapon/guardian_bomb/proc/disguise(var/obj/A)
	A.loc = src
	stored_obj = A
	anchored = A.anchored
	density = A.density
	appearance = A.appearance
	spawn(600)
		stored_obj.loc = get_turf(src.loc)
		spawner << "<span class='danger'><B>Failure! Your trap didn't catch anyone this time.</span></B>"
		qdel(src)

/obj/item/weapon/guardian_bomb/proc/detonate(var/mob/living/user)
	user << "<span class='danger'><B>The [src] was boobytrapped!</span></B>"
	spawner << "<span class='danger'><B>Success! Your trap caught [user]</span></B>"
	stored_obj.loc = get_turf(src.loc)
	playsound(get_turf(src),'sound/effects/Explosion2.ogg', 200, 1)
	user.ex_act(2)
	qdel(src)

/obj/item/weapon/guardian_bomb/attackby(mob/living/user)
	detonate(user)
	return

/obj/item/weapon/guardian_bomb/pickup(mob/living/user)
	detonate(user)
	return

/obj/item/weapon/guardian_bomb/examine(mob/user)
	stored_obj.examine(user)
	if(get_dist(user,src)<=2)
		user << "<span class='notice'>Looks odd!</span>"


////////Creation

/obj/item/weapon/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/used = FALSE
	var/theme = "magic"
	var/mob_name = "Guardian Spirit"
	var/use_message = "You shuffle the deck..."
	var/used_message = "All the cards seem to be blank now."
	var/failure_message = "..And draw a card! It's...blank? Maybe you should try again later."
	var/ling_failure = "The deck refuses to respond to a souless creature such as you."
	var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive")
	var/random = TRUE

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	for(var/mob/living/simple_animal/hostile/guardian/G in living_mob_list)
		if (G.summoner == user)
			user << "You already have a [mob_name]!"
			return
	if(user.mind && user.mind.changeling)
		user << "[ling_failure]"
		return
	if(used == TRUE)
		user << "[used_message]"
		return
	used = TRUE
	user << "[use_message]"
	var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_PAI, null, FALSE, 100)
	var/mob/dead/observer/theghost = null

	if(candidates.len)
		theghost = pick(candidates)
		spawn_guardian(user, theghost.key)
	else
		user << "[failure_message]"
		used = FALSE


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/gaurdiantype = "Standard"
	if(random)
		gaurdiantype = pick(possible_guardians)
	else
		gaurdiantype = input(user, "Pick the type of [mob_name]", "[mob_name] Creation") as null|anything in possible_guardians
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	switch(gaurdiantype)

		if("Chaos")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged

		if("Support")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer

		if("Explosive")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bomb

	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user)
	G.summoner = user
	G.key = key
	G << "You are a [mob_name] bound to serve [user.real_name]."
	G << "You are capable of manifesting or recalling to your master with verbs in the Guardian tab. You will also find a verb to communicate with them privately there."
	G << "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself."
	G << "[G.playstyle_string]"
	G.faction = user.faction
	user.verbs += /mob/living/proc/guardian_comm
	user.verbs += /mob/living/proc/guardian_recall
	user.verbs += /mob/living/proc/guardian_reset

	var/picked_name = pick("Aries", "Leo", "Sagittarius", "Taurus", "Virgo", "Capricorn", "Gemini", "Libra", "Aquarius", "Cancer", "Scorpio", "Pisces")
	var/colour = pick("orange", "pink", "red", "blue", "green")
	G.name = "[picked_name] [capitalize(colour)]"
	G.real_name = "[picked_name] [capitalize(colour)]"
	G.icon_living = "guardian[colour]"
	G.icon_state = "guardian[colour]"
	G.icon_dead = "guardian[colour]"

	switch (theme)
		if("magic")
			user << "[G.magic_fluff_string]."
		if("tech")
			user << "[G.tech_fluff_string]."
	G.mind.name = "[G.real_name]"

/obj/item/weapon/guardiancreator/choose
	random = FALSE

/obj/item/weapon/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "You start to power on the injector..."
	used_message = "The injector has already been used."
	failure_message = "<B>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</B>"
	ling_failure = "The holoparasites recoil in horror. They want nothing to do with a creature like you."

/obj/item/weapon/guardiancreator/tech/choose
	random = FALSE

/obj/item/weapon/paper/guardian
	name = "Holoparasite Guide"
	icon_state = "alienpaper_words"
	info = {"<b>A list of Holoparasite Types</b><br>

 <br>
 <b>Chaos</b>: Ignites mobs on touch. teleports them at random on attack. Automatically extinguishes the user if they catch fire.<br>
 <br>
 <b>Standard</b>:Devestating close combat attacks and high damage resist. No special powers.<br>
 <br>
 <b>Ranged</b>: Has two modes. Ranged: Extremely weak, highly spammable projectile attack. Scout: Can not attack, but can move through walls. Can lay surveillance snares in either mode.<br>
 <br>
 <b>Support</b>:Has two modes. Combat: Medium power attacks and damage resist. Healer: Attacks heal damage, but low damage resist and slow movemen. Can deploy a bluespace beacon and warp targets to it (including you) in either mode.<br>
 <br>
 <b>Explosive</b>: High damage resist and medium power attack. Can turn any object into a bomb, dealing explosive damage to the next person to touch it. The object will return to normal after the trap is triggered.<br>
"}

/obj/item/weapon/paper/guardian/update_icon()
	return


/obj/item/weapon/storage/box/syndie_kit/guardian
	name = "holoparasite injector kit"

/obj/item/weapon/storage/box/syndie_kit/guardian/New()
	..()
	new /obj/item/weapon/guardiancreator/tech/choose(src)
	new /obj/item/weapon/paper/guardian(src)
	return


///HUD

/datum/hud/proc/guardian_hud(ui_style = 'icons/mob/screen_midnight.dmi')
	adding = list()

	var/obj/screen/using

	using = new /obj/screen/guardian/Manifest()
	using.screen_loc = ui_rhand
	adding += using

	using = new /obj/screen/guardian/Recall()
	using.screen_loc = ui_lhand
	adding += using

	using = new /obj/screen/guardian/ToggleMode()
	using.screen_loc = ui_storage1
	adding += using

	using = new /obj/screen/guardian/ToggleLight()
	using.screen_loc = ui_inventory
	adding += using

	using = new /obj/screen/guardian/Communicate()
	using.screen_loc = ui_back
	adding += using

	mymob.client.screen = list()
	mymob.client.screen += mymob.client.void
	mymob.client.screen += adding


//HUD BUTTONS

/obj/screen/guardian
	icon = 'icons/mob/guardian.dmi'

/obj/screen/guardian/Manifest
	icon_state = "manifest"
	name = "Manifest"
	desc = "Spring forth into battle!"

/obj/screen/guardian/Manifest/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Manifest()


/obj/screen/guardian/Recall
	icon_state = "recall"
	name = "Recall"
	desc = "Return to your user."

/obj/screen/guardian/Recall/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Recall()

/obj/screen/guardian/ToggleMode
	icon_state = "toggle"
	name = "Toggle Mode"
	desc = "Switch between ability modes."

/obj/screen/guardian/ToggleMode/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleMode()

/obj/screen/guardian/Communicate
	icon_state = "communicate"
	name = "Communicate"
	desc = "Communicate telepathically with your user."

/obj/screen/guardian/Communicate/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.Communicate()


/obj/screen/guardian/ToggleLight
	icon_state = "light"
	name = "Toggle Light"
	desc = "Glow like star dust."

/obj/screen/guardian/ToggleLight/Click()
	if(isguardian(usr))
		var/mob/living/simple_animal/hostile/guardian/G = usr
		G.ToggleLight()
