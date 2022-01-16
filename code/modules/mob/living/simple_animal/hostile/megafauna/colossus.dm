#define COLOSSUS_ENRAGED (health < maxHealth/3)

/**
 * COLOSSUS
 *
 *The colossus spawns randomly wherever a lavaland creature is able to spawn. It is powerful, ancient, and extremely deadly.
 *The colossus has a degree of sentience, proving this in speech during its attacks.
 *
 *It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.
 *
 *The colossus' true danger lies in its ranged capabilities. It fires immensely damaging death bolts that penetrate all armor in a variety of ways:
 *A. The colossus fires death bolts in alternating patterns: the cardinal directions and the diagonal directions.
 *B. The colossus fires death bolts in a shotgun-like pattern, instantly downing anything unfortunate enough to be hit by all of them.
 *C. The colossus fires a spiral of death bolts.
 *At 33% health, the colossus gains an additional attack:
 *D. The colossus fires two spirals of death bolts, spinning in opposite directions.
 *
 *When a colossus dies, it leaves behind a chunk of glowing crystal known as a black box. Anything placed inside will carry over into future rounds.
 *For instance, you could place a bag of holding into the black box, and then kill another colossus next round and retrieve the bag of holding from inside.
 *
 * Intended Difficulty: Very Hard
 */
/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "judges"
	attack_verb_simple = "judge"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = ""
	health_doll_icon = "eva"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	pixel_x = -32
	base_pixel_x = -32
	maptext_height = 96
	maptext_width = 96
	del_on_death = TRUE
	gps_name = "Angelic Signal"
	achievement_type = /datum/award/achievement/boss/colossus_kill
	crusher_achievement_type = /datum/award/achievement/boss/colossus_crusher
	score_achievement_type = /datum/award/score/colussus_score
	crusher_loot = list(/obj/structure/closet/crate/necropolis/colossus/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/colossus)
	deathmessage = "disintegrates, leaving a glowing core in its wake."
	deathsound = 'sound/magic/demon_dies.ogg'
	small_sprite_type = /datum/action/small_sprite/megafauna/colossus
	/// Spiral shots ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots/spiral_shots
	/// Random shots ablity
	var/datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe/random_shots
	/// Shotgun blast ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/shotgun_blast
	/// Directional shots ability
	var/datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating/dir_shots

/mob/living/simple_animal/hostile/megafauna/colossus/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT) //we don't want this guy to float, messes up his animations.
	spiral_shots = new /datum/action/cooldown/mob_cooldown/projectile_attack/spiral_shots()
	random_shots = new /datum/action/cooldown/mob_cooldown/projectile_attack/random_aoe()
	shotgun_blast = new /datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast()
	dir_shots = new /datum/action/cooldown/mob_cooldown/projectile_attack/dir_shots/alternating()
	spiral_shots.Grant(src)
	random_shots.Grant(src)
	shotgun_blast.Grant(src)
	dir_shots.Grant(src)
	RegisterSignal(src, COMSIG_ABILITY_STARTED, .proc/start_attack)
	RegisterSignal(src, COMSIG_ABILITY_FINISHED, .proc/finished_attack)

/mob/living/simple_animal/hostile/megafauna/colossus/Destroy()
	QDEL_NULL(spiral_shots)
	QDEL_NULL(random_shots)
	QDEL_NULL(shotgun_blast)
	QDEL_NULL(dir_shots)
	return ..()

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = clamp(((maxHealth - health)/50),0,20)

	if(client)
		return

	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message(span_colossus("\"<b>You can't dodge.</b>\""))
		ranged_cooldown = world.time + 30
		telegraph()
		dir_shots.fire_in_directions(src, target, GLOB.alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	if(prob(20+anger_modifier)) //Major attack
		spiral_shots.Trigger(target = target)
	else if(prob(20))
		random_shots.Trigger(target = target)
	else
		if(prob(70))
			shotgun_blast.Trigger(target = target)
		else
			dir_shots.Trigger(target = target)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#C80000", 1)
			shake_camera(M, 4, 3)
	playsound(src, 'sound/magic/clockwork/narsie_attack.ogg', 200, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/start_attack(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if(activated == spiral_shots)
		spiral_shots.enraged = COLOSSUS_ENRAGED
		telegraph()
		icon_state = "eva_attack"
		visible_message(COLOSSUS_ENRAGED ? span_colossus("\"<b>Die.</b>\"") : span_colossus("\"<b>Judgement.</b>\""))

/mob/living/simple_animal/hostile/megafauna/colossus/proc/finished_attack(mob/living/owner, datum/action/cooldown/finished)
	SIGNAL_HANDLER
	if(finished == spiral_shots)
		icon_state = initial(icon_state)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/enrage(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.mind)
			if(istype(H.mind.martial_art, /datum/martial_art/the_sleeping_carp))
				. = TRUE
		if (is_species(H, /datum/species/golem/sand))
			. = TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/devour(mob/living/L)
	visible_message(span_colossus("[src] disintegrates [L]!"))
	L.dust()

/obj/effect/temp_visual/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	light_system = MOVABLE_LIGHT
	light_range = 2
	duration = 8
	var/target

/obj/effect/temp_visual/at_shield/Initialize(mapload, new_target)
	. = ..()
	target = new_target
	INVOKE_ASYNC(src, /atom/movable/proc/orbit, target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/projectile/P)
	if(!stat)
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	return ..()

/obj/projectile/colossus
	name = "death bolt"
	icon_state = "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	plane = GAME_PLANE
	var/explode_hit_objects = TRUE

/obj/projectile/colossus/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(isliving(target))
		direct_target = TRUE
	return ..(target, direct_target, ignore_loc, cross_failed)

/obj/projectile/colossus/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target))
		var/mob/living/dust_mob = target
		if(dust_mob.stat == DEAD)
			dust_mob.dust()
		return
	if(!explode_hit_objects || istype(target, /obj/vehicle/sealed))
		return
	if(isturf(target) || isobj(target))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target

///Anomolous Crystal///

#define ACTIVATE_TOUCH "touch"
#define ACTIVATE_SPEECH "speech"
#define ACTIVATE_HEAT "heat"
#define ACTIVATE_BULLET "bullet"
#define ACTIVATE_ENERGY "energy"
#define ACTIVATE_BOMB "bomb"
#define ACTIVATE_MOB_BUMP "bumping"
#define ACTIVATE_WEAPON "weapon"
#define ACTIVATE_MAGIC "magic"

/obj/machinery/anomalous_crystal
	name = "anomalous crystal"
	desc = "A strange chunk of crystal, being in the presence of it fills you with equal parts excitement and dread."
	var/observer_desc = "Anomalous crystals have descriptions that only observers can see. But this one hasn't been changed from the default."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "anomaly_crystal"
	light_range = 8
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE
	anchored = FALSE
	density = TRUE
	var/activation_method
	var/list/possible_methods = list(ACTIVATE_TOUCH, ACTIVATE_SPEECH, ACTIVATE_HEAT, ACTIVATE_BULLET, ACTIVATE_ENERGY, ACTIVATE_BOMB, ACTIVATE_MOB_BUMP, ACTIVATE_WEAPON, ACTIVATE_MAGIC)
	var/activation_damage_type = null
	/// Cooldown on this crystal
	var/cooldown_add = 3 SECONDS
	/// Time needed to use this crystal
	var/use_time = 0
	/// If we are being used
	var/active = FALSE
	var/list/affected_targets = list()
	var/activation_sound = 'sound/effects/break_stone.ogg'
	COOLDOWN_DECLARE(cooldown_timer)

/obj/machinery/anomalous_crystal/Initialize(mapload)
	. = ..()
	if(!activation_method)
		activation_method = pick(possible_methods)
	become_hearing_sensitive(trait_source = ROUNDSTART_TRAIT)

/obj/machinery/anomalous_crystal/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += observer_desc
		. += "It is activated by [activation_method]."

/obj/machinery/anomalous_crystal/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	..()
	if(isliving(speaker))
		ActivationReaction(speaker, ACTIVATE_SPEECH)

/obj/machinery/anomalous_crystal/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	ActivationReaction(user, ACTIVATE_TOUCH)

/obj/machinery/anomalous_crystal/attackby(obj/item/I, mob/user, params)
	if(I.get_temperature())
		ActivationReaction(user, ACTIVATE_HEAT)
	else
		ActivationReaction(user, ACTIVATE_WEAPON)
	..()

/obj/machinery/anomalous_crystal/bullet_act(obj/projectile/P, def_zone)
	. = ..()
	if(istype(P, /obj/projectile/magic))
		ActivationReaction(P.firer, ACTIVATE_MAGIC, P.damage_type)
		return
	ActivationReaction(P.firer, P.flag, P.damage_type)

/obj/machinery/anomalous_crystal/proc/ActivationReaction(mob/user, method, damtype)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		return FALSE
	if(activation_damage_type && activation_damage_type != damtype)
		return FALSE
	if(method != activation_method)
		return FALSE
	if(active)
		return FALSE
	if(use_time)
		charge_animation()
	COOLDOWN_START(src, cooldown_timer, cooldown_add)
	playsound(user, activation_sound, 100, TRUE)
	return TRUE

/obj/machinery/anomalous_crystal/proc/charge_animation()
	icon_state = "anomaly_crystal_charging"
	active = TRUE
	set_anchored(TRUE)
	balloon_alert_to_viewers("charging...")
	playsound(src, 'sound/magic/disable_tech.ogg', 50, TRUE)
	sleep(use_time)
	icon_state = initial(icon_state)
	active = FALSE
	set_anchored(FALSE)
	return TRUE

/obj/machinery/anomalous_crystal/Bumped(atom/movable/AM)
	..()
	if(ismob(AM))
		ActivationReaction(AM, ACTIVATE_MOB_BUMP)

/obj/machinery/anomalous_crystal/ex_act()
	ActivationReaction(null, ACTIVATE_BOMB)

/obj/machinery/anomalous_crystal/honk //Strips and equips you as a clown. I apologize for nothing
	observer_desc = "This crystal strips and equips its targets as clowns."
	possible_methods = list(ACTIVATE_MOB_BUMP, ACTIVATE_SPEECH)
	activation_sound = 'sound/items/bikehorn.ogg'
	use_time = 3 SECONDS

/obj/machinery/anomalous_crystal/honk/ActivationReaction(mob/user)
	if(..() && ishuman(user) && !(user in affected_targets) && (user in viewers(src)))
		var/mob/living/carbon/human/new_clown = user
		for(var/obj/item/to_strip in new_clown)
			new_clown.dropItemToGround(to_strip)
		new_clown.dress_up_as_job(SSjob.GetJobType(/datum/job/clown))
		affected_targets.Add(new_clown)

/obj/machinery/anomalous_crystal/theme_warp //Warps the area you're in to look like a new one
	observer_desc = "This crystal warps the area around it to a theme."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 20 SECONDS
	use_time = 5 SECONDS
	var/terrain_theme = "winter"
	var/NewTerrainFloors
	var/NewTerrainWalls
	var/NewTerrainChairs
	var/NewTerrainTables
	var/list/NewFlora = list()
	var/florachance = 8

/obj/machinery/anomalous_crystal/theme_warp/Initialize(mapload)
	. = ..()
	terrain_theme = pick("lavaland","winter","jungle","ayy lmao")
	observer_desc = "This crystal changes the area around it to match the theme of \"[terrain_theme]\"."

	switch(terrain_theme)
		if("lavaland")//Depressurizes the place... and free cult metal, I guess.
			NewTerrainFloors = /turf/open/floor/grass/snow/basalt/safe
			NewTerrainWalls = /turf/closed/wall/mineral/cult
			NewFlora = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)
			florachance = 1
		if("winter") //Snow terrain is slow to move in and cold! Get the assistants to shovel your driveway.
			NewTerrainFloors = /turf/open/floor/grass/snow/actually_safe
			NewTerrainWalls = /turf/closed/wall/mineral/wood
			NewTerrainChairs = /obj/structure/chair/wood
			NewTerrainTables = /obj/structure/table/glass
			NewFlora = list(/obj/structure/flora/grass/green, /obj/structure/flora/grass/brown, /obj/structure/flora/grass/both)
		if("jungle") //Beneficial due to actually having breathable air. Plus, monkeys and bows and arrows.
			NewTerrainFloors = /turf/open/floor/grass
			NewTerrainWalls = /turf/closed/wall/mineral/wood
			NewTerrainChairs = /obj/structure/chair/wood
			NewTerrainTables = /obj/structure/table/wood
			NewFlora = list(/obj/structure/flora/ausbushes/sparsegrass, /obj/structure/flora/ausbushes/fernybush, /obj/structure/flora/ausbushes/leafybush,
							/obj/structure/flora/ausbushes/grassybush, /obj/structure/flora/ausbushes/sunnybush, /obj/structure/flora/tree/palm, /mob/living/carbon/human/species/monkey)
			florachance = 20
		if("ayy lmao") //Beneficial, turns stuff into alien alloy which is useful to cargo and research. Also repairs atmos.
			NewTerrainFloors = /turf/open/floor/plating/abductor
			NewTerrainWalls = /turf/closed/wall/mineral/abductor
			NewTerrainChairs = /obj/structure/bed/abductor //ayys apparently don't have chairs. An entire species of people who only recline.
			NewTerrainTables = /obj/structure/table/abductor

/obj/machinery/anomalous_crystal/theme_warp/ActivationReaction(mob/user, method)
	if(..())
		var/area/A = get_area(src)
		if(!A.outdoors && !(A in affected_targets))
			for(var/atom/Stuff in A)
				if(isturf(Stuff))
					var/turf/T = Stuff
					if((isspaceturf(T) || isfloorturf(T)) && NewTerrainFloors)
						var/turf/open/O = T.ChangeTurf(NewTerrainFloors, flags = CHANGETURF_IGNORE_AIR)
						if(prob(florachance) && NewFlora.len && !O.is_blocked_turf(TRUE))
							var/atom/Picked = pick(NewFlora)
							new Picked(O)
						continue
					if(iswallturf(T) && NewTerrainWalls)
						T.ChangeTurf(NewTerrainWalls)
						continue
				if(istype(Stuff, /obj/structure/chair) && NewTerrainChairs)
					var/obj/structure/chair/Original = Stuff
					var/obj/structure/chair/C = new NewTerrainChairs(Original.loc)
					C.setDir(Original.dir)
					qdel(Stuff)
					continue
				if(istype(Stuff, /obj/structure/table) && NewTerrainTables)
					new NewTerrainTables(Stuff.loc)
					continue
			affected_targets += A

/obj/machinery/anomalous_crystal/emitter //Generates a projectile when interacted with
	observer_desc = "This crystal generates a projectile when activated."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 5 SECONDS
	var/obj/projectile/generated_projectile = /obj/projectile/colossus

/obj/machinery/anomalous_crystal/emitter/Initialize(mapload)
	. = ..()
	observer_desc = "This crystal generates \a [initial(generated_projectile.name)] when activated."

/obj/machinery/anomalous_crystal/emitter/ActivationReaction(mob/user, method)
	if(..())
		var/obj/projectile/P = new generated_projectile(get_turf(src))
		P.firer = src
		P.fire(dir2angle(dir))

/obj/machinery/anomalous_crystal/dark_reprise //Revives anyone nearby, but turns them into shadowpeople and renders them uncloneable, so the crystal is your only hope of getting up again if you go down.
	observer_desc = "When activated, this crystal revives anyone nearby, but turns them into Shadowpeople and makes them unclonable, making the crystal their only hope of getting up again."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/hallucinations/growl1.ogg'
	use_time = 3 SECONDS

/obj/machinery/anomalous_crystal/dark_reprise/ActivationReaction(mob/user, method)
	if(..())
		for(var/i in range(1, src))
			if(isturf(i))
				new /obj/effect/temp_visual/cult/sparks(i)
				continue
			if(ishuman(i))
				var/mob/living/carbon/human/H = i
				if(H.stat == DEAD)
					H.set_species(/datum/species/shadow, 1)
					H.regenerate_limbs()
					H.regenerate_organs()
					H.revive(full_heal = TRUE, admin_revive = FALSE)
					ADD_TRAIT(H, TRAIT_BADDNA, MAGIC_TRAIT) //Free revives, but significantly limits your options for reviving except via the crystal
					H.grab_ghost(force = TRUE)

/obj/machinery/anomalous_crystal/helpers //Lets ghost spawn as helpful creatures that can only heal people slightly. Incredibly fragile and they can't converse with humans
	observer_desc = "This crystal allows ghosts to turn into a fragile creature that can heal people."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/effects/ghost2.ogg'
	use_time = 5 SECONDS
	var/ready_to_deploy = FALSE

/obj/machinery/anomalous_crystal/helpers/ActivationReaction(mob/user, method)
	if(..() && !ready_to_deploy)
		SSpoints_of_interest.make_point_of_interest(src)
		ready_to_deploy = TRUE
		notify_ghosts("An anomalous crystal has been activated in [get_area(src)]! This crystal can always be used by ghosts hereafter.", enter_link = "<a href=?src=[REF(src)];ghostjoin=1>(Click to enter)</a>", ghost_sound = 'sound/effects/ghost2.ogg', source = src, action = NOTIFY_ATTACK, header = "Anomalous crystal activated")

/obj/machinery/anomalous_crystal/helpers/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(ready_to_deploy)
		var/be_helper = tgui_alert(usr,"Become a Lightgeist? (Warning, You can no longer be revived!)",,list("Yes","No"))
		if(be_helper == "Yes" && !QDELETED(src) && isobserver(user))
			var/mob/living/simple_animal/hostile/lightgeist/W = new /mob/living/simple_animal/hostile/lightgeist(get_turf(loc))
			W.key = user.key


/obj/machinery/anomalous_crystal/helpers/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/mob/living/simple_animal/hostile/lightgeist
	name = "lightgeist"
	desc = "This small floating creature is a completely unknown form of life... being near it fills you with a sense of tranquility."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	response_help_continuous = "waves away"
	response_help_simple = "wave away"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brush aside"
	response_harm_continuous = "disrupts"
	response_harm_simple = "disrupt"
	speak_emote = list("oscillates")
	maxHealth = 2
	health = 2
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	friendly_verb_continuous = "taps"
	friendly_verb_simple = "tap"
	density = FALSE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	atom_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "warps"
	verb_ask = "floats inquisitively"
	verb_exclaim = "zaps"
	verb_yell = "bangs"
	initial_language_holder = /datum/language_holder/lightbringer
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	light_range = 4
	faction = list("neutral")
	del_on_death = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 1500
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	AIStatus = AI_OFF
	stop_automated_movement = TRUE

/mob/living/simple_animal/hostile/lightgeist/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	remove_verb(src, /mob/living/verb/pulled)
	remove_verb(src, /mob/verb/me_verb)
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/lightgeist/AttackingTarget()
	if(isliving(target) && target != src)
		var/mob/living/L = target
		if(L.stat != DEAD)
			L.heal_overall_damage(melee_damage_upper, melee_damage_upper)
			new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")
			visible_message(span_notice("[src] mends the wounds of [target]."),span_notice("You mend the wounds of [target]."))

/mob/living/simple_animal/hostile/lightgeist/ghost()
	. = ..()
	if(.)
		death()

/obj/machinery/anomalous_crystal/possessor //Allows you to bodyjack small animals, then exit them at your leisure, but you can only do this once per activation. Because they blow up. Also, if the bodyjacked animal dies, SO DO YOU.
	observer_desc = "When activated, this crystal allows you to take over small animals, and then exit them at the possessors leisure. Exiting the animal kills it, and if you die while possessing the animal, you die as well."
	activation_method = ACTIVATE_TOUCH
	use_time = 1 SECONDS

/obj/machinery/anomalous_crystal/possessor/ActivationReaction(mob/user, method)
	if(..())
		if(ishuman(user))
			var/mobcheck = FALSE
			for(var/mob/living/simple_animal/A in range(1, src))
				if(A.melee_damage_upper > 5 || A.atom_size >= MOB_SIZE_LARGE || A.ckey || A.stat)
					break
				var/obj/structure/closet/stasis/S = new /obj/structure/closet/stasis(A)
				user.forceMove(S)
				mobcheck = TRUE
				break
			if(!mobcheck)
				new /mob/living/basic/cockroach(get_step(src,dir)) //Just in case there aren't any animals on the station, this will leave you with a terrible option to possess if you feel like it //i found it funny that in the file for a giant angel beast theres a cockroach

/obj/structure/closet/stasis
	name = "quantum entanglement stasis warp field"
	desc = "You can hardly comprehend this thing... which is why you can't see it."
	icon_state = null //This shouldn't even be visible, so if it DOES show up, at least nobody will notice
	enable_door_overlay = FALSE //For obvious reasons
	density = TRUE
	anchored = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/mob/living/simple_animal/holder_animal

/obj/structure/closet/stasis/process()
	if(holder_animal)
		if(holder_animal.stat == DEAD)
			dump_contents()
			holder_animal.gib()
			return

/obj/structure/closet/stasis/Initialize(mapload)
	. = ..()
	if(isanimal(loc))
		holder_animal = loc
	START_PROCESSING(SSobj, src)

/obj/structure/closet/stasis/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(isliving(arrived) && holder_animal)
		var/mob/living/L = arrived
		L.notransform = 1
		ADD_TRAIT(L, TRAIT_MUTE, STASIS_MUTE)
		L.status_flags |= GODMODE
		L.mind.transfer_to(holder_animal)
		var/obj/effect/proc_holder/spell/targeted/exit_possession/P = new /obj/effect/proc_holder/spell/targeted/exit_possession
		holder_animal.mind.AddSpell(P)
		remove_verb(holder_animal, /mob/living/verb/pulled)

/obj/structure/closet/stasis/dump_contents(kill = 1)
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/L in src)
		REMOVE_TRAIT(L, TRAIT_MUTE, STASIS_MUTE)
		L.status_flags &= ~GODMODE
		L.notransform = 0
		if(holder_animal)
			holder_animal.mind.transfer_to(L)
			L.mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/exit_possession)
		if(kill || !isanimal(loc))
			L.death(0)
	..()

/obj/structure/closet/stasis/emp_act()
	return

/obj/structure/closet/stasis/ex_act()
	return

/obj/effect/proc_holder/spell/targeted/exit_possession
	name = "Exit Possession"
	desc = "Exits the body you are possessing."
	charge_max = 60
	clothes_req = 0
	invocation_type = "none"
	max_targets = 1
	range = -1
	include_user = TRUE
	selection_type = "view"
	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "exit_possession"
	sound = null

/obj/effect/proc_holder/spell/targeted/exit_possession/cast(list/targets, mob/living/user = usr)
	if(!isfloorturf(user.loc))
		return
	var/datum/mind/target_mind = user.mind
	for(var/i in user)
		if(istype(i, /obj/structure/closet/stasis))
			var/obj/structure/closet/stasis/S = i
			S.dump_contents(0)
			qdel(S)
			break
	user.gib()
	target_mind.RemoveSpell(/obj/effect/proc_holder/spell/targeted/exit_possession)


#undef ACTIVATE_TOUCH
#undef ACTIVATE_SPEECH
#undef ACTIVATE_HEAT
#undef ACTIVATE_BULLET
#undef ACTIVATE_ENERGY
#undef ACTIVATE_BOMB
#undef ACTIVATE_MOB_BUMP
#undef ACTIVATE_WEAPON
#undef ACTIVATE_MAGIC
