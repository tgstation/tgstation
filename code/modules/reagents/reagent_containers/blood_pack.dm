/obj/item/weapon/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	volume = 200
	var/blood_type = null
	var/labelled = 0

/obj/item/weapon/reagent_containers/blood/New()
	..()
	if(blood_type != null)
		reagents.add_reagent("blood", 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_icon()

/obj/item/weapon/reagent_containers/blood/on_reagent_change()
	if(reagents)
		var/datum/reagent/blood/B = reagents.has_reagent("blood")
		if(B && B.data && B.data["blood_type"])
			blood_type = B.data["blood_type"]
		else
			blood_type = null
	update_pack_name()
	update_icon()

/obj/item/weapon/reagent_containers/blood/proc/update_pack_name()
	if(!labelled)
		if(volume)
			if(blood_type)
				name = "blood pack [blood_type]"
			else
				name = "blood pack"
		else
			name = "empty blood pack"

/obj/item/weapon/reagent_containers/blood/update_icon()
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
		if(0 to 9)
			icon_state = "empty"
		if(10 to 50)
			icon_state = "half"
		if(51 to INFINITY)
			icon_state = "full"

/obj/item/weapon/reagent_containers/blood/random/New()
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-", "L")
	..()

/obj/item/weapon/reagent_containers/blood/APlus
	blood_type = "A+"

/obj/item/weapon/reagent_containers/blood/AMinus
	blood_type = "A-"

/obj/item/weapon/reagent_containers/blood/BPlus
	blood_type = "B+"

/obj/item/weapon/reagent_containers/blood/BMinus
	blood_type = "B-"

/obj/item/weapon/reagent_containers/blood/OPlus
	blood_type = "O+"

/obj/item/weapon/reagent_containers/blood/OMinus
	blood_type = "O-"

/obj/item/weapon/reagent_containers/blood/lizard
	blood_type = "L"

/obj/item/weapon/reagent_containers/blood/empty
	name = "empty blood pack"
	icon_state = "empty"

/obj/item/weapon/reagent_containers/blood/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/toy/crayon))

		var/t = stripped_input(user, "What would you like to label the blood pack?", name, null, 53)
		if(!user.canUseTopic(src))
			return
		if(user.get_active_held_item() != I)
			return
		if(loc != user)
			return
		if(t)
			labelled = 1
			name = "blood pack - [t]"
		else
			labelled = 0
			update_pack_name()
	else
		return ..()
