/* Utility Closets
 * Contains:
 *		Emergency Closet
 *		Fire Closet
 *		Tool Closet
 *		Radiation Closet
 *		Bombsuit Closet
 *		Hydrant
 *		First Aid
 */

/*
 * Emergency Closet
 */
/obj/structure/closet/emcloset
	name = "emergency closet"
	desc = "It's a storage unit for emergency breath masks and O2 tanks."
	icon_state = "emergency"

/obj/structure/closet/emcloset/anchored
	anchored = TRUE
	desc = "It's a storage unit for emergency breath masks and O2 tanks, and is securely bolted in place."
	name = "anchored emergency closet"

/obj/structure/closet/emcloset/PopulateContents()
	..()

	if (prob(40))
		new /obj/item/weapon/storage/toolbox/emergency(src)

	switch (pickweight(list("small" = 40, "aid" = 25, "tank" = 20, "both" = 10, "nothing" = 4, "delete" = 1)))
		if ("small")
			new /obj/item/weapon/tank/internals/emergency_oxygen(src)
			new /obj/item/weapon/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)

		if ("aid")
			new /obj/item/weapon/tank/internals/emergency_oxygen(src)
			new /obj/item/weapon/storage/firstaid/o2(src)
			new /obj/item/clothing/mask/breath(src)

		if ("tank")
			new /obj/item/weapon/tank/internals/air(src)
			new /obj/item/clothing/mask/breath(src)

		if ("both")
			new /obj/item/weapon/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)

		if ("nothing")
			// doot

		// teehee
		if ("delete")
			qdel(src)

		//If you want to re-add fire, just add "fire" = 15 to the pick list.
		/*if ("fire")
			new /obj/structure/closet/firecloset(src.loc)
			qdel(src)*/

/*
 * Fire Closet
 */
/obj/structure/closet/firecloset
	name = "fire-safety closet"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "fire"

/obj/structure/closet/firecloset/PopulateContents()
	..()

	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/weapon/tank/internals/oxygen/red(src)
	new /obj/item/weapon/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/obj/structure/closet/firecloset/full/PopulateContents()
	new /obj/item/clothing/suit/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/device/flashlight(src)
	new /obj/item/weapon/tank/internals/oxygen/red(src)
	new /obj/item/weapon/extinguisher(src)
	new /obj/item/clothing/head/hardhat/red(src)

/*
 * Tool Closet
 */
/obj/structure/closet/toolcloset
	name = "tool closet"
	desc = "It's a storage unit for tools."
	icon_state = "eng"
	icon_door = "eng_tool"

/obj/structure/closet/toolcloset/PopulateContents()
	..()
	if(prob(40))
		new /obj/item/clothing/suit/hazardvest(src)
	if(prob(70))
		new /obj/item/device/flashlight(src)
	if(prob(70))
		new /obj/item/weapon/screwdriver(src)
	if(prob(70))
		new /obj/item/weapon/wrench(src)
	if(prob(70))
		new /obj/item/weapon/weldingtool(src)
	if(prob(70))
		new /obj/item/weapon/crowbar(src)
	if(prob(70))
		new /obj/item/weapon/wirecutters(src)
	if(prob(70))
		new /obj/item/device/t_scanner(src)
	if(prob(20))
		new /obj/item/weapon/storage/belt/utility(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(30))
		new /obj/item/stack/cable_coil/random(src)
	if(prob(20))
		new /obj/item/device/multitool(src)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	if(prob(40))
		new /obj/item/clothing/head/hardhat(src)


/*
 * Radiation Closet
 */
/obj/structure/closet/radiation
	name = "radiation suit closet"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "eng"
	icon_door = "eng_rad"

/obj/structure/closet/radiation/PopulateContents()
	..()
	new /obj/item/device/geiger_counter(src)
	new /obj/item/clothing/suit/radiation(src)
	new /obj/item/clothing/head/radiation(src)

/*
 * Bombsuit closet
 */
/obj/structure/closet/bombcloset
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bomb"

/obj/structure/closet/bombcloset/PopulateContents()
	..()
	new /obj/item/clothing/suit/bomb_suit( src )
	new /obj/item/clothing/under/color/black( src )
	new /obj/item/clothing/shoes/sneakers/black( src )
	new /obj/item/clothing/head/bomb_hood( src )


/obj/structure/closet/bombclosetsecurity
	name = "\improper EOD closet"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bomb"

/obj/structure/closet/bombclosetsecurity/PopulateContents()
	new /obj/item/clothing/suit/bomb_suit/security( src )
	new /obj/item/clothing/under/rank/security( src )
	new /obj/item/clothing/shoes/sneakers/brown( src )
	new /obj/item/clothing/head/bomb_hood/security( src )

/*
 * Ammunition
 */
/obj/structure/closet/ammunitionlocker
	name = "ammunition locker"

/obj/structure/closet/ammunitionlocker/PopulateContents()
	..()
	for(var/i in 1 to 8)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
