/mob/living/simple_animal/hostile/asteroid
	vision_range = 2
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("mining")
	weather_immunities = list("lava","ash")
	obj_damage = 30
	environment_smash = 2
	minbodytemp = 0
	maxbodytemp = INFINITY
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = INTENT_HARM
	var/throw_message = "bounces off of"
	var/icon_aggro = null // for swapping to when we get aggressive
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE

/mob/living/simple_animal/hostile/asteroid/Aggro()
	..()
	if(vision_range != aggro_vision_range)
		icon_state = icon_aggro

/mob/living/simple_animal/hostile/asteroid/LoseAggro()
	..()
	if(stat == DEAD)
		return
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
	SSblackbox.add_details("mobs_killed_mining","[src.type]")
	..(gibbed)

/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
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
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "bites into"
	a_intent = INTENT_HARM
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	aggro_vision_range = 9
	idle_vision_range = 2
	turns_per_move = 5
	loot = list(/obj/item/weapon/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/weapon/ore/diamond{layer = ABOVE_MOB_LAYER})

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
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)//No more being shot at point blank or spammed with RNG beams
			OpenFire(target)

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
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
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
	a_intent = INTENT_HELP
	speak_emote = list("screeches")
	throw_message = "sinks in slowly, before being pushed out of "
	deathmessage = "spits up the contents of its stomach before dying!"
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/weapon/ore/diamond, /obj/item/weapon/ore/gold, /obj/item/weapon/ore/silver,
						  /obj/item/weapon/ore/uranium)

	var/chase_time = 100
	var/will_burrow = TRUE

/mob/living/simple_animal/hostile/asteroid/goldgrub/Initialize()
	..()
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
			if(will_burrow)
				addtimer(CALLBACK(src, .proc/Burrow), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(istype(target, /obj/item/weapon/ore))
		EatOre(target)
		return
	return ..()

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

/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	idle_vision_range = 9
	. = ..()

/mob/living/simple_animal/hostile/asteroid/hivelord
	name = "hivelord"
	desc = "A truly alien creature, it is a mass of unknown organic material, constantly fluctuating. When attacking, pieces of it split off and attack in tandem with the original."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
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
	obj_damage = 0
	environment_smash = 0
	retreat_distance = 3
	minimum_distance = 3
	pass_flags = PASSTABLE
	loot = list(/obj/item/organ/hivelord_core)
	var/brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood

/mob/living/simple_animal/hostile/asteroid/hivelord/OpenFire(the_target)
	if(world.time >= ranged_cooldown)
		var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/A = new brood_type(src.loc)
		A.admin_spawned = admin_spawned
		A.GiveTarget(target)
		A.friends = friends
		A.faction = faction.Copy()
		ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/asteroid/hivelord/AttackingTarget()
	OpenFire()
	return TRUE

/mob/living/simple_animal/hostile/asteroid/hivelord/death(gibbed)
	mouse_opacity = 1
	..(gibbed)

/obj/item/organ/hivelord_core
	name = "hivelord remains"
	desc = "All that remains of a hivelord, it seems to be what allows it to break pieces of itself off without being hurt... its healing properties will soon become inert if not used quickly."
	icon_state = "roro core 2"
	flags = NOBLUDGEON
	slot = "hivecore"
	force = 0
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/inert = 0
	var/preserved = 0

/obj/item/organ/hivelord_core/Initialize()
	..()
	addtimer(CALLBACK(src, .proc/inert_check), 2400)

/obj/item/organ/hivelord_core/proc/inert_check()
	if(!owner && !preserved)
		go_inert()
	else
		preserved(implanted = 1)

/obj/item/organ/hivelord_core/proc/preserved(implanted = 0)
	inert = FALSE
	preserved = TRUE
	update_icon()

	if(implanted)
		SSblackbox.add_details("hivelord_core", "[type]|implanted")
	else
		SSblackbox.add_details("hivelord_core", "[type]|stabilizer")


/obj/item/organ/hivelord_core/proc/go_inert()
	inert = TRUE
	desc = "The remains of a hivelord that have become useless, having been left alone too long after being harvested."
	SSblackbox.add_details("hivelord_core", "[src.type]|inert")
	update_icon()

/obj/item/organ/hivelord_core/ui_action_click()
	owner.revive(full_heal = 1)
	qdel(src)

/obj/item/organ/hivelord_core/on_life()
	..()
	if(owner.health < HEALTH_THRESHOLD_CRIT)
		ui_action_click()

/obj/item/organ/hivelord_core/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(inert)
			to_chat(user, "<span class='notice'>[src] has become inert, its healing properties are no more.</span>")
			return
		else
			if(H.stat == DEAD)
				to_chat(user, "<span class='notice'>[src] are useless on the dead.</span>")
				return
			if(H != user)
				H.visible_message("[user] forces [H] to apply [src]... [H.p_they()] quickly regenerate all injuries!")
				SSblackbox.add_details("hivelord_core","[src.type]|used|other")
			else
				to_chat(user, "<span class='notice'>You start to smear [src] on yourself. It feels and smells disgusting, but you feel amazingly refreshed in mere moments.</span>")
				SSblackbox.add_details("hivelord_core","[src.type]|used|self")
			H.revive(full_heal = 1)
			qdel(src)
	..()

/obj/item/organ/hivelord_core/prepare_eat()
	return null

/mob/living/simple_animal/hostile/asteroid/hivelordbrood
	name = "hivelord brood"
	desc = "A fragment of the original Hivelord, rallying behind its original. One isn't much of a threat, but..."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
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
	movement_type = FLYING
	harm_intent_damage = 5
	melee_damage_lower = 2
	melee_damage_upper = 2
	attacktext = "slashes"
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "falls right through the strange body of the"
	obj_damage = 0
	environment_smash = 0
	pass_flags = PASSTABLE
	del_on_death = 1

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/Initialize()
	..()
	addtimer(CALLBACK(src, .proc/death), 100)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood
	name = "blood brood"
	desc = "A living string of blood and alien materials."
	icon_state = "bloodbrood"
	icon_living = "bloodbrood"
	icon_aggro = "bloodbrood"
	attacktext = "pierces"
	color = "#C80000"

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/death()
	if(loc) // Splash the turf we are on with blood
		reagents.reaction(get_turf(src))
	..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/Initialize()
	create_reagents(30)
	..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/AttackingTarget()
	. = ..()
	if(. && iscarbon(target))
		transfer_reagents(target, 1)


/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_hand(mob/living/carbon/human/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_paw(mob/living/carbon/monkey/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/attack_alien(mob/living/carbon/alien/humanoid/M)
	if("\ref[M]" in faction)
		reabsorb_host(M)
	else
		return ..()


/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/reabsorb_host(mob/living/carbon/C)
	C.visible_message("<span class='notice'>[src] is reabsorbed by [C]'s body.</span>", \
								"<span class='notice'>[src] is reabsorbed by your body.</span>")
	transfer_reagents(C)
	death()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/transfer_reagents(mob/living/carbon/C, volume = 30)
	if(!reagents.total_volume)
		return

	volume = min(volume, reagents.total_volume)

	var/fraction = min(volume/reagents.total_volume, 1)
	reagents.reaction(C, INJECT, fraction)
	reagents.trans_to(C, volume)

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/blood/proc/link_host(mob/living/carbon/C)
	faction = list("\ref[src]", "\ref[C]") // Hostile to everyone except the host.
	C.transfer_blood_to(src, 30)
	var/newcolor = mix_color_from_reagents(reagents.reagent_list)
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/hostile/asteroid/goliath
	name = "goliath"
	desc = "A massive beast that uses long tentacles to ensare its prey, threatening them is not advised under any conditions."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath"
	icon_living = "Goliath"
	icon_aggro = "Goliath_alert"
	icon_dead = "Goliath_dead"
	icon_gib = "syndicate_gib"
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
	obj_damage = 100
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "pulverizes"
	attack_sound = 'sound/weapons/punch1.ogg'
	throw_message = "does nothing to the rocky hide of the"
	aggro_vision_range = 9
	idle_vision_range = 5
	anchored = 1 //Stays anchored until death as to be unpullable
	var/pre_attack = 0
	var/pre_attack_icon = "Goliath_preattack"
	loot = list(/obj/item/stack/sheet/animalhide/goliath_hide)

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
	if(!isturf(tturf))
		return
	if(get_dist(src, target) <= 7)//Screen range check, so you can't get tentacle'd offscreen
		visible_message("<span class='warning'>The [src.name] digs its tentacles under [target.name]!</span>")
		new /obj/effect/goliath_tentacle/original(tturf)
		ranged_cooldown = world.time + ranged_cooldown_time
		icon_state = icon_aggro
		pre_attack = 0

/mob/living/simple_animal/hostile/asteroid/goliath/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	ranged_cooldown -= 10
	handle_preattack()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/goliath/Aggro()
	vision_range = aggro_vision_range
	handle_preattack()
	if(icon_state != icon_aggro)
		icon_state = icon_aggro

/obj/effect/goliath_tentacle
	name = "Goliath tentacle"
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goliath_tentacle"
	var/latched = 0
	anchored = 1

/obj/effect/goliath_tentacle/New()
	var/turftype = get_turf(src)
	if(ismineralturf(turftype))
		var/turf/closed/mineral/M = turftype
		M.gets_drilled()
	addtimer(CALLBACK(src, .proc/Trip), 10)

/obj/effect/goliath_tentacle/original

/obj/effect/goliath_tentacle/original/New()
	for(var/obj/effect/goliath_tentacle/original/O in loc)//No more GG NO RE from 2+ goliaths simultaneously tentacling you
		if(O != src)
			qdel(src)
	var/list/directions = GLOB.cardinal.Copy()
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
		QDEL_IN(src, 50)

/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER

/obj/item/stack/sheet/animalhide/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/clothing/suit/space/hardsuit/mining) || istype(target, /obj/item/clothing/head/helmet/space/hardsuit/mining) ||  istype(target, /obj/item/clothing/suit/hooded/explorer) || istype(target, /obj/item/clothing/head/hooded/explorer))
			var/obj/item/clothing/C = target
			var/list/current_armor = C.armor
			if(current_armor.["melee"] < 60)
				current_armor.["melee"] = min(current_armor.["melee"] + 10, 60)
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				use(1)
			else
				to_chat(user, "<span class='warning'>You can't improve [C] any further!</span>")
				return
		if(istype(target, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/D = target
			if(D.hides < 3)
				D.hides++
				D.armor["melee"] = min(D.armor["melee"] + 10, 70)
				D.armor["bullet"] = min(D.armor["bullet"] + 5, 50)
				D.armor["laser"] = min(D.armor["laser"] + 5, 50)
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				D.update_icon()
				if(D.hides == 3)
					D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
				else
					D.desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")
				return


/mob/living/simple_animal/hostile/asteroid/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(2)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(20)

/mob/living/simple_animal/hostile/asteroid/fugu
	name = "wumborian fugu"
	desc = "The wumborian fugu rapidly increases its body mass in order to ward off its prey. Great care should be taken to avoid it while it's in this state as it is nearly invincible, but it cannot maintain its form forever."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Fugu"
	icon_living = "Fugu"
	icon_aggro = "Fugu"
	icon_dead = "Fugu_dead"
	icon_gib = "syndicate_gib"
	mouse_opacity = 2
	move_to_delay = 5
	friendly = "floats near"
	speak_emote = list("puffs")
	vision_range = 5
	speed = 0
	maxHealth = 50
	health = 50
	harm_intent_damage = 5
	obj_damage = 0
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
	loot = list(/obj/item/asteroid/fugu_gland{layer = ABOVE_MOB_LAYER})

/mob/living/simple_animal/hostile/asteroid/fugu/Life()
	if(!wumbo)
		inflate_cooldown = max((inflate_cooldown - 1), 0)
	if(target && AIStatus == AI_ON)
		Inflate()
	..()

/mob/living/simple_animal/hostile/asteroid/fugu/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && wumbo)
		return FALSE
	. = ..()

/mob/living/simple_animal/hostile/asteroid/fugu/Aggro()
	..()
	Inflate()

/mob/living/simple_animal/hostile/asteroid/fugu/verb/Inflate()
	set name = "Inflate"
	set category = "Fugu"
	set desc = "Temporarily increases your size, and makes you significantly more dangerous and tough."
	if(wumbo)
		to_chat(src, "<span class='notice'>You're already inflated.</span>")
		return
	if(inflate_cooldown)
		to_chat(src, "<span class='notice'>We need time to gather our strength.</span>")
		return
	if(buffed)
		to_chat(src, "<span class='notice'>Something is interfering with our growth.</span>")
		return
	wumbo = 1
	icon_state = "Fugu_big"
	obj_damage = 60
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
	addtimer(CALLBACK(src, .proc/Deflate), 100)

/mob/living/simple_animal/hostile/asteroid/fugu/proc/Deflate()
	if(wumbo)
		walk(src, 0)
		wumbo = 0
		icon_state = "Fugu"
		obj_damage = 0
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
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	origin_tech = "biotech=6"
	var/list/banned_mobs()

/obj/item/asteroid/fugu_gland/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag && istype(target, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = target
		if(A.buffed || (A.type in banned_mobs) || A.stat)
			to_chat(user, "<span class='warning'>Something's interfering with the [src]'s effects. It's no use.</span>")
			return
		A.buffed++
		A.maxHealth *= 1.5
		A.health = min(A.maxHealth,A.health*1.5)
		A.melee_damage_lower = max((A.melee_damage_lower * 2), 10)
		A.melee_damage_upper = max((A.melee_damage_upper * 2), 10)
		A.transform *= 2
		A.environment_smash += 2
		to_chat(user, "<span class='info'>You increase the size of [A], giving it a surge of strength!</span>")
		qdel(src)

/////////////////////Lavaland

//Watcher

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	pixel_x = -10
	throw_message = "bounces harmlessly off of"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "impales"
	a_intent = INTENT_HARM
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	stat_attack = 1
	movement_type = FLYING
	robust_searching = 1
	loot = list()
	butcher_results = list(/obj/item/weapon/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)

//Goliath

/mob/living/simple_animal/hostile/asteroid/goliath/beast
	name = "goliath"
	desc = "A hulking, armor-plated beast with long tendrils arching from its back."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "goliath"
	icon_living = "goliath"
	icon_aggro = "goliath"
	icon_dead = "goliath_dead"
	throw_message = "does nothing to the tough hide of the"
	pre_attack_icon = "goliath2"
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/goliath = 2, /obj/item/stack/sheet/animalhide/goliath_hide = 1, /obj/item/stack/sheet/bone = 2)
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
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "lashes out at"
	speak_emote = list("echoes")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_message = "bounces harmlessly off of"
	loot = list(/obj/item/organ/hivelord_core/legion)
	brood_type = /mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion
	del_on_death = 1
	stat_attack = 1
	robust_searching = 1
	var/mob/living/carbon/human/stored_mob

/mob/living/simple_animal/hostile/asteroid/hivelord/legion/death(gibbed)
	visible_message("<span class='warning'>The skulls on [src] wail in anger as they flee from their dying host!</span>")
	var/turf/T = get_turf(src)
	if(T)
		if(stored_mob)
			stored_mob.forceMove(get_turf(src))
			stored_mob = null
		else
			new /obj/effect/mob_spawn/human/corpse/damaged(T)
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
	if(isturf(loc))
		for(var/mob/living/carbon/human/H in view(src,1)) //Only for corpse right next to/on same tile
			if(H.stat == UNCONSCIOUS)
				infest(H)
	..()

/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/proc/infest(mob/living/carbon/human/H)
	visible_message("<span class='warning'>[name] burrows into the flesh of [H]!</span>")
	var/mob/living/simple_animal/hostile/asteroid/hivelord/legion/L = new(H.loc)
	visible_message("<span class='warning'>[L] staggers to their feet!</span>")
	H.death()
	H.adjustBruteLoss(1000)
	L.stored_mob = H
	H.forceMove(L)
	qdel(src)

/obj/item/organ/hivelord_core/legion
	name = "legion's soul"
	desc = "A strange rock that still crackles with power... its \
		healing properties will soon become inert if not used quickly."
	icon_state = "legion_soul"

/obj/item/organ/hivelord_core/legion/New()
	..()
	update_icon()

/obj/item/organ/hivelord_core/update_icon()
	icon_state = inert ? "legion_soul_inert" : "legion_soul"
	cut_overlays()
	if(!inert && !preserved)
		add_overlay("legion_soul_crackle")
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/hivelord_core/legion/go_inert()
	. = ..()
	desc = "[src] has become inert, it crackles no more and is useless for \
		healing injuries."

/obj/item/organ/hivelord_core/legion/preserved(implanted = 0)
	..()
	desc = "[src] has been stabilized. It no longer crackles with power, but it's healing properties are preserved indefinitely."

/obj/item/weapon/legion_skull
	name = "legion's head"
	desc = "The once living, now empty eyes of the former human's skull cut deep into your soul."
	icon = 'icons/obj/mining.dmi'
	icon_state = "skull"


//Gutlunches

/mob/living/simple_animal/hostile/asteroid/gutlunch
	name = "gutlunch"
	desc = "A scavenger that eats raw meat, often found alongside ash walkers. Produces a thick, nutritious milk."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	speak_emote = list("warbles", "quavers")
	emote_hear = list("trills.")
	emote_see = list("sniffs.", "burps.")
	weather_immunities = list("lava","ash")
	faction = list("mining", "ashwalker")
	density = 0
	speak_chance = 1
	turns_per_move = 8
	obj_damage = 0
	environment_smash = 0
	move_to_delay = 15
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "squishes"
	friendly = "pinches"
	a_intent = INTENT_HELP
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = 2
	stat_attack = 1
	gender = NEUTER
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = TRUE
	stat_exclusive = TRUE
	robust_searching = TRUE
	search_objects = TRUE
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	deathmessage = "is pulped into bugmash."

	animal_species = /mob/living/simple_animal/hostile/asteroid/gutlunch
	childtype = list(/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck = 45, /mob/living/simple_animal/hostile/asteroid/gutlunch/guthen = 55)

	wanted_objects = list(/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/blood/gibs/)
	var/obj/item/udder/gutlunch/udder = null

/mob/living/simple_animal/hostile/asteroid/gutlunch/Initialize()
	udder = new()
	..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/Destroy()
	qdel(udder)
	udder = null
	return ..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/regenerate_icons()
	cut_overlays()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume)
		add_overlay("gl_full")
	..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/attackby(obj/item/O, mob/user, params)
	if(stat == CONSCIOUS && istype(O, /obj/item/weapon/reagent_containers/glass))
		udder.milkAnimal(O, user)
		regenerate_icons()
	else
		..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/AttackingTarget()
	if(is_type_in_typecache(target,wanted_objects)) //we eats
		udder.generateMilk()
		regenerate_icons()
		visible_message("<span class='notice'>[src] slurps up [target].</span>")
		qdel(target)
	return ..()


/obj/item/udder/gutlunch
	name = "nutrient sac"

/obj/item/udder/gutlunch/New()
	reagents = new(50)
	reagents.my_atom = src

/obj/item/udder/gutlunch/generateMilk()
	if(prob(60))
		reagents.add_reagent("cream", rand(2, 5))
	if(prob(45))
		reagents.add_reagent("salglu_solution", rand(2,5))


//Male gutlunch. They're smaller and more colorful!
/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	name = "gubbuck"
	gender = MALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/Initialize()
	..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	resize = 0.85
	update_transform()


//Lady gutlunch. They make the babby.
/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen
	name = "guthen"
	gender = FEMALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/Life()
	..()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume) //Only breed when we're full.
		make_babies()

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/make_babies()
	. = ..()
	if(.)
		udder.reagents.clear_reagents()
		regenerate_icons()

//Nests
/mob/living/simple_animal/hostile/spawner/lavaland
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground. Terrible monsters are pouring out of it."
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	icon_living = "tendril"
	icon_dead = "tendril"
	faction = list("mining")
	weather_immunities = list("lava","ash")
	luminosity = 1
	health = 250
	maxHealth = 250
	max_mobs = 3
	spawn_time = 300 //30 seconds default
	mob_type = /mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	spawn_text = "emerges from"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	loot = list(/obj/effect/collapse, /obj/structure/closet/crate/necropolis/tendril)
	del_on_death = 1
	var/gps = null

/mob/living/simple_animal/hostile/spawner/lavaland/Initialize()
	..()
	for(var/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/closed/mineral/M = F
			M.ChangeTurf(M.turf_type,FALSE,TRUE)
	gps = new /obj/item/device/gps/internal(src)

/mob/living/simple_animal/hostile/spawner/lavaland/Destroy()
	qdel(gps)
	. = ..()

#define MEDAL_PREFIX "Tendril"
/mob/living/simple_animal/hostile/spawner/lavaland/death()
	var/last_tendril = TRUE
	for(var/mob/living/simple_animal/hostile/spawner/lavaland/other in GLOB.mob_list)
		if(other != src)
			last_tendril = FALSE
			break
	if(last_tendril && !admin_spawned)
		if(global.medal_hub && global.medal_pass && global.medals_enabled)
			for(var/mob/living/L in view(7,src))
				if(L.stat)
					continue
				if(L.client)
					var/client/C = L.client
					var/suffixm = ALL_KILL_MEDAL
					var/prefix = MEDAL_PREFIX
					UnlockMedal("[prefix] [suffixm]",C)
					SetScore(TENDRIL_CLEAR_SCORE,C,1)
	..()
#undef MEDAL_PREFIX

/obj/effect/collapse
	name = "collapsing necropolis tendril"
	desc = "Get clear!"
	luminosity = 1
	layer = ABOVE_OPEN_TURF_LAYER
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	anchored = TRUE

/obj/effect/collapse/New()
	..()
	visible_message("<span class='boldannounce'>The tendril writhes in fury as the earth around it begins to crack and break apart! Get back!</span>")
	visible_message("<span class='warning'>Something falls free of the tendril!</span>")
	playsound(get_turf(src),'sound/effects/tendril_destroyed.ogg', 200, 0, 50, 1, 1)
	spawn(50)
		for(var/mob/M in range(7,src))
			shake_camera(M, 15, 1)
		playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, 1)
		visible_message("<span class='boldannounce'>The tendril falls inward, the ground around it widening into a yawning chasm!</span>")
		for(var/turf/T in range(2,src))
			if(!T.density)
				T.TerraformTurf(/turf/open/chasm/straight_down/lava_land_surface)
		qdel(src)

/mob/living/simple_animal/hostile/spawner/lavaland/goliath
	mob_type = /mob/living/simple_animal/hostile/asteroid/goliath/beast

/mob/living/simple_animal/hostile/spawner/lavaland/legion
	mob_type = /mob/living/simple_animal/hostile/asteroid/hivelord/legion
