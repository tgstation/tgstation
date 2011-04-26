/*
CONTAINS:
TABLE PARTS
REINFORCED TABLE PARTS
WOODEN TABLE PARTS
RACK PARTS
*/



// TABLE PARTS

/obj/item/weapon/table_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( src.loc )
		//SN src = null
		del(src)

/obj/item/weapon/table_parts/attack_self(mob/user as mob)
	var/state = input(user, "What type of table?", "Assembling Table", null) in list( "sides", "corners", "alone" )
	var/direct = SOUTH
	var/i_state
	if(state == "alone")
		i_state = "table"
	else if (state == "corners")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "NORTHWEST", "NORTHEAST", "SOUTHWEST", "SOUTHEAST" )
		i_state = "tabledir"
	else if (state == "sides")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "NORTH", "EAST", "SOUTH", "WEST" )
		i_state = "tabledir"
	var/obj/table/T = new /obj/table( user.loc )
	T.icon_state = i_state
	T.dir = text2dir(direct)
	T.add_fingerprint(user)
	del(src)
	return

// WOODEN TABLE PARTS
/obj/item/weapon/table_parts/wood/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/wood( src.loc )
		//SN src = null
		del(src)

/obj/item/weapon/table_parts/wood/attack_self(mob/user as mob)
	var/state = input(user, "What type of table?", "Assembling Table", null) in list( "sides", "corners", "alone" )
	var/direct = SOUTH
	var/i_state
	if(state == "alone")
		i_state = "woodtable"
	else if (state == "corners")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "NORTHWEST", "NORTHEAST", "SOUTHWEST", "SOUTHEAST" )
		i_state = "woodentable"
	else if (state == "sides")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "NORTH", "EAST", "SOUTH", "WEST" )
		i_state = "woodentable"
	var/obj/table/T = new /obj/table/woodentable( user.loc )
	T.icon_state = i_state
	T.dir = text2dir(direct)
	T.add_fingerprint(user)
	del(src)
	return


// REINFORCED TABLE PARTS
/obj/item/weapon/table_parts/reinforced/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/r_metal( src.loc )
		//SN src = null
		del(src)

/obj/item/weapon/table_parts/reinforced/attack_self(mob/user as mob)
	var/state = input(user, "What type of table?", "Assembling Table", null) in list( "sides", "corners", "alone" )
	var/direct = SOUTH
	var/i_state
	if(state == "alone")
		i_state = "reinf_table"
	else if (state == "corners")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "NORTHWEST", "NORTHEAST", "SOUTHWEST", "SOUTHEAST" )
		i_state = "reinf_tabledir"
	else if (state == "sides")
		direct = input(user, "Direction?", "Assembling Table", null) in list( "NORTH", "EAST", "SOUTH", "WEST" )
		i_state = "reinf_tabledir"
	var/obj/table/reinforced/T = new /obj/table/reinforced( user.loc )
	T.icon_state = i_state
	T.dir = text2dir(direct)
	T.add_fingerprint(user)
	del(src)
	return





// RACK PARTS
/obj/item/weapon/rack_parts/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/weapon/wrench))
		new /obj/item/stack/sheet/metal( src.loc )
		del(src)
		return
	return

/obj/item/weapon/rack_parts/attack_self(mob/user as mob)
	var/obj/rack/R = new /obj/rack( user.loc )
	R.add_fingerprint(user)
	del(src)
	return