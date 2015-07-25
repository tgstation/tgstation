//spooky human cultist
/mob/living/simple_animal/hostile/cultist/human
	name = "Cultist"
	desc = "Praise Nar'Sie!"
	icon_state = "cult"
	icon_living = "cult"
	icon_dead = null //can someone explain to me why these mobs need a dead/gibbed icon if the body is qdel'd after corpse spawn?
	icon_gib = null
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 20
	melee_damage_upper = 25
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	a_intent = "harm"
	var/corpse = /obj/effect/landmark/mobcorpse/cultist
	var/weapon1 = /obj/item/weapon/melee/cultblade
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 15
	faction = list("hostile")
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/cultist/human/space
	name = "Spacebound Cultist"
	desc = "Praise Nar'Sie!"
	icon_state = "cultspace"
	icon_living = "cultspace"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	corpse = /obj/effect/landmark/mobcorpse/cultist/space

/mob/living/simple_animal/hostile/cultist/human/death(gibbed)
	..(gibbed)
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	qdel(src)
	return

