/obj/structure/locker/athletic_mixed
	name = "athletic wardrobe"
	desc = "It's a storage unit for athletic wear."
	icon_door = "mixed"

/obj/structure/locker/athletic_mixed/PopulateContents()
	..()
	new /obj/item/clothing/under/shorts/purple(src)
	new /obj/item/clothing/under/shorts/grey(src)
	new /obj/item/clothing/under/shorts/black(src)
	new /obj/item/clothing/under/shorts/red(src)
	new /obj/item/clothing/under/shorts/blue(src)
	new /obj/item/clothing/under/shorts/green(src)
	new /obj/item/clothing/under/costume/jabroni(src)


/obj/structure/locker/boxinggloves
	name = "boxing gloves locker"
	desc = "It's a storage unit for gloves for use in the boxing ring."

/obj/structure/locker/boxinggloves/PopulateContents()
	..()
	new /obj/item/clothing/gloves/boxing/blue(src)
	new /obj/item/clothing/gloves/boxing/green(src)
	new /obj/item/clothing/gloves/boxing/yellow(src)
	new /obj/item/clothing/gloves/boxing(src)


/obj/structure/locker/masks
	name = "mask locker"
	desc = "IT'S A STORAGE UNIT FOR FIGHTER MASKS OLE!"

/obj/structure/locker/masks/PopulateContents()
	..()
	new /obj/item/clothing/mask/luchador(src)
	new /obj/item/clothing/mask/luchador/rudos(src)
	new /obj/item/clothing/mask/luchador/tecnicos(src)


/obj/structure/locker/lasertag/red
	name = "red laser tag equipment"
	desc = "It's a storage unit for laser tag equipment."
	icon_door = "red"

/obj/structure/locker/lasertag/red/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser/redtag(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/redtag(src)
	new /obj/item/clothing/head/helmet/redtaghelm(src)


/obj/structure/locker/lasertag/blue
	name = "blue laser tag equipment"
	desc = "It's a storage unit for laser tag equipment."
	icon_door = "blue"

/obj/structure/locker/lasertag/blue/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/gun/energy/laser/bluetag(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/suit/bluetag(src)
	new /obj/item/clothing/head/helmet/bluetaghelm(src)
