/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = "An ancient mutation that gives lizards breath of fire."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = "<span class='notice'>Your throat is burning!</span>"
	text_lose_indication = "<span class='notice'>Your throat is cooling down.</span>"
	power_path = /datum/action/cooldown/spell/cone/staggered/fire_breath
	instability = 30
	energy_coeff = 1
	power_coeff = 1

/datum/mutation/human/firebreath/modify()
	. = ..()
	var/datum/action/cooldown/spell/cone/staggered/fire_breath/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	if(GET_MUTATION_POWER(src) <= 1) // we only care about power from here on
		return

	to_modify.cone_levels += 2  // Cone fwooshes further, and...
	to_modify.self_throw_range += 1 // the breath throws the user back more

/datum/action/cooldown/spell/cone/staggered/fire_breath
	name = "Fire Breath"
	desc = "You breathe a cone of fire directly in front of you."
	button_icon_state = "fireball0"
	sound = 'sound/magic/demon_dies.ogg' //horrifying lizard noises

	school = SCHOOL_EVOCATION
	cooldown_time = 40 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	antimagic_flags = NONE

	cone_levels = 3
	respect_density = TRUE
	/// The range our user is thrown backwards after casting the spell
	var/self_throw_range = 1

/datum/action/cooldown/spell/cone/staggered/fire_breath/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!iscarbon(cast_on))
		return

	var/mob/living/carbon/our_lizard = cast_on
	if(!our_lizard.is_mouth_covered())
		return

	our_lizard.adjust_fire_stacks(cone_levels)
	our_lizard.ignite_mob()
	to_chat(our_lizard, span_warning("Something in front of your mouth catches fire!"))

/datum/action/cooldown/spell/cone/staggered/fire_breath/after_cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return

	var/mob/living/living_cast_on = cast_on
	// When casting, throw the caster backwards a few tiles.
	var/original_dir = living_cast_on.dir
	living_cast_on.throw_at(
		get_edge_target_turf(living_cast_on, turn(living_cast_on.dir, 180)),
		range = self_throw_range,
		speed = 2,
		gentle = TRUE,
	)
	// Try to set us to our original direction after, so we don't end up backwards.
	living_cast_on.setDir(original_dir)

/datum/action/cooldown/spell/cone/staggered/fire_breath/calculate_cone_shape(current_level)
	// This makes the cone shoot out into a 3 wide column of flames.
	// You may be wondering, "that equation doesn't seem like it'd make a 3 wide column"
	// well it does, and that's all that matters.
	return (2 * current_level) - 1

/datum/action/cooldown/spell/cone/staggered/fire_breath/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	// Further turfs experience less exposed_temperature and exposed_volume
	new /obj/effect/hotspot(target_turf) // for style
	target_turf.hotspot_expose(max(500, 900 - (100 * level)), max(50, 200 - (50 * level)), 1)

/datum/action/cooldown/spell/cone/staggered/fire_breath/do_mob_cone_effect(mob/living/target_mob, atom/caster, level)
	// Further out targets take less immediate burn damage and get less fire stacks.
	// The actual burn damage application is not blocked by fireproofing, like space dragons.
	target_mob.apply_damage(max(10, 40 - (5 * level)), BURN, spread_damage = TRUE)
	target_mob.adjust_fire_stacks(max(2, 5 - level))
	target_mob.ignite_mob()

/datum/action/cooldown/spell/cone/staggered/firebreath/do_obj_cone_effect(obj/target_obj, atom/caster, level)
	// Further out objects experience less exposed_temperature and exposed_volume
	target_obj.fire_act(max(500, 900 - (100 * level)), max(50, 200 - (50 * level)))
