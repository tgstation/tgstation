/obj/item/grenade/frag/mothlet //Grenade
	name = "mothlet grenade"
	desc = "CAUTION: DUBIOUS LITTLE CREATURES INSIDE."
	icon = 'monkestation/icons/obj/mothletgrenade.dmi'
	icon_state = "fragmoth"
	shrapnel_type = /obj/projectile/bullet/shrapnel/mothlet
	shrapnel_radius = 3
	ex_heavy = 0 //The grenade flings the moths with c02 so no structural damage to anyone (or the moths)
	ex_light = 0
	ex_flame = 0

/obj/projectile/bullet/shrapnel/mothlet //Projectile launched
	name = "Mothlet"
	desc = "WHY ARE YOU LOOKING AT IT, HIT THE DECK!!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mothmallow_slice"
	damage = 0
	range = 20
	weak_against_armour = FALSE
	dismemberment = 0
	ricochets_max = 3
	ricochet_chance = 100 //Living moths can buzz as much as they want
	ricochet_incidence_leeway = 0 //They are living moths, buzzing around
	hit_prone_targets = TRUE //You cant duck under a creature intent on pantsing you infront of everyone
	sharpness = SHARP_POINTY
	embedding = list(embed_chance=0, ignore_throwspeed_threshold=TRUE, fall_chance=1)


/obj/projectile/bullet/shrapnel/mothlet/on_hit(owner)
	. = ..()
	if(iscarbon(owner) && prob(50))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.unequip_everything()

