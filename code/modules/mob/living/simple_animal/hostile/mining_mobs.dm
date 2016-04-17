/mob/living/simple_animal/hostile/asteroid/
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("mining")
	environment_smash = 2
	minbodytemp = 0
	maxbodytemp = INFINITY
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = "harm"
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	if(vision_range != aggro_vision_range)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	icon_state = icon_living

/mob/living/simple_animal/hostile/asteroid/bullet_act(obj/item/projectile/P)//Reduces damage from most projectiles to curb off-screen kills
	if(!stat)
		Aggro()
	if(P.damage < 30 && P.damage_type != BRUTE)
		P.damage = (P.damage / 3)
		visible_message("<span class='danger'>[P] has a reduced effect on [src]!</span>")
	..()

/mob/living/simple_animal/hostile/asteroid/hitby(atom/movable/AM)//No floor tiling them to death, wiseguy
	if(istype(AM, /obj/item))
		var/obj/item/T = AM
		if(!stat)
			Aggro()
		if(T.throwforce <= 20)
			visible_message("<span class='notice'>The [T.name] [src.throw_message] [src.name]!</span>")
			return
	..()

/mob/living/simple_animal/hostile/asteroid/death(gibbed)
	feedback_add_details("mobs_killed_mining","[src.type]")
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/item/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	ranged_cooldown_time = 30
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = "harm"
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	aggro_vision_range = 9
	idle_vision_range = 2
	turns_per_move = 5
	loot = list(/obj/item/weapon/ore/diamond{layer = 4.1},
				/obj/item/weapon/ore/diamond{layer = 4.1})

/obj/item/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target))
			var/mob/living/L = target
			if(L.bodytemperature > 200)
				L.bodytemperature = 200
				visible_message("<span class='danger'>The [src.name]'s stare chills [L.name] to the bone!</span>")

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
		if(2)
			adjustBruteLoss(140)
		if(3)
			adjustBruteLoss(110)

/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 2
	aggro_vision_range = 9
	idle_vision_range = 2
	move_to_delay = 5
	friendly = "harmlessly rolls into"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "barrels into"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = "help"
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/uranium)

	var/chase_time = 100

/mob/living/simple_animal/hostile/asteroid/goldgrub/New()
	..()
	deathmessage = "[src] spits up the contents of its stomach before dying!"
	var/i = rand(1,3)
	while(i)
		loot += pick(/obj/item/weapon/ore/silver, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/uranium, /obj/item/weapon/ore/diamond)
		i--

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	target = new_target
	if(target != null)
		if(istype(target, /obj/item/weapon/ore) && loot.len < 10)
			visible_message("<span class='notice'>The [src.name] looks at [target.name] with hungry eyes.</span>")
		else if(isliving(target))
			Aggro()
			visible_message("<span class='danger'>The [src.name] tries to flee from [target.name]!</span>")
			retreat_distance = 10
			minimum_distance = 10
			spawn(chase_time)
				Burrow()

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		EatOre(target)
		return
	..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(atom/targeted_ore)
	for(var/obj/item/weapon/ore/O in targeted_ore.loc)
		if(loot.len < 10)
			loot += O.type
			qdel(O)
	visible_message("<span class='notice'>The ore was swallowed whole!</span>")

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//Begin the chase to kill the goldgrub in time
	if(!stat)
		visible_message("<span class='danger'>The [src.name] buries into the ground, vanishing from sight!</span>")
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>The [P.name] was repelled by [src.name]'s girth!</span>")
	return

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(damage)
	idle_vision_range = 9
	. = ..()

/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelord"
	icon_living = "Hivelord"
	icon_aggro = "Hivelord_alert"
	icon_dead = "Hivelord_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 14
	ranged = 1
	vision_range = 5
	aggro_vision_range = 9
	idle_vision_range = 5
	speed = 3
	maxHealth = 75
	health = 75
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "lashes out at"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "falls right through the strange body of the"
	ranged_cooldown = 0
	ranged_cooldown_time = 20
	environment_smash = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE
	loot = list(/obj/item/organ/internal/hivelord_core)
	var/brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(the_target)
	if(world.time >= ranged_cooldown)
		var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = new brood_type(src.loc)
		A.GiveTarget(target)
		A.friends = friends
		A.faction = faction
		ranged_cooldown = world.time + ranged_cooldown_time
	return

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()

/mob/living/simple_animal/hostile/asteroid/hivelord/death(gibbed)
	mouse_opacity = 1
	..(gibbed)

/obj/item/organ/internal/hivelord_core
	name = "hivelord remains"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly."
	icon_state = "roro core 2"
	flags = NOBLUDGEON
	slot = "hivecore"
	force = 0
	var/inert = 0
	var/preserved = 0

/obj/item/organ/internal/hivelord_core/New()
	..()
	spawn(2400)
		if(!owner && !preserved)
			inert = 1
			desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."
		else
			preserved = 1

/obj/item/organ/internal/hivelord_core/on_life()
	..()
	if(owner)
		owner.adjustBruteLoss(-1)
		owner.adjustFireLoss(-1)
		owner.adjustOxyLoss(-2)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/datum/reagent/blood/B = locate() in H.vessel.reagent_list //Grab some blood
		var/blood_volume = round(H.vessel.get_reagent_amount("blood"))
		if(B && blood_volume < 560 && blood_volume)
			B.volume += 2 // Fast blood regen

/obj/item/organ/internal/hivelord_core/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			user << "<span class='notice'>[src] have become inert, its healing properties are no more.</span>"
			return
		else
			if(H.stat == DEAD)
				user << "<span class='notice'>[src] are useless on the dead.</span>"
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... they quickly regenerate all injuries!")
			else
				user << "<span class='notice'>You start to smear [src] on yourself. It feels and smells disgusting, but you feel amazingly refreshed in mere moments.</span>"
			H.revive(full_heal = 1)
			qdel(src)
	..()

/obj/item/organ/internal/hivelord_core/prepare_eat()
	return null

/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Hivelordbrood"
	icon_living = "Hivelordbrood"
	icon_aggro = "Hivelordbrood"
	icon_dead = "Hivelordbrood"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 1
	friendly = "buzzes near"
	vision_range = 10
	speed = 3
	maxHealth = 1
	health = 1
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "falls right through the strange body of the"
	environment_smash = 0
	pass_flags = PASSTABLE
	del_on_death = 1

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/New()
	..()
	spawn(100)
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
	attack_sound = 'sound/weapons/punch4.ogg'
	mouse_opacity = 2
	move_to_delay = 40
	ranged = 1
	ranged_cooldown_time = 120
	friendly = "wails at"
	speak_emote = list("bellows")
	vision_range = 4
	speed = 3
	maxHealth = 300
	health = 300
	harm_intent_damage = 0
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	aggro_vision_range = 9
	idle_vision_range = 5
	anchored = 1 //Stays anchored until death as to be unpullable
	mob_size = MOB_SIZE_LARGE
	var/pre_attack = 0
	var/pre_attack_icon = "Goliath_preattack"
	loot = list(/obj/item/asteroid/goliath_hide{layer = 4.1})

/mob/living/simple_animal/hostile/asteroid/goliath/Life()
	..()
	handle_preattack()

/mob/living/simple_animal/hostile/asteroid/goliath/proc/handle_preattack()
	if(ranged_cooldown <= world.time + ranged_cooldown_time*0.25 && !pre_attack)
		pre_attack++
	if(!pre_attack || stat || AIStatus == AI_IDLE)
		return
	icon_state = pre_attack_icon

/mob/living/simple_animal/hostile/asteroid/goliath/revive(full_heal = 0, admin_revive = 0)
	if(..())
		anchored = 1
		. = 1

/mob/living/simple_animal/hostile/asteroid/goliath/death(gibbed)
	anchored = 0
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/goliath/OpenFire()
	var/tturf = get_turf(target)
	if(!(istype(tturf, /turf)))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/goliath_tentacle/original(tturf)
		ranged_cooldown = world.time + ranged_cooldown_time
		icon_state = icon_aggro
		pre_attack = 0
	return

/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(damage)
	ranged_cooldown -= 10
	handle_preattack()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro
	return

/obj/effect/goliath_tentacle/
	name = "Goliath tentacle"
	icon = 'icons/mob/animal.dmi'
	icon_state = "Goliath_tentacle"
	var/latched = 0
	anchored = 1

/obj/effect/goliath_tentacle/New()
	var/turftype = get_turf(src)
	if(istype(turftype, /turf/closed/mineral))
		var/turf/closed/mineral/M = turftype
		M.gets_drilled()
	spawn(10)
		Trip()

/obj/effect/goliath_tentacle/original

/obj/effect/goliath_tentacle/original/New()
	for(var/obj/effect/goliath_tentacle/original/O in loc)//No more GG NO RE from 2+ goliaths simultaneously tentacling you
		if(O != src)
			qdel(src)
	var/list/directions = cardinal.Copy()
	var/counter
	for(counter = 1, counter <= 3, counter++)
		var/spawndir = pick(directions)
		directions -= spawndir
		var/turf/T = get_step(src,spawndir)
		new /obj/effect/goliath_tentacle(T)
	..()

/obj/effect/goliath_tentacle/proc/Trip()
	for(var/mob/living/M in src.loc)
		visible_message("<span class='danger'>The [src.name] grabs hold of [M.name]!</span>")
		M.Stun(5)
		M.adjustBruteLoss(rand(10,15))
		latched = 1
	if(!latched)
		qdel(src)
	else
		spawn(50)
			qdel(src)

/obj/item/asteroid/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	flags = NOBLUDGEON
	w_class = 3
	layer = 4

/obj/item/asteroid/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/clothing/suit/space/hardsuit/mining) || istype(target, /obj/item/clothing/head/helmet/space/hardsuit/mining) ||  istype(target, /obj/item/clothing/suit/hooded/explorer) || istype(target, /obj/item/clothing/head/explorer))
			var/obj/item/clothing/C = target
			var/list/current_armor = C.armor
			if(current_armor.["melee"] < 60)
				current_armor.["melee"] = min(current_armor.["melee"] + 10, 60)
				user << "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>"
				qdel(src)
			else
				user << "<span class='warning'>You can't improve [C] any further!</span>"
				return
		if(istype(target, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/D = target
			var/list/damage_absorption = D.damage_absorption
			if(D.hides < 3)
				D.hides++
				damage_absorption["brute"] = max(damage_absorption["brute"] - 0.1, 0.3)
				damage_absorption["bullet"] = damage_absorption["bullet"] - 0.05
				damage_absorption["fire"] = damage_absorption["fire"] - 0.05
				damage_absorption["laser"] = damage_absorption["laser"] - 0.025
				user << "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>"
				D.update_icon()
				if(D.hides == 3)
					D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
				else
					D.desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."
				qdel(src)
			else
				user << "<span class='warning'>You can't improve [D] any further!</span>"
				return

/mob/living/simple_animal/hostile/asteroid/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(2)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)

/mob/living/simple_animal/hostile/asteroid/fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/animal.dmi'
	icon_state = "Fugu"
	icon_living = "Fugu"
	icon_aggro = "Fugu"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	attack_sound = 'sound/weapons/punch4.ogg'
	mouse_opacity = 2
	move_to_delay = 5
	friendly = "floats near"
	speak_emote = list("puffs")
	vision_range = 5
	speed = 0
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "chomps"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "is avoided by the"
	aggro_vision_range = 9
	idle_vision_range = 5
	mob_size = MOB_SIZE_SMALL
	environment_smash = 0
	var/wumbo = 0
	var/inflate_cooldown = 0
	loot = list(/obj/item/asteroid/fugu_gland{layer = 4.1})

/mob/living/simple_animal/hostile/asteroid/fugu/Life()
	if(!wumbo)
		inflate_cooldown = max((inflate_cooldown - 1), 0)
	if(target && AIStatus == AI_ON)
		Inflate()
	..()

/mob/living/simple_animal/hostile/asteroid/fugu/adjustHealth(var/damage)
	if(wumbo)
		return 0
	. = ..()

/mob/living/simple_animal/hostile/asteroid/fugu/Aggro()
	..()
	Inflate()

/mob/living/simple_animal/hostile/asteroid/fugu/verb/Inflate()
	set name = "Inflate"
	set category = "Fugu"
	set desc = "Temporarily increases your size, and makes you significantly more dangerous and tough."
	if(wumbo)
		src << "<span class='notice'>You're already inflated.</span>"
		return
	if(inflate_cooldown)
		src << "<span class='notice'>We need time to gather our strength.</span>"
		return
	if(buffed)
		src << "<span class='notice'>Something is interfering with our growth.</span>"
		return
	wumbo = 1
	icon_state = "Fugu_big"
	melee_damage_lower = 15
	melee_damage_upper = 20
	harm_intent_damage = 0
	throw_message = "is absorbed by the girth of the"
	retreat_distance = null
	minimum_distance = 1
	move_to_delay = 6
	transform *= 2
	environment_smash = 2
	mob_size = MOB_SIZE_LARGE
	speed = 1
	spawn(100)
		Deflate()

/mob/living/simple_animal/hostile/asteroid/fugu/proc/Deflate()
	if(wumbo)
		walk(src, 0)
		wumbo = 0
		icon_state = "Fugu"
		melee_damage_lower = 0
		melee_damage_upper = 0
		harm_intent_damage = 5
		throw_message = "is avoided by the"
		retreat_distance = 9
		minimum_distance = 9
		move_to_delay = 2
		transform /= 2
		inflate_cooldown = 4
		environment_smash = 0
		mob_size = MOB_SIZE_SMALL
		speed = 0

/mob/living/simple_animal/hostile/asteroid/fugu/death(gibbed)
	Deflate()
	..(gibbed)

/obj/item/asteroid/fugu_gland
	name = "wumborian fugu gland"
	desc = "The key to the wumborian fugu's ability to increase its mass arbitrarily, this disgusting remnant can apply the same effect to other creatures, giving them great strength."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fugu_gland"
	flags = NOBLUDGEON
	w_class = 3
	layer = 4
	origin_tech = "biotech=6"
	var/list/banned_mobs()

/obj/item/asteroid/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = target
		if(A.buffed || (A.type in banned_mobs) || A.stat)
			user << "<span class='warning'>Something's interfering with the [src]'s effects. It's no use.</span>"
			return
		A.buffed++
		A.maxHealth *= 1.5
		A.health = min(A.maxHealth,A.health*1.5)
		A.melee_damage_lower = max((A.melee_damage_lower * 2), 10)
		A.melee_damage_upper = max((A.melee_damage_upper * 2), 10)
		A.transform *= 2
		A.environment_smash += 2
		user << "<span class='info'>You increase the size of [A], giving it a surge of strength!</span>"
		qdel(src)

/////////////////////Lavaland

//Watcher

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	pixel_x = -10
	throw_message = "bounces harmlessly off of"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "stares into the soul of"
	a_intent = "harm"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	stat_attack = 1
	robust_searching = 1
	loot = list()
	butcher_results = list(/obj/item/weapon/ore/diamond = 2)

//Goliath

/mob/living/simple_animal/hostile/asteroid/goliath/beast
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	throw_message = "does nothing to the tough hide of the"
	pre_attack_icon = "goliath2"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/goliath = 2, /obj/item/asteroid/goliath_hide = 1)
	loot = list()
	stat_attack = 1
	robust_searching = 1

//Legion

/mob/living/simple_animal/hostile/asteroid/hivelord/legion
	name = "legion"
	desc = "You can still see what was once a human under the shifting mass of corruption."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion"
	icon_living = "legion"
	icon_aggro = "legion"
	icon_dead = "legion"
	icon_gib = "syndicate_gib"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "lashes out at"
	speak_emote = list("echoes")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "bounces harmlessly off of"
	loot = list(/obj/item/organ/internal/hivelord_core/legion)
	brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion
	del_on_death = 1
	stat_attack = 1
	robust_searching = 1
	var/mob/living/carbon/human/stored_mob

/mob/living/simple_animal/hostile/asteroid/hivelord/legion/death(gibbed)
	visible_message("<span class='warning'>[src] wails as in anger as they are driven from their form!</span>")
	if(stored_mob)
		stored_mob.loc = get_turf(src)
		stored_mob.adjustBruteLoss(1000)
	else
		new /obj/effect/mob_spawn/human/corpse/damaged(get_turf(src))
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion
	name = "legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "legion_head"
	icon_living = "legion_head"
	icon_aggro = "legion_head"
	icon_dead = "legion_head"
	icon_gib = "syndicate_gib"
	friendly = "buzzes near"
	vision_range = 10
	maxHealth = 1
	health = 5
	harm_intent_damage = 5
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites"
	speak_emote = list("echoes")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "is shrugged off by"
	pass_flags = PASSTABLE
	del_on_death = 1
	stat_attack = 1
	robust_searching = 1

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/Life()
	if(isturf(src.loc))
		for(var/mob/living/carbon/human/H in view(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == UNCONSCIOUS)
				visible_message("<span class='warning'>[src.name] burrows into the flesh of [H]!</span>")
				var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/L = new(H.loc)
				visible_message("<span class='warning'>[L] staggers to their feet!</span>")
				H.death()
				L.stored_mob = H
				H.loc = L
				qdel(src)
	..()

/obj/item/organ/internal/hivelord_core/legion
	name = "legion's heart"
	desc = "A demonic, still beating heart... its healing properties will soon become inert if not used quickly."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "demon_heart"

//Nests

/mob/living/simple_animal/hostile/spawner/lavaland
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground. Terrible monsters are pouring out of it."
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	icon_living = "tendril"
	icon_dead = "tendril"
	faction = list("mining")
	health = 250
	maxHealth = 250
	max_mobs = 3
	spawn_time = 300 //30 seconds default
	mob_type = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	spawn_text = "emerges from"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	layer = MOB_LAYER-0.1
	loot = list(/obj/effect/collapse, /obj/structure/closet/crate/necropolis/tendril)
	del_on_death = 1
	var/gps = null

/mob/living/simple_animal/hostile/spawner/lavaland/New()
	..()
	gps = new /obj/item/device/gps/internal(src)


/obj/effect/collapse
	name = "collapsing necropolis tendril"
	desc = "Get clear!"
	layer = 2
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	anchored = TRUE

/obj/effect/collapse/New()
	..()
	visible_message("<B><span class='danger'>The tendril writhes in pain and anger and the earth around it begins to split! Get back!</span></B>")
	visible_message("<span class='danger'>A chest falls clear of the tendril!</span>")
	playsound(get_turf(src),'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
	spawn(50)
		for(var/mob/M in range(7,src))
			shake_camera(M, 15, 1)
		playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, 1)
		visible_message("<B><span class='danger'>The tendril collapes!</span></B>")
		for(var/turf/T in range(2,src))
			if(!T.density)
				T.ChangeTurf(/turf/open/chasm/straight_down/lava_land_surface)
		qdel(src)

/mob/living/simple_animal/hostile/spawner/lavaland/goliath
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath/beast

/mob/living/simple_animal/hostile/spawner/lavaland/legion
	mob_type = /mob/living/simple_animal/hostile/asteroid/hivelord/legion
