/obj/item/stack/tile/iron
	name = "floor tile"
	singular_name = "floor tile"
	desc = "The ground you walk on."
	icon_state = "tile"
	inhand_icon_state = "tile"
	force = 6
	mats_per_unit = list(/datum/material/iron=500)
	throwforce = 10
	flags_1 = CONDUCT_1
	turf_type = /turf/open/floor/iron
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 70)
	resistance_flags = FIRE_PROOF
	matter_amount = 1
	cost = 125
	source = /datum/robot_energy_storage/iron
	merge_type = /obj/item/stack/tile/iron

/obj/item/stack/tile/iron/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER)
		if(get_amount() < 4)
			to_chat(user, "<span class='warning'>You need at least four tiles to do this!</span>")
			return
		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/stack/sheet/iron/new_item = new(user.loc)
			user.visible_message("<span class='notice'>[user] shaped [src] into [new_item] with [W].</span>", \
				"<span class='notice'>You shaped [src] into [new_item] with [W].</span>", \
				"<span class='hear'>You hear welding.</span>")
			var/holding = user.is_holding(src)
			use(4)
			if(holding && QDELETED(src))
				user.put_in_hands(new_item)
	else
		return ..()
