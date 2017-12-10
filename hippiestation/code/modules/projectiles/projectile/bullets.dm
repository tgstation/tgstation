/obj/item/projectile/bullet/magnum
	damage = 60

/obj/item/projectile/bullet/c38 // Detectives .38 revolver
	knockdown = 0
	stun = 0
	stamina = 45 //Plus the 15 base damage means two shots will down a perp

/obj/item/projectile/bullet/weakbullet2/on_hit(atom/target, blocked = 0)
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(prob(50))
			C.dropItemToGround(C.get_active_held_item())
		..()


/obj/item/projectile/bullet/shotgun_stunslug // Syndie bulldog shotgun stunslugs
	stun = 0
	knockdown = 0
	stamina = 80 //Stunshot can stay potent to give nukies an edge.

/obj/item/projectile/bullet/p50 // Sniper rifles
	stun = 10
	knockdown = 10
