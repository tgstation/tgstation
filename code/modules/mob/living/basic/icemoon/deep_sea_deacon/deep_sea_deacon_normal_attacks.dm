#define SWORD_DROP_TIMER 0.75 SECONDS

////celestial beams attack
/datum/action/cooldown/mob_cooldown/light_beam
	name = "Holy Light"
	button_icon = 'icons/effects/beam.dmi'
	button_icon_state = "light_beam"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Bathe your victim in holy rays of light."
	cooldown_time = 25 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	/// time between each droplet launched
	var/fire_interval = 3 SECONDS
	///how many turfs should we pick every so often?
	var/turf_pick = 7
	///how many times do we rain down a barrage?
	var/rain_down_count = 4

/datum/action/cooldown/mob_cooldown/light_beam/Activate(atom/target)
	if(isnull(target))
		return FALSE
	for(var/count in 0 to rain_down_count)
		addtimer(CALLBACK(src, PROC_REF(shoot_light), target), count * fire_interval)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/light_beam/proc/shoot_light(atom/target)
	var/turf/target_turf = get_turf(target)
	new /obj/effect/temp_visual/devestating_light(target_turf)
	new /obj/effect/temp_visual/shadow_telegraph/light_beam(target_turf)
	var/list/surrounding_turfs = RANGE_TURFS(5, target)
	if(!length(surrounding_turfs))
		return
	shuffle_inplace(surrounding_turfs)
	for(var/count in 1 to min(turf_pick, length(surrounding_turfs)))
		var/turf/curr_turf = surrounding_turfs[count]
		new /obj/effect/temp_visual/devestating_light(curr_turf)
		new /obj/effect/temp_visual/shadow_telegraph/light_beam(curr_turf)
		surrounding_turfs -= RANGE_TURFS(2, curr_turf) //spread out!

/obj/effect/temp_visual/devestating_light
	name = "holy light"
	icon = 'icons/effects/effects.dmi'
	icon_state = "falling_celeste"
	plane = ABOVE_GAME_PLANE
	duration = 1.5 SECONDS
	light_range = 1
	light_color = COLOR_PINK
	alpha = 0
	///damage we should apply
	var/damage_to_apply = 30
	pixel_y = 70

/obj/effect/temp_visual/devestating_light/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix().Scale(1, -4), alpha = 255, time = duration)
	addtimer(CALLBACK(src, PROC_REF(apply_damage)), duration)

/obj/effect/temp_visual/devestating_light/proc/apply_damage()
	playsound(src, 'sound/magic/magic_missile.ogg', 30, TRUE, pressure_affected = FALSE)
	var/turf/my_turf = get_turf(src)
	new /obj/effect/temp_visual/mook_dust(my_turf)
	for(var/mob/living/victim in my_turf)
		victim.apply_damage(damage_to_apply)

/obj/effect/temp_visual/shadow_telegraph/light_beam
	duration = 1.5 SECONDS

/obj/effect/temp_visual/shadow_telegraph/light_beam/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.1, 0.1)
	animate(src, transform = initial(transform), time = duration)

/////swords attack
/datum/action/cooldown/mob_cooldown/holy_blades
	name = "blades of judgement"
	button_icon = 'icons/obj/weapons/sword.dmi'
	button_icon_state = "divine_blade"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Let the blades judge your victim's fate."
	cooldown_time = 25 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	/// time between each sword launched
	var/fire_interval = SWORD_DROP_TIMER + 0.25 SECONDS
	//the list of swords we launched at the enemy
	var/list/current_swords = list()

/datum/action/cooldown/mob_cooldown/holy_blades/Activate(atom/movable/target)
	if(!isliving(target))
		return FALSE
	var/static/list/sword_y_offsets = list(-18, 0, 18)
	var/list/icon_offsets = get_icon_dimensions(target.icon)
	for(var/index in 1 to length(sword_y_offsets))
		var/obj/effect/overlay/sword_overlay/right_blade = new
		var/obj/effect/overlay/sword_overlay/left_blade = new
		right_blade.pixel_y = sword_y_offsets[index]
		right_blade.pixel_x = icon_offsets["width"]
		right_blade.transform = right_blade.transform.Scale(-1, 1) //flip the right blade
		left_blade.pixel_y = sword_y_offsets[index]
		left_blade.pixel_x = -icon_offsets["width"]
		target.vis_contents += left_blade
		target.vis_contents += right_blade
		current_swords += list(right_blade, left_blade)
	for(var/sword_index in 1 to length(current_swords))
		var/atom/sword = current_swords[sword_index]
		addtimer(CALLBACK(src, PROC_REF(remove_sword), target, sword), sword_index * fire_interval)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/holy_blades/proc/remove_sword(atom/target, atom/sword_overlay)
	animate(sword_overlay, alpha = 0, time = 0.5 SECONDS)
	if(!isnull(target))
		playsound(target, 'sound/effects/holy_sword_sheathe.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(drop_sword), target, sword_overlay), 0.5 SECONDS)

/datum/action/cooldown/mob_cooldown/holy_blades/proc/drop_sword(atom/target, atom/sword_overlay)
	current_swords -= sword_overlay
	qdel(sword_overlay)
	if(isnull(target))
		return
	new /obj/effect/temp_visual/falling_sword(get_turf(target))
	var/obj/effect/temp_visual/shadow_telegraph/falling_shadow = new(get_turf(target))
	animate(falling_shadow, transform = matrix().Scale(0.1, 0.1), time = falling_shadow.duration)

/obj/effect/temp_visual/falling_sword
	name = "falling sword"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_blade"
	layer = ABOVE_ALL_MOB_LAYER
	duration = SWORD_DROP_TIMER
	light_color = COLOR_BLUE
	light_range = 2
	///damage we should apply
	var/damage_to_apply = 50
	pixel_y = 70

/obj/effect/temp_visual/falling_sword/Initialize(mapload)
	. = ..()
	animate(src, pixel_y = 0, time = duration)
	addtimer(CALLBACK(src, PROC_REF(apply_damage)), duration)

/obj/effect/temp_visual/falling_sword/proc/apply_damage()
	var/turf/my_turf = get_turf(src)
	for(var/mob/living/living_mob in my_turf)
		if(!(FACTION_BOSS in living_mob.faction))
			living_mob.apply_damage(damage_to_apply)
	new /obj/effect/temp_visual/mook_dust(my_turf)
	playsound(get_turf(src), 'sound/effects/holy_sword_hit.ogg', 50, TRUE)
	new /obj/effect/temp_visual/embedded_sword(my_turf)

/obj/effect/temp_visual/embedded_sword
	name = "embedded sword"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_blade_embedded"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3 SECONDS
	light_color = COLOR_BLUE
	light_range = 2

/obj/effect/overlay/sword_overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "divine_blade"
	alpha = 0
	plane = ABOVE_GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/overlay/sword_overlay/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, INNATE_TRAIT)
	add_filter("sword_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))
	animate(src, alpha = 255, time = 1 SECONDS)

/////beams and projectiles
/obj/effect/ebeam/reacting/judgement
	name = "judgement beam"
	react_on_init = TRUE
	///damage we apply to whom who enter
	var/damage_to_apply = 50

/obj/effect/ebeam/reacting/judgement/beam_entered(atom/movable/entered)
	. = ..()
	if(!isliving(entered))
		return
	var/mob/living/living_entered = entered
	if(!(FACTION_BOSS in living_entered.faction))
		living_entered.apply_damage(damage_to_apply, BURN)

/obj/effect/ebeam/reacting/judgement/crystal
	damage_to_apply = 20

/obj/projectile/deacon_wisp
	name = "deacon wisp"
	icon_state = "deacon_wisp"
	damage = 15
	armour_penetration = 100
	light_range = 2
	light_color = COLOR_WHITE
	speed = 2
	pixel_speed_multiplier = 0.3
	damage_type = BURN
	pass_flags = PASSTABLE
	plane = GAME_PLANE
	nondirectional_sprite = TRUE

/obj/projectile/deacon_wisp/prehit_pierce(atom/target)
	if(!isliving(target))
		return ..()
	var/mob/living/living_target = target
	if(FACTION_BOSS in living_target.faction)
		return PROJECTILE_PIERCE_PHASE
	return ..()

/////phantom attack
/datum/action/cooldown/mob_cooldown/cast_phantom
	name = "Cast Phantom"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "plasmasoul"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Looks like ill need some help."
	cooldown_time = 50 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///the phantom we spawn
	var/phantom_type = /mob/living/basic/mining/deacon_phantom

/datum/action/cooldown/mob_cooldown/cast_phantom/Activate(atom/target)
	if(isnull(target) || !isliving(target))
		return FALSE
	var/turf/turf_list = RANGE_TURFS(2, target)
	shuffle_inplace(turf_list)
	for(var/turf/possible_turf in turf_list)
		if(isclosedturf(possible_turf))
			continue
		owner.Beam(
			BeamTarget = possible_turf,
			icon = 'icons/effects/beam.dmi',
			icon_state = "curse0",
			beam_color = COLOR_PINK,
			time = 0.75 SECONDS,
			emissive = TRUE,
		)
		var/mob/living/living_phantom = new phantom_type(possible_turf)
		living_phantom.alpha = 0
		animate(living_phantom, alpha = initial(living_phantom.alpha), 1.5 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(activate_phantom), living_phantom, target), 1.5 SECONDS)
		StartCooldown()
		return TRUE

/datum/action/cooldown/mob_cooldown/cast_phantom/proc/activate_phantom(mob/living/living_phantom, atom/target)
	if(isnull(living_phantom) || isnull(target))
		return
	living_phantom.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, target)
