
/obj/item/weapon/implant/abductor
	name = "recall implant"
	desc = "Returns you to the mothership."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "implant"
	activated = 1
	origin_tech = "materials=2;biotech=7;magnets=4;bluespace=4;abductor=5"
	var/obj/machinery/abductor/pad/home
	var/cooldown = 30

/obj/item/weapon/implant/abductor/activate()
	if(cooldown == initial(cooldown))
		home.Retrieve(imp_in,1)
		cooldown = 0
		START_PROCESSING(SSobj, src)
	else
		to_chat(imp_in, "<span class='warning'>You must wait [30 - cooldown] seconds to use [src] again!</span>")

/obj/item/weapon/implant/abductor/process()
	if(cooldown < initial(cooldown))
		cooldown++
		if(cooldown == initial(cooldown))
			STOP_PROCESSING(SSobj, src)

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
