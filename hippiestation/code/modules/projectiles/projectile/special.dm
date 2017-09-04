/obj/item/projectile/monkey
	name = "monkey poo"
	icon_state = "monkey"
	damage = 5
	damage_type = TOX
	icon = 'hippiestation/icons/obj/projectiles.dmi'

/obj/item/projectile/monkey/on_hit(atom/target, blocked = FALSE)
	..()
	new /obj/effect/decal/cleanable/poo(get_turf(target))
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/mutable_appearance/pooface = mutable_appearance('hippiestation/icons/effects/poo.dmi', "maskpoo")
		H.add_overlay(pooface)
	return TRUE