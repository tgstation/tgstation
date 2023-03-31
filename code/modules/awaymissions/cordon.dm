/// Turf type that appears to be a world border, completely impassable and non-interactable to all physical (alive) entities.
/turf/cordon
	name = "cordon"
	icon = 'icons/turf/walls.dmi'
	icon_state = "cordon"
	invisibility = INVISIBILITY_ABSTRACT
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	explosive_resistance = INFINITY
	rad_insulation = RAD_FULL_INSULATION
	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	space_lit = TRUE
	bullet_bounce_sound = null
	turf_flags = NOJAUNT
	baseturfs = /turf/cordon

/turf/cordon/AfterChange()
	. = ..()
	SSair.high_pressure_delta -= src

/turf/cordon/rust_heretic_act()
	return FALSE

/turf/cordon/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/cordon/Melt()
	to_be_destroyed = FALSE
	return src

/turf/cordon/singularity_act()
	return FALSE

/turf/cordon/ScrapeAway(amount, flags)
	return src // :devilcat:

/turf/cordon/bullet_act(obj/projectile/hitting_projectile, def_zone, piercing_hit)
	return BULLET_ACT_HIT

/turf/cordon/Adjacent(atom/neighbor, atom/target, atom/movable/mover)
	return FALSE

/// Area used in conjuction with the cordon turf to create a fully functioning world border.
/area/misc/cordon
	name = "CORDON"
	icon_state = "cordon"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = UNIQUE_AREA|NOTELEPORT|HIDDEN_AREA
	requires_power = FALSE

/area/misc/cordon/Entered(atom/movable/arrived, area/old_area)
	. = ..()
	for(var/mob/living/enterer as anything in arrived.get_all_contents_type(/mob/living))
		to_chat(enterer, span_userdanger("This was a bad idea..."))
		enterer.dust(TRUE, FALSE, TRUE)

/// This type of cordon will block ghosts from passing through it. Useful for stuff like Away Missions, where you feasibly want to block ghosts from entering to keep a certain map section a secret.
/turf/cordon/secret
	name = "secret cordon (ghost blocking)"

/turf/cordon/secret/attack_ghost(mob/dead/observer/user)
	return FALSE
