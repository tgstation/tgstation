/obj/item/weapon/reagent_containers/borgnutriment
	name = "cyborg nutriment injector"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty botany equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "Nutriment"
	amount_per_transfer_from_this = 10
	volume = 100
	possible_transfer_amounts = null
	flags = FPRINT
	var/mode = 1
	var/charge_cost = 20
	var/charge_tick = 0
	var/recharge_time = 5 //Time it takes for shots to recharge (in seconds)
	var/CURRENTMODE = 1
	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list("diethylamine", "nutriment", "anti_toxin" , "plantbgone")



/obj/item/weapon/reagent_containers/borgnutriment/New()
	..()
	for(var/R in reagent_ids)
		add_reagent(R)

	processing_objects.Add(src)


/obj/item/weapon/reagent_containers/borgnutriment/Del()
	processing_objects.Remove(src)
	..()


// Use this to add more chemicals for the borghypo to produce.
/obj/item/weapon/reagent_containers/borgnutriment/proc/add_reagent(var/reagent)
	reagent_ids |= reagent
	var/datum/reagents/RG = new(60)
	RG.my_atom = src
	reagent_list += RG

	var/datum/reagents/R = reagent_list[reagent_list.len]
	R.add_reagent(reagent, 100)


/obj/item/weapon/reagent_containers/borgnutriment/attack_self(mob/user)
	playsound(loc, 'sound/effects/pop.ogg', 50, 0)		//Change the mode
	mode++
	if(mode > reagent_list.len)
		mode = 1
	CURRENTMODE = mode
	var/datum/reagent/R = chemical_reagents_list[reagent_ids[mode]]
	user << "<span class='notice'>Synthesizer is now producing '[R.name]'.</span>"
	return

/obj/item/weapon/reagent_containers/borgnutriment/examine()
	set src in view()
	..()
	var/datum/reagent/R = chemical_reagents_list[reagent_ids[mode]]
	if(!(usr in view(2)) && usr != loc)
		return
	usr << "<span class='notice'>It currently set to inject '[R.name]'.</span>"