#define STARGAZER_RANGE 3 //How many tiles the stargazer can see out to
#define STARGAZER_POWER 20 //How many watts will be produced per second when the stargazer sees starlight

//Stargazer: A very fragile but cheap generator that creates power from starlight.
/obj/structure/destructible/clockwork/stargazer
	name = "stargazer"
	desc = "A large lantern-shaped machine made of thin brass. It looks fragile."
	clockwork_desc = "A lantern-shaped generator that produces power when near starlight."
	icon_state = "stargazer"
	unanchored_icon = "stargazer_unwrenched"
	max_integrity = 40
	construction_value = 5
	layer = WALL_OBJ_LAYER
	break_message = "<span class='warning'>The stargazer's fragile body shatters into pieces!</span>"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	light_color = "#DAAA18"
	var/star_light_star_bright = FALSE //If this stargazer can see starlight

/obj/structure/destructible/clockwork/stargazer/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/stargazer/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	. = ..()

/obj/structure/destructible/clockwork/stargazer/examine(mob/user)
	..()
	if(is_servant_of_ratvar(user))
		to_chat(user, "<span class='nzcrentr_small'>Generates <b>[DisplayPower(STARGAZER_POWER)]</b> per second while viewing starlight within [STARGAZER_RANGE] tiles.</span>")
	if(star_light_star_bright)
		to_chat(user, "[is_servant_of_ratvar(user) ? "<span class='nzcrentr_small'>It can see starlight!</span>" : "It's shining brilliantly!"]")

/obj/structure/destructible/clockwork/stargazer/process()
	star_light_star_bright = check_starlight()
	if(star_light_star_bright)
		adjust_clockwork_power(STARGAZER_POWER)

/obj/structure/destructible/clockwork/stargazer/update_anchored(mob/living/user, damage)
	. = ..()
	star_light_star_bright = check_starlight()

/obj/structure/destructible/clockwork/stargazer/proc/check_starlight()
	var/old_status = star_light_star_bright
	var/has_starlight
	if(!anchored)
		has_starlight = FALSE
	else
		for(var/turf/T in view(3, src))
			if(isspaceturf(T))
				has_starlight = TRUE
				break
	if(has_starlight && anchored)
		var/area/A = get_area(src)
		if(A.outdoors || A.map_name == "Space" || !A.blob_allowed)
			has_starlight = FALSE
	if(old_status != has_starlight)
		if(has_starlight)
			visible_message("<span class='nzcrentr_small'>[src] hums and shines brilliantly!</span>")
			playsound(src, 'sound/machines/clockcult/stargazer_activate.ogg', 50, TRUE)
			add_overlay("stargazer_light")
			set_light(1.5, 5)
		else
			if(anchored) //We lost visibility somehow
				visible_message("<span class='danger'>[src] flickers, and falls dark.</span>")
			else
				visible_message("<span class='danger'>[src] whooshes quietly as it slides into a less bulky form.</span>")
			cut_overlays()
			set_light(0)
	return has_starlight
