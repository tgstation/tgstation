 //Suits for the pink and grey skeletons!

/obj/item/clothing/suit/space/hardsuit/atmos/plasmaman
	name = "plasmaman suit"
	desc = "A special containment suit designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_casing,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0)
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/atmos/plasmaman
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/atmos/plasmaman/examine(mob/user)
	..()
	user << "<span class='notice'>There are [extinguishes_left] extinguisher canisters left in this suit.</span>"


/obj/item/clothing/suit/space/hardsuit/atmos/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.fire_stacks)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message("<span class='warning'>[H]'s suit automatically extinguishes them!</span>","<span class='warning'>Your suit automatically extinguishes you.</span>")
			H.ExtinguishMob()
			PoolOrNew(/obj/effect/effect/water, get_turf(H))

/obj/item/clothing/head/helmet/space/hardsuit/atmos/plasmaman
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	icon_state = "hardsuit0-plasma"
	item_color = "plasma" //needed for the helmet lighting
	item_state = "plasmaman_helmet0"
	flags = BLOCKHAIR | STOPSPRESSUREDMAGE | THICKMATERIAL
	//Removed the NODROP from /helmet/space/hardsuit.
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	//Removed the HIDEFACE from /helmet/space/hardsuit
//	basestate = "plasmaman_helmet"
	body_parts_covered = EYES | MOUTH
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT

//Ghetto plasmaman-suits. Someone add these to toxins

/obj/item/clothing/head/bio_hood/plasma	//Todo: own sprite to seperate from the plasmaman hardsuit
	name = "toxins fire hood"
	desc = "A hood that protects the head and face from biological contaminants and heat."
	icon_state = "hardsuit0-plasma"
	item_state = "plasmaman_helmet0"
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/suit/bio_suit/plasma
	name = "toxins firesuit"
	desc = "A suit that protects against biological contamination and heat."
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	icon_state = "plasmasuit"
	item_state = "plasmasuit"