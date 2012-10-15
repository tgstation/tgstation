////////////////////////////////////////////////////////////////////////////////
/// HYPOSPRAY
////////////////////////////////////////////////////////////////////////////////

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

/obj/item/weapon/reagent_containers/hypospray/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/item/weapon/reagent_containers/hypospray/New() //comment this to make hypos start off empty
	..()
	reagents.add_reagent("tricordrazine", 30)
	return

/obj/item/weapon/reagent_containers/hypospray/attack(mob/M as mob, mob/user as mob)
	if(!reagents.total_volume)
		user << "\red The hypospray is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		user << "\blue You inject [M] with the hypospray."
		M << "\red You feel a tiny prick!"

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [M.name] ([M.ckey])</font>")

		log_attack("<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
		log_admin("ATTACK: [user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])")
		msg_admin_attack("ATTACK: [user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])") //BS12 EDIT ALG

		src.reagents.reaction(M, INGEST)
		if(M.reagents)
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected.  [reagents.total_volume] units remaining in the hypospray."
	return

/obj/item/weapon/reagent_containers/hypospray/ert
	name = "emergency hypospray"
	desc = "The DeForest Medical Corporation hypospray is a sterile, air-needle autoinjector for rapid administration of drugs to patients."
	amount_per_transfer_from_this = 50
	volume = 50

/obj/item/weapon/reagent_containers/hypospray/autoinjector
	name = "autoinjector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	icon_state = "autoinjector"
	item_state = "autoinjector"
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/weapon/reagent_containers/hypospray/autoinjector/New()
	..()
	reagents.remove_reagent("tricordrazine", 30)
	reagents.add_reagent("inaprovaline", 5)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/attack(mob/M as mob, mob/user as mob)
	..()
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/update_icon()
	if(reagents.total_volume > 0)
		icon_state = "[initial(icon_state)]1"
	else
		icon_state = "[initial(icon_state)]0"

/obj/item/weapon/reagent_containers/hypospray/autoinjector/examine()
	..()
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			usr << "\blue It currently has [R.volume] units of [R.name] stored."
	else
		usr << "\blue It is currently empty."
