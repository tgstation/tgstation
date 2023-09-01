// Abilities:
// Bone Shotgun - Projectiles that reflect off of walls
// Targeted Eye Lasers - Trails players
// Ball spin - Increases the speed of the balls that rotate around the boss
// Summon Monsters (Blood Rune Required) - Self Explanatory
// AOE Bone Toss (Shadow Rune Required) - Bone Shotgun but in a 360
// Ball Spin Fast (Ice Rune Required) - Spins the balls even faster
// Targeted Burn (Smoke Rune Required) - Makes a sliver of the arena a damage space
// Arena Slam (Shadow Rune & Smoke Rune Required) - An AOE that expands outward that can be dodged by running through it, like the wendigo slam
// Tricky Eye Lasers (Shadow Rune Required) - Same as eye lasers but targets ahead of you where you're running

/datum/action/cooldown/mob_cooldown/projectile_attack/shotgun_blast/bone_shotgun
	name = "Bone Shotgun Fire"
	button_icon = 'icons/obj/weapons/guns/ballistic.dmi'
	button_icon_state = "shotgun"
	desc = "Fires projectiles in a shotgun pattern that bounce."
	cooldown_time = 3 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_NONE
	projectile_type = /obj/projectile/legion_bone
	projectile_sound = 'sound/magic/clockwork/invoke_general.ogg'
	shot_angles = list(-40, -20, 0, 20, 40)

/obj/projectile/legion_bone
	name = "rapidly spinning bone"
	desc = "Spinning so fast..."
	icon_state = "chronobolt"
	damage = 10
	armour_penetration = 100
	range = 25
	speed = 1
	pixel_speed_multiplier = 0.5
	ricochets_max = 100
	ricochet_chance = 100000
	ricochet_shoots_firer = FALSE
	ricochet_incidence_leeway = 0
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE
	plane = GAME_PLANE
	var/bone_spin = 0
	var/bone_spin_rate = 10

/obj/projectile/legion_bone/pixel_move(trajectory_multiplier, hitscanning = FALSE)
	. = ..()
	var/matrix/matrix = new
	matrix.Turn(bone_spin)
	transform = matrix
	bone_spin += bone_spin_rate

/datum/action/cooldown/mob_cooldown/legion_lasers
	name = "Lasers"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to make lasers that chase after all targets in your arena."
	cooldown_time = 15 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_NONE
	var/laser_amount = 6
	var/radius = 2

/datum/action/cooldown/mob_cooldown/legion_lasers/Activate(atom/target_atom)
	disable_cooldown_actions()
	create_meteors(target_atom)
	StartCooldown()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/cooldown, enable_cooldown_actions)), 2 SECONDS)
	return TRUE

/datum/action/cooldown/mob_cooldown/legion_lasers/proc/create_meteors(atom/target)
	if(!target)
		return
	target.visible_message(span_boldwarning("Lasers rain from the sky!"))
	for(var/i in 1 to laser_amount)
		for(var/turf/open/targetturf in urange(radius, target, FALSE, FALSE))
			new /obj/effect/temp_visual/target(targetturf)
		SLEEP_CHECK_DEATH(0.5 SECONDS, owner)

/datum/action/cooldown/mob_cooldown/orbiting_projectile
	name = "Orbiting Projectiles"
	button_icon = 'icons/obj/weapons/guns/ballistic.dmi'
	button_icon_state = "shotgun"
	desc = "Passively has projectiles that orbit them. Using this ability toggles them being active."
	cooldown_time = 3 SECONDS
	shared_cooldown = MOB_SHARED_COOLDOWN_NONE
	var/projectile_type = /obj/projectile/legion_bone
	// Radius that the projectiles orbit around the owner
	var/list/radius = list(3, 6, 9)
	var/projectile_speed = 1

/datum/action/cooldown/mob_cooldown/orbiting_projectile/Activate(atom/target_atom)
	disable_cooldown_actions()
	//create_meteors(target_atom)
	StartCooldown()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum/action/cooldown, enable_cooldown_actions)), 2 SECONDS)
	return TRUE
