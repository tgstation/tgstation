/datum/outfit/abductor
	name = "Abductor Basic"
	uniform = /obj/item/clothing/under/color/grey //they're greys gettit
	shoes = /obj/item/clothing/shoes/combat
	back = /obj/item/storage/backpack
	ears = /obj/item/device/radio/headset/abductor

/datum/outfit/abductor/proc/get_team_console(team_number)
	for(var/obj/machinery/abductor/console/C in GLOB.machines)
		if(C.team == team_number)
			return C

/datum/outfit/abductor/proc/link_to_console(mob/living/carbon/human/H, team_number)
	if(!team_number && isabductor(H))
		var/datum/species/abductor/S = H.dna.species
		team_number = S.team

	if(!team_number)
		team_number = 1

	var/obj/machinery/abductor/console/console = get_team_console(team_number)
	if(console)
		var/obj/item/clothing/suit/armor/abductor/vest/V = locate() in H
		if(V)
			console.AddVest(V)
			V.flags |= NODROP

		var/obj/item/storage/backpack/B = locate() in H
		if(B)
			for(var/obj/item/device/abductor/gizmo/G in B.contents)
				console.AddGizmo(G)

/datum/outfit/abductor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!visualsOnly)
		link_to_console(H)


/datum/outfit/abductor/agent
	name = "Abductor Agent"
	head = /obj/item/clothing/head/helmet/abductor
	suit = /obj/item/clothing/suit/armor/abductor/vest
	suit_store = /obj/item/abductor_baton
	belt = /obj/item/storage/belt/military/abductor/full

	backpack_contents = list(
		/obj/item/gun/energy/alien = 1,
		/obj/item/device/abductor/silencer = 1
		)

/datum/outfit/abductor/scientist
	name = "Abductor Scientist"

	backpack_contents = list(
		/obj/item/device/abductor/gizmo = 1
		)

/datum/outfit/abductor/scientist/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(!visualsOnly)
		var/obj/item/implant/abductor/beamplant = new /obj/item/implant/abductor(H)
		beamplant.implant(H)
