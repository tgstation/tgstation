/**
 *LEGION
 *
 *Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
 *Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort. LOL
 *
 *It has three attacks.
 *Spawn Skull. Most of the time it will use this attack. Spawns a single legion skull.
 *Spawn Sentinel. The legion will spawn up to three sentinels, depending on its size.
 *CHARGE! The legion starts spinning and tries to melee the player. It will try to flick itself towards the player, dealing some damage if it hits.
 *
 *When Legion dies, it will split into three smaller skulls up to three times.
 *If you kill all of the smaller ones it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.
 *
 *Difficulty: Medium
 *
 *SHITCODE AHEAD. BE ADVISED. Also comment extravaganza
 */

#define LEGION_LARGE 3
#define LEGION_MEDIUM 2
#define LEGION_SMALL 1

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 700
	maxHealth = 700
	icon_state = "mega_legion"
	icon_living = "mega_legion"
	health_doll_icon = "mega_legion"
	desc = "One of many."
	icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/effects/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 25
	melee_damage_upper = 25
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL|MOB_UNDEAD|MOB_MINING
	speed = 5
	ranged = TRUE
	del_on_death = TRUE
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 2 SECONDS
	gps_name = "Echoing Signal"
	achievement_type = /datum/award/achievement/boss/legion_kill
	crusher_achievement_type = /datum/award/achievement/boss/legion_crusher
	score_achievement_type = /datum/award/score/legion_score
	SET_BASE_PIXEL(-32, -16)
	maptext_height = 96
	maptext_width = 96
	loot = list(/obj/item/stack/sheet/bone = 3)
	vision_range = 13
	wander = FALSE
	elimination = TRUE
	appearance_flags = LONG_GLIDE
	mouse_opacity = MOUSE_OPACITY_ICON
	var/size = LEGION_LARGE
	/// Create Skulls ability
	var/datum/action/cooldown/mob_cooldown/create_legion_skull/create_legion_skull
	/// Charge Target Ability
	var/datum/action/cooldown/mob_cooldown/chase_target/chase_target
	/// Create Turrets Ability
	var/datum/action/cooldown/mob_cooldown/create_legion_turrets/create_legion_turrets

/mob/living/simple_animal/hostile/megafauna/legion/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	create_legion_skull = new(src)
	chase_target = new(src)
	chase_target.size = size
	create_legion_turrets = new(src)
	create_legion_turrets.maximum_turrets = size * 2
	create_legion_skull.Grant(src)
	chase_target.Grant(src)
	create_legion_turrets.Grant(src)

/mob/living/simple_animal/hostile/megafauna/legion/Destroy()
	create_legion_skull = null
	chase_target = null
	create_legion_turrets = null
	return ..()

/mob/living/simple_animal/hostile/megafauna/legion/medium
	icon = 'icons/mob/simple/lavaland/64x64megafauna.dmi'
	pixel_x = -16
	pixel_y = -8
	maxHealth = 350
	size = LEGION_MEDIUM

/mob/living/simple_animal/hostile/megafauna/legion/medium/left
	icon_state = "mega_legion_left"

/mob/living/simple_animal/hostile/megafauna/legion/medium/eye
	icon_state = "mega_legion_eye"

/mob/living/simple_animal/hostile/megafauna/legion/medium/right
	icon_state = "mega_legion_right"

/mob/living/simple_animal/hostile/megafauna/legion/small
	icon = 'icons/mob/simple/lavaland/lavaland_monsters.dmi'
	icon_state = "mega_legion"
	pixel_x = 0
	pixel_y = 0
	maxHealth = 200
	size = LEGION_SMALL

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(client)
		return

	switch(rand(4)) //Larger skulls use more attacks.
		if(0 to 2)
			create_legion_skull.Trigger(target = target)
		if(3)
			chase_target.Trigger(target = target)
		if(4)
			create_legion_turrets.Trigger(target = target)

///Deals some extra damage on throw impact.
/mob/living/simple_animal/hostile/megafauna/legion/throw_impact(mob/living/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(istype(hit_atom))
		playsound(src, attack_sound, 100, TRUE)
		hit_atom.apply_damage(22 * size / 2, wound_bonus = CANT_WOUND) //It gets pretty hard to dodge the skulls when there are a lot of them. Scales down with size
		hit_atom.safe_throw_at(get_step(src, get_dir(src, hit_atom)), 2) //Some knockback. Prevent the legion from melee directly after the throw.

/mob/living/simple_animal/hostile/megafauna/legion/GiveTarget(new_target)
	. = ..()
	if(target)
		wander = TRUE

///This makes sure that the legion door opens on taking damage, so you can't cheese this boss.
/mob/living/simple_animal/hostile/megafauna/legion/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(GLOB.necropolis_gate && true_spawn)
		GLOB.necropolis_gate.toggle_the_gate(null, TRUE) //very clever.
	return ..()


///In addition to parent functionality, this will also turn the target into a small legion if they are unconscious.
/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!. || !ishuman(target))
		return
	var/mob/living/living_target = target
	switch(living_target.stat)
		if(UNCONSCIOUS, HARD_CRIT)
			var/mob/living/basic/legion_brood/legion = new(loc)
			legion.infest(living_target)

///Special snowflake death() here. Can only die if size is 1 or lower and HP is 0 or below.
/mob/living/simple_animal/hostile/megafauna/legion/death()
	//Make sure we didn't get cheesed
	if(health > 0)
		return
	if(Split())
		return
	//We check what loot we should drop.
	var/last_legion = TRUE
	for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_living_list)
		if(other != src)
			last_legion = FALSE
			break
	if(last_legion)
		loot = list(/obj/item/storm_staff)
		elimination = FALSE
	else if(prob(20)) //20% chance for sick lootz.
		loot = list(/obj/structure/closet/crate/necropolis/tendril)
		if(!true_spawn)
			loot = null
	return ..()

///Splits legion into smaller skulls.
/mob/living/simple_animal/hostile/megafauna/legion/proc/Split()
	size--
	switch(size)
		if (LEGION_SMALL)
			for (var/i in 0 to 2)
				new /mob/living/simple_animal/hostile/megafauna/legion/small(loc)
		if (LEGION_MEDIUM)
			new /mob/living/simple_animal/hostile/megafauna/legion/medium/left(loc)
			new /mob/living/simple_animal/hostile/megafauna/legion/medium/right(loc)
			new /mob/living/simple_animal/hostile/megafauna/legion/medium/eye(loc)

#undef LEGION_LARGE
#undef LEGION_MEDIUM
#undef LEGION_SMALL
