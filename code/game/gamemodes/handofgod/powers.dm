
/mob/camera/god/proc/ability_cost(cost = 0,structures = 0, requires_conduit = 0, can_place_near_enemy_nexus = 0)
	if(faith < cost)
		src << "<span class='danger'>You lack the faith!</span>"
		return 0

	if(structures)
		if(!isturf(loc) || istype(loc, /turf/space))
			src << "<span class='danger'>Your structure would just float away, you need stable ground!</span>"
			return 0

		var/turf/T = get_turf(src)
		if(T)
			if(T.density)
				src << "<span class='danger'>There is something blocking your structure!</span>"
				return 0

			for(var/atom/movable/AM in T)
				if(AM == src)
					continue
				if(AM.density)
					src << "<span class='danger'>There is something blocking your structure!</span>"
					return 0

	if(requires_conduit)
		//Organised this way as there can be multiple conduits, so it's more likely to be a conduit check.
		var/valid = 0

		for(var/obj/structure/divine/conduit/C in conduits)
			if(get_dist(src, C) <= CONDUIT_RANGE)
				valid++
				break

		if(!valid)
			if(get_dist(src, god_nexus) <= CONDUIT_RANGE)
				valid++

		if(!valid)
			src << "<span class='danger'>You must be near your Nexus or a Conduit to do this!</span>"
			return 0

	if(!can_place_near_enemy_nexus)
		var/datum/mind/enemy
		switch(side)
			if("red")
				if(ticker.mode.blue_deities.len)
					enemy = ticker.mode.blue_deities[1]
			if("blue")
				if(ticker.mode.red_deities.len)
					enemy = ticker.mode.red_deities[1]

		if(enemy && is_handofgod_god(enemy.current))
			var/mob/camera/god/enemy_god = enemy.current
			if(enemy_god.god_nexus && (get_dist(src,enemy_god.god_nexus) <= CONDUIT_RANGE*2))
				src << "<span class='danger'>You are too close to the other god's stronghold!</span>"
				return 0

	return 1


/mob/camera/god/verb/returntonexus()
	set category = "Deity"
	set name = "Goto Nexus"
	set desc = "Teleports you to your next instantly."

	if(god_nexus)
		Move(get_turf(god_nexus))
	else
		src << "You don't even have a Nexus, construct one."


/mob/camera/god/verb/jumptofollower()
	set category = "Deity"
	set name = "Jump to Follower"
	set desc = "Teleports you to one of your followers."
	var/list/following = list()
	if(side == "red")
		following = ticker.mode.red_deity_followers|ticker.mode.red_deity_prophets
	else if(side == "blue")
		following = ticker.mode.blue_deity_followers|ticker.mode.blue_deity_prophets
	else
		src << "You are unaligned, and thus do not have followers"
		return

	var/datum/mind/choice = input("Choose a follower","Jump to Follower") as null|anything in following
	if(choice && choice.current)
		Move(get_turf(choice.current))


/mob/camera/god/verb/newprophet()
	set category = "Deity"
	set name = "Appoint Prophet (100)"
	set desc = "Appoint one of your followers as your Prophet, who can hear your words"

	var/list/following = list()

	if(!ability_cost(100))
		return
	if(side == "red")
		var/datum/mind/old_proph = locate() in ticker.mode.red_deity_prophets
		if(old_proph && old_proph.current && old_proph.current.stat != DEAD)
			src << "You can only have one prophet alive at a time."
			return
		else
			following = ticker.mode.red_deity_followers
	else if(side == "blue")
		var/datum/mind/old_proph = locate() in ticker.mode.blue_deity_prophets
		if(old_proph && old_proph.current && old_proph.current.stat != DEAD)
			src << "You can only have one prophet alive at a time."
			return
		else
			following = ticker.mode.blue_deity_followers

	else
		src << "You are unalligned, and thus do not have prophets"
		return

	var/datum/mind/choice = input("Choose a follower to make into your prophet","Prophet Uplifting") as null|anything in following
	if(choice && choice.current && choice.current.stat != DEAD)
		src << "You choose [choice.current] as your prophet."
		choice.make_Handofgod_prophet(side)
		speak2god = new()
		speak2god.god = src
		speak2god.Grant(choice.current)

		//Prophet gear
		var/mob/living/carbon/human/H = choice.current
		var/popehat = null
		var/popestick = null

		switch(side)
			if("red")
				popehat = /obj/item/clothing/head/helmet/plate/crusader/prophet/red
				popestick = /obj/item/weapon/godstaff/red
			if("blue")
				popehat = /obj/item/clothing/head/helmet/plate/crusader/prophet/blue
				popestick = /obj/item/weapon/godstaff/blue

		if(popehat)
			var/obj/item/clothing/head/helmet/plate/crusader/prophet/P = new popehat()

			H.unEquip(H.head)
			H << "<span class='boldnotice'>A powerful hat has been bestowed upon your head, you will need to wear this to utilize your staff fully..</span>"
			H.equip_to_slot_or_del(P,slot_head)

		if(popestick)
			var/obj/item/weapon/godstaff/G = new popestick()
			G.god = src
			var/success = ""
			if(!H.put_in_hands(G))
				if(!H.equip_to_slot_if_possible(G,slot_in_backpack,0,1,1))
					G.loc = get_turf(H)
					success = "It is on the floor..."
				else
					success = "It is in your backpack..."
			else
				success = "It is in your hands..."

			if(success)
				H << "<span class='boldnotice'>A powerful staff has been bestowed upon you, you can use this to convert the false god's structures!</span>"
				H << "<span class='boldnotice'>[success]</span>"
		//end prophet gear

		add_faith(-100)


/mob/camera/god/verb/talk(msg as text)
	set category = "Deity"
	set name = "Talk to Anyone (20)"
	set desc = "Allows you to send a message to anyone, regardless of their faith."
	if(!ability_cost(20))
		return
	var/mob/choice = input("Choose who you wish to talk to", "Talk to ANYONE") as null|anything in mob_list
	if(choice)
		var/original = msg
		msg = "<B>You hear a voice coming from everywhere and nowhere... <i>[msg]</i></B>"
		choice << msg
		src << "You say the following to [choice], [original]"
		add_faith(-20)


/mob/camera/god/verb/smite()
	set category = "Deity"
	set name = "Smite (40)"
	set desc = "Hits anything under you with a moderate amount of damage."

	if(!ability_cost(40,0,1))
		return
	if(!range(7,god_nexus))
		src << "You lack the strength to smite this far from your nexus."
		return

	var/has_smitten = 0 //Hast thou been smitten, infidel?
	for(var/mob/living/L in get_turf(src))
		L.adjustFireLoss(20)
		L.adjustBruteLoss(20)
		L << "<span class='danger'><B>You feel the wrath of [name]!<B></span>"
		has_smitten = 1
	if(has_smitten)
		add_faith(-40)


/mob/camera/god/verb/disaster()
	set category = "Deity"
	set name = "Invoke Disaster (300)" //difficult to reach without lots of followers
	set desc = "Tug at the fibres of reality itself and bend it to your whims!"

	if(!ability_cost(300,0,1))
		return

	var/event = pick(/datum/round_event/meteor_wave, /datum/round_event/communications_blackout, /datum/round_event/radiation_storm, /datum/round_event/carp_migration,
	/datum/round_event/spacevine, /datum/round_event/vent_clog, /datum/round_event/wormholes)
	if(event)
		new event()
		add_faith(-300)


/mob/camera/god/verb/constructnexus()
	set category = "Deity"
	set name = "Construct Nexus"
	set desc = "Instantly creates your nexus, You can only do this once, make sure you're happy with it!"

	if(!ability_cost(0,1,0))
		return

	place_nexus()


/* //Transolocators have no sprite
/mob/camera/god/verb/movenexus()
	set category = "Deity"
	set name = "Relocate Nexus (50)"
	set desc = "Instantly relocates your nexus to an existing translocator belonging to your faith, this destroys the translocator in the process"

	if(ability_cost(50,0,0) && god_nexus)
		var/list/translocators = list()
		var/list/used_keys = list()
		for(var/obj/structure/divine/translocator/T in structures)
			translocators["[T.name] ([get_area(T)])"] = T

		if(!translocators.len)
			src << "<span class='warning'>You have no translocators!</span>"
			return

		var/picked = input(src,"Choose a translocator","Relocate Nexus") as null|anything in translocators
		if(!picked || !translocators[picked])
			return

		var/obj/structure/divine/translocator/T = translocators[T]
		var/turf/Tturf = get_turf(T)
		god_nexus.loc = T
		translocators[picked] = null
		add_faith(-50)
		qdel(T)
*/

/mob/camera/god/verb/construct_structures()
	set category = "Deity"
	set name = "Construct Structure (75)"
	set desc = "Create the foundation of a divine object."

	if(!ability_cost(75,1,1))
		return

	structure_construction_ui(src)


/mob/camera/god/verb/construct_traps()
	set category = "Deity"
	set name = "Construct Trap (20)"
	set desc = "Creates a ward or trap."

	if(!ability_cost(20,1,1))
		return

	trap_construction_ui(src)



/mob/camera/god/verb/construct_items()
	set category = "Deity"
	set name = "Construct Items (20)"
	set desc = "Construct some items for your followers"

	if(!ability_cost(20,1,1))
		return

	var/list/item_types = list("claymore sword" = /obj/item/weapon/claymore/hog)
	if(side == "red")
		item_types["red banner"] = /obj/item/weapon/banner/red
		item_types["red bannerbackpack"] = /obj/item/weapon/storage/backpack/bannerpack/red
		item_types["red armour"] = /obj/item/weapon/storage/box/itemset/crusader/red

	else if(side == "blue")
		item_types["blue banner"] = /obj/item/weapon/banner/blue
		item_types["blue bannerbackpack"] = /obj/item/weapon/storage/backpack/bannerpack/blue
		item_types["blue armour"] = /obj/item/weapon/storage/box/itemset/crusader/blue


	var/item = input("Choose what you wish to create.", "Divine Items") as null|anything in item_types
	if(!item || !item_types[item] || !ability_cost(20,1,1))
		return

	src << "You produce \a [item]"
	add_faith(-20)

	var/itemtype = item_types[item]
	new itemtype (get_turf(src))



/mob/camera/god/verb/veil_structures()
	set category = "Deity"
	set name = "Veil Structures (20)"
	set desc = "Hide your structures from sight and touch, but prevent yourself from using them."

	if(!ability_cost(20,1,1))
		return

	src << "You focus your powers and start dragging your influence into the spiritual plane."
	for(var/mob/M in orange(3,src))//Yes I know this is terrible, but visible message doesnt work for this
		M << "<span class='warning'>The air begins to shimmer...</span>"
	if(do_after(src, 30, 0, src))
		for(var/obj/structure/divine/R in orange(3,src))
			if(istype(R, /obj/structure/divine/nexus)|| istype(R, /obj/structure/divine/trap)||(src.side != R.side))
				continue
			R.visible_message("<span class='danger'>[R] fades away.</span>")
			R.invisibility = 55
			R.alpha = 100 //To help ghosts distinguish hidden structures
			R.density = 0
			R.deactivate()
		src << "You hide your influence from view"
		add_faith(-20)


/mob/camera/god/verb/reveal_structures()
	set category = "Deity"
	set name = "Reveal Structures (20)"
	set desc = "Make your structures visible again and allow them to be used."

	if(!ability_cost(20,1,1))
		return

	src << "You focus your powers and start dragging your influence into the material plane."
	for(var/mob/M in orange(3,src))//Yes I know this is terrible, but visible message doesnt work for this
		M << "<span class='warning'>The air begins to shimmer...</span>"
	if(do_after(src, 40, 0, src))
		for(var/obj/structure/divine/R in orange(3,src))
			if(istype(R, /obj/structure/divine/nexus)|| istype(R, /obj/structure/divine/trap)||(src.side != R.side))
				continue
			R.visible_message("<span class='danger'>[R] suddenly appears!</span>")
			R.invisibility = 0
			R.alpha = initial(R.alpha)
			R.density = initial(R.density)
			R.activate()
		src << "You bring your influence into view"
		add_faith(-20)

