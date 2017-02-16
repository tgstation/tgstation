/obj/item/weapon/reagent_containers
	name = "Container"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	w_class = WEIGHT_CLASS_TINY
	var/amount_per_transfer_from_this = 5
	var/list/possible_transfer_amounts = list(5,10,15,20,25,30)
	var/volume = 30
	var/list/list_reagents = null
	var/spawned_disease = null
	var/disease_amount = 20
	var/spillable = 0

/obj/item/weapon/reagent_containers/New(location, vol = 0)
	..()
	if (isnum(vol) && vol > 0)
		volume = vol
	create_reagents(volume)
	if(spawned_disease)
		var/datum/disease/F = new spawned_disease(0)
		var/list/data = list("viruses"= list(F))
		reagents.add_reagent("blood", disease_amount, data)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)

/obj/item/weapon/reagent_containers/attack_self(mob/user)
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == amount_per_transfer_from_this)
				if(i<possible_transfer_amounts.len)
					amount_per_transfer_from_this = possible_transfer_amounts[i+1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				user << "<span class='notice'>[src]'s transfer amount is now [amount_per_transfer_from_this] units.</span>"
				return

/obj/item/weapon/reagent_containers/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM)
		return ..()

/obj/item/weapon/reagent_containers/afterattack(obj/target, mob/user , flag)
	return

/obj/item/weapon/reagent_containers/proc/reagentlist(obj/item/weapon/reagent_containers/snack) //Attack logs for regents in pills
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
		var/who = (isnull(user) || eater == user) ? "your" : "[eater.p_their()]"
		user << "<span class='warning'>You have to remove [who] [covered] first!</span>"
		return 0
	return 1

/obj/item/weapon/reagent_containers/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

/obj/item/weapon/reagent_containers/fire_act(exposed_temperature, exposed_volume)
	reagents.chem_temp += 30
	reagents.handle_reactions()
	..()

/obj/item/weapon/reagent_containers/throw_impact(atom/target)
	. = ..()
	SplashReagents(target, TRUE)

/obj/item/weapon/reagent_containers/proc/SplashReagents(atom/target, thrown = FALSE)
	if(!reagents || !reagents.total_volume || !spillable)
		return

	if(ismob(target) && target.reagents)
		if(thrown)
			reagents.total_volume *= rand(5,10) * 0.1 //Not all of it makes contact with the target
		var/mob/M = target
		var/R
		target.visible_message("<span class='danger'>[M] has been splashed with something!</span>", \
						"<span class='userdanger'>[M] has been splashed with something!</span>")
		for(var/datum/reagent/A in reagents.reagent_list)
			R += A.id + " ("
			R += num2text(A.volume) + "),"

		if(thrownby)
			add_logs(thrownby, M, "splashed", R)
		reagents.reaction(target, TOUCH)

	else if((target.CanPass(src, get_turf(src))) && thrown && thrownby && thrownby.mind && thrownby.mind.assigned_role == "Bartender")
		visible_message("<span class='notice'>[src] lands onto the [target.name] without spilling a single drop.</span>")
		return

	else
		visible_message("<span class='notice'>[src] spills its contents all over [target].</span>")
		reagents.reaction(target, TOUCH)
		if(QDELETED(src))
			return

	reagents.clear_reagents()

/obj/item/weapon/reagent_containers/microwave_act(obj/machinery/microwave/M)
	if(is_open_container())
		reagents.chem_temp = max(reagents.chem_temp, 1000)
		reagents.handle_reactions()
	..()