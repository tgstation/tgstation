////lightning fissure attack
#define AOE_THUNDER_TELEGRAPH_PERIOD 1.25 SECONDS
#define CELESTIAL_BEAM_PERIOD 2 SECONDS

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
	///how many times we repeat this attack
	var/attack_repeat = 2

/datum/action/cooldown/mob_cooldown/lightning_fissure/Activate(atom/target)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, REF(src))
	INVOKE_ASYNC(src, PROC_REF(attack_sequence))
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/attack_sequence()
	for(var/count in 1 to attack_repeat)
		fill_turf_ranges()
		commence_attack()
	end_attack()

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/fill_turf_ranges()
	for(var/count in 2 to turf_range)
		ranges_to_select += count

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/commence_attack()
	while(length(ranges_to_select))
		var/outter_box = pick_n_take(ranges_to_select)
		var/inner_box = outter_box - 1
		ranges_to_select -= inner_box
		prepare_thunder(outter_box, inner_box)
		SLEEP_CHECK_DEATH(fire_interval, owner)

/datum/action/cooldown/mob_cooldown/lightning_fissure/proc/end_attack()
	if(!isnull(owner))
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

/obj/effect/temp_visual/holy_lightning/aoe
	icon = 'icons/effects/beam.dmi'
	icon_state = "curse0"
	light_range = 2
	light_color = COLOR_PURPLE
	damage_to_apply = 50
	sound_effect = null

////crystal barrage attack
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

/obj/effect/temp_visual/holy_lightning/proc/damage_victims()
	if(sound_effect)
		playsound(src, sound_effect, 10)
	var/turf/our_turf = get_turf(src)
	if(isnull(our_turf))
		return
	for(var/mob/living/victim in our_turf)
		victim.apply_damage(damage_to_apply)

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

/obj/effect/temp_visual/holy_lightning/infectious
	spread_lightning = TRUE

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

////beam crystal attack
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
	playsound(owner, 'sound/magic/holy_crystal_fire.ogg', 70, TRUE, pressure_affected = FALSE)
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
	///effect we create at the point we hit
	var/effect_to_create = /obj/effect/temp_visual/celestial_crossing

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
	playsound(src, 'sound/effects/curse2.ogg', 70, TRUE, pressure_affected = FALSE)
	my_turf.Beam(
		BeamTarget = target_turf,
		beam_type = /obj/effect/ebeam/reacting/judgement,
		icon = 'icons/effects/beam.dmi',
		icon_state = "celestial_beam",
		beam_color = COLOR_WHITE,
		time = CELESTIAL_BEAM_PERIOD,
		emissive = TRUE,
	)
	if(!locate(effect_to_create) in target_turf)
		new effect_to_create(target_turf)

	damage_enemies_in_line(get_line(my_turf, target_turf))
	addtimer(CALLBACK(src, PROC_REF(charge_up_beam)), 2 SECONDS) //recursive until delete

/obj/effect/temp_visual/judgement_crystal/proc/damage_enemies_in_line(list/turfs)
	for(var/turf/current_turf as anything in turfs)
		for(var/mob/living/victim in current_turf)
			if((FACTION_BOSS in victim.faction))
				continue
			victim.apply_damage(50, BURN)

/obj/effect/temp_visual/celestial_crossing
	light_color = COLOR_WHITE
	icon = 'icons/effects/effects.dmi'
	icon_state = "celestial_crossing"
	plane = ABOVE_GAME_PLANE
	duration = CELESTIAL_BEAM_PERIOD
