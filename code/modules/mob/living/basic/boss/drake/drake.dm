///used to see if the drake is enraged or not
#define DRAKE_ENRAGED (health < maxHealth*0.5)

#define SWOOP_DAMAGEABLE 1
#define SWOOP_INVULNERABLE 2

/*£
 *
 *ASH DRAKE
 *
 *Ash drakes spawn randomly wherever a lavaland creature is able to spawn. They are the draconic guardians of the Necropolis.
 *
 *It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.
 *
 *Whenever possible, the drake will breathe fire directly at it's target, igniting and heavily damaging anything caught in the blast.
 *It also often causes lava to pool from the ground around you - many nearby turfs will temporarily turn into lava, dealing damage to anything on the turfs.
 *The drake also utilizes its wings to fly into the sky, flying after its target and attempting to slam down on them. Anything near when it slams down takes huge damage.
 *Sometimes it will chain these swooping attacks over and over, making swiftness a necessity.
 *Sometimes, it will encase its target in an arena of lava
 *
 *When an ash drake dies, it leaves behind a chest that can contain four things:
 *A. A spectral blade that allows its wielder to call ghosts to it, enhancing its power
 *B. A lava staff that allows its wielder to create lava
 *C. A spellbook and wand of fireballs
 *D. A bottle of dragon's blood with several effects, including turning its imbiber into a drake themselves.
 *
 *When butchered, they leave behind diamonds, sinew, bone, and ash drake hide. Ash drake hide can be used to create a hooded cloak that protects its wearer from ash storms.
 *
 *Intended Difficulty: Medium
 */

/mob/living/basic/boss/dragon
	name = "ash drake"
	desc = "Guardians of the necropolis."
	health = 2500
	maxHealth = 2500
	attack_verb_continuous = "chomps"
	attack_verb_simple = "chomp"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	icon = 'icons/mob/simple/lavaland/96x96megafauna.dmi'
	icon_state = "dragon"
	icon_living = "dragon"
	icon_dead = "dragon_dead"
	health_doll_icon = "dragon"
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	speed = 5
	pixel_x = -32
	base_pixel_x = -32
	maptext_height = 64
	maptext_width = 64
	crusher_loot = list(/obj/structure/closet/crate/necropolis/dragon/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/dragon)
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	guaranteed_butcher_results = list(/obj/item/stack/sheet/animalhide/ashdrake = 10)
	gps_name = "Fiery Signal"
	achievement_type = /datum/award/achievement/boss/drake_kill
	crusher_achievement_type = /datum/award/achievement/boss/drake_crusher
	score_achievement_type = /datum/award/score/drake_score
	death_message = "collapses into a pile of bones, its flesh sloughing away."
	death_sound = 'sound/magic/demon_dies.ogg'
	summon_line = "ROOOOOOOOAAAAAAAAAAAR!"
	ai_controller = /datum/ai_controller/basic_controller/drake
	/// Fire cone ability
	var/datum/action/cooldown/mob_cooldown/fire_breath/cone/fire_cone
	/// Meteors ability
	var/datum/action/cooldown/mob_cooldown/meteors/meteors
	/// Mass fire ability
	var/datum/action/cooldown/mob_cooldown/fire_breath/mass_fire/mass_fire
	/// Lava swoop ability
	var/datum/action/cooldown/mob_cooldown/lava_swoop/lava_swoop
	/// are we swooping
	var/swooping = NONE

/mob/living/basic/boss/dragon/Initialize(mapload)
	. = ..()
	fire_cone = new(src)
	meteors = new(src)
	mass_fire = new(src)
	lava_swoop = new(src)
	fire_cone.Grant(src)
	meteors.Grant(src)
	mass_fire.Grant(src)
	lava_swoop.Grant(src)
	RegisterSignal(src, COMSIG_MOB_ABILITY_STARTED, PROC_REF(start_attack))
	RegisterSignal(src, COMSIG_MOB_ABILITY_FINISHED, PROC_REF(finished_attack))
	RegisterSignal(src, COMSIG_SWOOP_INVULNERABILITY_STARTED, PROC_REF(swoop_invulnerability_started))
	RegisterSignal(src, COMSIG_LAVA_ARENA_FAILED, PROC_REF(on_arena_fail))
	AddElement(/datum/element/change_force_on_death, move_force = MOVE_FORCE_DEFAULT)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)

/mob/living/basic/boss/dragon/Destroy()
	fire_cone = null
	meteors = null
	mass_fire = null
	lava_swoop = null
	return ..()

/mob/living/basic/boss/dragon/RangedAttack(atom/target)
	if(!combat_mode)
		return

	if(swooping)
		return

	if(client)
		return

	var/anger_modifier = ai_controller?.blackboard[BB_ANGER_MODIFIER]
	if(prob(15 + anger_modifier))
		if(DRAKE_ENRAGED)
			// Lava Arena
			lava_swoop.Trigger(target = target)
			return
		// Lava Pools
		if(lava_swoop.Trigger(target = target))
			fire_cone.StartCooldown(0)
			fire_cone.Trigger(target = target)
			meteors.StartCooldown(0)
			meteors.Trigger(target = target)
			return
	else if(prob(10+anger_modifier) && DRAKE_ENRAGED)
		mass_fire.Trigger(target = target)
		return
	if(fire_cone.Trigger(target = target) && prob(50))
		meteors.StartCooldown(0)
		meteors.Trigger(target = target)

/mob/living/basic/boss/dragon/proc/start_attack(mob/living/owner, datum/action/cooldown/activated)
	SIGNAL_HANDLER
	if(activated == lava_swoop)
		icon_state = "dragon_shadow"
		swooping = SWOOP_DAMAGEABLE

/mob/living/basic/boss/dragon/proc/swoop_invulnerability_started()
	SIGNAL_HANDLER
	swooping = SWOOP_INVULNERABLE

/mob/living/basic/boss/dragon/proc/finished_attack(mob/living/owner, datum/action/cooldown/finished)
	SIGNAL_HANDLER
	if(finished == lava_swoop)
		icon_state = initial(icon_state)
		swooping = NONE

/mob/living/basic/boss/dragon/proc/on_arena_fail()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(arena_escape_enrage))

/mob/living/basic/boss/dragon/proc/arena_escape_enrage() // you ran somehow / teleported away from my arena attack now i'm mad fucker
	if(stat)
		return
	visible_message(span_boldwarning("[src] starts to glow vibrantly as its wounds close up!"))
	adjustBruteLoss(-250) // yeah you're gonna pay for that, don't run nerd
	add_atom_colour(rgb(255, 255, 0), TEMPORARY_COLOUR_PRIORITY)
	set_varspeed(speed / 2)
	set_light_range(10)
	addtimer(CALLBACK(src, PROC_REF(stop_rage)), 5 SECONDS, TIMER_UNIQUE)

/mob/living/basic/boss/dragon/proc/stop_rage()
	if(stat)
		return
	mass_fire.Activate(ai_controller?.blackboard[BB_BASIC_MOB_CURRENT_TARGET])
	mass_fire.StartCooldown(8 SECONDS)
	set_varspeed(initial(speed))
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	set_light_range(initial(light_range))

/mob/living/basic/boss/dragon/ex_act(severity, target)
	if(severity <= EXPLODE_LIGHT)
		return FALSE
	return ..()

/mob/living/basic/boss/dragon/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && (swooping & SWOOP_INVULNERABLE))
		return FALSE
	if(amount <= 0)
		return ..()
	ai_controller?.set_blackboard_key(BB_ANGER_MODIFIER, clamp(((maxHealth - health)/60),0,20))
	lava_swoop.enraged = DRAKE_ENRAGED
	return ..()

/mob/living/basic/boss/dragon/visible_message(message, self_message, blind_message, vision_distance = DEFAULT_MESSAGE_RANGE, list/ignored_mobs, visible_message_flags = NONE)
	if(swooping & SWOOP_INVULNERABLE) //to suppress attack messages without overriding every single proc that could send a message saying we got hit
		return
	return ..()

/mob/living/basic/boss/dragon/melee_attack(mob/living/target, list/modifiers, ignore_cooldown = FALSE)
	if(!swooping)
		return ..()

/mob/living/basic/boss/dragon/Move()
	if(!swooping)
		..()

/obj/effect/temp_visual/lava_warning
	icon_state = "lavastaff_warn"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 2
	duration = 13
	var/mob/owner

/obj/effect/temp_visual/lava_warning/Initialize(mapload, reset_time = 10)
	. = ..()
	playsound(loc,'sound/magic/fleshtostone.ogg', 80, TRUE)
	src.alpha = 63.75
	animate(src, alpha = 255, time = duration)
	addtimer(CALLBACK(src, PROC_REF(fall), reset_time), duration, TIMER_UNIQUE)

/obj/effect/temp_visual/lava_warning/proc/fall(reset_time)
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fireball.ogg', 200, TRUE)

	for(var/mob/living/L in T.contents - owner)
		if(istype(L, /mob/living/basic/boss/dragon))
			continue
		L.adjustFireLoss(10)
		to_chat(L, span_userdanger("You fall directly into the pool of lava!"))

	// deals damage to mechs
	for(var/obj/vehicle/sealed/mecha/M in T.contents)
		M.take_damage(45, BRUTE, MELEE, 1)

	// changes turf to lava temporarily
	if(!isclosedturf(T) && !islava(T))
		var/lava_turf = /turf/open/lava/smooth
		var/reset_turf = T.type
		T.TerraformTurf(lava_turf, flags = CHANGETURF_INHERIT_AIR)
		addtimer(CALLBACK(T, TYPE_PROC_REF(/turf, ChangeTurf), reset_turf, null, CHANGETURF_INHERIT_AIR), reset_time, TIMER_OVERRIDE|TIMER_UNIQUE)

/obj/effect/temp_visual/drakewall
	desc = "An ash drakes true flame."
	name = "Fire Barrier"
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	can_atmos_pass = ATMOS_PASS_DENSITY
	duration = 82
	color = COLOR_DARK_ORANGE

/obj/effect/temp_visual/lava_safe
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "trap-earth"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 13

/obj/effect/temp_visual/fireball
	icon = 'icons/effects/magic.dmi'
	icon_state = "fireball"
	name = "fireball"
	desc = "Get out of the way!"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	randomdir = FALSE
	duration = 9
	pixel_z = 270

/obj/effect/temp_visual/fireball/Initialize(mapload)
	. = ..()
	animate(src, pixel_z = 0, time = duration)

/obj/effect/temp_visual/target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	light_range = 2
	duration = 9

/obj/effect/temp_visual/target/Initialize(mapload, list/flame_hit)
	. = ..()
	var/turf/T = get_turf(src)
	playsound(T,'sound/magic/fleshtostone.ogg', 80, TRUE)
	new /obj/effect/temp_visual/fireball(T)
	addtimer(CALLBACK(src, PROC_REF(fall), flame_hit), duration, TIMER_UNIQUE)

/obj/effect/temp_visual/target/proc/fall(list/flame_hit)
	var/turf/T = get_turf(src)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled()
	playsound(T, SFX_EXPLOSION, 80, TRUE)
	new /obj/effect/hotspot(T)
	T.hotspot_expose(DRAKE_FIRE_TEMP, DRAKE_FIRE_EXPOSURE, 1)
	for(var/mob/living/L in T.contents)
		if(istype(L, /mob/living/basic/boss/dragon))
			continue
		if(islist(flame_hit) && !flame_hit[L])
			L.adjustFireLoss(40)
			to_chat(L, span_userdanger("You're hit by the drake's fire breath!"))
			flame_hit[L] = TRUE
		else
			L.adjustFireLoss(10) //if we've already hit them, do way less damage

/mob/living/basic/boss/dragon/lesser
	name = "lesser ash drake"
	maxHealth = 200
	health = 200
	faction = list(FACTION_NEUTRAL)
	obj_damage = 80
	melee_damage_upper = 30
	melee_damage_lower = 30
	mouse_opacity = MOUSE_OPACITY_ICON
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, STAMINA = 0, OXY = 1)
	loot = list()
	crusher_loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/sinew = 5, /obj/item/stack/sheet/bone = 30)
	attack_action_types = list()

/mob/living/basic/boss/dragon/lesser/Initialize(mapload)
	. = ..()
	meteors.Remove(src)
	mass_fire.Remove(src)
	lava_swoop.cooldown_time = 20 SECONDS

/mob/living/basic/boss/dragon/lesser/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	lava_swoop?.enraged = FALSE // In case taking damage caused us to start deleting ourselves

/mob/living/basic/boss/dragon/lesser/grant_achievement(medaltype,scoretype)
	return

#undef DRAKE_ENRAGED
#undef SWOOP_DAMAGEABLE
#undef SWOOP_INVULNERABLE
