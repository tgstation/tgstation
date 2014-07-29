/obj/effect/spawner/lootdrop
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	color = "yellow"
	var/lootcount = 1		//how many items will be spawned
	var/lootdoubles = 0		//if the same item can be spawned twice
	var/list/loot			//a list of possible items to spawn e.g. list(/obj/item, /obj/structure, /obj/effect)

/obj/effect/spawner/lootdrop/initialize()
	if(loot && loot.len)
		for(var/i = 0, i < lootcount, i++)
			if(!loot.len) break
			var/lootspawn = weighted_pick(loot)
			if(!lootdoubles && lootspawn)
				var/j = loot.Find(lootspawn)
				if(j)
					loot.Cut(j,j+1)

			if(lootspawn)
				new lootspawn(get_turf(src))
	qdel(src)

/obj/effect/spawner/lootdrop/armory_contraband
	name = "armory contraband gun spawner"

	loot = list("/obj/item/weapon/gun/projectile/automatic/pistol",8,
				"/obj/item/weapon/gun/projectile/shotgun/combat",5,
				"/obj/item/weapon/gun/projectile/revolver/mateba",1,
				"/obj/item/weapon/gun/projectile/automatic/deagle",1
				)

/obj/effect/spawner/lootdrop/extinguisher
	name = "random fire extinguisher spawner"

	loot = list("/obj/item/weapon/extinguisher",1,
				"/obj/item/weapon/extinguisher/mini",1,
				)

/obj/effect/spawner/lootdrop/mask
	name = "random breathing mask spawner"

	loot = list("/obj/item/clothing/mask/gas",2,
				"/obj/item/clothing/mask/breath",2,
				"",1
				)

/obj/effect/spawner/lootdrop/oxygen
	name = "random oxygen tank spawner"

	loot = list("/obj/item/weapon/tank/emergency_oxygen",2,
				"/obj/item/weapon/tank/oxygen",2,
				"",1
				)

/obj/effect/spawner/lootdrop/tools
	name = "random tools spawner"

	loot = list("/obj/item/weapon/crowbar",1,
				"/obj/item/weapon/screwdriver",1,
				"/obj/item/weapon/wirecutters",1,
				"/obj/item/weapon/wrench",1,
				"/obj/item/weapon/weldingtool",1,
				"/obj/item/device/multitool",1,
				"",1
				)