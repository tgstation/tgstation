/obj/effect/proc_holder/spell/aimed/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "furious_steel"
	action_background_icon_state = "bg_ecult"
	invocation = "F'LSH'NG S'LV'R!"
	invocation_type = INVOCATION_SHOUT
	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	charge_max = 30 SECONDS
	range = 20
	projectile_amount = 3
	projectiles_per_fire = 1
	projectile_type = /obj/projectile/floating_blade
	sound = 'sound/weapons/guillotine.ogg'
	active_msg = "You summon forth three blades of furious silver."
	deactive_msg = "You conceal the blades of furious silver."
	/// A list of weakrefs to the blade EFFECTS we have orbiting our caster.
	var/list/datum/weakref/blades = list()

/obj/effect/proc_holder/spell/aimed/furious_steel/Destroy()
	QDEL_LIST(blades)
	return ..()

/obj/effect/proc_holder/spell/aimed/furious_steel/cast(list/targets, mob/living/user)
	if(!length(blades))
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/aimed/furious_steel/ready_projectile(obj/projectile/to_launch, atom/target, mob/user, iteration)
	. = ..()
	if(!istype(to_launch, /obj/projectile/floating_blade))
		return
	var/obj/projectile/floating_blade/launched_blade = to_launch
	launched_blade.caster_weakref = WEAKREF(user)

/obj/effect/proc_holder/spell/aimed/furious_steel/fire_projectile(mob/living/user, atom/target)
	. = ..()
	var/datum/weakref/to_remove = blades[1]
	var/obj/effect/real_blade = to_remove.resolve()
	real_blade.stop_orbit(user.orbiters)

	blades -= to_remove
	qdel(to_remove)

/obj/effect/proc_holder/spell/aimed/furious_steel/on_activation(mob/user)
	. = ..()
	for(var/blade_num in 1 to current_amount)
		addtimer(CALLBACK(src, .proc/create_blade, user), (blade_num - 1) * 0.66 SECONDS)
	RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, .proc/on_shield_reaction)

/obj/effect/proc_holder/spell/aimed/furious_steel/on_deactivation(mob/user)
	. = ..()
	QDEL_LIST(blades)
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

/obj/effect/proc_holder/spell/aimed/furious_steel/proc/create_blade(mob/user)
	var/obj/effect/floating_blade/blade = new(get_turf(user))
	blade.orbit(user, 25)
	blades += WEAKREF(blade)

/obj/effect/proc_holder/spell/aimed/furious_steel/proc/on_shield_reaction(
	mob/living/carbon/human/source,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
)

	SIGNAL_HANDLER

	if(current_amount <= 0 || !length(blades))
		return

	var/datum/weakref/to_remove = blades[1]
	var/obj/effect/real_blade = to_remove.resolve()
	real_blade.stop_orbit(source.orbiters)

	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.visible_message(
		span_warning("\The [real_blade] orbiting [source] snaps in front of [attack_text], blocking it before vanishing!"),
		span_warning("\The [real_blade] orbiting you snaps in front of [attack_text], blocking it before vanishing!"),
		span_hear("You hear a clink."),
	)

	current_amount--
	blades -= to_remove
	qdel(to_remove)

	if(current_amount <= 0)
		on_deactivation(source)

	return SHIELD_BLOCK

/obj/projectile/floating_blade
	name = "blade"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	speed = 2
	damage = 25
	armour_penetration = 100
	sharpness = SHARP_EDGED
	wound_bonus = 15
	pass_flags = PASSTABLE | PASSFLAPS
	plane = GAME_PLANE
	/// Weakref to whatever casted our blade, so we can't stab ourselves our our minions.
	var/datum/weakref/caster_weakref

/obj/projectile/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("knife", 2, list("type" = "outline", "color" = "#f8f8ff", "size" = 1))

/obj/projectile/floating_blade/prehit_pierce(atom/hit)
	if(isliving(hit))
		var/mob/living/caster = caster_weakref?.resolve()
		var/mob/living/living_hit = hit
		if(caster == living_hit)
			return PROJECTILE_PIERCE_PHASE

		if(caster.mind)
			var/datum/antagonist/heretic_monster/monster = living_hit.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
			if(monster?.master == caster.mind)
				return PROJECTILE_PIERCE_PHASE

	return ..()
