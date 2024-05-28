#define SWORD_DROP_TIMER 0.75 SECONDS
/obj/effect/overlay/crystal_overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_crystal"
	alpha = 0
	light_range = 2
	light_color = COLOR_BLUE_LIGHT
	plane = ABOVE_GAME_PLANE
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/overlay/crystal_overlay/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 2 SECONDS)

/obj/projectile/holy_crystal
	name = "holy crystal"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_crystal"
	damage = 30
	damage_type = BURN
	light_range = 2
	range = 9
	light_color = LIGHT_COLOR_BABY_BLUE
	speed = 1
	can_hit_turfs = TRUE
	pixel_speed_multiplier = 0.75
	impact_effect_type = /obj/effect/temp_visual/holy_lightning/infectious
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'

/datum/action/cooldown/mob_cooldown/crystal_barrage
	name = "Crystal Barrage"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "holy_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Rain down a barrage oh holy crystals!"
	cooldown_time = 25 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	/// time between each droplet launched
	var/fire_interval = 2 SECONDS
	/// list of effect positions before we fire
	var/list/crystal_positions = list(
		list(0, 0),
		list(0, 38),
		list(14, 64),
		list(52, 64),
		list(64, 39),
		list(64, 0),
	)

/datum/action/cooldown/mob_cooldown/crystal_barrage/Activate(atom/target)
	var/amount_of_projectiles = length(crystal_positions)
	if(!amount_of_projectiles)
		return FALSE
	for(var/index in 1 to amount_of_projectiles)
		var/list/position = crystal_positions[index]
		if(!islist(position))
			continue
		var/obj/effect/overlay/crystal_overlay/overlay_to_add = new
		owner.vis_contents += overlay_to_add
		overlay_to_add.pixel_x = position[1]
		overlay_to_add.pixel_y = position[2]
		addtimer(CALLBACK(src, PROC_REF(remove_effect), target, overlay_to_add), index * fire_interval)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/crystal_barrage/proc/remove_effect(atom/target, atom/movable/my_overlay)
	my_overlay.AddElement(/datum/element/temporary_atom, life_time = 2 SECONDS, fade_time = 1.5 SECONDS)
	if(!isnull(target))
		addtimer(CALLBACK(src, PROC_REF(shoot_crystal), target, my_overlay), 1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/crystal_barrage/proc/shoot_crystal(atom/target)
	if(isnull(target))
		return
	var/turf/my_turf = get_turf(owner)
	var/turf/enemy_turf = get_turf(target)
	if(!my_turf || !enemy_turf)
		return
	playsound(owner, 'sound/magic/holy_crystal_fire.ogg', 60, TRUE)
	var/obj/projectile/holy_crystal/crystal = new
	crystal.preparePixelProjectile(enemy_turf, my_turf)
	crystal.firer = owner
	crystal.original = enemy_turf
	crystal.fire()

/obj/effect/temp_visual/holy_lightning/infectious
	spread_lightning = TRUE

/obj/effect/temp_visual/holy_lightning
	name = "holy lightning"
	icon = 'icons/effects/beam.dmi'
	icon_state = "sm_arc_supercharged"
	layer = ABOVE_ALL_MOB_LAYER
	light_range = 2
	light_color = COLOR_BLUE_LIGHT
	alpha = 0
	duration = 1.5 SECONDS
	///should we spawn holy beams around us?
	var/spread_lightning = FALSE
	///damage we should apply
	var/damage_to_apply = 10
	///range to spread the lightning
	var/lightning_range = 2
	///the sound effect
	var/sound_effect = 'sound/magic/lightningbolt.ogg'

/obj/effect/temp_visual/holy_lightning/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(fade_away)), 0.5 SECONDS)
	damage_victims()
	if(!spread_lightning)
		return
	spread_lightning()

/obj/effect/temp_visual/holy_lightning/proc/fade_away()
	animate(src, alpha = 0, transform = matrix().Scale(0.3, 1), time = 0.5 SECONDS)

/obj/effect/temp_visual/holy_lightning/proc/spread_lightning()
	for(var/count in 1 to lightning_range)
		addtimer(CALLBACK(src, PROC_REF(spawn_thunder), count), count * 0.5 SECONDS)

/obj/effect/temp_visual/holy_lightning/proc/spawn_thunder(range)
	var/turf/my_turf = get_turf(src)
	var/list/target_turfs = CORNER_OUTLINE(my_turf, range, range)
	for(var/turf/curr_turf as anything in target_turfs)
		new /obj/effect/temp_visual/holy_lightning(curr_turf)

/obj/effect/temp_visual/shadow_telegraph/light_beam
	duration = 1.5 SECONDS

/obj/effect/temp_visual/shadow_telegraph/light_beam/Initialize(mapload)
	. = ..()
	transform = transform.Scale(0.1, 0.1)
	animate(src, transform = initial(transform), time = duration)

/obj/effect/temp_visual/holy_lightning/proc/damage_victims()
	if(sound_effect)
		playsound(src, sound_effect, 10)
	var/turf/our_turf = get_turf(src)
	if(isnull(our_turf))
		return
	for(var/mob/living/victim in our_turf)
		victim.apply_damage(damage_to_apply)


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
	var/turf_pick = 4
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

/obj/effect/temp_visual/devestating_light
	name = "holy light"
	icon = 'icons/effects/beam.dmi'
	icon_state = "plasmabeam"
	layer = ABOVE_ALL_MOB_LAYER
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
	playsound(src, 'sound/magic/lightningbolt.ogg', 20)
	var/turf/my_turf = get_turf(src)
	new /obj/effect/temp_visual/mook_dust(my_turf)
	for(var/mob/living/victim in my_turf)
		victim.apply_damage(damage_to_apply)

/obj/effect/temp_visual/holy_lightning/aoe
	icon = 'icons/effects/beam.dmi'
	icon_state = "curse0"
	light_range = 2
	light_color = COLOR_PURPLE
	damage_to_apply = 50
	sound_effect = null

#define AOE_THUNDER_TELEGRAPH_PERIOD 1.25 SECONDS

/datum/action/cooldown/mob_cooldown/lightning_fissure
	name = "lightning Fissure"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "holy_lightning"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "The ground errupts with holy lightning beams."
	cooldown_time = 25 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	/// time between each droplet launched
	var/fire_interval = 1.25 SECONDS
	///how many turfs should we pick every so often?
	var/turf_range = 7
	///ranges we have already selected
	var/list/ranges_to_select = list()

/datum/action/cooldown/mob_cooldown/lightning_fissure/Activate(atom/target)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	for(var/count in 2 to turf_range)
		ranges_to_select += count
	INVOKE_ASYNC(src, PROC_REF(commence_attack))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/commence_attack()
	while(length(ranges_to_select))
		var/outter_box = pick_n_take(ranges_to_select)
		var/inner_box = outter_box - 1
		ranges_to_select -= inner_box
		prepare_thunder(outter_box, inner_box)
		SLEEP_CHECK_DEATH(fire_interval, owner)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/prepare_thunder(outter_box, inner_box)
	var/turf/my_turf = get_turf(owner)
	var/list/target_turfs = RANGE_TURFS(outter_box, my_turf) - RANGE_TURFS(inner_box - 1, my_turf)
	for(var/turf/curr_turf as anything in target_turfs)
		if(curr_turf.density)
			continue
		new /obj/effect/temp_visual/shadow_telegraph/aoe_thunder(curr_turf)
	addtimer(CALLBACK(src, PROC_REF(create_thunder), target_turfs), AOE_THUNDER_TELEGRAPH_PERIOD)

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/create_thunder(list/target_turfs)
	playsound(owner, 'sound/magic/magic_block_holy.ogg', 200, TRUE)
	for(var/turf/curr_turf as anything in target_turfs)
		if(curr_turf.density)
			continue
		new /obj/effect/temp_visual/holy_lightning/aoe(curr_turf)

/obj/effect/temp_visual/shadow_telegraph/aoe_thunder
	duration = AOE_THUNDER_TELEGRAPH_PERIOD
	alpha = 0

/obj/effect/temp_visual/shadow_telegraph/aoe_thunder/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)

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

/datum/action/cooldown/mob_cooldown/entrappment
	name = "Entrapment"
	button_icon = 'icons/obj/service/hand_of_god_structures.dmi'
	button_icon_state = "trapping_pylon"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Enclose your victim within a border."
	cooldown_time = 25 SECONDS
	click_to_activate = TRUE
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///the range of entrappment
	var/entrappment_range = 2
	/// time between entrappment and damaging attack
	var/time_to_fire = 2 SECONDS

/datum/action/cooldown/mob_cooldown/entrappment/Activate(atom/movable/target)
	if(!isliving(target))
		return FALSE
	var/turf/target_turf = get_turf(target)
	var/list/box_turfs = RANGE_TURFS( entrappment_range-1, target_turf)
	var/list/edge_turfs = RANGE_TURFS(entrappment_range, target_turf) - box_turfs
	for(var/turf/curr_turf as anything in edge_turfs)
		if(curr_turf.is_blocked_turf())
			continue
		new /obj/structure/entrappment_crystal(curr_turf)
	addtimer(CALLBACK(src, PROC_REF(release_thunder), box_turfs), time_to_fire)
	StartCooldown()
	return TRUE


/datum/action/cooldown/mob_cooldown/entrappment/proc/release_thunder(list/turfs)
	for(var/turf/curr_turf as anything in turfs)
		new /obj/effect/temp_visual/holy_lightning/red_crystal(curr_turf)

/obj/effect/temp_visual/holy_lightning/red_crystal
	icon = 'icons/effects/beam.dmi'
	icon_state = "sm_arc_dbz_referance" //epic icon name
	light_range = 2
	light_color = COLOR_RED_LIGHT
	damage_to_apply = 20

/obj/structure/entrappment_crystal
	name = "Red crystal"
	desc = "Gotta get outta here..."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "trapping_pylon"
	alpha = 0
	light_range = 2
	light_color = COLOR_WHITE
	max_integrity = 5 //easily destroyed
	density = TRUE
	anchored = TRUE

/obj/structure/entrappment_crystal/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	AddElement(/datum/element/temporary_atom, life_time = 3 SECONDS, fade_time = 1 SECONDS)


/datum/action/cooldown/mob_cooldown/black_n_white
	name = "beams of judgement"
	button_icon = 'icons/effects/beam.dmi'
	button_icon_state = "holy_beam"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Release beams of judgement in all directions."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///how many times we fire off.
	var/fire_amount = 4
	/// time between entrappment and damaging attack
	var/time_to_fire = 2 SECONDS
	/// angle we fire projectiles at
	var/list/projectile_angles = list(22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5, 337.5)

/datum/action/cooldown/mob_cooldown/black_n_white/Activate(atom/movable/target)
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	animate(owner, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(telegraph_attack)), 1 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/black_n_white/proc/telegraph_attack()
	owner.icon_state = "deep_sea_deacon_blacknwhite"
	animate(owner, alpha = 255, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(commence_fire)), 2 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/commence_fire()
	for(var/count in 0 to fire_amount)
		addtimer(CALLBACK(src, PROC_REF(shoot_projectiles)), count * time_to_fire * 2)
	for(var/count in 1 to fire_amount)
		beam_directions(GLOB.cardinals)
		SLEEP_CHECK_DEATH(time_to_fire, owner)
		beam_directions(GLOB.diagonals)
		SLEEP_CHECK_DEATH(time_to_fire, owner)
	if(isnull(owner))
		return
	animate(owner, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_attack)), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/shoot_projectiles()
	if(isnull(owner))
		return
	var/turf/my_turf = get_turf(owner)
	var/turf/target_turf = get_turf(target)
	for(var/angle in projectile_angles)
		var/obj/projectile/deacon_wisp/wisp = new
		wisp.preparePixelProjectile(my_turf, target_turf)
		wisp.firer = owner
		wisp.original = my_turf
		wisp.fire(angle)


/datum/action/cooldown/mob_cooldown/black_n_white/proc/end_attack()
	if(isnull(owner))
		return
	owner.icon_state = initial(owner.icon_state)
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	animate(owner, alpha = 255, time = 1 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/beam_directions(list/directions)
	for(var/direction in directions)
		playsound(owner, 'sound/magic/magic_block_holy.ogg', 60, TRUE)
		var/turf/next_turf = get_step(owner, direction)
		var/turf/target_turf = get_ranged_target_turf(owner, direction, 9)
		if(isnull(target_turf))
			continue
		next_turf.Beam(
			BeamTarget = target_turf,
			beam_type = /obj/effect/ebeam/reacting/judgement,
			icon = 'icons/effects/beam.dmi',
			icon_state = "holy_beam",
			beam_color = COLOR_WHITE,
			time = time_to_fire,
			emissive = TRUE,
		)
		damage_enemies_in_line(get_line(next_turf, target_turf))

/datum/action/cooldown/mob_cooldown/black_n_white/proc/damage_enemies_in_line(list/turfs)
	for(var/turf/current_turf as anything in turfs)
		for(var/mob/living/victim in current_turf) //this is sin
			victim.apply_damage(50, BURN)

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

/datum/action/cooldown/mob_cooldown/beam_crystal
	name = "beam crystal"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "judgement_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "A holy crystal that will unleash beams on your target."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS

/datum/action/cooldown/mob_cooldown/beam_crystal/Activate(atom/movable/target)
	if(isnull(target))
		return
	var/turf/my_turf = get_turf(owner)
	var/turf/right_turf = get_ranged_target_turf(owner, EAST, 4)
	var/turf/left_turf = get_ranged_target_turf(owner, WEST, 4)
	var/list/target_turfs = list(right_turf, left_turf)
	playsound(owner, 'sound/magic/holy_crystal_fire.ogg', 100, TRUE)
	for(var/turf/current_turf as anything in target_turfs)
		var/obj/projectile/judgement_crystal/crystal = new
		crystal.preparePixelProjectile(current_turf, my_turf)
		crystal.firer = owner
		crystal.original = current_turf
		crystal.fire()
		crystal.to_beam = WEAKREF(target)
	StartCooldown()
	return TRUE

/obj/projectile/judgement_crystal
	name = "holy crystal"
	icon = 'icons/effects/effects.dmi'
	icon_state = "judgement_crystal"
	damage = 0
	light_range = 2
	light_color = COLOR_WHITE
	speed = 1
	can_hit_turfs = TRUE
	pass_flags = PASSTABLE | PASSMOB
	pixel_speed_multiplier = 0.75
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	///the victim w will be beaming
	var/datum/weakref/to_beam

/obj/projectile/judgement_crystal/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/obj/effect/temp_visual/judgement_crystal/judgement = new(get_turf(src))
	judgement.beam_victim = to_beam

/obj/effect/temp_visual/judgement_crystal
	name = "judgement crystal"
	icon = 'icons/effects/effects.dmi'
	icon_state = "judgement_crystal"
	duration = 15 SECONDS
	light_range = 2
	light_color = COLOR_WHITE
	///the victim we will be beaming
	var/datum/weakref/beam_victim

/obj/effect/temp_visual/judgement_crystal/Initialize(mapload)
	. = ..()
	charge_up_beam()

/obj/effect/temp_visual/judgement_crystal/proc/charge_up_beam()
	remove_filter("crystal_glow")
	addtimer(CALLBACK(src, PROC_REF(select_target_destination)), 2 SECONDS)

/obj/effect/temp_visual/judgement_crystal/proc/select_target_destination()
	add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
	var/atom/target = beam_victim?.resolve()
	if(isnull(target))
		qdel(src)
		return
	var/turf/target_turf = get_turf(target)
	addtimer(CALLBACK(src, PROC_REF(shoot_target), target_turf), 0.75 SECONDS)

/obj/effect/temp_visual/judgement_crystal/proc/shoot_target(turf/target_turf)
	var/turf/my_turf = get_turf(src)
	playsound(src, 'sound/effects/curse2.ogg', 100, TRUE)
	my_turf.Beam(
		BeamTarget = target_turf,
		beam_type = /obj/effect/ebeam/reacting/judgement,
		icon = 'icons/effects/beam.dmi',
		icon_state = "holy_beam",
		beam_color = COLOR_WHITE,
		time = 2 SECONDS,
		emissive = TRUE,
	)
	damage_enemies_in_line(get_line(my_turf, target_turf))
	addtimer(CALLBACK(src, PROC_REF(charge_up_beam)), 2 SECONDS) //recursive until delete

/obj/effect/temp_visual/judgement_crystal/proc/damage_enemies_in_line(list/turfs)
	for(var/turf/current_turf as anything in turfs)
		for(var/mob/living/victim in current_turf)
			if((FACTION_BOSS in victim.faction))
				continue
			victim.apply_damage(50, BURN)

/datum/action/cooldown/mob_cooldown/healing_pylon
	name = "healing pylon"
	button_icon = 'icons/obj/service/hand_of_god_structures.dmi'
	button_icon_state = "healing_pylon"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Summon crystals that give you all the power."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///list of pylons we have created
	var/list/our_pylons = list()

/datum/action/cooldown/mob_cooldown/healing_pylon/Activate(atom/movable/target)
	var/turf/my_turf = get_turf(owner)

	for(var/direction in GLOB.diagonals)
		var/turf/destination_turf = get_ranged_target_turf(owner, direction, 5)
		var/obj/projectile/healing_crystal/crystal = new
		crystal.preparePixelProjectile(destination_turf, my_turf)
		crystal.firer = owner
		crystal.ability = src
		crystal.fire()

	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))

	owner.add_filter("healing_pylon", 2, list("type" = "outline", "color" = "#6b2d8f", "alpha" = 0, "size" = 1))
	var/filter = owner.get_filter("healing_pylon")
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)

	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/healing_pylon/proc/add_pylon(atom/pylon)
	our_pylons += pylon
	RegisterSignal(pylon, COMSIG_QDELETING, PROC_REF(on_pylon_delete))

/datum/action/cooldown/mob_cooldown/healing_pylon/proc/on_pylon_delete(datum/source)
	SIGNAL_HANDLER
	our_pylons -= source
	if(!length(our_pylons))
		terminate_ability()

/datum/action/cooldown/mob_cooldown/healing_pylon/proc/terminate_ability()
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	owner.remove_filter("healing_pylon")

/obj/projectile/healing_crystal
	name = "healing crystal"
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "healing_pylon"
	damage = 0
	light_range = 2
	range = 9
	light_color = LIGHT_COLOR_BABY_BLUE
	speed = 1
	can_hit_turfs = TRUE
	pixel_speed_multiplier = 0.75
	pass_flags = PASSTABLE | PASSMOB
	///the ability that owns us
	var/datum/action/cooldown/mob_cooldown/healing_pylon/ability

/obj/projectile/healing_crystal/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/obj/structure/healing_crystal/healing = new(get_turf(src))
	ability.add_pylon(healing)
	healing.set_owner(firer)

/obj/projectile/healing_crystal/Destroy(force)
	. = ..()
	ability = null

/obj/structure/healing_crystal
	name = "healing pylon"
	desc = "Probably a good idea to destroy this..."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "healing_pylon"
	light_range = 2
	light_color = COLOR_WHITE
	max_integrity = 10
	density = TRUE

	anchored = TRUE
	///the owner we must heal
	var/mob/living/our_owner
	///the beam we are using
	var/datum/beam/our_beam
	///how much we heal on processing
	var/heal_tick = 5

/obj/structure/healing_crystal/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	AddElement(/datum/element/temporary_atom, life_time = 15 SECONDS, fade_time = 1 SECONDS)

/obj/structure/healing_crystal/proc/set_owner(mob/living/owner)
	our_owner = owner
	RegisterSignal(our_owner, COMSIG_QDELETING, PROC_REF(on_master_delete))
	var/turf/my_turf = get_turf(src)
	our_beam = my_turf.Beam(
		BeamTarget = our_owner,
		icon = 'icons/effects/beam.dmi',
		icon_state = "blood",
		beam_color = COLOR_WHITE,
		override_target_pixel_x = 12,
		emissive = TRUE,
	)
	START_PROCESSING(SSobj, src)

/obj/structure/healing_crystal/process(seconds_per_tick)
	if(isnull(our_owner))
		return PROCESS_KILL
	our_owner.heal_overall_damage(heal_tick)

/obj/structure/healing_crystal/proc/on_master_delete(datum/source)
	SIGNAL_HANDLER
	our_owner = null
	qdel(src)

/obj/structure/healing_crystal/Destroy(force)
	. = ..()
	STOP_PROCESSING(SSobj, src)
	our_owner = null
	QDEL_NULL(our_beam)

/datum/action/cooldown/mob_cooldown/beam_trial
	name = "beam trial"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "judgement_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "A holy crystal that will unleash beams on your target."
	cooldown_time = 25 SECONDS
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///max distance of crystals from the target
	var/distance = 3
	///our list of pylons
	var/list/our_pylons = list()
	///amount of trials
	var/trial_amount = 6

/datum/action/cooldown/mob_cooldown/beam_trial/Activate(atom/movable/target)
	if(isnull(target))
		return
	var/static/list/directions_ordered = list( //clockwise direction
		SOUTH,
		SOUTHWEST,
		WEST,
		NORTHWEST,
		NORTH,
		NORTHEAST,
		EAST,
		SOUTHEAST,
	)

	for(var/direction in directions_ordered)
		var/turf/destination_turf = get_ranged_target_turf(target, direction, distance)
		var/obj/structure/trial_crystal/crystal = new(destination_turf)
		our_pylons[dir2text(direction)] = crystal
		RegisterSignal(crystal, COMSIG_QDELETING, PROC_REF(crystal_deleted))

	for(var/count in 1 to length(directions_ordered))
		var/direction = directions_ordered[count]
		var/next_direction = count == length(directions_ordered) ? directions_ordered[1] : directions_ordered[count + 1]
		var/obj/structure/trial_crystal/first = our_pylons[dir2text(direction)]
		var/obj/structure/trial_crystal/next = our_pylons[dir2text(next_direction)]
		first.Beam(
			BeamTarget = next,
			beam_type = /obj/effect/ebeam/reacting/judgement/barrier,
			icon = 'icons/effects/beam.dmi',
			icon_state = "holy_beam",
			beam_color = COLOR_WHITE,
			time = 30 SECONDS,
			emissive = TRUE,
		)
	INVOKE_ASYNC(src, PROC_REF(commence_trials))
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	StartCooldown()
	if(get_dist(owner, target) > distance)
		return TRUE
	var/list/outside_bound_turfs = RANGE_TURFS(distance + 2, target) - RANGE_TURFS(distance, target)
	for(var/turf/possible_turf as anything in outside_bound_turfs)
		if(isclosedturf(possible_turf))
			continue
		do_teleport(owner, possible_turf)
		break
	return TRUE

/datum/action/cooldown/mob_cooldown/beam_trial/proc/commence_trials()
	for(var/count in 1 to trial_amount)
		var/list/copied_directions = GLOB.alldirs.Copy()
		var/first_direction = pick_n_take(copied_directions)
		copied_directions -= REVERSE_DIR(first_direction)
		var/second_direction = pick_n_take(copied_directions)
		beam_directions(list(first_direction, second_direction))
		SLEEP_CHECK_DEATH(5 SECONDS, owner)

/datum/action/cooldown/mob_cooldown/beam_trial/proc/beam_directions(list/directions)
	for(var/direction in directions)
		var/obj/structure/trial_crystal = our_pylons[dir2text(direction)]
		var/obj/structure/next_crystal = our_pylons[dir2text(REVERSE_DIR(direction))]
		if(isnull(trial_crystal) || isnull(next_crystal))
			return
		trial_crystal.add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
		next_crystal.add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
		addtimer(CALLBACK(src, PROC_REF(beam_opposite_crystal), trial_crystal, next_crystal), 1.5 SECONDS)


/datum/action/cooldown/mob_cooldown/beam_trial/proc/beam_opposite_crystal(atom/our_crystal, atom/target_crystal)
	our_crystal.Beam(
		BeamTarget = target_crystal,
		beam_type = /obj/effect/ebeam/reacting/judgement/crystal,
		icon = 'icons/effects/beam.dmi',
		icon_state = "holy_beam",
		beam_color = COLOR_WHITE,
		time = 2 SECONDS,
		emissive = TRUE,
	)
	playsound(our_crystal, 'sound/magic/magic_block_holy.ogg', 100, TRUE)
	var/list/turfs = get_line(our_crystal, target_crystal)
	for(var/turf/current_turf as anything in turfs)
		for(var/mob/living/victim in current_turf) //this is sin
			victim.apply_damage(10, BURN)
	our_crystal.remove_filter("crystal_glow")
	target_crystal.remove_filter("crystal_glow")

/datum/action/cooldown/mob_cooldown/beam_trial/proc/crystal_deleted(datum/source)
	SIGNAL_HANDLER

	for(var/direction in our_pylons)
		if(our_pylons[direction] == source)
			our_pylons -= direction
	if(!length(our_pylons))
		REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))

/obj/structure/trial_crystal
	name = "Red crystal"
	desc = "Gotta get outta here..."
	icon = 'icons/effects/effects.dmi'
	icon_state = "judgement_crystal"
	alpha = 0
	light_range = 2
	light_color = COLOR_WHITE
	max_integrity = INFINITY

	density = TRUE
	anchored = TRUE
	///how long do we exist for
	var/exist_time = 30 SECONDS

/obj/structure/trial_crystal/Initialize(mapload)
	. = ..()
	animate(src, alpha = 255, time = 0.5 SECONDS)
	AddElement(/datum/element/temporary_atom, life_time = exist_time, fade_time = 1 SECONDS)

/obj/effect/ebeam/reacting/judgement/barrier
	layer = BELOW_OBJ_LAYER
	density = TRUE

#define DOMAIN_STAY_TIMER 20 SECONDS

/datum/action/cooldown/mob_cooldown/domain_teleport //jjk ahh attack
	name = "domain teleportation"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "judgement_crystal"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Its your playground now..."
	cooldown_time = 3 MINUTES
	shared_cooldown = NONE
	melee_cooldown_time = 0 SECONDS
	///the boss landmark of our domain
	var/boss_landmark = /obj/effect/landmark/deacon_hell_boss
	///the victims landmark of our domain
	var/victim_landmark = /obj/effect/landmark/deacon_hell_player
	///list of people we have teleported
	var/list/victim_list = list()
	///our turf
	var/turf/previous_turf

/datum/action/cooldown/mob_cooldown/domain_teleport/Activate(atom/movable/target)
	for(var/mob/living/living_player in oview(9, owner))
		if(isnull(living_player.mind))
			continue
		victim_list[living_player] = get_turf(living_player)
	previous_turf = get_turf(owner)
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	teleport_victims()
	addtimer(CALLBACK(src, PROC_REF(end_attack)), DOMAIN_STAY_TIMER)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/domain_teleport/proc/on_death(datum/source, gibbed)
	SIGNAL_HANDLER
	end_attack()

/datum/action/cooldown/mob_cooldown/domain_teleport/proc/teleport_victims()
	var/obj/effect/landmark/boss_marker = locate(boss_landmark) in GLOB.landmarks_list
	var/obj/effect/landmark/player_marker = locate(victim_landmark) in GLOB.landmarks_list
	do_teleport(owner, boss_marker)
	for(var/mob/living/living_player in victim_list)
		do_teleport(living_player, player_marker)

/datum/action/cooldown/mob_cooldown/domain_teleport/hell
	name = "hell domain"
	///the boss landmark of our domain
	boss_landmark = /obj/effect/landmark/deacon_hell_boss
	///the victims landmark of our domain
	victim_landmark = /obj/effect/landmark/deacon_hell_player
	///list of our crystals
	var/list/our_crystals = list()

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/teleport_victims()
	. = ..()
	ADD_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	var/static/list/crystal_directions = list(
		WEST,
		SOUTHWEST,
		NORTHWEST,
	)
	for(var/direction in crystal_directions)
		var/turf/crystal_turf = get_step(owner, direction)
		var/obj/structure/trial_crystal/hell_domain/my_crystal = new(crystal_turf)
		our_crystals += my_crystal
	select_shoot_crystals()

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/proc/select_shoot_crystals()
	if(!length(our_crystals))
		return
	var/list/copied_list = our_crystals.Copy()
	pick_n_take(copied_list)
	for(var/atom/crystal as anything in copied_list)
		crystal.add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 2))
	addtimer(CALLBACK(src, PROC_REF(shoot_crystals), copied_list), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/proc/shoot_crystals(list/crystals_list)
	var/list/target_turf_list = list()
	for(var/atom/crystal as anything in crystals_list)
		var/turf/target_turf = get_ranged_target_turf(crystal, WEST, 10)
		if(isnull(target_turf))
			continue
		target_turf_list += get_line(crystal, target_turf)
		crystal.Beam(
			BeamTarget = target_turf,
			beam_type = /obj/effect/ebeam/reacting/judgement/crystal,
			icon = 'icons/effects/beam.dmi',
			icon_state = "holy_beam",
			beam_color = COLOR_WHITE,
			time = 1 SECONDS,
			emissive = TRUE,
		)
		crystal.remove_filter("crystal_glow")
		playsound(crystal, 'sound/magic/magic_block_holy.ogg', 60, TRUE)
	for(var/turf/current_turf as anything in target_turf_list)
		for(var/mob/living/victim in current_turf)
			victim.apply_damage(25, BURN)
	addtimer(CALLBACK(src, PROC_REF(select_shoot_crystals)), 1.5 SECONDS)

/datum/action/cooldown/mob_cooldown/domain_teleport/proc/end_attack()
	for(var/atom/victim as anything in victim_list)
		do_teleport(victim, victim_list[victim], forced = TRUE)
		victim_list -= victim
	if(isnull(owner))
		return
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	do_teleport(owner, previous_turf, forced = TRUE)
	var/datum/ai_controller/controller = owner.ai_controller
	controller.set_ai_status(controller.get_expected_ai_status())

/datum/action/cooldown/mob_cooldown/domain_teleport/hell/end_attack()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_AI_PAUSED, REF(src))
	for(var/atom/crystal as anything in our_crystals)
		our_crystals -= crystal
		qdel(crystal)

/obj/structure/trial_crystal/hell_domain
	density = FALSE
	exist_time = DOMAIN_STAY_TIMER

/datum/action/cooldown/mob_cooldown/bounce
	name = "bounce"
	button_icon = 'icons/effects/effects.dmi'
	button_icon_state = "rift"
	background_icon_state = "bg_revenant"
	overlay_icon_state = "bg_revenant_border"
	desc = "Leap upon your target!"
	cooldown_time = 5 SECONDS
	shared_cooldown = NONE
	///angle we fire projectiles at
	var/list/projectile_angles = list(0, 90, 180, 270)

/datum/action/cooldown/mob_cooldown/bounce/Activate(atom/movable/target)
	if(isnull(target))
		return
	animate(owner, pixel_y = 500, time = 1 SECONDS)
	var/obj/effect/temp_visual/deacon_bounce/leap = new (get_turf(owner))
	addtimer(CALLBACK(src, PROC_REF(commence_bounce), target, leap), 1 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/bounce/proc/commence_bounce(atom/movable/target, atom/movable/leap)
	var/turf/target_turf = get_turf(target)
	var/turf/our_turf = get_turf(owner)
	var/pixel_x_difference = target_turf.x - our_turf.x
	var/pixel_y_difference = target_turf.y - our_turf.y
	animate(leap, pixel_x = (pixel_x_difference * 32), pixel_y = (pixel_y_difference * 32), time = 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_bounce), target_turf, leap), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/bounce/proc/end_bounce(turf/target, atom/movable/leap)
	owner.forceMove(target)
	animate(leap, transform = matrix().Scale(0.1, 0.1), time = 0.4 SECONDS)
	animate(owner, pixel_y = initial(owner.pixel_y), time = 0.4 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(apply_damage), target), 0.4 SECONDS)

/datum/action/cooldown/mob_cooldown/bounce/proc/apply_damage(atom/target)
	fire_projectiles(target)
	var/turf/chasmed_turfs = list()
	for(var/turf/possible_turf as anything in RANGE_TURFS(1, owner))
		if(isclosedturf(possible_turf) || isgroundlessturf(possible_turf))
			continue
		new /obj/effect/temp_visual/mook_dust(possible_turf)
		var/old_turf_type = possible_turf.type
		var/turf/new_turf = possible_turf.TerraformTurf(/turf/open/chasm/icemoon, /turf/open/chasm/icemoon, flags = CHANGETURF_INHERIT_AIR)
		chasmed_turfs[new_turf] = old_turf_type
	for(var/mob/living/living_mob in oview(9, owner))
		shake_camera(living_mob, duration = 3, strength = 1)
	addtimer(CALLBACK(src, PROC_REF(revert_turfs), chasmed_turfs), 25 SECONDS)

/datum/action/cooldown/mob_cooldown/bounce/proc/fire_projectiles(atom/target)
	var/turf/target_turf = get_turf(target)
	var/turf/my_turf = get_turf(owner)
	for(var/angle in projectile_angles)
		var/obj/projectile/deacon_wisp/wisp = new
		wisp.preparePixelProjectile(my_turf, target_turf)
		wisp.firer = owner
		wisp.original = my_turf
		wisp.fire(angle)

/datum/action/cooldown/mob_cooldown/bounce/proc/revert_turfs(list/chasmed_turfs)
	for(var/turf/old_turf as anything in chasmed_turfs)
		var/chasmed_turf_type = chasmed_turfs[old_turf]
		chasmed_turfs -= old_turf
		old_turf.TerraformTurf(chasmed_turf_type, chasmed_turf_type, flags = CHANGETURF_INHERIT_AIR)

/datum/action/cooldown/mob_cooldown/domain_teleport/heaven
	name = "heaven domain"
	boss_landmark = /obj/effect/landmark/deacon_heaven_boss
	victim_landmark = /obj/effect/landmark/deacon_heaven_player

/datum/action/cooldown/mob_cooldown/domain_teleport/heaven/teleport_victims()
	. = ..()
	owner.ai_controller?.set_blackboard_key(BB_DEACON_BOUNCE_MODE, TRUE) //initiate bouncing protocols

/datum/action/cooldown/mob_cooldown/domain_teleport/heaven/end_attack()
	. = ..()
	owner.ai_controller?.set_blackboard_key(BB_DEACON_BOUNCE_MODE, FALSE)

/obj/effect/temp_visual/deacon_bounce
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "deep_sea_deacon_shadow"
	pixel_x = -32
	base_pixel_x = -32
	duration = 10 SECONDS

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
