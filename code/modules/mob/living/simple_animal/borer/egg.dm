/obj/item/weapon/reagent_containers/food/snacks/borer_egg
	name = "borer egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "borer egg-growing"
	bitesize = 12
	origin_tech = "biotech=4"
	var/grown = 0
	var/hatching = 0 // So we don't spam ghosts.
	var/datum/recruiter/recruiter = null

	var/list/required_mols=list(
		"toxins"=MOLES_PLASMA_VISIBLE,
		"oxygen"=5
	)

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/New()
	..()
	reagents.add_reagent("nutriment", 4)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/Grow()
	grown = 1
	icon_state = "borer egg-grown"
	processing_objects.Add(src)

	if(!recruiter)
		recruiter = new(src)
		recruiter.display_name = "borer"
		recruiter.role = ROLE_BORER
		recruiter.jobban_roles = list("pAI")

		// A player has their role set to Yes or Always
		recruiter.player_volunteering.Add(src, "recruiter_recruiting")
		// ", but No or Never
		recruiter.player_not_volunteering.Add(src, "recruiter_not_recruiting")

		recruiter.recruited.Add(src, "recruiter_recruited")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/Hatch()
	if(hatching)
		return
	processing_objects.Remove(src)
	icon_state="borer egg-triggered"
	hatching=1
	src.visible_message("<span class='notice'>The [name] pulsates and quivers!</span>")
	recruiter.request_player()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/recruiter_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class='recruit'>\The [src] is starting to hatch. You have been added to the list of potential ghosts. ([controls])</span>")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/recruiter_not_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	to_chat(O, "<span class='recruit'>\The [src] is starting to hatch. ([controls])</span>")

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/proc/recruiter_recruited(var/list/args)
	var/mob/dead/observer/O = args["player"]
	if(O)
		var/turf/T = get_turf(src)
		src.visible_message("<span class='notice'>\The [name] bursts open!</span>")
		var/mob/living/simple_animal/borer/B = new (T)
		B.transfer_personality(O.client)
		// Play hatching noise here.
		qdel(src)
	else
		src.visible_message("<span class='notice'>\The [name] calms down.</span>")
		Grow() // Reset egg, check for hatchability.


/obj/item/weapon/reagent_containers/food/snacks/borer_egg/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	//testing("[type]/PROCESS() - plasma: [environment.toxins]")
	var/meets_conditions=1
	for(var/gas_id in required_mols)
		if(environment.vars[gas_id] <= required_mols[gas_id])
			meets_conditions=0
	if(meets_conditions)
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/borer_egg/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()