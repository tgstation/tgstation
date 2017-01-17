 //Suits for the pink and grey skeletons!


/obj/item/clothing/suit/space/eva/plasmaman
	name = "plasmaman suit"
	desc = "A special containment suit designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_casing,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0, fire = 100, acid = 75)
	resistance_flags = FIRE_PROOF
	icon_state = "plasmaman_suit"
	item_state = "plasmaman_suit"
	var/next_extinguish = 0
	var/extinguish_cooldown = 100
	var/extinguishes_left = 10


/obj/item/clothing/suit/space/eva/plasmaman/examine(mob/user)
	..()
	user << "<span class='notice'>There are [extinguishes_left] extinguisher canisters left in this suit.</span>"


/obj/item/clothing/suit/space/eva/plasmaman/proc/Extinguish(mob/living/carbon/human/H)
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
			PoolOrNew(/obj/effect/particle_effect/water, get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasmaman helmet"
	desc = "A special containment helmet designed to protect a plasmaman's volatile body from outside exposure and quickly extinguish it in emergencies."
	icon_state = "plasmaman-helm"
	item_color = "plasma" //needed for the helmet lighting
	item_state = "plasmaman-helm"
	strip_delay = 80
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0, fire = 100, acid = 75)
	resistance_flags = FIRE_PROOF


