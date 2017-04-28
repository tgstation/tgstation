 //Suits for the pink and grey skeletons! //EVA version no longer used in favor of the Jumpsuit version


/obj/item/clothing/suit/space/eva/plasmaman
	name = "EVA plasma envirosuit"
	desc = "A special plasma containment suit designed to be space-worthy, as well as worn over other clothing. Like it's smaller counterpart, it can automatically extinguish the wearer in a crisis, and holds twice as many charges."
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
	to_chat(user, "<span class='notice'>There are [extinguishes_left] extinguisher charges left in this suit.</span>")


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
			new /obj/effect/particle_effect/water(get_turf(H))


//I just want the light feature of the hardsuit helmet
/obj/item/clothing/head/helmet/space/plasmaman
	name = "plasma envirosuit helmet"
	desc = "A special containment helmet that allows plasma-based lifeforms to exist safely in an oxygenated environment. It is space-worthy, and may be worn in tandem with other EVA gear."
	icon_state = "plasmaman-helm"
	item_state = "plasmaman-helm"
	strip_delay = 80
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0, fire = 100, acid = 75)
	resistance_flags = FIRE_PROOF
	var/brightness_on = 4 //luminosity when the light is on
	var/on = 0
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/head/helmet/space/plasmaman/attack_self(mob/user)
	on = !on
	icon_state = "[initial(icon_state)][on ? "-light":""]"
	item_state = icon_state
	user.update_inv_head() //So the mob overlay updates

	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	for(var/X in actions)
		var/datum/action/A=X
		A.UpdateButtonIcon()
