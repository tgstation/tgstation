/obj/machinery/smelter
	name = "smelter"
	desc = "An old Sendarian tool."
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "forge"
	density = 1
	anchored = 0

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
	density = 1
	anchored = 0
	var/obj/item/weapon/reagent_containers/glass/mold/current_mold = null
	var/mutable_appearance/my_mold = null

/obj/machinery/anvil/attackby(obj/item/weapon/W, mob/user, params)
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
		else
			to_chat(user, "The mold is empty, dipshit.")
			return
	if(istype(W, /obj/item/weapon/smith_hammer))
		if(current_mold)
			to_chat(user, "You break the result out of [current_mold].")
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
			return
		else
			to_chat(user, "There's nothing to smith, retard.")
			return

/obj/item/weapon/smith_hammer
	name = "smith's hammer"
	desc = "John was here."
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "hammer"
	force = 10
	w_class = 1

/obj/item/weapon/smith_sword
	name = "sword"
	desc = "Vanquish thy foes!"
	icon = 'icons/obj/blacksmithing.dmi'
	icon_state = "sword_base"

/obj/item/weapon/smith_sword/post_smithing()
	name = "[smelted_material.name] sword"
	var/image/I = image('icons/obj/blacksmithing.dmi', "sword_blade")
	I.color = smelted_material.color
	add_overlay(I)
	force = smelted_material.attack_force
