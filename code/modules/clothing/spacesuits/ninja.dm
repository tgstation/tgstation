/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_mask"
	see_face = 1
	allowed = list(/obj/item/weapon/cell)
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 25)


/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_magazine,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/handcuffs,/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/cell)
	protective_temperature = 5000
	slowdown = 0
	armor = list(melee = 60, bullet = 50, laser = 30,energy = 15, bomb = 30, bio = 30, rad = 30)

	var
		//Important parts of the suit.
		mob/living/carbon/affecting = null//The wearer.
		obj/item/weapon/cell/cell//Starts out with a high-capacity cell using New().
		datum/effect/system/spark_spread/spark_system//To create sparks.
		reagent_list[] = list("tricordrazine","dexalinp","spaceacillin","anti_toxin","nutriment","radium","hyronalin")//The reagents ids which are added to the suit at New().
		stored_research[]//For stealing station research.
		obj/item/weapon/disk/tech_disk/t_disk//To copy design onto disk.

		//Other articles of ninja gear worn together, used to easily reference them after initializing.
		obj/item/clothing/head/helmet/space/space_ninja/n_hood
		obj/item/clothing/shoes/space_ninja/n_shoes
		obj/item/clothing/gloves/space_ninja/n_gloves

		//Main function variables.
		s_initialized = 0//Suit starts off.
		s_coold = 0//If the suit is on cooldown. Can be used to attach different cooldowns to abilities. Ticks down every second based on suit ntick().
		s_cost = 5.0//Base energy cost each ntick.
		s_acost = 25.0//Additional cost for additional powers active.
		k_cost = 200.0//Kamikaze energy cost each ntick.
		k_damage = 1.0//Brute damage potentially done by Kamikaze each ntick.
		s_delay = 40.0//How fast the suit does certain things, lower is faster. Can be overridden in specific procs. Also determines adverse probability.
		a_transfer = 20.0//How much reagent is transferred when injecting.
		r_maxamount = 80.0//How much reagent in total there is.

		//Support function variables.
		spideros = 0//Mode of SpiderOS. This can change so I won't bother listing the modes here (0 is hub). Check ninja_equipment.dm for how it all works.
		s_active = 0//Stealth off.
		s_busy = 0//Is the suit busy with a process? Like AI hacking. Used for safety functions.
		kamikaze = 0//Kamikaze on or off.
		k_unlock = 0//To unlock Kamikaze.

		//Ability function variables.
		s_bombs = 10.0//Number of starting ninja smoke bombs.
		a_boost = 3.0//Number of adrenaline boosters.

		//Onboard AI related variables.
		mob/living/silicon/ai/AI//If there is an AI inside the suit.
		obj/item/device/paicard/pai//A slot for a pAI device
		obj/effect/overlay/hologram//Is the AI hologram on or off? Visible only to the wearer of the suit. This works by attaching an image to a blank overlay.
		flush = 0//If an AI purge is in progress.
		s_control = 1//If user in control of the suit.
