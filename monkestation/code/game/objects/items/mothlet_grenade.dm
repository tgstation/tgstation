/obj/item/grenade/frag/mothlet //Grenade
	name = "mothlet grenade"
	desc = "They are hungery, and they are many."
	icon = 'monkestation/icons/obj/mothletgrenade.dmi'
	icon_state = "fragmoth"
	shrapnel_type = /obj/projectile/bullet/shrapnel/mothlet
	shrapnel_radius = 5
	ex_heavy = 0 //The grenade flings the moths with c02 so no structural damage to anyone (or the moths)
	ex_light = 0
	ex_flame = 0

/obj/projectile/bullet/shrapnel/mothlet //Projectile launched
	name = "Soaring Mothlet"
	desc = "WHY ARE YOU LOOKING AT IT, HIT THE DECK!!"
	icon = 'icons/obj/food/moth.dmi'
	icon_state = "mothmallow_slice"
	damage = 0
	range = 20
	weak_against_armour = FALSE
	dismemberment = 0
	ricochets_max = 3 //The moths starve after this long
	ricochet_chance = 100 //Living moths can buzz as much as they want
	ricochet_incidence_leeway = 0 //They are living moths, buzzing around
	hit_prone_targets = TRUE //You cant duck under a creature intent on eating your clothing
	sharpness = SHARP_POINTY //They have sharp teeth that go chomp
	embedding = list(embed_chance=0, ignore_throwspeed_threshold=TRUE, fall_chance=1)


/obj/projectile/bullet/shrapnel/mothlet/on_hit(owner)
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		for(var/obj/item/thing in carbon_owner.get_equipped_items())
			if(!QDELETED(thing))
				thing.take_damage(75)

