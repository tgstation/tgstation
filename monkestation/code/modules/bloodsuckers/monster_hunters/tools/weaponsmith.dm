/obj/structure/rack/weaponsmith
	name = "Weapon Forge"
	desc = "Fueled by the tears of rabbits."
	icon = 'icons/obj/cult/structures.dmi'
	icon_state = "altar"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/rack/weaponsmith/attackby(obj/item/rabbit_eye/eye, mob/living/user, params)
	if(!istype(eye))
		return ..()
	var/obj/item/melee/trick_weapon/tool = locate() in src.loc
	if(QDELETED(tool))
		user.balloon_alert(user, "place weapon on table!")
		return
	eye.upgrade(tool, user)
