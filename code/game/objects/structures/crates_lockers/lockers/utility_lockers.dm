/* Utility Lockers
 * Contains:
 * Emergency Locker
 * Fire Locker
 * Tool Locker
 * Radiation Locker
 * Bombsuit Locker
 * Hydrant
 * First Aid
 */

/*
 * Emergency Locker
 */
/obj/structure/locker/emlocker
	name = "emergency locker"
	desc = "It's a storage unit for emergency breath masks and O2 tanks."
	icon_state = "emergency"

/obj/structure/locker/emlocker/anchored
	anchored = TRUE

/obj/structure/locker/emlocker/Initialize(mapload)
	. = ..()

	if (prob(1))
		return INITIALIZE_HINT_QDEL

/obj/structure/locker/emlocker/PopulateContents()
	..()

	if (prob(40))
		new /obj/item/storage/toolbox/emergency(src)

	switch (pick_weight(list("small" = 35, "aid" = 30, "tank" = 20, "both" = 10, "nothing" = 4)))
		if ("small")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)
			new /obj/item/clothing/mask/breath(src)

		if ("aid")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/storage/medkit/emergency(src)
			new /obj/item/clothing/mask/breath(src)

		if ("tank")
			new /obj/item/tank/internals/oxygen(src)
			new /obj/item/clothing/mask/breath(src)

		if ("both")
			new /obj/item/tank/internals/emergency_oxygen(src)
			new /obj/item/clothing/mask/breath(src)

		if ("nothing")
			// doot
			pass()

/*
 * Fire Locker
 */
/obj/structure/locker/firelocker
	name = "fire-safety locker"
	desc = "It's a storage unit for fire-fighting supplies."
	icon_state = "fire"

/obj/structure/locker/firelocker/PopulateContents()
	..()

	new /obj/item/clothing/suit/utility/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/head/utility/hardhat/red(src)
	new /obj/item/crowbar/large/emergency(src)

/obj/structure/locker/firelocker/full/PopulateContents()
	new /obj/item/clothing/suit/utility/fire/firefighter(src)
	new /obj/item/clothing/mask/gas(src)
	new /obj/item/flashlight(src)
	new /obj/item/tank/internals/oxygen/red(src)
	new /obj/item/extinguisher(src)
	new /obj/item/clothing/head/utility/hardhat/red(src)
	new /obj/item/crowbar/large/emergency(src)

/*
 * Tool Locker
 */
/obj/structure/locker/toollocker
	name = "tool locker"
	desc = "It's a storage unit for tools."
	icon_state = "eng"
	icon_door = "eng_tool"

/obj/structure/locker/toollocker/PopulateContents()
	..()
	if(prob(40))
		new /obj/item/clothing/suit/hazardvest(src)
	if(prob(70))
		new /obj/item/flashlight(src)
	if(prob(70))
		new /obj/item/screwdriver(src)
	if(prob(70))
		new /obj/item/wrench(src)
	if(prob(70))
		new /obj/item/weldingtool(src)
	if(prob(70))
		new /obj/item/crowbar(src)
	if(prob(70))
		new /obj/item/wirecutters(src)
	if(prob(70))
		new /obj/item/t_scanner(src)
	if(prob(20))
		new /obj/item/storage/belt/utility(src)
	if(prob(30))
		new /obj/item/stack/cable_coil(src)
	if(prob(30))
		new /obj/item/stack/cable_coil(src)
	if(prob(30))
		new /obj/item/stack/cable_coil(src)
	if(prob(20))
		new /obj/item/multitool(src)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	if(prob(40))
		new /obj/item/clothing/head/utility/hardhat(src)


/*
 * Radiation Locker
 */
/obj/structure/locker/radiation
	name = "radiation suit locker"
	desc = "It's a storage unit for rad-protective suits."
	icon_state = "eng"
	icon_door = "eng_rad"

/obj/structure/locker/radiation/PopulateContents()
	..()
	new /obj/item/geiger_counter(src)
	new /obj/item/clothing/suit/utility/radiation(src)
	new /obj/item/clothing/head/utility/radiation(src)

/*
 * Bombsuit Locker
 */
/obj/structure/locker/bomblocker
	name = "\improper EOD locker"
	desc = "It's a storage unit for explosion-protective suits."
	icon_state = "bomb"

/obj/structure/locker/bomblocker/PopulateContents()
	..()
	new /obj/item/clothing/suit/utility/bomb_suit(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/utility/bomb_hood(src)

/obj/structure/locker/bomblocker/security/PopulateContents()
	new /obj/item/clothing/suit/utility/bomb_suit/security(src)
	new /obj/item/clothing/under/rank/security/officer(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/head/utility/bomb_hood/security(src)

/obj/structure/locker/bomblocker/white/PopulateContents()
	new /obj/item/clothing/suit/utility/bomb_suit/white(src)
	new /obj/item/clothing/under/color/black(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/head/utility/bomb_hood/white(src)

/*
 * Ammunition
 */
/obj/structure/locker/ammunitionlocker
	name = "ammunition locker"

/obj/structure/locker/ammunitionlocker/PopulateContents()
	..()
	for(var/i in 1 to 8)
		new /obj/item/ammo_casing/shotgun/beanbag(src)
