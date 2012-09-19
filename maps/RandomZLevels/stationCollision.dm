/* Station-Collision(sc) away mission map specific stuff
 *
 * Note: Some of this is unnecessary, but I tried adding a small variety of things here to serve as examples
 *       for anyone who wants to make their own stuff.
 *
 * Contains:
 *		Areas
 *		Landmarks
 *		Safe code hints
 *		Captain's safe
 *		Modified Nar-Sie
 */

/*
 * Areas
 */
 //Gateroom gets its own APC specifically for the gate
 /area/awaymission/gateroom

 //Library, medbay, storage room
 /area/awaymission/southblock

 //Arrivals, security, hydroponics, shuttles (since they dont move, they dont need specific areas)
 /area/awaymission/arrivalblock

 //Crew quarters, cafeteria, chapel
 /area/awaymission/midblock

 //engineering, bridge (not really north but it doesnt really need its own APC)
 /area/awaymission/northblock

 //That massive research room
 /area/awaymission/research

//Syndicate shuttle
/area/awaymission/syndishuttle


/*
 * Landmarks - Instead of spawning a new object type, I'll spawn the bible using a landmark!
 */
/obj/effect/landmark/sc_bible_spawner
	name = "Safecode hint spawner"

/obj/effect/landmark/sc_bible_spawner/New()
	var/obj/item/weapon/storage/bible/B = new /obj/item/weapon/storage/bible/booze(src.loc)
	B.name = "The Holy book of the Geometer"
	B.deity_name = "Narsie"
	B.icon_state = "melted"
	B.item_state = "melted"
	new /obj/item/weapon/paper/sc_safehint_paper_bible(B)
	new /obj/item/weapon/pen(B)
	del(src)


/*
 * Safe code hints
 */

//Pieces of paper actually containing the hints
/obj/item/weapon/paper/sc_safehint_paper_prison
	info = "<i>The ink is smudged, you can only make out a couple numbers:</i> '3**9*'"

/obj/item/weapon/paper/sc_safehint_paper_hydro
	info = "<i>Although the paper is shredded, you can clearly see the number:</i> '7'"

/obj/item/weapon/paper/sc_safehint_paper_caf
	info = "<font color=red><i>This paper is soaked in blood, it is impossible to read any text.</i></font>"

/obj/item/weapon/paper/sc_safehint_paper_bible
	info = {"<i>It would appear that the pen hidden with the paper had leaked ink over the paper.
			However you can make out the last three digits:</i>'596'
			"}

/obj/item/weapon/paper/sc_safehint_paper_shuttle
	info = {"<b>Target:</b> Research-station Epsilon<br>
			<b>Objective:</b> Prototype weaponry. The captain likely keeps them locked in her safe.<br>
			<br>
			Our on-board spy has learned the code and has hidden away a few copies of the code around the station. Unfortunatly he has been captured by security
			Your objective is to split up, locate any of the papers containing the captain's safe code, open the safe and
			secure anything found inside. If possible, recover the imprisioned syndicate operative and recieve the code from him.<br>
			<br>
			<u>As always, eliminate anyone who gets in the way.</u><br>
			<br>
			Your assigned ship is designed specifically for penetrating the hull of another station or ship with minimal damage to operatives.
			It is completely fly-by-wire meaning you have just have to enjoy the ride and when the red light comes on... find something to hold onto!
			"}
/*
 * Captain's safe
 */
/obj/item/weapon/secstorage/ssafe/sc_ssafe
	name = "Captain's secure safe"
	l_code = "37596"
	l_set = 1

/obj/item/weapon/secstorage/ssafe/sc_ssafe/New()
	..()
	new /obj/item/weapon/gun/energy/pulse_rifle(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/weapon/teleportation_scroll(src)
	new /obj/item/weapon/ore/diamond(src)

/*
 * Modified Nar-Sie
 */
/obj/machinery/singularity/narsie/sc_Narsie
	desc = "Your body becomes weak and your feel your mind slipping away as you try to comprehend what you know can't be possible."
	move_self = 0 //Contianed narsie does not move!
	grav_pull = 0 //Contained narsie does not pull stuff in!

//Override this to prevent no adminlog runtimes and admin warnings about a singularity without containment
/obj/machinery/singularity/narsie/sc_Narsie/admin_investigate_setup()
	return

/obj/machinery/singularity/narsie/sc_Narsie/process()
	eat()
	if(prob(25))
		mezzer()

/obj/machinery/singularity/narsie/sc_Narsie/consume(var/atom/A)
	if(is_type_in_list(A, uneatable))
		return 0
	if (istype(A,/mob/living))
		var/mob/living/L = A
		L.gib()
	else if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1.0)
		if(O) del(O)
	else if(isturf(A))
		var/turf/T = A
		if(T.intact)
			for(var/obj/O in T.contents)
				if(O.level != 1)
					continue
				if(O.invisibility == 101)
					src.consume(O)
		T.ReplaceWithSpace()
	return

/obj/machinery/singularity/narsie/sc_Narsie/ex_act()
	return