/turf/open/indestructible/gold
	name = "gold floor"
	baseturfs = /turf/open/indestructible/gold
	icon_state = "gold"
	tiled_dirt = FALSE
	desc = "Very rich floor made out of pure gold! This floor seems indestructible for some reason..."

/turf/open/indestructible/diamond
	name = "diamond floor"
	baseturfs = /turf/open/indestructible/diamond
	icon_state = "diamond"
	tiled_dirt = FALSE
	desc = "Very rich floor made out of pure diamond! This floor seems indestructible for some reason..."

/obj/projectile/goat
	name = "goat"
	icon = 'icons/mob/animal.dmi'
	icon_state = "goat"
	damage = 5
	damage_type = BRUTE
	flag = "bullet"

/obj/projectile/goat/on_hit(atom/target)
	knockdown = 20
	var/turf/location = get_turf(target)
	new/mob/living/simple_animal/hostile/retaliate/goat(location)
	playsound(location, 'sound/items/goatsound.ogg', 40, TRUE)
	qdel(src)

/obj/item/ammo_casing/energy/goat
	projectile_type = /obj/projectile/goat
	select_name = "goat"

/obj/item/gun/energy/goatgun
	name = "goat gun"
	desc = "Whoever you fire this at is gonna be in for a baaaaaaad surprise." //ha ha I am funny man please laugh HAHAHAHAHAHAHAHA
	icon_state = "meteor_gun"
	item_state = "c20r"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/goat)
	cell_type = /obj/item/stock_parts/cell
	clumsy_check = 0
	selfcharge = 1

/obj/structure/ladder/unbreakable/goat
	name = "Ladder Out of King Goats Lair"
	desc = "Apparantly the exit was inside him the whole time...gross."
	resistance_flags = INDESTRUCTIBLE
	id = "goatlayer"
	height = 1
