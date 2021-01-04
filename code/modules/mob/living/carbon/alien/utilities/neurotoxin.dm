/obj/projectile/neurotoxin
	name = "neurotoxin spit"
	icon_state = "neurotoxin"
	damage = 60
	damage_type = STAMINA
	nodamage = FALSE
	flag = BIO
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin

/obj/projectile/neurotoxin/on_hit(atom/target, blocked = FALSE)
	if(isalien(target))
		nodamage = TRUE
	return ..()
