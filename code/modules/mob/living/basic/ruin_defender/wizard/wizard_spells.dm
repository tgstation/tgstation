// Lesser versions of wizard spells to be used by AI wizards

/// Lesser fireball, which is slightly less "instant death" than the normal one
/datum/action/cooldown/spell/pointed/projectile/fireball/lesser
	name = "Lesser Fireball"
	projectile_type = /obj/projectile/magic/fireball/lesser
	cooldown_time = 10 SECONDS

/obj/projectile/magic/fireball/lesser
	damage = 0
	exp_light = 1

/// Lesser Blink, shorter range than the normal blink spell
/datum/action/cooldown/spell/teleport/radius_turf/blink/lesser
	name = "Lesser Blink"
	outer_tele_radius = 3
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
