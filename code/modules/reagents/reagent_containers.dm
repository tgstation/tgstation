/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = 1
	var/amount_per_transfer_from_this = 5
	var/possible_transfer_amounts = list(5,10,15,25,30)
	var/volume = 30
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20
	var/spillable = 0

/obj/item/weapon/reagent_containers/verb/set_APTFT() //set amount_per_transfer_from_this
	set name = "Set transfer amount"
	set category = "Object"
	set src in range(0)
	if(usr.stat || !usr.canmove || usr.restrained())
		return
	var/N = input("Amount per transfer from this:","[src]") as null|anything in possible_transfer_amounts
	if (N)
		amount_per_transfer_from_this = N

/obj/item/weapon/reagent_containers/New(location, vol = 0)
	..()
	if (!possible_transfer_amounts)
		src.verbs -= /obj/item/weapon/reagent_containers/verb/set_APTFT
	if (vol > 0)
		volume = vol
	create_reagents(volume)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", disease_amount, data)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/weapon/reagent_containers/attack_self(mob/user as mob)
	return

/obj/item/weapon/reagent_containers/attack(mob/M as mob, mob/user as mob, def_zone)
	return

/obj/item/weapon/reagent_containers/afterattack(obj/target, mob/user , flag)
	return

/obj/item/weapon/reagent_containers/proc/reagentlist(var/obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
	var/data
	if(snack.reagents.reagent_list && snack.reagents.reagent_list.len) //find a reagent list if there is and check if it has entries
		for (var/datum/reagent/R in snack.reagents.reagent_list) //no reagents will be left behind
			data += "[R.id]([R.volume] units); " //Using IDs because SOME chemicals(I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
		return data
	else return "No reagents"

/obj/item/weapon/reagent_containers/proc/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return 0
	var/mob/living/carbon/C = eater
	var/covered = ""
	if(C.is_mouth_covered(head_only = 1))
		covered = "headgear"
	else if(C.is_mouth_covered(mask_only = 1))
		covered = "mask"
	if(covered)
		var/who = (isnull(user) || eater == user) ? "your" : "their"
		user << "<span class='warning'>You have to remove [who] [covered] first!</span>"
		return 0
	return 1

/obj/item/weapon/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	..()

/obj/item/weapon/reagent_containers/fire_act()
	reagents.chem_temp += 30
	reagents.handle_reactions()
	..()

/obj/item/weapon/reagent_containers/throw_impact(atom/target,mob/thrower)
	..()

	if(!reagents.total_volume || !spillable)
		return

	if(ismob(target) && target.reagents)
		reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[M] has been splashed with something!</span>", \
						"<span class='userdanger'>[M] has been splashed with something!</span>")
		if(reagents)
			for(var/datum/reagent/A in reagents.reagent_list)
				R += A.id + " ("
				R += num2text(A.volume) + "),"

		if(thrower)
			add_logs(thrower, M, "splashed", object="[R]")
		reagents.reaction(target, TOUCH)

	else if((!target.density || target.throwpass) && thrower && thrower.mind && thrower.mind.assigned_role == "Bartender")
		visible_message("<span class='notice'>[src] lands onto the [target.name] without spilling a single drop.</span>")
		return

	else
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>")
		reagents.reaction(target, TOUCH)

	reagents.clear_reagents()
