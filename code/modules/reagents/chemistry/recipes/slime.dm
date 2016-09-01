// GENERIC //

/datum/chemical_reaction/slime
	required_other = 1
	var/slimecore = null

/datum/chemical_reaction/slime/special_reqs(datum/reagents/holder)
	..()
	if(slime_check && slimecore && istype(holder, slimecore))
		return 1

/datum/chemical_reaction/slime/proc/slime_check(datum/reagents/holder)
	if(istype(holder.my_atom, /obj/item/slime_extract))
		var/obj/item/slime_extract/M = my_atom
		if(M.Uses > 0) // added a limit to slime cores -- Muskets requested this
			return 1

/datum/chemical_reaction/slime/proc/slime_success(datum/reagents/holder)
	feedback_add_details("slime_cores_used","[type]")

	var/list/seen = viewers(4, get_turf(my_atom))
	if(istype(my_atom, /obj/item/slime_extract))
		var/obj/item/slime_extract/ME2 = my_atom
		ME2.Uses--
		if(ME2.Uses <= 0) // give the notification that the slime core is dead
			for(var/mob/M in seen)
				M << "<span class='notice'>\icon[my_atom] \The [my_atom]'s power is consumed in the reaction.</span>"
				ME2.name = "used slime extract"
				ME2.desc = "This extract has been used up."

// GREY SLIME //

// Plasma //
/datum/chemical_reaction/slime/greyplasma
	required_reagents = list("plasma" = 1)
	slimecore = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/greyplasma/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(FALSE)
	if(!multiplier)
		return 0

	var/mob/living/simple_animal/slime/S
	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		S = new(get_turf(holder.my_atom), "grey")
		consume_reagents(1)
		slime_success(holder)
	S.visible_message("<span class='danger'>Infused with plasma, the \
			core begins to quiver and grow, and soon [multiplier > 1 ? "mew baby slimes emerge":"a new baby slime emerges"] from it!</span>")
	simple_feedback()
	return 1

// Water //
/datum/chemical_reaction/slime/greywater
	results = list("epinephrine" = 3)
	required_reagents = list("water" = 5)
	slimecore = /obj/item/slime_extract/grey

/datum/chemical_reaction/slime/greywater/react(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(FALSE)
	if(!multiplier)
		return 0

	for(var/i = 1, i <= multiplier && slime_check(holder), i++)
		slime_success(holder)
		simple_react(1)
	simple_feedback()
	return 1

// Blood //
/datum/chemical_reaction/slime/greyblood
	required_reagents = list("blood" = 1)
	slimecore = /obj/item/slime_extract/grey

/datum/chemical_reaction/slimemonkey/on_reaction(datum/reagents/holder)
	..()
	var/multiplier = get_multiplier(FALSE)
	if(!multiplier)
		return 0
	for(var/i = 1, i <= 3*multiplier && slimecheck(holder), i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)
		consume_reagents(1)
		slime_success(holder)
	simple_feedback()
	return 1


