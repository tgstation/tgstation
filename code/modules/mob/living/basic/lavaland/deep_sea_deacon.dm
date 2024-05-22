/mob/living/basic/mining/deacon
	name = "deep sea deacon"
	desc = "If anyone does not love the Lord, let them be accursed at His coming... Amen!"
	icon = 'icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "deep_sea_deacon"
	icon_living = "deep_sea_deacon"
	pixel_x = -32
	base_pixel_x = -32
	gender = MALE
	speed = 10
	basic_mob_flags = IMMUNE_TO_FISTS
	maxHealth = 2000
	health = 2000
	speak_emote = list("preaches")
	obj_damage = 100
	armour_penetration = 20
	melee_damage_lower = 40
	melee_damage_upper = 40
	sentience_type = SENTIENCE_BOSS
	attack_sound = 'sound/magic/magic_block_holy.ogg'
	attack_verb_continuous = "exorcizes"
	attack_verb_simple = "exorcize"
	throw_blocked_message = "does nothing to the tough hide of"
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG

/mob/living/basic/mining/deacon/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	var/datum/action/cooldown/mob_cooldown/crystal_barrage/barrage = new(src)
	var/datum/action/cooldown/mob_cooldown/light_beam/beam = new(src)
	var/datum/action/cooldown/mob_cooldown/lightning_fissure/fissure = new(src)
	var/datum/action/cooldown/mob_cooldown/holy_blades/blades = new(src)
	var/datum/action/cooldown/mob_cooldown/entrappment/trap = new(src)
	var/datum/action/cooldown/mob_cooldown/black_n_white/directionals = new(src)
	var/datum/action/cooldown/mob_cooldown/beam_crystal/beam_crystal = new(src)
	beam.Grant(src)
	barrage.Grant(src)
	fissure.Grant(src)
	blades.Grant(src)
	trap.Grant(src)
	directionals.Grant(src)
	beam_crystal.Grant(src)

/obj/effect/overlay/crystal_overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_crystal"
	alpha = 0
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
	var/fire_interval = 3 SECONDS
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
	crystal.original = target
	crystal.fire()

/obj/effect/temp_visual/holy_lightning/infectious
	spread_lightning = TRUE

/obj/effect/temp_visual/holy_lightning
	name = "holy lightning"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_lightning"
	layer = ABOVE_ALL_MOB_LAYER
	alpha = 0
	duration = 1.5 SECONDS
	///should we spawn holy beams around us?
	var/spread_lightning = FALSE
	///damage we should apply
	var/damage_to_apply = 10
	///range to spread the lightning
	var/lightning_range = 2

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
	playsound(src, 'sound/magic/lightningbolt.ogg', 50)
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
	var/fire_interval = 4 SECONDS
	///how many turfs should we pick every so often?
	var/turf_pick = 6
	///how many times do we rain down a barrage?
	var/rain_down_count = 3

/datum/action/cooldown/mob_cooldown/light_beam/Activate(atom/target)
	if(isnull(target))
		return FALSE
	for(var/count in 1 to rain_down_count)
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
	icon_state = "light_beam"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 1.5 SECONDS
	alpha = 0
	///damage we should apply
	var/damage_to_apply = 50
	pixel_y = 70

/obj/effect/temp_visual/devestating_light/Initialize(mapload)
	. = ..()
	animate(src, transform = matrix().Scale(1, -4), alpha = 255, time = duration)
	addtimer(CALLBACK(src, PROC_REF(apply_damage)), duration)

/obj/effect/temp_visual/devestating_light/proc/apply_damage()
	playsound(src, 'sound/magic/lightningbolt.ogg', 50)
	for(var/direction in GLOB.alldirs)
		var/turf/next_turf = get_step(src, direction)
		if(isnull(next_turf))
			continue
		new /obj/effect/temp_visual/mook_dust(next_turf)

	for(var/mob/living/victim in oview(1, src))
		victim.apply_damage(damage_to_apply)

/obj/effect/temp_visual/holy_lightning/aoe
	icon = 'icons/effects/beam.dmi'
	icon_state = "sm_arc"
	damage_to_apply = 50

#define AOE_THUNDER_TELEGRAPH_PERIOD 0.75 SECONDS
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
	for(var/count in 2 to turf_range)
		ranges_to_select += count
	while(length(ranges_to_select))
		var/outter_box = pick_n_take(ranges_to_select)
		var/inner_box = outter_box - 1
		ranges_to_select -= inner_box
		prepare_thunder(outter_box, inner_box)
		SLEEP_CHECK_DEATH(fire_interval, owner)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/prepare_thunder(outter_box, inner_box)
	var/turf/my_turf = get_turf(owner)
	var/list/target_turfs = RANGE_TURFS(outter_box, my_turf) - RANGE_TURFS(inner_box - 1, my_turf)
	for(var/turf/curr_turf as anything in target_turfs)
		if(curr_turf.density)
			continue
		new /obj/effect/temp_visual/shadow_telegraph/aoe_thunder(curr_turf)
	addtimer(CALLBACK(src, PROC_REF(create_thunder), target_turfs), AOE_THUNDER_TELEGRAPH_PERIOD)

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/create_thunder(list/target_turfs)
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
	/// time between each droplet launched
	var/fire_interval = 1.5 SECONDS
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
	duration = 1 SECONDS
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
		living_mob.apply_damage(damage_to_apply)
	new /obj/effect/temp_visual/mook_dust(my_turf)
	new /obj/effect/temp_visual/embedded_sword(my_turf)

/obj/effect/temp_visual/embedded_sword
	name = "embedded sword"
	icon = 'icons/effects/effects.dmi'
	icon_state = "holy_blade_embedded"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3 SECONDS

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
	damage_to_apply = 20

/obj/structure/entrappment_crystal
	name = "Red crystal"
	desc = "Gotta get outta here..."
	icon = 'icons/obj/service/hand_of_god_structures.dmi'
	icon_state = "trapping_pylon"
	alpha = 0
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

/datum/action/cooldown/mob_cooldown/black_n_white/Activate(atom/movable/target)
	animate(owner, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(telegraph_attack)), 1 SECONDS)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/black_n_white/proc/telegraph_attack()
	owner.icon_state = "deep_sea_deacon_blacknwhite"
	animate(owner, alpha = 255, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(commence_fire)), 2 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/commence_fire()
	for(var/count in 1 to fire_amount)
		beam_directions(GLOB.cardinals)
		SLEEP_CHECK_DEATH(time_to_fire, owner)
		beam_directions(GLOB.diagonals)
		SLEEP_CHECK_DEATH(time_to_fire, owner)
	if(isnull(owner))
		return
	animate(owner, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(end_attack)), 1 SECONDS)

/datum/action/cooldown/mob_cooldown/black_n_white/proc/end_attack()
	if(isnull(owner))
		return
	owner.icon_state = initial(owner.icon_state)
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

/obj/effect/ebeam/reacting/judgement/beam_entered(atom/movable/entered)
	. = ..()
	if(!isliving(entered))
		return
	var/mob/living/living_entered = entered
	living_entered.apply_damage(50, BURN)

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
	playsound(owner, 'sound/magic/holy_crystal_fire.ogg', 60, TRUE)
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
	///the victim we will be beaming
	var/datum/weakref/beam_victim

/obj/effect/temp_visual/judgement_crystal/Initialize(mapload)
	. = ..()
	charge_up_beam()

/obj/effect/temp_visual/judgement_crystal/proc/charge_up_beam()
	remove_filter("crystal_glow")
	addtimer(CALLBACK(src, PROC_REF(select_target_destination)), 2 SECONDS)

/obj/effect/temp_visual/judgement_crystal/proc/select_target_destination()
	add_filter("crystal_glow", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))
	var/atom/target = beam_victim?.resolve()
	if(isnull(target))
		qdel(src)
		return
	var/turf/target_turf = get_turf(target)
	addtimer(CALLBACK(src, PROC_REF(shoot_target), target_turf), 0.75 SECONDS)

/obj/effect/temp_visual/judgement_crystal/proc/shoot_target(turf/target_turf)
	var/turf/my_turf = get_turf(src)
	playsound(src, 'sound/magic/magic_block_holy.ogg', 60, TRUE)
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
		for(var/mob/living/victim in current_turf) //this is sin
			victim.apply_damage(50, BURN)
