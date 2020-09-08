/obj/item/grenade/empgrenade
	name = "classic EMP grenade"
	desc = "It is designed to wreak havoc on electronic systems."
	icon_state = "emp"
	inhand_icon_state = "emp"

/obj/item/grenade/empgrenade/prime(mob/living/lanced_by)
	. = ..()
	update_mob()
	empulse(src, 4, 10)
	qdel(src)
