/obj/item/weapon/reagent_containers/hypospray
	name = "hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	icon = 'icons/obj/syringe.dmi'
	item_state = "hypo"
	icon_state = "hypo"
	amount_per_transfer_from_this = 5
	volume = 30
	possible_transfer_amounts = list()
	resistance_flags = ACID_PROOF
	container_type = OPENCONTAINER
	slot_flags = SLOT_BELT
	var/ignore_flags = 0
	var/infinite = FALSE

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/weapon/reagent_containers/hypospray/attack(mob/living/M, mob/user)
	if(!reagents.total_volume)
		user << "<span class='warning'>[src] is empty!</span>"
		return
	if(!iscarbon(M))
		return

	if(reagents.total_volume && (ignore_flags || M.can_inject(user, 1))) // Ignore flag should be checked first or there will be an error message.
		M << "<span class='warning'>You feel a tiny prick!</span>"
		user << "<span class='notice'>You inject [M] with [src].</span>"

		var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
		reagents.reaction(M, INJECT, fraction)
		if(M.reagents)
			var/list/injected = list()
			for(var/datum/reagent/R in reagents.reagent_list)
				injected += R.name
			var/trans = 0
			if(!infinite)
				trans = reagents.trans_to(M, amount_per_transfer_from_this)
			else
				trans = reagents.copy_to(M, amount_per_transfer_from_this)

			user << "<span class='notice'>[trans] unit\s injected.  [reagents.total_volume] unit\s remaining in [src].</span>"

			var/contained = english_list(injected)

			add_logs(user, M, "injected", src, "([contained])")

/obj/item/weapon/reagent_containers/hypospray/CMO
	list_reagents = list("omnizine" = 30)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/weapon/reagent_containers/hypospray/combat
	name = "combat stimulant injector"
	desc = "A modified air-needle autoinjector, used by support operatives to quickly heal injuries in combat."
	amount_per_transfer_from_this = 10
	icon_state = "combat_hypo"
	volume = 90
	ignore_flags = 1 // So they can heal their comrades.
	list_reagents = list("epinephrine" = 30, "omnizine" = 30, "leporazine" = 15, "atropine" = 15)

/obj/item/weapon/reagent_containers/hypospray/combat/nanites
	desc = "A modified air-needle autoinjector for use in combat situations. Prefilled with expensive medical nanites for rapid healing."
	volume = 100
	list_reagents = list("nanites" = 80, "synaptizine" = 20)

//MediPens

/obj/item/weapon/reagent_containers/hypospray/medipen
	name = "epinephrine medipen"
	desc = "A rapid and safe way to stabilize patients in critical condition for personnel without advanced medical knowledge."
	icon_state = "medipen"
	item_state = "medipen"
	amount_per_transfer_from_this = 10
	volume = 10
	ignore_flags = 1 //so you can medipen through hardsuits
	flags = null
	list_reagents = list("epinephrine" = 10)

/obj/item/weapon/reagent_containers/hypospray/medipen/attack(mob/M, mob/user)
	if(!reagents.total_volume)
		user << "<span class='warning'>[src] is empty!</span>"
		return
	..()
	update_icon()
	spawn(80)
		if(iscyborg(user) && !reagents.total_volume)
			var/mob/living/silicon/robot/R = user
			if(R.cell.use(100))
				reagents.add_reagent_list(list_reagents)
				update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/medipen/update_icon()
	if(reagents.total_volume > 0)
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/weapon/reagent_containers/hypospray/medipen/examine()
	..()
	if(reagents && reagents.reagent_list.len)
		usr << "<span class='notice'>It is currently loaded.</span>"
	else
		usr << "<span class='notice'>It is spent.</span>"

/obj/item/weapon/reagent_containers/hypospray/medipen/stimpack //goliath kiting
	name = "stimpack medipen"
	desc = "A rapid way to stimulate your body's adrenaline, allowing for freer movement in restrictive armor."
	icon_state = "stimpen"
	volume = 20
	amount_per_transfer_from_this = 20
	list_reagents = list("ephedrine" = 10, "coffee" = 10)

/obj/item/weapon/reagent_containers/hypospray/medipen/stimpack/traitor
	desc = "A modified stimulants autoinjector for use in combat situations. Has a mild healing effect."
	list_reagents = list("stimulants" = 10, "omnizine" = 10)

/obj/item/weapon/reagent_containers/hypospray/medipen/morphine
	name = "morphine medipen"
	desc = "A rapid way to get you out of a tight situation and fast! You'll feel rather drowsy, though."
	list_reagents = list("morphine" = 10)

/obj/item/weapon/reagent_containers/hypospray/medipen/tuberculosiscure
	name = "BVAK autoinjector"
	desc = "Bio Virus Antidote Kit autoinjector. Has a two use system for yourself, and someone else. Inject when infected."
	icon_state = "stimpen"
	volume = 60
	amount_per_transfer_from_this = 30
	list_reagents = list("atropine" = 10, "epinephrine" = 10, "salbutamol" = 20, "spaceacillin" = 20)

/obj/item/weapon/reagent_containers/hypospray/medipen/survival
	name = "survival medipen"
	desc = "A medipen for surviving in the harshest of environments, heals and protects from environmental hazards. WARNING: Do not inject more than one pen in quick succession."
	icon_state = "stimpen"
	volume = 57
	amount_per_transfer_from_this = 57
	list_reagents = list("salbutamol" = 10, "leporazine" = 15, "tricordrazine" = 15, "epinephrine" = 10, "miningnanites" = 2, "omnizine" = 5)

/obj/item/weapon/reagent_containers/hypospray/medipen/species_mutator
	name = "species mutator medipen"
	desc = "Embark on a whirlwind tour of racial insensitivity by \
		literally appropriating other races."
	volume = 1
	amount_per_transfer_from_this = 1
	list_reagents = list("unstablemutationtoxin" = 1)
