/obj/item/weapon/reagent_containers/blood
<<<<<<< HEAD
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	volume = 200
	var/blood_type = null
	var/labelled = 0
=======
	name = "Bloodpack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "empty"
	volume = 200

	var/blood_type = null
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/weapon/reagent_containers/blood/New()
	..()
	if(blood_type != null)
<<<<<<< HEAD
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
=======
		name = "[blood_type] Bloodpack"
	reagents.add_reagent(BLOOD, 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
	update_icon()

/obj/item/weapon/reagent_containers/blood/on_reagent_change()
	update_icon()
	if(reagents.total_volume == 0 && name != "Empty Bloodback")
		name = "Empty Bloodpack"
		desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	else if (reagents.reagent_list.len > 0)
		var/target_type = null
		var/the_volume = 0
		for(var/datum/reagent/A in reagents.reagent_list)
			if(A.volume > the_volume && ("blood_type" in A.data))
				the_volume = A.volume
				target_type = A.data["blood_type"]
		if (target_type)
			name = "[target_type] Bloodpack"
			desc = "A bloodpack filled with [target_type] blood."
			blood_type = target_type
		else
			name = "Murky Bloodpack"
			desc = "A bloodpack that's clearly not filled with blood."
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

/obj/item/weapon/reagent_containers/blood/update_icon()
	var/percent = round((reagents.total_volume / volume) * 100)
	switch(percent)
<<<<<<< HEAD
		if(0 to 9)
			icon_state = "empty"
		if(10 to 50)
			icon_state = "half"
		if(51 to INFINITY)
			icon_state = "full"

/obj/item/weapon/reagent_containers/blood/random/New()
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-", "L")
	..()

=======
		if(0 to 9)		icon_state = "empty"
		if(10 to 50) 		icon_state = "half"
		if(51 to INFINITY)	icon_state = "full"

/obj/item/weapon/reagent_containers/blood/examine(mob/user)
	//I don't want this to be an open container.
	..()
	if(get_dist(user,src) > 3)
		to_chat(user, "<span class='info'>You can't make out the contents.</span>")
		return
	if(reagents)
		to_chat(user, "It contains:")
		if(reagents.reagent_list.len)
			for(var/datum/reagent/R in reagents.reagent_list)
				if (R.id == BLOOD)
					var/type = R.data["blood_type"]
					to_chat(user, "<span class='info'>[R.volume] units of [R.name], of type [type]</span>")
				else
					to_chat(user, "<span class='info'>[R.volume] units of [R.name]</span>")
		else
			to_chat(user, "<span class='info'>Nothing.</span>")

//These should be kept for legacy purposes, probably. At least until they disappear from maps.
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
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

<<<<<<< HEAD
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
		if(user.get_active_hand() != I)
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
=======
/obj/item/weapon/reagent_containers/blood/empty
	name = "Empty Bloodpack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "empty"
	New()
		..()
		blood_type = null
		reagents.clear_reagents()
		update_icon()

/obj/item/weapon/reagent_containers/blood/chemo
	name = "Phalanximine IV kit"
	desc = "IV kit for chemotherapy."
	icon = 'icons/obj/chemopack.dmi'
	New()
		..()
		reagents.clear_reagents()
		reagents.add_reagent(PHALANXIMINE, 200)
		update_icon()
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
