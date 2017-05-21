/obj/machinery/smelter
	name = "smelter"
	desc = "An old Sendarian tool."
	icon = 'icons/obj/blacksmithing_64.dmi'
	icon_state = "forge"
	density = TRUE
	anchored = TRUE

/obj/machinery/smelter/attackby(obj/item/weapon/W, mob/user, params)
	var/smelting_result = W.on_smelt()
	if(!smelting_result)
		return ..()
	if(user.drop_item())
		to_chat(user, "You smelt [W].")
		qdel(W)
		var/obj/item/weapon/reagent_containers/glass/bucket/AB = new(get_turf(src))
		AB.reagents.add_reagent(smelting_result, 75)
		AB.reagents.chem_temp = 1000
		AB.reagents.handle_reactions()
		AB.name = "bucket of [AB.reagents.get_master_reagent_name()]"


/obj/machinery/anvil
	name = "anvil"
	desc = "Goodman Durnik, is that you?"
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "anvil"
	density = TRUE
	anchored = FALSE
	var/obj/item/weapon/reagent_containers/glass/mold/current_mold = null
	var/mutable_appearance/my_mold = null

/obj/machinery/anvil/attackby(obj/item/weapon/W, mob/user, params)
	..()
	if(!current_mold && istype(W, /obj/item/weapon/reagent_containers/glass/mold))
		var/obj/item/weapon/reagent_containers/glass/mold/M = W
		var/datum/reagent/R = M.reagents.get_master_reagent()
		if(R && R.volume == 25)
			if(user.drop_item())
				to_chat(user, "You place [M] on [src].")
				M.loc = src
				current_mold = M
				my_mold = mutable_appearance('icons/obj/blacksmithing.dmi', M.icon_state)
				add_overlay(my_mold)
				return
		if(R && R.volume)
			to_chat(user, "There's not enough in the mold to make a full cast!")
			return
		else
			to_chat(user, "There's nothing in the mold!")
			return
	if(istype(W, /obj/item/weapon/smith_hammer))
		if(current_mold)
			to_chat(user, "You break the result out of the mold.")
			new current_mold.type(get_turf(src))
			var/datum/reagent/R = current_mold.reagents.get_master_reagent()
			var/obj/item/I
			if(!istype(current_mold, /obj/item/weapon/reagent_containers/glass/mold/bar))
				I = new current_mold.produce_type(get_turf(src))
				I.smelted_material = new R.type()
				I.post_smithing()
			else
				I = new R.produce_type(get_turf(src))
			qdel(current_mold)
			cut_overlay(my_mold)
			my_mold = null
			current_mold = null
		else
			to_chat(user, "There's nothing in the mold!")

/obj/item/weapon/smith_hammer
	name = "smith's hammer"
	desc = "John was here."
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "hammer"
	force = 10
	w_class = WEIGHT_CLASS_TINY

/obj/item/weapon/mold_result
	name = "molten blob"
	desc = "A hardened blob of ore. You shouldn't be seeing this."
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "blob_base"
	w_class = WEIGHT_CLASS_NORMAL
	var/material_type = "unobtanium" //these are mostly for the smelt-crafting and whatever custom shenanigans for var-editing
	var/mold_type = "blob" //determines what the resulting item is used for and gives appropriate stats
	var/pickaxe_speed = 0
	var/metal_force = 0
	var/attack_amt = 0

/obj/item/weapon/mold_result/blade
	name = "blade"
	desc = "A blade made of "
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "sword_blade"
	mold_type = "offensive"

/obj/item/weapon/mold_result/armor_plating
	name = "armor plating"
	desc = "Armor plating made of "
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "armor"
	mold_type = "offensive"

/obj/item/weapon/mold_result/helmet_plating
	name = "helmet plating"
	desc = "Helmet plating made of "
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "helmet"
	mold_type = "offensive"

/obj/item/weapon/mold_result/pickaxe_head
	name = "pickaxe head"
	desc = "A pickaxe head made of "
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "pickaxe_head"
	mold_type = "digging"

/obj/item/weapon/mold_result/shovel_head
	name = "shovel head"
	desc = "A shovel head made of "
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "shovel_head"
	mold_type = "digging"

/obj/item/weapon/mold_result/post_smithing()
	name = "[smelted_material.name] [name]"
	material_type = "[smelted_material.name]"
	color = smelted_material.color
	armour_penetration = smelted_material.penetration_value
	attack_amt = smelted_material.attack_force
	force = smelted_material.attack_force * 0.6 //stabbing people with the resulting piece, build the full tool for full force
	desc += "[smelted_material.name]."
	if(mold_type == "digging")
		pickaxe_speed = smelted_material.pick_speed
	if(smelted_material.sharp_result)
		sharpness = IS_SHARP


////////////////////////// Smithed Items///////////////////////
/*Sword*/
/obj/item/weapon/smithed_sword
	name = "unobtanium broadsword"
	desc = "A broadsword made of unobtanium, you probably shouldn't be seeing this."
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	icon = 'icons/obj/weapons.dmi'
	icon_state = "claymore"
	item_state = "claymore"

/obj/item/weapon/smithed_sword/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/blade/B = locate() in contents
	if(B)
		var/image/I = image('icons/obj/blacksmithing.dmi', "sword_blade")
		I.color = B.color
		smelted_material = new B.smelted_material.type()
		add_overlay(I)
		name = "[B.material_type] broadsword"
		force = B.attack_amt * 2 //stabby stab
		desc = "A broadsword made of [B.material_type]."
		armour_penetration = B.armour_penetration
		sharpness = B.sharpness

/*Pickaxe*/
/obj/item/weapon/pickaxe/smithed_pickaxe
	name = "unobtanium pickaxe"
	desc = "A pickaxe made of unobtanium, you probably shouldn't be seeing this."
	icon = 'icons/obj/mining.dmi'
	icon_state = "spickaxe"
	item_state = "spickaxe"

/obj/item/weapon/pickaxe/smithed_pickaxe/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/pickaxe_head/P = locate() in contents
	if(P)
		var/image/O = image('icons/obj/blacksmithing.dmi', "pickaxe_head")
		O.color = P.color
		add_overlay(O)
		smelted_material = new P.smelted_material.type()
		name = "[P.material_type] pickaxe"
		force = P.attack_amt
		digspeed = P.pickaxe_speed
		desc = "A pickaxe with a [P.material_type] head."
		armour_penetration = P.armour_penetration * 1.25 //pickaxe would probably be the best at piercing armor
		sharpness = P.sharpness

/*Shovel*/
/obj/item/weapon/shovel/smithed_shovel
	name = "unobtanium shovel"
	desc = "A shovel made of unobtanium, you probably shouldn't be seeing this."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"

/obj/item/weapon/shovel/smithed_shovel/CheckParts(list/parts_list)
	..()
	var/obj/item/weapon/mold_result/shovel_head/S = locate() in contents
	if(S)
		var/image/Q = image('icons/obj/blacksmithing.dmi', "shovel_head")
		Q.color = S.color
		add_overlay(Q)
		smelted_material = new S.smelted_material.type()
		name = "[S.material_type] shovel"
		force = S.attack_amt * 0.8 //probably not the best idea for a weapon but it'd probably still work
		digspeed = S.pickaxe_speed * 0.5 //gotta DIG FAST
		desc = "A shovel with a [S.material_type] head."
		armour_penetration = S.armour_penetration * 0.5
		sharpness = S.sharpness



