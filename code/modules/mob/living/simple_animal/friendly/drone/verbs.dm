
///////////////
//DRONE VERBS//
///////////////
//Drone verbs that appear in the Drone tab and on buttons


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "Drone"
	set name = "Check Laws"

	src << "<b>Drone Laws</b>"
	src << laws

/mob/living/simple_animal/drone/verb/toggle_light()
	set category = "Drone"
	set name = "Toggle drone light"
	if(light_on)
		AddLuminosity(-4)
	else
		AddLuminosity(4)

	light_on = !light_on

	src << "<span class='notice'>Your light is now [light_on ? "on" : "off"].</span>"

/mob/living/simple_animal/drone/verb/drone_ping()
	set category = "Drone"
	set name = "Drone ping"

	var/alert_s = input(src,"Alert severity level","Drone ping",null) as null|anything in list("Low","Medium","High","Critical")

	var/area/A = get_area(loc)

	if(alert_s && A && stat != DEAD)
		var/msg = "<span class='boldnotice'>DRONE PING: [name]: [alert_s] priority alert in [A.name]!</span>"
		alert_drones(msg)


/mob/living/simple_animal/drone/verb/toggle_statics()
	set name = "Change Vision Filter"
	set desc = "Change the filter on the system used to remove non drone beings from your viewscreen."
	set category = "Drone"

	if(!seeStatic)
		src << "<span class='warning'>You have no vision filter to change!</span>"
		return

	var/selectedStatic = input("Select a vision filter", "Vision Filter") as null|anything in staticChoices
	if(selectedStatic in staticChoices)
		staticChoice = selectedStatic

	updateSeeStaticMobs()

/mob/living/simple_animal/drone/verb/toggle_headgear_camo()
	set category = "Drone"
	set name = "Toggle headgear type"

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = head
	var/obj/new_headgear

	if(istype(head,/obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone()
		src << "<span class='notice'>Headgear in MASK mode.</span>"
	else if(istype(head,/obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone()
		src << "<span class='notice'>Headgear in HAT mode.</span>"
	else
		src << "<span class='warning'>You don't have a headgear projector installed.</span>"
	if(new_headgear)
		// Force drop the item in the headslot, even though
		// it's NODROP
		unEquip(head, 1)
		qdel(old_headgear)
		// where is `slot_head` defined? WHO KNOWS
		equip_to_slot(new_headgear, slot_head)
