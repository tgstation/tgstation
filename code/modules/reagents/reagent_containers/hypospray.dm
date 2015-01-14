//Hyposprays

/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = null
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	var/ignore_flags = 0

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		user << "<span class='notice'>[src] is empty.</span>"
		return
	if(!istype(M))
		return

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		M << "<span class='warning'>You feel a tiny prick!</span>"
		user << "<span class='notice'>You inject [M] with [src].</span>"

		reagents.reaction(M, INGEST)
		if(M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name

			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>"

			var/contained = english_list(injected)

			add_logs(user, M, "injected", object="[src.name]", addition="([contained])")

/obj/item/weapon/reagent_containers/hypospray/CMO/New()
	..()
	reagents.add_reagent("doctorsdelight", 30)

/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 60
	ignore_flags = 1 // So they can heal their comrades.

/obj/item/weapon/reagent_containers/hypospray/combat/New()
	..()
	reagents.add_reagent("synaptizine", 30)



//MediPens

/obj/item/weapon/reagent_containers/hypospray/medipen
	name = "inaprovaline medipen" //lol epipen is copyrighted
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	icon_state = "medipen"
	item_state = "medipen"
	amount_per_transfer_from_this = 10
	volume = 10
	ignore_flags = 1 //so you can medipen through hardsuits
	flags = null
	var/starting_reagent = "inaprovaline"
	var/starting_amount = 10

/obj/item/weapon/reagent_containers/hypospray/medipen/New()
	..()
	reagents.add_reagent(starting_reagent, starting_amount)
	update_icon()
	return


/obj/item/weapon/reagent_containers/hypospray/medipen/attack(mob/M as mob, mob/user as mob)
	..()
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/weapon/reagent_containers/hypospray/medipen/examine()
	..()
	if(reagents && reagents.reagent_list.len)
		usr << "<span class='notice'>It is currently loaded.</span>"
	else
		usr << "<span class='notice'>It is spent.</span>"


/obj/item/weapon/reagent_containers/hypospray/medipen/leporazine //basilisks
	name = "leporazine medipen"
	desc = "A rapid way to regulate your body's temperature in the event of a hardsuit malfunction at the cost of some shortness of breath."
	icon_state = "lepopen"
	starting_reagent = "leporazine"
	starting_amount = 9

/obj/item/weapon/reagent_containers/hypospray/medipen/leporazine/New()
	..()
	reagents.add_reagent("lexorin", 1)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor at the cost of some shortness of breath."
	icon_state = "stimpen"
	starting_reagent = "hyperzine"
	starting_amount = 9

/obj/item/weapon/reagent_containers/hypospray/medipen/stimpack/New()
	..()
	reagents.add_reagent("lexorin", 1)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	icon_state = "medipen"
	starting_reagent = "morphine"

/obj/item/weapon/reagent_containers/hypospray/medipen/ephedrine
	name = "ephedrine medipen"
	desc = "A rapid way to get you up and out of a tight situation and fast!"
	icon_state = "medipen"
	starting_reagent = "ephedrine"