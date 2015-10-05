/obj/item/weapon/reagent_containers/food/snacks/egg/borer
	name = "borer egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "borer egg-growing"
	bitesize = 12
	origin_tech = "biotech=4"
	var/grown = 0
	var/datum/recruiter/recruiter

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/New()
	..()
	reagents.add_reagent("nutriment", 4)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/proc/Grow()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Grow() called tick#: [world.time]")
	grown = 1
	icon_state = "borer egg-grown"
	processing_objects.Add(src)

	recruiter = new()
	recruiter.display_name = "borer"
	recruiter.role = ROLE_BORER
	recruiter.jobban_roles = list("pAI")

	// A player has their role set to Yes or Always
	recruiter.player_volunteering.Add(src, "recruiter_recruiting")
	// ", but No or Never
	recruiter.player_not_volunteering.Add(src, "recruiter_not_recruiting")

	recruiter.recruited.Add(src, "recruiter_recruited")
	return

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/proc/Hatch()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Hatch() called tick#: [world.time]")
	processing_objects.Remove(src)
	src.visible_message("<span class='notice'>The [name] pulsates and quivers!</span>")
	recruiter.request_player()

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/proc/recruiter_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	O << "<span class='recruit'>\The [src] is starting to hatch. You have been added to the list of potential ghosts. ([controls])</span>"

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/proc/recruiter_not_recruiting(var/list/args)
	var/mob/dead/observer/O = args["player"]
	var/controls = args["controls"]
	O << "<span class='recruit'>\The [src] is starting to hatch. ([controls])</span>"

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/proc/recruiter_recruited(var/list/args)
	var/mob/dead/observer/O = args["player"]
	if(O)
		var/turf/T = get_turf(src)
		src.visible_message("<span class='notice'>The [name] bursts open!</span>")
		var/mob/living/simple_animal/borer/B = new (T)
		B.transfer_personality(O.client)
		// Play hatching noise here.
		qdel(src)


/obj/item/weapon/reagent_containers/food/snacks/egg/borer/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	//testing("[type]/PROCESS() - plasma: [environment.toxins]")
	if (environment.toxins > MOLES_PLASMA_VISIBLE)//plasma exposure causes the egg to hatch
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/egg/borer/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()