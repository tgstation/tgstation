/area/awaymission/black_mesa
	name = "Black Mesa Inside"

/area/awaymission/black_mesa/outside
	name = "Black Mesa Outside"
	static_lighting = FALSE

/obj/structure/fluff/server_rack
	name = "Server Rack"
	desc = "A server rack with lots of cables coming out."
	density = TRUE
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "nanite_cloud_controller"

/mob/living/simple_animal/hostile/blackmesa
	var/list/alert_sounds
	var/alert_cooldown = 3 SECONDS
	var/alert_cooldown_time

/mob/living/simple_animal/hostile/blackmesa/xen
	faction = list(FACTION_XEN)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500

/mob/living/simple_animal/hostile/blackmesa/Aggro()
	if(alert_sounds)
		if(!(world.time <= alert_cooldown_time))
			playsound(src, pick(alert_sounds), 70)
			alert_cooldown_time = world.time + alert_cooldown

/mob/living/simple_animal/hostile/blackmesa/xen/bullsquid
	name = "bullsquid"
	desc = "Some highly aggressive alien creature. Thrives in toxic environments."
	icon = 'modular_skyrat/master_files/icons/mob/blackmesa.dmi'
	icon_state = "bullsquid"
	icon_living = "bullsquid"
	icon_dead = "bullsquid_dead"
	icon_gib = null
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_chance = 1
	speak_emote = list("growls")
	emote_taunt = list("growls", "snarls", "grumbles")
	taunt_chance = 100
	turns_per_move = 7
	maxHealth = 110
	health = 110
	obj_damage = 50
	harm_intent_damage = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	ranged = TRUE
	retreat_distance = 4
	minimum_distance = 4
	dodging = TRUE
	projectiletype = /obj/projectile/bullsquid
	projectilesound = 'modular_skyrat/master_files/sound/blackmesa/bullsquid/goo_attack3.ogg'
	melee_damage_upper = 18
	attack_sound = 'modular_skyrat/master_files/sound/blackmesa/bullsquid/attack1.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	alert_sounds = list(
		'modular_skyrat/master_files/sound/blackmesa/bullsquid/detect1.ogg',
		'modular_skyrat/master_files/sound/blackmesa/bullsquid/detect2.ogg',
		'modular_skyrat/master_files/sound/blackmesa/bullsquid/detect3.ogg'
	)

/obj/projectile/bullsquid
	name = "nasty ball of ooze"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	knockdown = 20
	flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin
	hitsound = 'modular_skyrat/master_files/sound/blackmesa/bullsquid/splat1.ogg'
	hitsound_wall = 'modular_skyrat/master_files/sound/blackmesa/bullsquid/splat1.ogg'

/obj/projectile/bullsquid/on_hit(atom/target, blocked, pierce_hit)
	new /obj/effect/decal/cleanable/greenglow(target.loc)
	return ..()

/mob/living/simple_animal/hostile/blackmesa/xen/houndeye
	name = "houndeye"
	desc = "Some highly aggressive alien creature. Thrives in toxic environments."
	icon = 'modular_skyrat/master_files/icons/mob/blackmesa.dmi'
	icon_state = "houndeye"
	icon_living = "houndeye"
	icon_dead = "houndeye_dead"
	icon_gib = null
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_chance = 1
	speak_emote = list("growls")
	speed = 1
	emote_taunt = list("growls", "snarls", "grumbles")
	taunt_chance = 100
	turns_per_move = 7
	maxHealth = 110
	health = 110
	obj_damage = 50
	harm_intent_damage = 10
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	//Since those can survive on Xen, I'm pretty sure they can thrive on any atmosphere

	minbodytemp = 0
	maxbodytemp = 1500
	charger = TRUE
	loot = list(/obj/item/stack/sheet/bluespace_crystal)
	alert_sounds = list(
		'modular_skyrat/master_files/sound/blackmesa/houndeye/he_alert1.ogg',
		'modular_skyrat/master_files/sound/blackmesa/houndeye/he_alert2.ogg',
		'modular_skyrat/master_files/sound/blackmesa/houndeye/he_alert3.ogg',
		'modular_skyrat/master_files/sound/blackmesa/houndeye/he_alert4.ogg',
		'modular_skyrat/master_files/sound/blackmesa/houndeye/he_alert5.ogg'
	)

/mob/living/simple_animal/hostile/blackmesa/xen/houndeye/enter_charge(atom/target)
	playsound(src, pick(list(
		'modular_skyrat/master_files/sound/blackmesa/houndeye/charge3.ogg',
		'modular_skyrat/master_files/sound/blackmesa/houndeye/charge3.ogg',
		'modular_skyrat/master_files/sound/blackmesa/houndeye/charge3.ogg'
	)), 100)
	return ..()

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab
	name = "headcrab"
	desc = "Don't let it latch onto your hea-... hey, that's kinda cool."
	icon = 'modular_skyrat/master_files/icons/mob/blackmesa.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	icon_gib = null
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_chance = 1
	speak_emote = list("growls")
	speed = 1
	emote_taunt = list("growls", "snarls", "grumbles")
	taunt_chance = 100
	turns_per_move = 7
	maxHealth = 100
	health = 100
	harm_intent_damage = 15
	melee_damage_lower = 17
	melee_damage_upper = 17
	attack_sound = 'sound/weapons/bite.ogg'
	gold_core_spawnable = HOSTILE_SPAWN
	charger = TRUE
	charge_frequency = 3 SECONDS
	loot = list(/obj/item/stack/sheet/bone)
	alert_sounds = list(
		'modular_skyrat/master_files/sound/blackmesa/headcrab/alert1.ogg'
	)
	var/is_zombie = FALSE
	var/mob/living/carbon/human/oldguy

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/handle_charge_target(atom/target)
	playsound(src, pick(list(
		'modular_skyrat/master_files/sound/blackmesa/headcrab/attack1.ogg',
		'modular_skyrat/master_files/sound/blackmesa/headcrab/attack2.ogg',
		'modular_skyrat/master_files/sound/blackmesa/headcrab/attack3.ogg'
	)), 100)
	return ..()

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/death(gibbed)
	. = ..()
	playsound(src, pick(list(
		'modular_skyrat/master_files/sound/blackmesa/headcrab/die1.ogg',
		'modular_skyrat/master_files/sound/blackmesa/headcrab/die2.ogg'
	)), 100)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(hit_atom && stat != DEAD)
		if(ishuman(hit_atom))
			var/mob/living/carbon/human/human_to_dunk = hit_atom
			if(!human_to_dunk.get_item_by_slot(ITEM_SLOT_HEAD) && prob(50)) //Anything on de head stops the head hump
				if(zombify(human_to_dunk))
					to_chat(human_to_dunk, "<span class='userdanger'>[src] latches onto your head as it pierces your skull, instantly killing you!</span>")
					playsound(src, 'modular_skyrat/master_files/sound/blackmesa/headcrab/headbite.ogg', 100)
					human_to_dunk.death(FALSE)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/proc/zombify(mob/living/carbon/human/H)
	if(is_zombie)
		return FALSE
	is_zombie = TRUE
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		maxHealth += A.armor.melee //That zombie's got armor, I want armor!
	maxHealth += 40
	health = maxHealth
	name = "zombie"
	desc = "A shambling corpse animated by a headcrab!"
	mob_biotypes |= MOB_HUMANOID
	melee_damage_lower += 8
	melee_damage_upper += 11
	obj_damage = 21 //now that it has a corpse to puppet, it can properly attack structures
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	movement_type = GROUND
	icon_state = ""
	H.hairstyle = null
	H.update_hair()
	H.forceMove(src)
	oldguy = H
	update_appearance()
	visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")
	charger = FALSE
	return TRUE

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/death(gibbed)
	. = ..()
	if(oldguy)
		oldguy.forceMove(loc)
		oldguy = null
	if(is_zombie)
		if(prob(30))
			new /mob/living/simple_animal/hostile/blackmesa/xen/headcrab(loc) //OOOO it unlached!
			qdel(src)
			return
		cut_overlays()
		update_appearance()

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/update_overlays()
	. = ..()
	if(is_zombie)
		copy_overlays(oldguy, TRUE)
		var/mutable_appearance/blob_head_overlay = mutable_appearance('modular_skyrat/master_files/icons/mob/blackmesa.dmi', "headcrab_zombie")
		add_overlay(blob_head_overlay)

/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth
	name = "nihilanth"
	desc = "Holy shit."
	icon = 'modular_skyrat/master_files/icons/mob/nihilanth.dmi'
	icon_state = "nihilanth"
	icon_living = "nihilanth"
	base_pixel_x = -156
	pixel_x = -156
	base_pixel_y = -154
	speed = 3
	pixel_y = -154
	bound_height = 64
	bound_width = 64
	icon_dead = "bullsquid_dead"
	maxHealth = 3000
	health = 3000
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	projectilesound = 'sound/weapons/lasercannonfire.ogg'
	projectiletype = /obj/projectile/nihilanth
	ranged = TRUE
	rapid = 3
	alert_cooldown = 2 MINUTES
	harm_intent_damage = 5
	melee_damage_lower = 30
	melee_damage_upper = 40
	attack_verb_continuous = "lathes"
	attack_verb_simple = "lathe"
	attack_sound = 'sound/weapons/punch1.ogg'
	status_flags = NONE
	del_on_death = TRUE
	loot = list(/obj/effect/gibspawner/xeno, /obj/item/stack/sheet/bluespace_crystal/fifty, /obj/item/key/gateway)

/obj/item/stack/sheet/bluespace_crystal/fifty
	amount = 50

/obj/projectile/nihilanth
	name = "portal energy"
	icon_state = "seedling"
	damage = 20
	damage_type = BURN
	light_range = 2
	flag = ENERGY
	light_color = LIGHT_COLOR_YELLOW
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	nondirectional_sprite = TRUE

/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth/Aggro()
	. = ..()
	if(!(world.time <= alert_cooldown_time))
		alert_cooldown_time = world.time + alert_cooldown
		switch(health)
			if(0 to 999)
				playsound(src, pick(list('modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_pain01.ogg', 'modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_freeeemmaan01.ogg')), 100)
			if(1000 to 2999)
				playsound(src, pick(list('modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_youalldie01.ogg', 'modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_foryouhewaits01.ogg')), 100)
			if(3000 to 6000)
				playsound(src, pick(list('modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_whathavedone01.ogg', 'modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_deceiveyou01.ogg')), 100)
			else
				playsound(src, pick(list('modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_thetruth01.ogg', 'modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_iamthelast01.ogg')), 100)
	set_combat_mode(TRUE)

/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth/death(gibbed)
	. = ..()
	playsound(src, 'modular_skyrat/master_files/sound/blackmesa/nihilanth/nihilanth_death01.ogg', 100)
	new /obj/effect/singularity_creation(loc)

/mob/living/simple_animal/hostile/blackmesa/xen/nihilanth/LoseAggro()
	. = ..()
	set_combat_mode(FALSE)
/datum/round_event_control/resonance_cascade
	name = "Portal Storm: Spacetime Cascade"
	typepath = /datum/round_event/portal_storm/resonance_cascade
	weight = 0
	max_occurrences = 0

/datum/round_event/portal_storm/resonance_cascade/announce(fake)
	set waitfor = 0
	sound_to_playing_players('modular_skyrat/master_files/sound/blackmesa/tc_12_portalsuck.ogg')
	sleep(40)
	priority_announce("GENERAL ALERT: Spacetime cascade detected; massive transdimentional rift inbound!", "Transdimentional Rift", ANNOUNCER_KLAXON)
	sleep(20)
	sound_to_playing_players('modular_skyrat/master_files/sound/blackmesa/tc_13_teleport.ogg')

/datum/round_event/portal_storm/resonance_cascade
	hostile_types = list(
		/mob/living/simple_animal/hostile/blackmesa/xen/bullsquid = 30,
		/mob/living/simple_animal/hostile/blackmesa/xen/houndeye = 30,
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab = 30
	)

///////////////////HECU SPAWNERS
/obj/effect/spawner/random/hecu_smg
	name = "HECU SMG drops"
	spawn_all_loot = TRUE
	loot = list(/obj/item/gun/ballistic/automatic/c20r/unrestricted = 30,
				/obj/item/clothing/mask/gas/hecu2 = 20,
				/obj/item/clothing/head/helmet = 20,
				/obj/item/clothing/suit/armor/vest = 15,
				/obj/item/clothing/shoes/combat = 15)

/obj/effect/spawner/random/hecu_deagle
	name = "HECU Deagle drops"
	spawn_all_loot = TRUE
	loot = list(/obj/item/gun/ballistic/automatic/pistol/deagle = 30,
				/obj/item/clothing/mask/gas/hecu2 = 20,
				/obj/item/clothing/head/helmet = 20,
				/obj/item/clothing/suit/armor/vest = 15,
				/obj/item/clothing/shoes/combat = 15)

///////////////////HECU
/mob/living/simple_animal/hostile/blackmesa/hecu
	name = "HECU Grunt"
	desc = "I didn't sign on for this shit. Monsters, sure, but civilians? Who ordered this operation anyway?"
	icon = 'modular_skyrat/master_files/icons/mob/blackmesa.dmi'
	icon_state = "hecu_melee"
	icon_living = "hecu_melee"
	icon_dead = "hecu_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 10
	speak = list("Stop right there!")
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 150
	health = 150
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	loot = list(/obj/item/melee/baton)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(FACTION_XEN)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = 1
	dodging = TRUE
	rapid_melee = 2
	footstep_type = FOOTSTEP_MOB_SHOE
	alert_sounds = list(
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert01.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert03.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert04.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert05.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert06.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert07.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert08.ogg',
		'modular_skyrat/master_files/sound/blackmesa/hecu/hg_alert10.ogg'
	)


/mob/living/simple_animal/hostile/blackmesa/hecu/ranged
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "hecu_ranged"
	icon_living = "hecu_ranged"
	casingtype = /obj/item/ammo_casing/a50ae
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	loot = list(/obj/effect/gibspawner/human, /obj/effect/spawner/random/hecu_deagle)
	dodging = TRUE
	rapid_melee = 1

/mob/living/simple_animal/hostile/blackmesa/hecu/ranged/smg
	rapid = 3
	icon_state = "hecu_ranged_smg"
	icon_living = "hecu_ranged_smg"
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gun/smg/shot.ogg'
	loot = list(/obj/effect/gibspawner/human, /obj/effect/spawner/random/hecu_smg)

/mob/living/simple_animal/hostile/blackmesa/sec
	name = "Security Guard"
	desc = "About that beer I owe'd ya!"
	icon = 'modular_skyrat/master_files/icons/mob/blackmesa.dmi'
	icon_state = "security_guard_melee"
	icon_living = "security_guard_melee"
	icon_dead = "security_guard_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_HUMANOID
	sentience_type = SENTIENCE_HUMANOID
	speak_chance = 10
	speak = list("Hey, freeman! Over here!")
	turns_per_move = 5
	speed = 0
	stat_attack = HARD_CRIT
	robust_searching = 1
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 7
	melee_damage_upper = 7
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	loot = list(/obj/effect/gibspawner/human, /obj/item/clothing/suit/armor/vest/blueshirt)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(FACTION_BLACKMESA)
	check_friendly_fire = 1
	status_flags = CANPUSH
	del_on_death = TRUE
	combat_mode = TRUE
	dodging = TRUE
	rapid_melee = 2
	footstep_type = FOOTSTEP_MOB_SHOE
	alert_sounds = list(
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance01.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance02.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance02.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance03.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance04.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance05.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance06.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance07.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance08.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance09.ogg',
		'modular_skyrat/master_files/sound/blackmesa/security_guard/annoyance10.ogg'
	)


/mob/living/simple_animal/hostile/blackmesa/sec/ranged
	ranged = TRUE
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "security_guard_ranged"
	icon_living = "security_guard_ranged"
	casingtype = /obj/item/ammo_casing/c10mm
	projectilesound = 'sound/weapons/gun/pistol/shot.ogg'
	loot = list(/obj/item/clothing/suit/armor/vest/blueshirt, /obj/item/gun/ballistic/automatic/pistol/g17)
	rapid_melee = 1

/obj/machinery/porta_turret/black_mesa
	use_power = IDLE_POWER_USE
	req_access = list(ACCESS_CENT_GENERAL)
	faction = list(FACTION_XEN, FACTION_BLACKMESA, FACTION_HECU)
	mode = TURRET_LETHAL
	uses_stored = FALSE
	max_integrity = 120
	base_icon_state = "syndie"
	lethal_projectile = /obj/projectile/beam/emitter
	lethal_projectile_sound = 'sound/weapons/laser.ogg'

/obj/machinery/porta_turret/black_mesa/assess_perp(mob/living/carbon/human/perp)
	return 10

/obj/machinery/porta_turret/black_mesa/setup(obj/item/gun/turret_gun)
	return

/obj/machinery/porta_turret/black_mesa/heavy
	name = "Heavy Defence Turret"
	max_integrity = 200
	lethal_projectile = /obj/projectile/beam/laser/heavylaser
	lethal_projectile_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/effect/random_mob_placer
	name = "mob placer"
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = "mobspawner"
	var/list/possible_mobs = list(/mob/living/simple_animal/hostile/blackmesa/xen/headcrab)

/obj/effect/random_mob_placer/Initialize(mapload)
	. = ..()
	var/mob/picked_mob = pick(possible_mobs)
	new picked_mob(loc)
	return INITIALIZE_HINT_QDEL

/obj/effect/random_mob_placer/xen
	possible_mobs = list(
		/mob/living/simple_animal/hostile/blackmesa/xen/headcrab,
		/mob/living/simple_animal/hostile/blackmesa/xen/houndeye,
		/mob/living/simple_animal/hostile/blackmesa/xen/bullsquid
	)

/obj/effect/mob_spawn/human/black_mesa
	name = "Research Facility Science Team"
	roundstart = FALSE
	death = FALSE
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	outfit = /datum/outfit/science_team
	short_desc = "You are a scientist in a top secret government facility. You blacked out. Now, you have woken up to the horrors that lay within."
	permanent = FALSE
	can_use_alias = TRUE
	any_station_species = FALSE

/datum/outfit/science_team
	name = "Scientist"
	uniform = /obj/item/clothing/under/misc/hlscience
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/laceup
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/radio, /obj/item/reagent_containers/glass/beaker)
	id = /obj/item/card/id
	id_trim = /datum/id_trim/science_team

/datum/outfit/science_team/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.faction |= FACTION_BLACKMESA

/datum/id_trim/science_team
	assignment = "Science Team Scientist"
	trim_state = "trim_scientist"
	access = list(ACCESS_RND)

/obj/effect/mob_spawn/human/black_mesa/guard
	name = "Research Facility Security Guard"
	outfit = /datum/outfit/security_guard
	short_desc = "You are a security guard in a top secret government facility. You blacked out. Now, you have woken up to the horrors that lay within. DO NOT TRY TO EXPLORE THE LEVEL. STAY AROUND YOUR AREA."

/obj/item/clothing/under/rank/security/peacekeeper/junior/sol/blackmesa
	name = "security guard uniform"
	desc = "About that beer I owe'd ya!"

/datum/outfit/security_guard
	name = "Security Guard"
	uniform = /obj/item/clothing/under/rank/security/peacekeeper/junior/sol/blackmesa
	head = /obj/item/clothing/head/helmet/blueshirt
	gloves = /obj/item/clothing/gloves/color/black
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/radio, /obj/item/gun/ballistic/automatic/pistol/g17, /obj/item/ammo_box/magazine/multi_sprite/g17)
	id = /obj/item/card/id
	id_trim = /datum/id_trim/security_guard

/datum/outfit/security_guard/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.faction |= FACTION_BLACKMESA

/datum/id_trim/security_guard
	assignment = "Security Guard"
	trim_state = "trim_securityofficer"
	access = list(ACCESS_SEC_DOORS, ACCESS_SECURITY, ACCESS_AWAY_SEC)

/obj/effect/mob_spawn/human/black_mesa/hecu
	name = "HECU"
	outfit = /datum/outfit/hecu
	short_desc = "You are an elite tactical squad deployed into the research facility to contain the infestation. DO NOT TRY TO EXPLORE THE LEVEL. STAY AROUND YOUR AREA."

/obj/item/clothing/under/rank/security/officer/hecu
	name = "hecu jumpsuit"
	desc = "A tactical HECU jumpsuit for officers complete with Nanotrasen belt buckle."
	icon = 'modular_skyrat/master_files/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'modular_skyrat/master_files/icons/mob/clothing/uniform.dmi'
	icon_state = "hecu_uniform"
	inhand_icon_state = "r_suit"

/datum/outfit/hecu
	name = "HECU Grunt"
	uniform = /obj/item/clothing/under/rank/security/officer/hecu
	head = /obj/item/clothing/head/helmet
	mask = /obj/item/clothing/mask/gas/hecu2
	gloves = /obj/item/clothing/gloves/combat
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/radio, /obj/item/gun/ballistic/automatic/assault_rifle/m16, /obj/item/ammo_box/magazine/m16 = 4, /obj/item/storage/firstaid/expeditionary)
	id = /obj/item/card/id
	id_trim = /datum/id_trim/hecu

/datum/outfit/hecu/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	H.faction |= FACTION_XEN
	H.hairstyle = "Crewcut"
	H.hair_color = COLOR_ALMOST_BLACK
	H.facial_hairstyle = "Shaved"
	H.facial_hair_color = COLOR_ALMOST_BLACK
	H.update_hair()

/datum/id_trim/hecu
	assignment = "HECU Soldier"
	trim_state = "trim_securityofficer"
	access = list(ACCESS_SEC_DOORS, ACCESS_SECURITY, ACCESS_AWAY_SEC)
