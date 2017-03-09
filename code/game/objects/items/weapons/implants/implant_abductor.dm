/obj/item/weapon/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	actions_types = list(/datum/action/item_action/hands_free/abductor_implant)
	activated = 1
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	var/obj/machinery/abductor/pad/home
	var/cooldown_timer
	var/cooldown = 300

/obj/item/weapon/implant/abductor/proc/off_cooldown()
	. = !cooldown_timer || cooldown_timer < world.time

/obj/item/weapon/implant/abductor/activate()
	if(off_cooldown())
		home.Retrieve(imp_in,1)
		cooldown_timer = world.time + cooldown
	else
		var/time_remaining = (cooldown_timer - world.time) / 10
		imp_in << "<span class='warning'>You must wait [time_remaining] seconds to use [src] again!</span>"

/obj/item/weapon/implant/abductor/implant(mob/living/target, mob/user)
	if(..())
		var/obj/machinery/abductor/console/console
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(H.dna.species.id == "abductor")
				var/datum/species/abductor/S = H.dna.species
				console = get_team_console(S.team)
				home = console.pad

		if(!home)
			console = get_team_console(pick(1, 2, 3, 4))
			home = console.pad
		return 1

/obj/item/weapon/implant/abductor/proc/get_team_console(var/team)
	var/obj/machinery/abductor/console/console
	for(var/obj/machinery/abductor/console/c in machines)
		if(c.team == team)
			console = c
			break
	return console

/datum/action/item_action/hands_free/abductor_implant
	name = "Recall"

/datum/action/item_action/hands_free/abductor_implant/IsAvailable()
	var/obj/item/weapon/implant/abductor/A = target
	if(!istype(A) || !A.off_cooldown())
		. = FALSE
	else
		. = ..()
