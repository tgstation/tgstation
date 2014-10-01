/obj/item/weapon/reagent_containers/borghypo
	name = "Cyborg Hypospray"
	desc = "An advanced chemical synthesizer and injection system, designed for heavy-duty medical equipment."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "borghypo"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null
	flags = FPRINT
	var/mode = 1
	var/charge_cost = 50
	var/charge_tick = 0
	var/recharge_time = 5 // time it takes for shots to recharge (in seconds)

	var/list/datum/reagents/reagent_list = list()
	var/list/reagent_ids = list("tricordrazine", "inaprovaline", "spaceacillin")
	//var/list/reagent_ids = list("dexalin", "kelotane", "bicaridine", "anti_toxin", "inaprovaline", "spaceacillin")

/obj/item/weapon/reagent_containers/borghypo/New(loc)
	..(loc)
	reagents.Destroy()
	reagents = null

	for(var/reagent in reagent_ids)
		var/datum/reagents/reagents = new(volume)
		reagents.my_atom = src
		reagents.add_reagent(reagent, volume)
		reagent_list += reagents

	processing_objects += src

/obj/item/weapon/reagent_containers/borghypo/Destroy()
	for(var/datum/reagents/reagents in reagent_list)
		reagents.Destroy()
		reagents = null

	processing_objects -= src
	..()

/obj/item/weapon/reagent_containers/borghypo/process() //Every [recharge_time] seconds, recharge some reagents for the cyborg
	if(++charge_tick < recharge_time)
		return 0

	charge_tick = 0

	if(isrobot(loc))
		var/mob/living/silicon/robot/robot = loc

		if(robot && robot.cell)
			var/datum/reagents/reagents = reagent_list[mode]

			if(reagents.total_volume < reagents.maximum_volume) // don't recharge reagents and drain power if the storage is full
				robot.cell.use(charge_cost) // take power from borg
				reagents.add_reagent(reagent_ids[mode], 5) // and fill hypo with reagent.

	//update_icon()
	return 1

// Purely for testing purposes I swear~
/*
/obj/item/weapon/reagent_containers/borghypo/verb/add_cyanide()
	set src in world
	add_reagent("cyanide")
*/

/obj/item/weapon/reagent_containers/borghypo/attack(mob/M as mob, mob/user as mob)
	var/datum/reagents/reagents = reagent_list[mode]

	if(!reagents.total_volume)
		user << "<span class='notice'>The injector is empty.</span>"
		return

	if(!ismob(M))
		return

	user << "<span class='info'>You inject [M] with the injector.<span>"
	M << "<span class='warning'>You feel a tiny prick!</span>"
	reagents.reaction(M, INGEST)

	if(M.reagents)
		var/transferred = reagents.trans_to(M, amount_per_transfer_from_this)
		user << "<span class='notice'>[transferred] units injected. [reagents.total_volume] units remaining.</span>"

/obj/item/weapon/reagent_containers/borghypo/attack_self(mob/user as mob)
	playsound(get_turf(src), 'sound/effects/pop.ogg', 50, 0) // change the mode

	if(++mode > reagent_list.len)
		mode = 1

	charge_tick = 0 // prevents wasted chems/cell charge if you're cycling through modes.

	user << "<span class='notice'>Synthesizer is now producing '[reagent_ids[mode]]'.</span>"

/obj/item/weapon/reagent_containers/borghypo/examine()
	set src in view()
	..()
	if (!(usr in view(2)) && usr!=src.loc) return

	var/contents_count = 0

	for(var/datum/reagents/reagents in reagent_list)
		usr << "<span class='notice'>It's currently has [reagents.total_volume] units of [reagent_ids[++contents_count]] stored.</span>"

	usr << "<span class='notice'>It's currently producing '[reagent_ids[mode]]'.</span>"

/obj/item/weapon/reagent_containers/borghypo/upgraded
	name = "Upgraded Cyborg Hypospray"
	desc = "An upgraded hypospray with more potent chemicals and a larger storage capacity."
	reagent_ids = list("doctorsdelight", "dexalinp", "spaceacillin", "charcoal")
	volume = 50
	recharge_time = 3 // time it takes for shots to recharge (in seconds)
