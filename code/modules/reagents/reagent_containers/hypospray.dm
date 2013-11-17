/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	slot_flags = SLOT_BELT

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/reagent_containers/hypospray/New()	//comment this to make hypos start off empty
	..()
	reagents.add_reagent("doctorsdelight", 30)


/obj/item/weapon/reagent_containers/hypospray/attack(mob/M, mob/user)
	if(!reagents.total_volume)
		user << "<span class='notice'>[src] is empty.</span>"
		return
	if(!ismob(M))
		return
	if(reagents.total_volume)
		user << "<span class='notice'>You inject [M] with [src].</span>"
		M << "<span class='warning'>You feel a tiny prick!</span>"

		reagents.reaction(M, INGEST)
		if(M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>"

			var/contained = english_list(injected)

			log_attack("<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name], which had [contained] (INTENT: [uppertext(user.a_intent)])</font>")
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected ([contained]) with [src.name] by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.ckey]) with [contained]</font>")


/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by operatives trained in medical practices to quickly heal injuries in the field."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 60

/obj/item/weapon/reagent_containers/hypospray/combat/New()
	..()
	reagents.add_reagent("synaptizine", 30)