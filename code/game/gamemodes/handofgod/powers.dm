
/mob/camera/god/proc/ability_cost(cost = 0,structures = 0, requires_conduit = 0)
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
		for(var/obj/structure/divine/conduit/C in range(src,15))
			if(C.side == side)
				valid++
				break

		if(!valid)
			for(var/obj/structure/divine/nexus/N in range(src,15))
				if(N.side == side)
					valid++
					break
		if(!valid)
			src << "<span class='danger'>You must be near your Nexus or a Conduit to do this!</span>"
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
		L.Weaken(2)
		L << "<span class='danger'><B>You feel the wrath of [name]!<B></span>"
		has_smitten = 1
	if(has_smitten)
		add_faith(-40)


/mob/camera/god/verb/holyslumber()
	set category = "Deity"
	set name = "Holy Slumber (20)"
	set desc = "Knocks out the mortal below you for a brief amount of time."

	if(!ability_cost(20,0,1))
		return

	for(var/mob/living/L in get_turf(src))
		src << "You whisper a lullaby into the ears of [L]. Moments later they drift off..."
		L << "<span class='danger'><B>You hear a lullaby so soft...</B></span>"
		L.SetSleeping(40)
	add_faith(-20)


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

	var/construct = input("Choose what you wish to create.", "Divine Construction") as null|anything in global_handofgod_structuretypes
	if(!construct || !global_handofgod_structuretypes[construct] || !ability_cost(75,1,1)) //check again, they might try to cheat the input window.
		return

	var/obj/structure/divine/construct_type = global_handofgod_structuretypes[construct] //it's a path but we need to initial() some vars
	if(!construct_type)
		return

	add_faith(-75)

	var/obj/structure/divine/construction_holder/CH = new(get_turf(src))
	CH.assign_deity(src)
	CH.setup_construction(construct_type)
	CH.visible_message("<span class='notice'>[src] has created a transparent, unfinished [construct]. It can be finished by adding materials.</span>")


/mob/camera/god/verb/construct_traps()
	set category = "Deity"
	set name = "Construct Trap (20)"
	set desc = "Creates a ward or trap."

	if(!ability_cost(20,1,1))
		return

	var/trap = input("Choose what you wish to create.", "Divine Traps") as null|anything in global_handofgod_traptypes
	if(!trap || !global_handofgod_traptypes[trap] || !ability_cost(20,1,1))
		return

	src << "You lay \a [trap]."
	add_faith(-20)

	var/traptype = global_handofgod_traptypes[trap]
	new traptype (get_turf(src))




/mob/camera/god/verb/construct_items()
	set category = "Deity"
	set name = "Construct Items (20)"
	set desc = "Construct some items for your followers"

	if(!ability_cost(20,1,1))
		return

	var/list/item_types = list("claymore sword" = /obj/item/weapon/claymore)
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
