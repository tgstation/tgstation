///lasertag team tracking component
/datum/component/lasertag
	dupe_mode = COMPONENT_DUPE_SOURCES
	///What team the mob that this component is attached to is part of.
	var/team_color = LASERTAG_TEAM_NEUTRAL

/datum/component/lasertag/Initialize(team_color)
	if (!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	register_lasertag_signals()
	src.team_color = team_color

///For the sake of organization, put any new signals in here.
/datum/component/lasertag/proc/register_lasertag_signals()
	RegisterSignal(parent, COMSIG_LIVING_FIRING_PIN_CHECK, PROC_REF(team_color_match))
	RegisterSignal(parent, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_laser_hit))


/datum/component/lasertag/proc/team_color_match(datum/source, firing_pin)
	SIGNAL_HANDLER
	var/obj/item/firing_pin/tag/pin = firing_pin
	if (pin.tagcolor == team_color)
		return ALLOW_FIRE
	return BLOCK_FIRE

/datum/component/lasertag/proc/on_laser_hit(datum/source, projectile)
	SIGNAL_HANDLER
	if(!istype(projectile, /obj/projectile/beam/lasertag))
		return
	var/obj/projectile/beam/lasertag/laser = projectile
	if (laser.lasertag_team != team_color)
		var/mob/living/carbon/human/laser_target = parent
		laser_target.adjust_stamina_loss(laser.lasertag_damage)

