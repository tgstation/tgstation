#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1

/obj/item/weapon/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe that can hold up to 15 units."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null	//list(5, 10, 15)
	volume = 15
	var/mode = SYRINGE_DRAW
	var/busy = 0		// needed for delayed drawing of blood
	materials = list(MAT_METAL=10, MAT_GLASS=20)

/obj/item/weapon/reagent_containers/syringe/New()
	..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_paw()
	return attack_hand()

/obj/item/weapon/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	return

/obj/item/weapon/reagent_containers/syringe/afterattack(obj/target, mob/user , proximity)
	if(busy)
		return
	if(!proximity) return
	if(!target.reagents) return

	if(isliving(target))
		var/mob/living/M = target
		if(!M.can_inject(user, 1))
			return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "<span class='notice'>The syringe is full.</span>"
				return

			if(ismob(target))	//Blood!
				if(ishuman(target))
					var/mob/living/carbon/human/H = target
					if(H.dna)
						if(NOBLOOD in H.dna.species.specflags && !H.dna.species.exotic_blood)
							user << "<span class='warning'>You are unable to locate any blood!</span>"
							return
				if(reagents.has_reagent("blood"))
					user << "<span class='warning'>There is already a blood sample in this syringe!</span>"
					return
				if(istype(target, /mob/living/carbon))	//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
					var/amount = src.reagents.maximum_volume - src.reagents.total_volume
					var/mob/living/carbon/T = target
					if(!check_dna_integrity(T))
						user << "<span class='warning'>You are unable to locate any blood!</span>"
						return
					if(NOCLONE in T.mutations)	//target done been eat, no more blood in him
						user << "<span class='warning'>You are unable to locate any blood!</span>"
						return
					if(target != user)
						target.visible_message("<span class='danger'>[user] is trying to take a blood sample from [target]!</span>", \
										"<span class='userdanger'>[user] is trying to take a blood sample from [target]!</span>")
						busy = 1
						if(!do_mob(user, target))
							busy = 0
							return
					busy = 0
					var/datum/reagent/B
					B = T.take_blood(src,amount)

					if(!B && ishuman(target))
						var/mob/living/carbon/human/H = target
						if(H.dna && H.dna.species.exotic_blood && H.reagents.total_volume)
							target.reagents.trans_to(src, amount)
						else
							user << "<span class='warning'>You are unable to locate any blood!</span>"
							return
					if (B)
						src.reagents.reagent_list += B
						src.reagents.update_total()
						src.on_reagent_change()
						src.reagents.handle_reactions()
					user.visible_message("[user] takes a blood sample from [target].")

			else //if not mob
				if(!target.reagents.total_volume)
					user << "<span class='warning'>[target] is empty!</span>"
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime_extract))
					user << "<span class='warning'>You cannot directly remove reagents from [target]!</span>"
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				user << "<span class='notice'>You fill [src] with [trans] units of the solution.</span>"
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				user << "<span class='notice'>[src] is empty.</span>"
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/weapon/storage/fancy/cigarettes))
				user << "<span class='warning'>You cannot directly fill [target]!</span>"
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "<span class='notice'>[target] is full.</span>"
				return

			if(ismob(target) && target != user)
				target.visible_message("<span class='danger'>[user] is trying to inject [target]!</span>", \
										"<span class='userdanger'>[user] is trying to inject [target]!</span>")
				if(!do_mob(user, target))
					return
				//Sanity checks after sleep
				if(!reagents.total_volume)
					return
				if(target.reagents.total_volume >= target.reagents.maximum_volume)
					return

				target.visible_message("<span class='danger'>[user] injects [target] with the syringe!", \
								"<span class='userdanger'>[user] injects [target] with the syringe!")
				//Attack log entries are produced here due to failure to produce elsewhere. Remove them here if you have doubles from normal syringes.
				var/list/rinject = list()
				for(var/datum/reagent/R in src.reagents.reagent_list)
					rinject += R.name
				var/contained = english_list(rinject)
				var/mob/M = target
				add_logs(user, M, "injected", src, addition="which had [contained]")
				var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
				reagents.reaction(target, INGEST, fraction)
			if(ismob(target) && target == user)
				//Attack log entries are produced here due to failure to produce elsewhere. Remove them here if you have doubles from normal syringes.
				var/list/rinject = list()
				for(var/datum/reagent/R in src.reagents.reagent_list)
					rinject += R.name
				var/contained = english_list(rinject)
				var/mob/M = target
				log_attack("<font color='red'>[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [src.name], which had [contained] (INTENT: [uppertext(user.a_intent)])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Injected themselves ([contained]) with [src.name].</font>")
				var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
				reagents.reaction(target, INGEST, fraction)
			spawn(5)
				var/datum/reagent/blood/B
				for(var/datum/reagent/blood/d in src.reagents.reagent_list)
					B = d
					break
				if(B && istype(target,/mob/living/carbon))
					var/mob/living/carbon/C = target
					C.inject_blood(src,5)
				else
					src.reagents.trans_to(target, amount_per_transfer_from_this)
				user << "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [src.reagents.total_volume] units.</span>"
				if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()


/obj/item/weapon/reagent_containers/syringe/update_icon()
	var/rounded_vol = min(max(round(reagents.total_volume,5),5),15)
	overlays.Cut()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")
		filling.icon_state = "syringe[rounded_vol]"
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/syringe/epinephrine
	name = "syringe (epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 15)

/obj/item/weapon/reagent_containers/syringe/charcoal
	name = "syringe (charcoal)"
	desc = "Contains charcoal."
	list_reagents = list("charcoal" = 15)

/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list("spaceacillin" = 15)

/obj/item/weapon/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list("neurotoxin" = 5, "mutetoxin" = 5, "sodium_thiopental" = 5)

/obj/item/weapon/reagent_containers/syringe/stimulants
	name = "Stimpack"
	desc = "Contains stimulants."
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list("stimulants" = 50)

/obj/item/weapon/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel."
	list_reagents = list("calomel" = 15)

/obj/item/weapon/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	volume = 50

/obj/item/weapon/reagent_containers/syringe/lethal/choral
	list_reagents = list("chloralhydrate" = 50)
