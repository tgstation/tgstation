/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by it's charge, ever vigilant."
	speak_emote = list("intones")
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/mob.dmi'
	icon_state = "guardian"
	icon_living = "guardian"
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	floating = 1
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	attacktext = "punches"
	maxHealth = 100000 //The spirit itself is invincible
	health = 100000
	environment_smash = 0
	melee_damage_lower = 15
	melee_damage_upper = 15
	var/cooldown = 0
	var/damage_transfer = 1 //how much damage from each attack we transfer to the owner
	var/mob/living/summoner
	var/range = 10 //how far from the user the spirit can be
	var/playstyle_string = "You are a standard Guardian. You shouldn't exist!"


/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	..()
	if(summoner)
		if(summoner.stat == DEAD)
			src << "Your summoner has died!"
			ghostize()
			qdel(src)
	else
		src << "No summoner!"
		ghostize()
		qdel(src)
	if(summoner)
		if (get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]"
			loc = get_turf(summoner)

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	..()
	if(summoner)
		if (get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			src << "You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]"
			loc = get_turf(summoner)



/mob/living/simple_animal/hostile/guardian/adjustBruteLoss(amount) //The spirit is invincible, but passes on damage to the summoner
	var/damage = amount * src.damage_transfer
	if (src.summoner)
		src.summoner.adjustBruteLoss(damage)
		if(damage)
			src.summoner << "<span class='danger'><B>Your [src.name] is under attack! You take damage!</span></B>"


//Manifest, Recall, Communicate

/mob/living/simple_animal/hostile/guardian/verb/Manifest()
	set name = "Manifest"
	set category = "Guardian"
	set desc = "Spring forth into battle!"
	if(cooldown > world.time)
		return
	if(src.loc == summoner)
		src.loc = get_turf(summoner)
		cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/verb/Recall()
	set name = "Recall"
	set category = "Guardian"
	set desc = "Return to your summoner."
	if(cooldown > world.time)
		return
	src.loc = summoner
	cooldown = world.time + 30

/mob/living/simple_animal/hostile/guardian/verb/Communicate()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your summoner."
	var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")

	for(var/mob/M in mob_list)
		if(M == src.summoner)
			M << "<span class='boldannounce'><i>[src]:</i> [input]</span>"

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")

	for(var/mob/living/simple_animal/hostile/guardian/M in mob_list)
		if(M.summoner == src)
			M << "<span class='boldannounce'><i>[src]:</i> [input]</span>"



//////////////////////////TYPES OF GUARDIANS


//Fire. Low damage, low resistance, sets mobs on fire when bumping

/mob/living/simple_animal/hostile/guardian/fire
	a_intent = "help"
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_sound = 'sound/items/Welder.ogg'
	attacktext = "sears"
	damage_transfer = 0.6
	range = 10
	playstyle_string = "As a fire type, you have only light damage resistance, but will ignite any enemy you bump into."
	environment_smash = 1

/mob/living/simple_animal/hostile/guardian/fire/Crossed(AM as mob|obj)
	if(istype(AM, /mob/living/))
		var/mob/living/M = AM
		if(AM != src.summoner)
			M.adjust_fire_stacks(10)
			M.IgniteMob()

//Standard

/mob/living/simple_animal/hostile/guardian/punch
	melee_damage_lower = 25
	melee_damage_upper = 25
	damage_transfer = 0.4
	playstyle_string = "As a standard type you have no special abilities, but have a high damage resistance and a powerful attack capable of smashing through walls."
	environment_smash = 2

//Fast Standard. Does less damage, has less resistance, but moves faster, has higher range

/mob/living/simple_animal/hostile/guardian/fast
	melee_damage_lower = 25
	melee_damage_upper = 25
	damage_transfer = 0.6
	speed = -1
	range = 15
	attack_sound = 'sound/weapons/bladeslice.ogg'
	playstyle_string = "As a fast standard type, you have no special abilities and only light damage resistance, but deal high damage at high speed."
	environment_smash = 1

//Defender. Does no damage, takes no damage, moves slowly.
/mob/living/simple_animal/hostile/guardian/shield
	melee_damage_lower = 0
	melee_damage_upper = 0
	speed = 1
	range = 10
	damage_transfer = 0
	friendly = "stares down"
	status_flags = CANPUSH
	playstyle_string = "As a defensive type, you are incapable of attacking and move slowly, but completely nullify any attack that hits you."

//Scout. No damage, high range, high mobility, low resistance

/mob/living/simple_animal/hostile/guardian/scout
	ventcrawler = 1
	range = 255
	incorporeal_move = 1
	damage_transfer = 1.2
	melee_damage_lower = 0
	melee_damage_upper = 0
	alpha = 100
	friendly = "quietly assesses"
	playstyle_string = "As a scout type, you are incapable of attacking, but have infinite range, can pass through walls, and crawl through vents."

//Healer

/mob/living/simple_animal/hostile/guardian/healer
	a_intent = "help"
	friendly = "heals"
	melee_damage_lower = 0
	melee_damage_upper = 0
	playstyle_string = "As a healer type, you are incapable of attacking, but can mend any wound simply by touching a target."

/mob/living/simple_animal/hostile/guardian/healer/AttackingTarget()
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(-5)
		C.adjustFireLoss(-5)
		C.adjustOxyLoss(-5)
		C.adjustToxLoss(-5)

/mob/living/simple_animal/hostile/guardian/ranged
	a_intent = "help"
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_transfer = 1.2
	projectiletype = /obj/item/projectile/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	rapid = 1
	range = 13
	playstyle_string = "As a ranged type, you have only light damage resistance, but are capable of spraying neurotoxin."

/mob/living/simple_animal/hostile/guardian/bluespace
	ranged = 1
	range = 15
	melee_damage_lower = 10
	melee_damage_upper = 10
	speed = -1
	projectiletype = /obj/item/projectile/magic/teleport
	projectilesound = 'sound/weapons/emitter.ogg'
	playstyle_string = "As a bluespace type, you have only light damage resistance, but are capable of shooting teleporation bolts as well as flinging enemies away with your standard attack."

/mob/living/simple_animal/hostile/guardian/bluespace/AttackingTarget()
	..()
	if(target != anchored && target != src.summoner)
		do_teleport(target, target, 10)





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

/obj/item/weapon/guardiancreator/attack_self(mob/living/user)
	if(used == TRUE)
		user << "[used_message]"
		return
	used = TRUE
	user << "[use_message]"
	var/list/candidates = get_candidates(BE_ALIEN, ALIEN_AFK_BRACKET)

	shuffle(candidates)

	var/time_passed = world.time
	var/list/consenting_candidates = list()

	for(var/candidate in candidates)

		spawn(0)
			switch(alert(candidate, "Would you like to play as the [mob_name] of [user.real_name]? Please choose quickly!","Confirmation","Yes","No"))
				if("Yes")
					if((world.time-time_passed)>=50 || !src)
						return
					consenting_candidates += candidate

	sleep(50)

	if(!src)
		return

	if(consenting_candidates.len)
		var/client/C = null
		C = pick(consenting_candidates)
		spawn_guardian(user, C.key)
	else
		user << "[failure_message]"
		used = FALSE


/obj/item/weapon/guardiancreator/proc/spawn_guardian(var/mob/living/user, var/key)
	var/gaurdiantype = pick("Fire", "Standard", "Scout", "Shield", "Ranged", "Healer", "Fast")
	var/pickedtype = /mob/living/simple_animal/hostile/guardian/punch
	var/picked_color = randomColor(0)
	switch(gaurdiantype)

		if("Fire")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fire
			switch (theme)
				if("magic")
					user << "..And draw Atmosia, bringer of cleansing fires!"
				if("tech")
					user << "Boot sequence complete. Incendiary combat modules loaded. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, capable of igniting enemies on touch."

		if("Standard")
			pickedtype = /mob/living/simple_animal/hostile/guardian/punch
			switch (theme)
				if("magic")
					user << "..And draw the Assistant, faceless and generic, but never to be underestimated."
				if("tech")
					user << "Boot sequence complete. Standard combat modules loaded. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm stirs to life, ready to tear apart your enemies."

		if("Scout")
			pickedtype = /mob/living/simple_animal/hostile/guardian/scout
			switch (theme)
				if("magic")
					user << "..And draw the AI, all seeing and all knowing."
				if("tech")
					user << "Boot sequence complete. Surveillance modules loaded. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, helpless, but near invsible, and capable of near unlimited travel."

		if("Shield")
			pickedtype = /mob/living/simple_animal/hostile/guardian/shield
			switch (theme)
				if("magic")
					user << "..And draw the Juggernaut, an invincible, unstoppable force."
				if("tech")
					user << "Boot sequence complete. Defensive modules active. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, helpless, but invulnerable."

		if("Ranged")
			pickedtype = /mob/living/simple_animal/hostile/guardian/ranged
			switch (theme)
				if("magic")
					user << "..And draw the Sentinel, an alien master of ranged combat."
				if("tech")
					user << "Boot sequence complete. Ranged combat modules active. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, capable of spitting neurotoxin."
		if("Healer")
			pickedtype = /mob/living/simple_animal/hostile/guardian/healer
			switch (theme)
				if("magic")
					user << "..And draw the CMO, a potent force of life and health."
				if("tech")
					user << "Boot sequence complete. Medical modules active. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, capable of mending wounds."

		if("Fast")
			pickedtype = /mob/living/simple_animal/hostile/guardian/fast
			switch (theme)
				if("magic")
					user << "..And draw the Shoes, bringer of great speed. The card is badly damaged, and barely legible."
				if("tech")
					user << "Boot sequence complete. High speed combat modules active. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, capable of moving at blinding speed."

		if("Bluespace")
			pickedtype = /mob/living/simple_animal/hostile/guardian/bluespace
			switch (theme)
				if("magic")
					user << "..And draw the Wizard, master of teleportation."
				if("tech")
					user << "Boot sequence complete. Experimental bluespace combat modules active. Nanoswarm online."
				if("bio")
					user << "Your scarab swarm finishes mutating and stirs to life, crackling with bluespace energy."


	var/mob/living/simple_animal/hostile/guardian/G = new pickedtype(user)
	G.summoner = user
	G.key = key
	G.name = "[color][mob_name]"
	G.real_name = "[color][mob_name]"
	G.color = color2hex(picked_color)
	G << "You are a [mob_name] bound to serve [user.real_name]."
	G << "You are capable of manifesting or recalling to your master with verbs in the Guardian tab. You will also find a verb to communicate with them privately there."
	G << "While personally invincible, you will die if [user.real_name] does, and any damage dealt to you will have a portion passed on to them as you feed upon them to sustain yourself."
	G << "[G.playstyle_string]"
	user.verbs += /mob/living/proc/guardian_comm


/obj/item/weapon/guardiancreator/tech
	name = "parasitic nanomachine injector"
	desc = "Though powerful in combat, these nanomachines require a living host as a source of fuel and home base."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Nanomachine Swarm"
	use_message = "You start to power on the injector..."
	used_message = "The injector has already been used."
	failure_message = "<B>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</B>"



/obj/item/weapon/guardiancreator/biological
	name = "scarab egg cluster"
	desc = "A parasitic species that will nest in the closest living creature upon birth. While not great for your health, they'll defend their new 'hive' to the death."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "bio"
	mob_name = "Scarab Swarm"
	use_message = "The egs begin to twitch..."
	used_message = "The cluster already hatched."
	failure_message = "<B>...but soon settles again. Guess they weren't ready to hatch after all.</B>"