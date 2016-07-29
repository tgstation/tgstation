<<<<<<< HEAD
/var/list/sacrificed = list()
var/list/non_revealed_runes = (subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)

/*

This file contains runes.
Runes are used by the cult to cause many different effects and are paramount to their success.
They are drawn with an arcane tome in blood, and are distinguishable to cultists and normal crew by examining.
Fake runes can be drawn in crayon to fool people.
Runes can either be invoked by one's self or with many different cultists. Each rune has a specific incantation that the cultists will say when invoking it.

To draw a rune, use an arcane tome.

*/

/obj/effect/rune
	name = "rune"
	var/cultist_name = "basic rune"
	desc = "An odd collection of symbols drawn in what seems to be blood."
	var/cultist_desc = "a basic rune with no function." //This is shown to cultists who examine the rune in order to determine its true purpose.
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = ABOVE_NORMAL_TURF_LAYER
	color = rgb(255,0,0)

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/rune_in_use = 0 // Used for some runes, this is for when you want a rune to not be usable when in use.

	var/scribe_delay = 50 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it

	var/allow_excess_invokers = 0 //if we allow excess invokers when being invoked
	var/construct_invoke = 1 //if constructs can invoke it

	var/req_keyword = 0 //If the rune requires a keyword - go figure amirite
	var/keyword //The actual keyword for the rune

/obj/effect/rune/New(loc, set_keyword)
	..()
	if(set_keyword)
		keyword = set_keyword

/obj/effect/rune/examine(mob/user)
	..()
	if(iscultist(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		user << "<b>Name:</b> [cultist_name]"
		user << "<b>Effects:</b> [capitalize(cultist_desc)]"
		user << "<b>Required Acolytes:</b> [req_cultists]"
		if(req_keyword && keyword)
			user << "<b>Keyword:</b> [keyword]"

/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		user << "<span class='notice'>You carefully erase the [lowertext(cultist_name)] rune.</span>"
		qdel(src)
		return
	else if(istype(I, /obj/item/weapon/nullrod))
		user.say("BEGONE FOUL MAGIKS!!")
		user << "<span class='danger'>You disrupt the magic of [src] with [I].</span>"
		qdel(src)
		return
	return

/obj/effect/rune/attack_hand(mob/living/user)
	if(!iscultist(user))
		user << "<span class='warning'>You aren't able to understand the words of [src].</span>"
		return
	var/list/invokers = can_invoke(user)
	if(invokers.len >= req_cultists)
		invoke(invokers)
	else
		fail_invoke()

/obj/effect/rune/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/shade) || istype(M, /mob/living/simple_animal/hostile/construct))
		if(construct_invoke || !iscultist(M)) //if you're not a cult construct we want the normal fail message
			attack_hand(M)
		else
			M << "<span class='warning'>You are unable to invoke the rune!</span>"

/obj/effect/rune/proc/talismanhide() //for talisman of revealing/hiding
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes

/obj/effect/rune/proc/talismanreveal() //for talisman of revealing/hiding
	invisibility = 0
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)

/*

There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.

*/

/obj/effect/rune/proc/can_invoke(var/mob/living/user=null)
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	var/list/invokers = list() //people eligible to invoke the rune
	var/list/chanters = list() //people who will actually chant the rune when passed to invoke()
	if(user)
		chanters |= user
		invokers |= user
	if(req_cultists > 1 || allow_excess_invokers)
		for(var/mob/living/L in range(1, src))
			if(iscultist(L))
				if(L == user)
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if((H.disabilities & MUTE) || H.silent)
						continue
				if(L.stat)
					continue
				invokers |= L
		if(invokers.len >= req_cultists)
			if(allow_excess_invokers)
				chanters |= invokers
			else
				invokers -= user
				shuffle(invokers)
				for(var/i in 0 to req_cultists)
					var/L = pick_n_take(invokers)
					chanters |= L
	return chanters

/obj/effect/rune/proc/invoke(var/list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	if(invocation)
		for(var/M in invokers)
			var/mob/living/L = M
			L.say(invocation)
	var/oldtransform = transform
	spawn(0) //animate is a delay, we want to avoid being delayed
		animate(src, transform = matrix()*2, alpha = 0, time = 5) //fade out
		animate(transform = oldtransform, alpha = 255, time = 0)

/obj/effect/rune/proc/fail_invoke()
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message("<span class='warning'>The markings pulse with a \
		small flash of red light, then fall dark.</span>")
	spawn(0) //animate is a delay, we want to avoid being delayed
		animate(src, color = rgb(255, 0, 0), time = 0)
		animate(src, color = initial(color), time = 5)

//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "malformed rune"
	cultist_desc = "a senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/effect/rune/malformed/New()
	..()
	icon_state = "[rand(1,6)]"
	color = rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/effect/rune/malformed/invoke(var/list/invokers)
	..()
	for(var/M in invokers)
		var/mob/living/L = M
		L << "<span class='cultitalic'><b>You feel your life force draining. The Geometer is displeased.</b></span>"
		L.apply_damage(30, BRUTE)
	qdel(src)

/mob/proc/null_rod_check() //The null rod, if equipped, will protect the holder from the effects of most runes
	var/obj/item/weapon/nullrod/N = locate() in src
	if(N && !ratvar_awakens) //If Nar-Sie or Ratvar are alive, null rods won't protect you
		return N
	return 0

/mob/proc/bible_check() //The bible, if held, might protect against certain things
	var/obj/item/weapon/storage/book/bible/B = locate() in src
	if(B && (l_hand == B || r_hand == B))
		return B
	return 0

//Rite of Binding: A paper on top of the rune to a talisman.
/obj/effect/rune/imbue
	cultist_name = "Create Talisman"
	cultist_desc = "transforms paper into powerful magic talismans."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "3"
	color = rgb(0, 0, 255)

/obj/effect/rune/imbue/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/papers_on_rune = checkpapers()
	var/entered_talisman_name
	var/obj/item/weapon/paper/talisman/talisman_type
	var/list/possible_talismans = list()
	if(!papers_on_rune.len)
		user << "<span class='cultitalic'>There must be a blank paper on top of [src]!</span>"
		fail_invoke()
		log_game("Talisman Creation rune failed - no blank papers on rune")
		return
	if(rune_in_use)
		user << "<span class='cultitalic'>[src] can only support one ritual at a time!</span>"
		fail_invoke()
		log_game("Talisman Creation rune failed - already in use")
		return

	for(var/I in subtypesof(/obj/item/weapon/paper/talisman) - /obj/item/weapon/paper/talisman/malformed - /obj/item/weapon/paper/talisman/supply - /obj/item/weapon/paper/talisman/supply/weak)
		var/obj/item/weapon/paper/talisman/J = I
		var/talisman_cult_name = initial(J.cultist_name)
		if(talisman_cult_name)
			possible_talismans[talisman_cult_name] = J //This is to allow the menu to let cultists select talismans by name
	entered_talisman_name = input(user, "Choose a talisman to imbue.", "Talisman Choices") as null|anything in possible_talismans
	talisman_type = possible_talismans[entered_talisman_name]
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated() || rune_in_use || !talisman_type)
		return
	papers_on_rune = checkpapers()
	if(!papers_on_rune.len)
		user << "<span class='cultitalic'>There must be a blank paper on top of [src]!</span>"
		fail_invoke()
		log_game("Talisman Creation rune failed - no blank papers on rune")
		return
	var/obj/item/weapon/paper/paper_to_imbue = papers_on_rune[1]
	..()
	visible_message("<span class='warning'>Dark power begins to channel into the paper!</span>")
	rune_in_use = 1
	if(!do_after(user, 100, target = paper_to_imbue))
		rune_in_use = 0
		return
	new talisman_type(get_turf(src))
	visible_message("<span class='warning'>[src] glows with power, and bloody images form themselves on [paper_to_imbue].</span>")
	qdel(paper_to_imbue)
	rune_in_use = 0

/obj/effect/rune/imbue/proc/checkpapers()
	. = list()
	for(var/obj/item/weapon/paper/P in get_turf(src))
		if(!P.info && !istype(P, /obj/item/weapon/paper/talisman))
			. |= P

var/list/teleport_runes = list()
/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "warps everything above it to another chosen teleport rune."
	invocation = "Sas'so c'arta forbici!"
	icon_state = "2"
	color = "#551A8B"
	req_keyword = 1
	var/listkey

/obj/effect/rune/teleport/New(loc, set_keyword)
	..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = set_keyword ? "[set_keyword] [locname]":"[locname]"
	teleport_runes += src

/obj/effect/rune/teleport/Destroy()
	teleport_runes -= src
	return ..()

/obj/effect/rune/teleport/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()
	for(var/R in teleport_runes)
		var/obj/effect/rune/teleport/T = R
		var/resultkey = T.listkey
		if(resultkey in teleportnames)
			duplicaterunecount[resultkey]++
			resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
		else
			teleportnames.Add(resultkey)
			duplicaterunecount[resultkey] = 1
		if(T != src && (T.z <= ZLEVEL_SPACEMAX))
			potential_runes[resultkey] = T

	if(!potential_runes.len)
		user << "<span class='warning'>There are no valid runes to teleport to!</span>"
		log_game("Teleport rune failed - no other teleport runes")
		fail_invoke()
		return

	if(user.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>You are not in the right dimension!</span>"
		log_game("Teleport rune failed - user in away mission")
		fail_invoke()
		return

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated() || !actual_selected_rune)
		fail_invoke()
		return

	var/turf/T = get_turf(src)
	var/movedsomething = 0
	var/moveuserlater = 0
	for(var/atom/movable/A in T)
		if(A == user)
			moveuserlater = 1
			movedsomething = 1
			continue
		if(!A.anchored)
			movedsomething = 1
			A.forceMove(get_turf(actual_selected_rune))
	if(movedsomething)
		..()
		visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>")
		user << "<span class='cult'>You[moveuserlater ? "r vision blurs, and you suddenly appear somewhere else":" send everything above the rune away"].</span>"
		if(moveuserlater)
			user.forceMove(get_turf(actual_selected_rune))
	else
		fail_invoke()


//Rite of Enlightenment: Converts a normal crewmember to the cult.
/obj/effect/rune/convert
	cultist_name = "Convert"
	cultist_desc = "converts a normal crewmember on top of it to the cult. Does not work on mindshield-implanted crew."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = rgb(200, 0, 0)
	req_cultists = 2

/obj/effect/rune/convert/invoke(var/list/invokers)
	var/list/convertees = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(M.stat != DEAD && !iscultist(M) && is_convertable_to_cult(M.mind))
			convertees |= M
		else if(is_sacrifice_target(M.mind))
			for(var/C in invokers)
				C << "<span class='cultlarge'>\"I desire this one for myself. <i>SACRIFICE THEM!</i>\"</span>"
		else if(is_servant_of_ratvar(M))
			M.visible_message("<span class='warning'>[M]'s eyes glow a defiant yellow!</span>", \
			"<span class='cultlarge'>\"Stop resisting. You <i>will</i> be mi-\"</span> <span class='large_brass'>\"Give up and you will feel pain unlike anything you've ever felt!\"</span>")
			M.Weaken(4)
	if(!convertees.len)
		fail_invoke()
		log_game("Convert rune failed - no eligible convertees")
		return
	var/mob/living/new_cultist = pick(convertees)
	if(new_cultist.null_rod_check())
		for(var/M in invokers)
			M << "<span class='warning'>Something is shielding [new_cultist]'s mind!</span>"
		fail_invoke()
		log_game("Convert rune failed - convertee had null rod")
		return
	..()
	new_cultist.visible_message("<span class='warning'>[new_cultist] writhes in pain as the markings below them glow a bloody red!</span>", \
					  			"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
	ticker.mode.add_cultist(new_cultist.mind, 1)
	new /obj/item/weapon/tome(get_turf(src))
	new_cultist.mind.special_role = "Cultist"
	new_cultist << "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
	and something evil takes root.</b></span>"
	new_cultist << "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve the Geometer above all else. Bring it back.\
	</b></span>"

//Rite of Tribute: Sacrifices a crew member to Nar-Sie. Places them into a soul shard if they're in their body.
/obj/effect/rune/sacrifice
	cultist_name = "Sacrifice"
	cultist_desc = "sacrifices a crew member to the Geometer. May place them into a soul shard if their spirit remains in their body."
	icon_state = "3"
	allow_excess_invokers = 1
	invocation = "Barhah hra zar'garis!"
	color = rgb(255, 255, 255)
	rune_in_use = 0

/obj/effect/rune/sacrifice/New()
	..()
	icon_state = "[rand(1,6)]"

/obj/effect/rune/sacrifice/invoke(var/list/invokers)
	if(rune_in_use)
		return
	rune_in_use = 1
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/turf/T = get_turf(src)
	var/list/possible_targets = list()
	for(var/mob/living/M in T.contents)
		if(M.mind)
			if(M.mind in sacrificed)
				continue
		if(!iscultist(M))
			possible_targets.Add(M)
	var/mob/offering
	if(possible_targets.len > 1) //If there's more than one target, allow choice
		offering = input(user, "Choose an offering to sacrifice.", "Unholy Tribute") as null|anything in possible_targets
		if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
			return
	else if(possible_targets.len) //Otherwise, if there's a target at all, pick the only one
		offering = possible_targets[possible_targets.len]
	if(!offering)
		rune_in_use = 0
		return
	/*var/obj/item/weapon/nullrod/N = offering.null_rod_check()
	if(N)
		user << "<span class='warning'>Something is blocking the Geometer's magic!</span>"
		log_game("Sacrifice rune failed - target has \a [N]!")
		fail_invoke()
		rune_in_use = 0
		return*/
	if(((ishuman(offering) || isrobot(offering)) && offering.stat != DEAD) || is_sacrifice_target(offering.mind)) //Requires three people to sacrifice living targets
		if(invokers.len < 3)
			for(var/M in invokers)
				M << "<span class='cultitalic'>[offering] is too greatly linked to the world! You need three acolytes!</span>"
			fail_invoke()
			log_game("Sacrifice rune failed - not enough acolytes and target is living")
			rune_in_use = 0
			return
	visible_message("<span class='warning'>[src] pulses blood red!</span>")
	color = rgb(126, 23, 23)
	..()
	sac(invokers, offering)
	color = initial(color)

/obj/effect/rune/sacrifice/proc/sac(var/list/invokers, mob/living/T)
	var/sacrifice_fulfilled
	if(T)
		if(istype(T, /mob/living/simple_animal/pet/dog))
			for(var/M in invokers)
				var/mob/living/L = M
				L << "<span class='cultlarge'>\"Even I have standards, such as they are!\"</span>"
				if(L.reagents)
					L.reagents.add_reagent("hell_water", 2)
		if(T.mind)
			sacrificed.Add(T.mind)
			if(is_sacrifice_target(T.mind))
				sacrifice_fulfilled = 1
		PoolOrNew(/obj/effect/overlay/temp/cult/sac, src.loc)
		for(var/M in invokers)
			if(sacrifice_fulfilled)
				M << "<span class='cultlarge'>\"Yes! This is the one I desire! You have done well.\"</span>"
			else
				if(ishuman(T) || isrobot(T))
					M << "<span class='cultlarge'>\"I accept this sacrifice.\"</span>"
				else
					M << "<span class='cultlarge'>\"I accept this meager sacrifice.\"</span>"
		if(T.mind)
			var/obj/item/device/soulstone/stone = new /obj/item/device/soulstone(get_turf(src))
			stone.invisibility = INVISIBILITY_MAXIMUM //so it's not picked up during transfer_soul()
			if(!stone.transfer_soul("FORCE", T, usr)) //If it cannot be added
				qdel(stone)
			if(stone)
				stone.invisibility = 0
			if(!T)
				rune_in_use = 0
				return
		if(isrobot(T))
			playsound(T, 'sound/magic/Disable_Tech.ogg', 100, 1)
			T.dust() //To prevent the MMI from remaining
		else
			playsound(T, 'sound/magic/Disintegrate.ogg', 100, 1)
			T.gib()
	rune_in_use = 0

//Ritual of Dimensional Rending: Calls forth the avatar of Nar-Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Summon Nar-Sie"
	cultist_desc = "tears apart dimensional barriers, calling forth the Geometer. Requires 9 invokers."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	color = rgb(125,23,23)
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	scribe_delay = 450 //how long the rune takes to create
	scribe_damage = 40.1 //how much damage you take doing it
	var/used

/obj/effect/rune/narsie/New()
	. = ..()
	poi_list |= src

/obj/effect/rune/narsie/Destroy()
	poi_list -= src
	. = ..()

/obj/effect/rune/narsie/talismanhide() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/narsie/invoke(var/list/invokers)
	if(used)
		return
	if(z != ZLEVEL_STATION)
		return
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/cult_mode = ticker.mode
		if(!cult_mode.eldergod)
			for(var/M in invokers)
				M << "<span class='warning'>Nar-Sie is already on this plane!</span>"
			log_game("Summon Nar-Sie rune failed - already summoned")
			return
		//BEGIN THE SUMMONING
		used = 1
		..()
		world << 'sound/effects/dimensional_rend.ogg' //There used to be a message for this but every time it was changed it got edgier so I removed it
		var/turf/T = get_turf(src)
		sleep(40)
		if(src)
			color = rgb(255, 0, 0)
		new /obj/singularity/narsie/large(T) //Causes Nar-Sie to spawn even if the rune has been removed
		cult_mode.eldergod = 0
	else
		for(var/M in invokers)
			M << "<span class='warning'>Nar-Sie does not respond!</span>"
		fail_invoke()
		log_game("Summon Nar-Sie rune failed - gametype is not cult")

/obj/effect/rune/narsie/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/weapon/tome) && iscultist(user)))
		user.visible_message("<span class='warning'>[user.name] begins erasing the [src]...</span>", "<span class='notice'>You begin erasing the [src]...</span>")
		if(do_after(user, 50, target = src))	//Prevents accidental erasures.
			log_game("Summon Narsie rune erased by [user.mind.key] (ckey) with a tome")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a tome")
			..()
			return
	else
		if(istype(I, /obj/item/weapon/nullrod))	//Begone foul magiks. You cannot hinder me.
			log_game("Summon Narsie rune erased by [user.mind.key] (ckey) using a null rod")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a null rod")
			..()
	return

//Rite of Resurrection: Requires two corpses. Revives one and gibs the other.
/obj/effect/rune/raise_dead
	cultist_name = "Raise Dead"
	cultist_desc = "requires two corpses, one on the rune and one adjacent to the rune. The one on the rune is brought to life, the other is turned to ash."
	invocation = null //Depends on the name of the user - see below
	icon_state = "1"
	color = rgb(200, 0, 0)

/obj/effect/rune/raise_dead/invoke(var/list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_sacrifice
	var/mob/living/mob_to_revive
	var/list/potential_sacrifice_mobs = list()
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	for(var/mob/living/M in orange(1,T))
		if(M.stat == DEAD && !iscultist(M))
			potential_sacrifice_mobs |= M
	if(!potential_sacrifice_mobs.len)
		user << "<span class='cultitalic'>There are no eligible sacrifices nearby!</span>"
		log_game("Raise Dead rune failed - no catalyst corpses")
		fail_invoke()
		return
	for(var/mob/living/M in T.contents)
		if(M.stat == DEAD)
			potential_revive_mobs |= M
	if(!potential_revive_mobs.len)
		user << "<span class='cultitalic'>There is no eligible revival target on the rune!</span>"
		log_game("Raise Dead rune failed - no corpses to revive")
		fail_invoke()
		return
	mob_to_sacrifice = input(user, "Choose a corpse to sacrifice.", "Corpse to Sacrifice") as null|anything in potential_sacrifice_mobs
	if(!src || qdeleted(src) || rune_in_use || !validness_checks(mob_to_sacrifice, user, 1))
		return
	mob_to_revive = input(user, "Choose a corpse to revive.", "Corpse to Revive") as null|anything in potential_revive_mobs
	if(!src || qdeleted(src) || rune_in_use || !validness_checks(mob_to_sacrifice, user, 1))
		return
	if(!validness_checks(mob_to_revive, user, 0))
		return
	rune_in_use = 1
	if(user.name == "Herbert West")
		user.say("To life, to life, I bring them!")
	else
		user.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	..()
	mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice]'s body rises into the air, connected to [mob_to_revive] by a glowing tendril!</span>")
	mob_to_revive.Beam(mob_to_sacrifice,icon_state="sendbeam",icon='icons/effects/effects.dmi',time=20)
	sleep(20)
	if(!mob_to_sacrifice || !in_range(mob_to_sacrifice, src))
		rune_in_use = 0
		return
	if(!mob_to_revive || mob_to_revive.stat != DEAD)
		visible_message("<span class='warning'>The glowing tendril snaps against the rune with a shocking crack.</span>")
		rune_in_use = 0
		fail_invoke()
		return
	mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice] disintegrates into a pile of bones.</span>")
	mob_to_sacrifice.dust()
	mob_to_revive.revive(1, 1) //This does remove disabilities and such, but the rune might actually see some use because of it!
	mob_to_revive.grab_ghost()
	mob_to_revive << "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>"
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from their eyes.</span>", \
								  "<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = 0

/obj/effect/rune/raise_dead/proc/validness_checks(mob/living/target_mob, mob/living/user, saccing)
	var/turf/T = get_turf(src)
	if(!user)
		return 0
	if(!Adjacent(user) || user.incapacitated())
		return 0
	if(!target_mob)
		fail_invoke()
		return 0
	if(saccing)
		if(!in_range(target_mob, src))
			user << "<span class='cultitalic'>The sacrificial target has been moved!</span>"
			fail_invoke()
			log_game("Raise Dead rune failed - catalyst corpse moved")
			return 0
		if(target_mob.stat != DEAD)
			user << "<span class='cultitalic'>The sacrificial target must be dead!</span>"
			fail_invoke()
			log_game("Raise Dead rune failed - catalyst corpse is not dead")
			return 0
	else if(!(target_mob in T.contents))
		user << "<span class='cultitalic'>The corpse to revive has been moved!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - revival target moved")
		return 0
	return 1

/obj/effect/rune/raise_dead/fail_invoke()
	..()
	for(var/mob/living/M in range(1,src))
		if(M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")


//Rite of Disruption: Emits an EMP blast.
/obj/effect/rune/emp
	cultist_name = "Electromagnetic Disruption"
	cultist_desc = "emits a large electromagnetic pulse, increasing in size for each cultist invoking it, hindering electronics and disabling silicons."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	icon_state = "5"
	allow_excess_invokers = 1
	color = rgb(77, 148, 255)

/obj/effect/rune/emp/invoke(var/list/invokers)
	var/turf/E = get_turf(src)
	..()
	visible_message("<span class='warning'>[src] glows blue for a moment before vanishing.</span>")
	switch(invokers.len)
		if(1 to 2)
			playsound(E, 'sound/items/Welder2.ogg', 25, 1)
			for(var/M in invokers)
				M << "<span class='warning'>You feel a minute vibration pass through you...</span>"
		if(3 to 6)
			playsound(E, 'sound/magic/Disable_Tech.ogg', 50, 1)
			for(var/M in invokers)
				M << "<span class='danger'>Your hair stands on end as a shockwave eminates from the rune!</span>"
		if(7 to INFINITY)
			playsound(E, 'sound/magic/Disable_Tech.ogg', 100, 1)
			for(var/M in invokers)
				var/mob/living/L = M
				L << "<span class='userdanger'>You chant in unison and a colossal burst of energy knocks you backward!</span>"
				L.Weaken(2)
	qdel(src) //delete before pulsing because it's a delay reee
	empulse(E, 9*invokers.len, 12*invokers.len) // Scales now, from a single room to most of the station depending on # of chanters

//Rite of Astral Communion: Separates one's spirit from their body. They will take damage while it is active.
/obj/effect/rune/astral
	cultist_name = "Astral Communion"
	cultist_desc = "severs the link between one's spirit and body. This effect is taxing and one's physical body will take damage while this is active."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	icon_state = "6"
	color = rgb(126, 23, 23)
	rune_in_use = 0 //One at a time, please!
	construct_invoke = 0
	var/mob/living/affecting = null

/obj/effect/rune/astral/examine(mob/user)
	..()
	if(affecting)
		user << "<span class='cultitalic'>A translucent field encases [user] above the rune!</span>"

/obj/effect/rune/astral/can_invoke(mob/living/user)
	if(rune_in_use)
		user << "<span class='cultitalic'>[src] cannot support more than one body!</span>"
		log_game("Astral Communion rune failed - more than one user")
		return list()
	var/turf/T = get_turf(src)
	if(!user in T.contents)
		user << "<span class='cultitalic'>You must be standing on top of [src]!</span>"
		log_game("Astral Communion rune failed - user not standing on rune")
		return list()
	return ..()

/obj/effect/rune/astral/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	..()
	var/turf/T = get_turf(src)
	rune_in_use = 1
	affecting = user
	user.color = "#7e1717"
	user.visible_message("<span class='warning'>[user] freezes statue-still, glowing an unearthly red.</span>", \
						 "<span class='cult'>You see what lies beyond. All is revealed. While this is a wondrous experience, your physical form will waste away in this state. Hurry...</span>")
	user.ghostize(1)
	while(user)
		if(!affecting)
			visible_message("<span class='warning'>[src] pulses gently before falling dark.</span>")
			affecting = null //In case it's assigned to a number or something
			rune_in_use = 0
			return
		affecting.apply_damage(1, BRUTE)
		if(!(user in T.contents))
			user.visible_message("<span class='warning'>A spectral tendril wraps around [user] and pulls them back to the rune!</span>")
			Beam(user,icon_state="drainbeam",icon='icons/effects/effects.dmi',time=2)
			user.forceMove(get_turf(src)) //NO ESCAPE :^)
		if(user.key)
			user.visible_message("<span class='warning'>[user] slowly relaxes, the glow around them dimming.</span>", \
								 "<span class='danger'>You are re-united with your physical form. [src] releases its hold over you.</span>")
			user.color = initial(user.color)
			user.Weaken(3)
			rune_in_use = 0
			affecting = null
			return
		if(user.stat == UNCONSCIOUS)
			if(prob(10))
				var/mob/dead/observer/G = user.get_ghost()
				if(G)
					G << "<span class='cultitalic'>You feel the link between you and your body weakening... you must hurry!</span>"
		if(user.stat == DEAD)
			user.color = initial(user.color)
			rune_in_use = 0
			affecting = null
			var/mob/dead/observer/G = user.get_ghost()
			if(G)
				G << "<span class='cultitalic'><b>You suddenly feel your physical form pass on. [src]'s exertion has killed you!</b></span>"
			return
		sleep(10)
	rune_in_use = 0


//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Form Barrier"
	cultist_desc = "when invoked, makes an invisible wall to block passage. Can be invoked again to reverse this."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "1"
	color = rgb(255, 0, 0)

/obj/effect/rune/wall/examine(mob/user)
	..()
	if(density)
		user << "<span class='cultitalic'>There is a barely perceptible shimmering of the air above [src].</span>"

/obj/effect/rune/wall/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	..()
	density = !density
	user.visible_message("<span class='warning'>[user] [iscarbon(user) ? "places their hands on":"stares intently at"] [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cultitalic'>You channel your life energy into [src], [density ? "preventing" : "allowing"] passage above it.</span>")
	if(density)
		var/image/I = image(layer = ABOVE_MOB_LAYER, icon = 'icons/effects/effects.dmi', icon_state = "barriershimmer")
		I.appearance_flags = RESET_COLOR
		I.alpha = 60
		I.color = "#701414"
		overlays += I
	else
		overlays.Cut()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick("l_arm", "r_arm"))


//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Summon Cultist"
	cultist_desc = "summons a single cultist to the rune. Requires 2 invokers."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	allow_excess_invokers = 1
	icon_state = "5"
	color = rgb(0, 255, 0)

/obj/effect/rune/summon/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/cultists = list()
	for(var/datum/mind/M in ticker.mode.cult)
		if(!(M.current in invokers) && M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_summon = input(user, "Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in cultists
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		user << "<span class='cultitalic'>You require a summoning target!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.stat == DEAD)
		user << "<span class='cultitalic'>[cultist_to_summon] has died!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - target died")
		return
	if(!iscultist(cultist_to_summon))
		user << "<span class='cultitalic'>[cultist_to_summon] is not a follower of the Geometer!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - target was deconverted")
		return
	if(cultist_to_summon.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
									  "<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
	..()
	visible_message("<span class='warning'>A foggy shape materializes atop [src] and solidifes into [cultist_to_summon]!</span>")
	user.apply_damage(10, BRUTE, "head")
	cultist_to_summon.forceMove(get_turf(src))
	qdel(src)

//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "boils the blood of non-believers who can see the rune, dealing extreme amounts of damage. Requires 3 invokers."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	color = rgb(200, 0, 0)
	req_cultists = 3
	construct_invoke = 0

/obj/effect/rune/blood_boil/invoke(var/list/invokers)
	..()
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] briefly bubbles before exploding!</span>")
	for(var/mob/living/carbon/C in viewers(T))
		if(!iscultist(C))
			var/obj/item/weapon/nullrod/N = C.null_rod_check()
			if(N)
				C << "<span class='userdanger'>\The [N] suddenly burns hotly before returning to normal!</span>"
				continue
			C << "<span class='cultlarge'>Your blood boils in your veins!</span>"
			C.take_overall_damage(45,45)
			C.Stun(7)
			if(is_servant_of_ratvar(C))
				C << "<span class='userdanger'>You feel unholy darkness dimming the Justiciar's light!</span>"
				C.adjustStaminaLoss(30)
	for(var/M in invokers)
		var/mob/living/L = M
		L.apply_damage(15, BRUTE, pick("l_arm", "r_arm"))
		L << "<span class='cultitalic'>[src] saps your strength!</span>"
	qdel(src)
	explosion(T, -1, 0, 1, 5)


//Rite of Spectral Manifestation: Summons a ghost on top of the rune as a cultist human with no items. User must stand on the rune at all times, and takes damage for each summoned ghost.
/obj/effect/rune/manifest
	cultist_name = "Manifest Spirit"
	cultist_desc = "manifests a spirit as a servant of the Geometer. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "6"
	construct_invoke = 0
	color = rgb(200, 0, 0)

/obj/effect/rune/manifest/New(loc)
	..()
	notify_ghosts("Manifest rune created in [get_area(src)].", 'sound/effects/ghost2.ogg', source = src)

/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(!(user in get_turf(src)))
		user << "<span class='cultitalic'>You must be standing on [src]!</span>"
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return list()
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	if(!ghosts_on_rune.len)
		user << "<span class='cultitalic'>There are no spirits near [src]!</span>"
		fail_invoke()
		log_game("Manifest rune failed - no nearby ghosts")
		return list()
	return ..()

/obj/effect/rune/manifest/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
	var/mob/living/carbon/human/new_human = new(get_turf(src))
	new_human.real_name = ghost_to_spawn.real_name
	new_human.alpha = 150 //Makes them translucent
	..()
	visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a man.</span>")
	user << "<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>"
	var/obj/machinery/shield/N = new(get_turf(src))
	N.name = "Invoker's Shield"
	N.desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals"
	N.color = "red"
	N.health = 20
	N.mouse_opacity = 0
	new_human.key = ghost_to_spawn.key
	ticker.mode.add_cultist(new_human.mind, 0)
	new_human << "<span class='cultitalic'><b>You are a servant of the Geometer. You have been made semi-corporeal by the cult of Nar-Sie, and you are to serve them at all costs.</b></span>"

	while(user in get_turf(src))
		if(user.stat)
			break
		user.apply_damage(0.1, BRUTE)
		sleep(3)

	qdel(N)
	if(new_human)
		new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>", \
								  "<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
		for(var/obj/I in new_human)
			new_human.unEquip(I)
		new_human.dust()
=======
/obj/effect/rune/cultify()
	return

/obj/effect/rune/proc/findNullRod(var/atom/target)
	if(istype(target,/obj/item/weapon/nullrod))
		var/turf/T = get_turf(target)
		nullblock = 1
		T.turf_animation('icons/effects/96x96.dmi',"nullding",-32,-32,MOB_LAYER+1,'sound/piano/Ab7.ogg',anim_plane = PLANE_EFFECTS)
		return 1
	else if(target.contents)
		for(var/atom/A in target.contents)
			findNullRod(A)
	return 0

/obj/effect/rune/proc/invocation(var/animation_icon)
	c_animation = new /atom/movable/overlay(src.loc)
	c_animation.name = "cultification"
	c_animation.density = 0
	c_animation.anchored = 1
	c_animation.icon = 'icons/effects/effects.dmi'
	c_animation.layer = 5
	c_animation.master = src.loc
	c_animation.icon_state = "[animation_icon]"
	flick("cultification",c_animation)
	spawn(10)
		if(c_animation)
			c_animation.master = null
			qdel(c_animation)
			c_animation = null

/////////////////////////////////////////FIRST RUNE
/obj/effect/rune/proc/teleport(var/key)
	var/mob/living/user = usr
	var/allrunesloc[]
	allrunesloc = new/list()
	var/index = 0
//	var/tempnum = 0
	for(var/obj/effect/rune/R in rune_list)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["self"] && R.word3 == key && R.z != 2)
			index++
			allrunesloc.len = index
			allrunesloc[index] = R.loc
	if(index >= 5)
		to_chat(user, "<span class='warning'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>")
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	if(allrunesloc && index != 0)
		if(istype(src,/obj/effect/rune))
			user.say("Sas[pick("'","`")]so c'arta forbici!")//Only you can stop auto-muting
		else
			user.whisper("Sas[pick("'","`")]so c'arta forbici!")
		if(universe.name != "Hell Rising")
			user.visible_message("<span class='warning'> [user] disappears in a flash of red light!</span>", \
			"<span class='warning'>You feel as your body gets dragged through the dimension of Nar-Sie!</span>", \
			"<span class='warning'>You hear a sickening crunch and sloshing of viscera.</span>")
		else
			user.visible_message("<span class='warning'> [user] disappears in a flash of red light!</span>", \
			"<span class='warning'>You feel as your body gets dragged through a tunnel of viscera !</span>", \
			"<span class='warning'>You hear a sickening crunch and sloshing of viscera.</span>")

		if(istype(src,/obj/effect/rune))
			invocation("rune_teleport")

		user.loc = allrunesloc[rand(1,index)]
		return
	if(istype(src,/obj/effect/rune))
		return	fizzle() //Use friggin manuals, Dorf, your list was of zero length.
	else
		call(/obj/effect/rune/proc/fizzle)()
		return


/obj/effect/rune/proc/itemport(var/key)
//	var/allrunesloc[]
//	allrunesloc = new/list()
//	var/index = 0
//	var/tempnum = 0
	var/culcount = 0
	var/runecount = 0
	var/obj/effect/rune/IP = null
	var/mob/living/user = usr
	var/swapping[] = null
	for(var/obj/effect/rune/R in rune_list)
		if(R == src)
			continue
		if(R.word1 == cultwords["travel"] && R.word2 == cultwords["other"] && R.word3 == key)
			IP = R
			runecount++
	if(runecount >= 2)
		to_chat(user, "<span class='warning'>You feel pain, as rune disappears in reality shift caused by too much wear of space-time fabric</span>")
		if (istype(user, /mob/living))
			user.take_overall_damage(5, 0)
		qdel(src)
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		user.say("Sas[pick("'","`")]so c'arta forbici tarem!")

		nullblock = 0
		for(var/turf/T1 in range(src,1))
			findNullRod(T1)
		if(nullblock)
			user.visible_message("<span class='warning'>A nearby null rod seems to be blocking the transfer.</span>")
			return

		for(var/turf/T2 in range(IP,1))
			findNullRod(T2)
		if(nullblock)
			user.visible_message("<span class='warning'>A null rod seems to be blocking the transfer on the other side.</span>")
			return

		user.visible_message("<span class='warning'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='warning'>You feel air moving from the rune - like as it was swapped with somewhere else.</span>", \
		"<span class='warning'>You smell ozone.</span>")

		swapping = list()
		for(var/obj/O in IP.loc)//filling a list with all the teleportable atoms on the other rune
			if(!O.anchored)
				swapping += O
		for(var/mob/M in IP.loc)
			swapping += M

		for(var/obj/O in src.loc)//sending the items on the rune to the other rune
			if(!O.anchored)
				O.loc = IP.loc
		for(var/mob/M in src.loc)
			M.loc = IP.loc

		for(var/obj/O in swapping)//bringing the items previously marked from the other rune to our rune
			O.loc = src.loc
		for(var/mob/M in swapping)
			M.loc = src.loc

		swapping = 0
		return
	return fizzle()


/////////////////////////////////////////SECOND RUNE

/obj/effect/rune/proc/tomesummon()
	if(istype(src,/obj/effect/rune))
		usr.say("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	else
		usr.whisper("N[pick("'","`")]ath reth sh'yro eth d'raggathnor!")
	usr.visible_message("<span class='warning'>Rune disappears with a flash of red light, and in its place now a book lies.</span>", \
	"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a book.</span>", \
	"<span class='warning'>You hear a pop and smell ozone.</span>")
	if(istype(src,/obj/effect/rune))
		new /obj/item/weapon/tome(src.loc)
		src.invocation("tome_spawn")
	else
		new /obj/item/weapon/tome(usr.loc)
	qdel(src)
	stat_collection.cult.tomes_created++
	return

/////////////////////////////////////////THIRD RUNE

/obj/effect/rune/proc/convert()

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	for(var/mob/living/carbon/M in src.loc)
		if(iscultist(M))
			to_chat(usr, "<span class='warning'>You cannot convert what is already a follower of Nar-Sie.</span>")
			return 0
		if(M.stat==DEAD)
			to_chat(usr, "<span class='warning'>You cannot convert the dead.</span>")
			return 0
		if(!M.mind)
			to_chat(usr, "<span class='warning'>You cannot convert that which has no soul</span>")
			return 0
		if(cult_round && (M.mind == cult_round.sacrifice_target))
			to_chat(usr, "<span class='warning'>The Geometer of blood wants this mortal for himself.</span>")
			return 0
		usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
		nullblock = 0
		for(var/turf/T in range(M,1))
			findNullRod(T)
		if(nullblock)
			usr.visible_message("<span class='warning'>Something is blocking the conversion!</span>")
			return 0
		invocation("rune_convert")
		M.visible_message("<span class='warning'>[M] writhes in pain as the markings below him glow a bloody red.</span>", \
		"<span class='danger'>AAAAAAHHHH!.</span>", \
		"<span class='warning'>You hear an anguished scream.</span>")
		if(is_convertable_to_cult(M.mind) && !jobban_isbanned(M, "cultist"))//putting jobban check here because is_convertable uses mind as argument
			ticker.mode.add_cultist(M.mind)
			M.mind.special_role = "Cultist"
			to_chat(M, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
			to_chat(M, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
			to_chat(M, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")
			M.add_language("Cult")
			log_admin("[usr]([ckey(usr.key)]) has converted [M] ([ckey(M.key)]) to the cult at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.loc.x];Y=[M.loc.y];Z=[M.loc.z]'>([M.loc.x], [M.loc.y], [M.loc.z])</a>")
			stat_collection.cult.converted++
			if(M.client)
				spawn(600)
					if(M && !M.client)
						var/turf/T = get_turf(M)
						message_admins("[M] ([ckey(M.key)]) ghosted/disconnected less than a minute after having been converted to the cult! ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
						log_admin("[M]([ckey(M.key)]) ghosted/disconnected less than a minute after having been converted to the cult! ([T.x],[T.y],[T.z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
			return 1
		else
			if(jobban_isbanned(M, "cultist"))
				M.Sleeping(300)//putting them to sleep for 5 minutes.
				to_chat(usr, "<span class='danger'>The ritual didn't work! Looks like this person just isn't suited to be part of our cult.</span>")
				to_chat(usr, "<span class='notice'>It appears that the ritual at least put the target to sleep. Try to figure a way to deal with them before they wake up.</span>")
			else if(M.weakened)
				to_chat(usr, "<span class='danger'>The ritual didn't work, either something is disrupting it, or this person just isn't suited to be part of our cult.</span>")
				to_chat(usr, "<span class='danger'>You have to restrain him before the talisman's effects wear off!</span>")
			to_chat(M, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
			to_chat(M, "<span class='danger'>And you were able to force it out of your mind. You now know the truth, there's something horrible out there, stop it and its minions at all costs.</span>")
			return 0

	usr.say("Mah[pick("'","`")]weyh pleggh at e'ntrath!")
	usr.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	to_chat(usr, "<span class='notice'>You remembered the words correctly, but the rune isn't working. Maybe your ritual is missing something important.</span>")

/////////////////////////////////////////FOURTH RUNE

/obj/effect/rune/proc/tearreality()
	if(summoning)
		return

	var/list/active_cultists=list()
	var/ghostcount = 0

	for(var/mob/M in range(1,src))
		if(iscultist(M) && !M.stat)
			active_cultists.Add(M)
			if (istype(M, /mob/living/carbon/human/manifested))
				ghostcount++

	if(universe.name == "Hell Rising")
		for(var/mob/M in active_cultists)
			to_chat(M, "<span class='warning'>This plane of reality has already been torn into Nar-Sie's realm.</span>")
		return

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	if(ticker.mode.eldergod)
		// Sanity checks
		// Are we permitted to spawn Nar-Sie?

		if(!cult_round || cult_round.narsie_condition_cleared)//if the game mode wasn't cult to begin with, there won't be need to complete a first objective to prepare the summoning.
			if(active_cultists.len >= 9)
				if(z != map.zMainStation)
					for(var/mob/M in active_cultists)
						to_chat(M, "<span class='danger'>YOU HAVE A TERRIBLE FEELING. IS SOMETHING WRONG WITH THE RITUAL?</span>")//You get one warning

				summoning = 1
				log_admin("NAR-SIE SUMMONING: [active_cultists.len] are summoning Nar-Sie at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>). [6 + (ghostcount * 5)] seconds remaining.")
				message_admins("NAR-SIE SUMMONING: [active_cultists.len] are summoning Nar-Sie at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>). [6 + (ghostcount * 5)] seconds remaining.")
				updatetear(6 + (ghostcount * 5))	//the summoning takes 6 seconds by default , but for each manifested ghost around it takes 5 more seconds.
				return								//with 8 manifested ghosts summoned by a single human, it'd take 46 seconds, which would cause 46*8 = 368 brute damage over time to the human.
													//no more lone human summoning nar-sie all by himself (as all the ghosts would die as soon as he goes uncounscious)
		else
			for(var/mob/M in active_cultists)
				to_chat(M, "<span class='sinister'>The Geometer of Blood has required of you to perform a certain task. This place cannot welcome him until this task has been cleared.</span>")
			return

	else
		for(var/mob/M in active_cultists)
			to_chat(M, "<span class='danger'>Nar-Sie has lost interest in this world.</span>")//narsie won't appear if a supermatter cascade has started

		return

	return fizzle()


/obj/effect/rune/proc/updatetear(var/currentCountdown)
	if(!summoning)
		summonturfs = list()
		return
	summonturfs = list()
	var/list/active_cultists=list()
	for(var/mob/M in range(1,src))
		if(iscultist(M) && !M.stat)
			active_cultists.Add(M)
			var/turf/T = get_turf(M)
			summonturfs += T
			if(!(locate(/obj/effect/summoning) in T))
				var/obj/effect/summoning/S = new(T)
				S.init(src)


	if(active_cultists.len < 9)
		summoning = 0
		summonturfs = list()
		for(var/mob/M in active_cultists)
			to_chat(M, "<span class='warning'>The ritual has been disturbed. All summoners need to stay by the rune.</span>")
		return

	if(currentCountdown <= 0)
		if(z != map.zMainStation)//No more summonings on the Asteroid!
			for(var/mob/M in active_cultists)
				M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
			summonturfs = list()
			summoning = 0
			for(var/mob/M in active_cultists)
				to_chat(M, "<span class='sinister'>THE GEOMETER OF BLOOD IS HIGHLY DISAPOINTED WITH YOUR INABILITY TO PERFORM THE RITUAL IN ITS REQUESTED LOCATION.</span>")
				M.gib()
		else
			for(var/mob/M in active_cultists)
				// Only chant when Nar-Sie spawns
				M.say("Tok-lyr rqa'nap g[pick("'","`")]lt-ulotf!")
			ticker.mode.eldergod = 0
			summonturfs = list()
			summoning = 0
			new /obj/machinery/singularity/narsie/large(src.loc)
			stat_collection.cult.narsie_summoned = 1
		return

	currentCountdown--

	sleep(10)

	updatetear(currentCountdown)
	return

/obj/effect/summoning
	name = "summoning"
	icon = 'icons/effects/effects.dmi'
	icon_state = "summoning"
	mouse_opacity = 1
	density = 0
	flags = 0
	var/obj/effect/rune/summon_target = null

/obj/effect/summoning/New()
	..()
	spawn(10)
		update()

/obj/effect/summoning/proc/update()
	if(summon_target && (locate(get_turf(src)) in summon_target.summonturfs))
		sleep(10)
		update()
		return
	else
		qdel(src)

/obj/effect/summoning/proc/init(var/obj/effect/rune/S)
	summon_target = S

/////////////////////////////////////////FIFTH RUNE

/obj/effect/rune/proc/emp(var/U,var/range_red) //range_red - var which determines by which number to reduce the default emp range, U is the source loc, needed because of talisman emps which are held in hand at the moment of using and that apparently messes things up -- Urist
	if(istype(src,/obj/effect/rune))
		usr.say("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	else
		usr.whisper("Ta'gh fara[pick("'","`")]qha fel d'amar det!")
	playsound(U, 'sound/items/Welder2.ogg', 25, 1)
	var/turf/T = get_turf(U)
	if(T)
		T.hotspot_expose(700,125,surfaces=1)
	var/rune = src // detaching the proc - in theory
	empulse(U, (range_red - 2), range_red)
	qdel(rune)
	return

/////////////////////////////////////////SIXTH RUNE

/obj/effect/rune/proc/drain()
	var/drain = 0
	var/list/drain_turflist = list()
	for(var/obj/effect/rune/R in rune_list)
		if(R.word1==cultwords["travel"] && R.word2==cultwords["blood"] && R.word3==cultwords["self"])
			for(var/mob/living/carbon/D in R.loc)
				if(D.stat!=2)
					nullblock = 0
					for(var/turf/T in range(D,1))
						findNullRod(T)
					if(!nullblock)
						var/bdrain = rand(1,25)
						to_chat(D, "<span class='warning'>You feel weakened.</span>")
						D.take_overall_damage(bdrain, 0)
						drain += bdrain
						drain_turflist += get_turf(R)
	if(!drain)
		return fizzle()
	usr.say ("Yu[pick("'","`")]gular faras desdae. Havas mithum javara. Umathar uf'kal thenar!")
	usr.visible_message("<span class='warning'>Blood flows from the rune into [usr]!</span>", \
	"<span class='warning'>The blood starts flowing from the rune and into your frail mortal body. You feel... empowered.</span>", \
	"<span class='warning'>You hear a liquid flowing.</span>")

	var/mob/living/user = usr

	spawn()
		for(var/i = 0;i < 2;i++)
			for(var/turf/T in drain_turflist)
				make_tracker_effects(T, user, 1, "soul", 3, /obj/effect/tracker/drain)
				sleep(1)

	if(user.bhunger)
		user.bhunger = max(user.bhunger-2*drain,0)
	if(drain>=50)
		user.visible_message("<span class='warning'>[user]'s eyes give off eerie red glow!</span>", \
		"<span class='warning'>...but it wasn't nearly enough. You crave, crave for more. The hunger consumes you from within.</span>", \
		"<span class='warning'>You hear a heartbeat.</span>")
		user.bhunger += drain
		src = user
		spawn()
			for (,user.bhunger>0,user.bhunger--)
				sleep(50)
				user.take_overall_damage(3, 0)
		return
	user.heal_organ_damage(drain%5, 0)
	drain-=drain%5
	for (,drain>0,drain-=5)
		sleep(2)
		user.heal_organ_damage(5, 0)
	return






/////////////////////////////////////////SEVENTH RUNE

/obj/effect/rune/proc/seer()
	if(usr.loc==src.loc)
		if(usr.seer==1)
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium viortia.")
			to_chat(usr, "<span class='warning'>The world beyond fades from your vision.</span>")
			usr.see_invisible = SEE_INVISIBLE_LIVING
			usr.seer = 0
		else if(usr.see_invisible!=SEE_INVISIBLE_LIVING)
			to_chat(usr, "<span class='warning'>The world beyond flashes your eyes but disappears quickly, as if something is disrupting your vision.</span>")
			usr.see_invisible = SEE_INVISIBLE_OBSERVER
			usr.seer = 0
		else
			usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
			to_chat(usr, "<span class='warning'>The world beyond opens to your eyes.</span>")
			usr.see_invisible = SEE_INVISIBLE_OBSERVER
			usr.seer = 1
		return
	usr.say("Rash'tla sektath mal[pick("'","`")]zua. Zasan therium vivira. Itonis al'ra matum!")
	usr.show_message("\<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	to_chat(usr, "<span class='notice'>You remembered the words correctly, but the rune isn't reacting. Maybe you should position yourself differently.</span>")

/////////////////////////////////////////EIGHTH RUNE

/obj/effect/rune/proc/raise()
	var/mob/living/carbon/human/corpse_to_raise
	var/mob/living/carbon/human/body_to_sacrifice

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	var/is_sacrifice_target = 0
	for(var/mob/living/carbon/human/M in src.loc)
		if(M.stat == DEAD)
			if(cult_round && (M.mind == cult_round.sacrifice_target))
				is_sacrifice_target = 1
			else
				corpse_to_raise = M
				if(M.key)
					M.ghostize(1)	//kick them out of their body
				break
	if(!corpse_to_raise)
		if(is_sacrifice_target)
			to_chat(usr, "<span class='warning'>The Geometer of blood wants this mortal for himself.</span>")
		return fizzle()


	is_sacrifice_target = 0
	find_sacrifice:
		for(var/obj/effect/rune/R in rune_list)
			if(R.word1==cultwords["blood"] && R.word2==cultwords["join"] && R.word3==cultwords["hell"])
				for(var/mob/living/carbon/human/N in R.loc)
					if(cult_round && (N.mind) && (N.mind == cult_round.sacrifice_target))
						is_sacrifice_target = 1
					else
						if(N.stat!= DEAD)
							nullblock = 0
							for(var/turf/T in range(N,1))
								findNullRod(T)
							if(nullblock)
								return fizzle()
							else
								body_to_sacrifice = N
								break find_sacrifice

	if(!body_to_sacrifice)
		if (is_sacrifice_target)
			to_chat(usr, "<span class='warning'>The Geometer of blood wants that corpse for himself.</span>")
		else
			to_chat(usr, "<span class='warning'>The sacrifical corpse is not dead. You must free it from this world of illusions before it may be used.</span>")
		return fizzle()

	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break

	if(!ghost)
		to_chat(usr, "<span class='warning'>You require a restless spirit which clings to this world. Beckon their prescence with the sacred chants of Nar-Sie.</span>")
		return fizzle()

	corpse_to_raise.revive()

	corpse_to_raise.key = ghost.key	//the corpse will keep its old mind! but a new player takes ownership of it (they are essentially possessed)
									//This means, should that player leave the body, the original may re-enter
	usr.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	corpse_to_raise.visible_message("<span class='warning'>[corpse_to_raise]'s eyes glow with a faint red as he stands up, slowly starting to breathe again.</span>", \
	"<span class='warning'>Life... I am alive again...</span>", \
	"<span class='warning'>You hear a faint, slightly familiar whisper.</span>")
	body_to_sacrifice.visible_message("<span class='warning'>[body_to_sacrifice] is torn apart, a black smoke swiftly dissipating from his remains!</span>", \
	"<span class='warning'>You feel as your blood boils, tearing you apart.</span>", \
	"<span class='warning'>You hear a thousand voices, all crying in pain.</span>")
	body_to_sacrifice.gib()

//	if(cult_round)
//		cult_round.add_cultist(corpse_to_raise.mind)
//	else
//		ticker.mode.cult |= corpse_to_raise.mind

	to_chat(corpse_to_raise, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(corpse_to_raise, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
	return





/////////////////////////////////////////NINETH RUNE

/obj/effect/rune/proc/obscure(var/rad)
	var/S=0
	for(var/obj/effect/rune/R in orange(rad,src))
		if(R!=src)
			R.invisibility=INVISIBILITY_OBSERVER
		S=1
	if(S)
		if(istype(src,/obj/effect/rune))
			usr.say("Kla[pick("'","`")]atu barada nikt'o!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='warning'>The rune turns into gray dust, veiling the surrounding runes.</span>")
			qdel(src)
		else
			usr.whisper("Kla[pick("'","`")]atu barada nikt'o!")
			to_chat(usr, "<span class='warning'>Your talisman turns into gray dust, veiling the surrounding runes.</span>")
			for (var/mob/V in orange(1,src))
				if(V!=usr)
					V.show_message("<span class='warning'>Dust emanates from [usr]'s hands for a moment.</span>")

		return
	if(istype(src,/obj/effect/rune))
		return	fizzle()
	else
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////TENTH RUNE

/obj/effect/rune/proc/ajourney() //some bits copypastaed from admin tools - Urist
	if(usr.loc==src.loc)
		var/mob/living/carbon/human/L = usr
		usr.say("Fwe[pick("'","`")]sh mah erl nyag r'ya!")
		usr.visible_message("<span class='warning'>[usr]'s eyes glow blue as \he freezes in place, absolutely motionless.</span>", \
		"<span class='warning'>The shadow that is your spirit separates itself from your body. You are now in the realm beyond. While this is a great sight, being here strains your mind and body. Hurry...</span>", \
		"<span class='warning'>You hear only complete silence for a moment.</span>")
		usr.ghostize(1)
		L.ajourn = src
		ajourn = L
		while(L)
			if(L.key)
				L.ajourn=null
				ajourn = null
				return
			else
				L.take_organ_damage(10, 0)
			sleep(100)
	return fizzle()

/////////////////////////////////////////ELEVENTH RUNE

/obj/effect/rune/proc/manifest()
	var/obj/effect/rune/this_rune = src
	src = null
	if(usr.loc!=this_rune.loc)
		return this_rune.fizzle()
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in this_rune.loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break
	if(!ghost)
		return this_rune.fizzle()
	if(jobban_isbanned(ghost, "cultist"))
		return this_rune.fizzle()

	usr.say("Gal'h'rfikk harfrandid mud[pick("'","`")]gib!")

	var/mob/living/carbon/human/manifested/D = new(this_rune.loc)
	D.key = ghost.key
	D.icon = null
	D.invisibility = 101
	D.canmove = 0
	var/atom/movable/overlay/animation = null

	usr.visible_message("<span class='warning'> A shape forms in the center of the rune. A shape of... a man.<BR>The world feels blury as your soul permeates this temporary body.</span>", \
	"<span class='warning'> A shape forms in the center of the rune. A shape of... a man.</span>", \
	"<span class='warning'>You hear liquid flowing.</span>")

	animation = new(D.loc)
	animation.layer = usr.layer + 1
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = this_rune
	flick("appear-hm", animation)
	sleep(5)
	D.invisibility = 0
	sleep(10)
	D.real_name = "Unknown"
	var/chose_name = 0
	for(var/obj/item/weapon/paper/P in this_rune.loc)
		if(P.info)
			D.real_name = copytext(P.info, 1, MAX_NAME_LEN)
			chose_name = 1
			break
	if(!chose_name)
		D.real_name = "[pick(first_names_male)] [pick(last_names)]"
	D.status_flags &= ~GODMODE

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")
	if(cult_round)
		cult_round.add_cultist(D.mind)
	else
		ticker.mode.cult += D.mind

	ticker.mode.update_cult_icons_added(D.mind)
	D.canmove = 1
	animation.master = null
	qdel(animation)

	D.mind.special_role = "Cultist"
	to_chat(D, "<span class='sinister'>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible truth. The veil of reality has been ripped away and in the festering wound left behind something sinister takes root.</span>")
	to_chat(D, "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>")
	to_chat(D, "<span class='sinister'>You can now speak and understand the forgotten tongue of the occult.</span>")

	D.add_language("Cult")


	var/mob/living/user = usr
	while(this_rune && user && user.stat==CONSCIOUS && user.client && user.loc==this_rune.loc)
		user.take_organ_damage(1, 0)
		sleep(30)
	if(D)
		D.visible_message("<span class='warning'>[D] slowly dissipates into dust and bones.</span>", \
		"<span class='warning'>You feel pain, as bonds formed between your soul and this homunculus break.</span>", \
		"<span class='warning'>You hear faint rustle.</span>")
		D.dust()
	return

/////////////////////////////////////////TWELFTH RUNE

/obj/effect/rune/proc/talisman()//only tome, communicate, hide, reveal, emp, teleport, deafen, blind, stun and armor runes can be imbued
	var/obj/item/weapon/paper/newtalisman
	var/unsuitable_newtalisman = 0
	for(var/obj/item/weapon/paper/P in src.loc)
		if(!P.info)
			newtalisman = P
			break
		else
			unsuitable_newtalisman = 1
	if (!newtalisman)
		if (unsuitable_newtalisman)
			to_chat(usr, "<span class='warning'>The blank is tainted. It is unsuitable.</span>")
		return fizzle()

	if (istype(newtalisman, /obj/item/weapon/paper/nano))//I mean, cult and technology don't mix well together right?
		to_chat(usr, "<span class='warning'>This piece of technologically advanced paper is unsuitable.</span>")
		return fizzle()

	var/obj/effect/rune/imbued_from
	var/obj/item/weapon/paper/talisman/T
	for(var/obj/effect/rune/R in orange(1,src))
		if(R==src)
			continue
		if(R.word1==cultwords["travel"] && R.word2==cultwords["self"])  //teleport
			T = new(src.loc)
			T.imbue = "[R.word3]"
			imbued_from = R
			break
		if(R.word1==cultwords["see"] && R.word2==cultwords["blood"] && R.word3==cultwords["hell"]) //tome
			T = new(src.loc)
			T.imbue = "newtome"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["technology"]) //emp
			T = new(src.loc)
			T.imbue = "emp"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["destroy"]) //conceal
			T = new(src.loc)
			T.imbue = "conceal"
			imbued_from = R
			break
		if(R.word1==cultwords["hell"] && R.word2==cultwords["destroy"] && R.word3==cultwords["other"]) //armor
			T = new(src.loc)
			T.imbue = "armor"
			imbued_from = R
			break
		if(R.word1==cultwords["blood"] && R.word2==cultwords["see"] && R.word3==cultwords["hide"]) //reveal
			T = new(src.loc)
			T.imbue = "revealrunes"
			imbued_from = R
			break
		if(R.word1==cultwords["hide"] && R.word2==cultwords["other"] && R.word3==cultwords["see"]) //deafen
			T = new(src.loc)
			T.imbue = "deafen"
			imbued_from = R
			break
		if(R.word1==cultwords["destroy"] && R.word2==cultwords["see"] && R.word3==cultwords["other"]) //blind
			T = new(src.loc)
			T.imbue = "blind"
			imbued_from = R
			break
		if(R.word1==cultwords["self"] && R.word2==cultwords["other"] && R.word3==cultwords["technology"]) //communicate
			T = new(src.loc)
			T.imbue = "communicate"
			imbued_from = R
			break
		if(R.word1==cultwords["join"] && R.word2==cultwords["hide"] && R.word3==cultwords["technology"]) //stun
			T = new(src.loc)
			T.imbue = "runestun"
			imbued_from = R
			break
	if (imbued_from)
		for (var/mob/V in viewers(src))
			V.show_message("<span class='warning'>The runes turn into dust, which then forms into an arcane image on the paper.</span>", 1)
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		qdel(imbued_from)
		qdel(newtalisman)
		invocation("rune_imbue")
	else
		usr.say("H'drak v[pick("'","`")]loso, mir'kanas verbot!")
		usr.show_message("\<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 1, "<span class='warning'>You hear a faint fizzle.</span>", 2)
		to_chat(usr, "<span class='notice'>You remembered the words correctly, but the rune isn't working properly. Maybe you're missing something in the ritual.</span>")

/////////////////////////////////////////THIRTEENTH RUNE

/obj/effect/rune/proc/mend()
	var/mob/living/user = usr
	src = null
	user.say("Uhrast ka'hfa heldsagen ver[pick("'","`")]lot!")
	user.take_overall_damage(200, 0)
	runedec+=10
	user.visible_message("<span class='warning'>[user] keels over dead, his blood glowing blue as it escapes his body and dissipates into thin air.</span>", \
	"<span class='warning'>In the last moment of your humble life, you feel an immense pain as fabric of reality mends... with your blood.</span>", \
	"<span class='warning'>You hear faint rustle.</span>")
	for(,user.stat==2)
		sleep(600)
		if (!user)
			return
	runedec-=10
	return


/////////////////////////////////////////FOURTEETH RUNE

// returns 0 if the rune is not used. returns 1 if the rune is used.
/obj/effect/rune/proc/communicate()
	. = 1 // Default output is 1. If the rune is deleted it will return 1
	var/mob/user = usr
	var/input = stripped_input(user, "Please choose a message to tell to the other acolytes.", "Voice of Blood", "")
	if(!input)
		if (istype(src))
			fizzle()
			return 0
		else
			return 0
	if(istype(src,/obj/effect/rune))
		user.say("O bidai nabora se[pick("'","`")]sma!")
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!")

	if(istype(src,/obj/effect/rune))
		user.say("[input]")
	else
		user.whisper("[input]")
	for(var/datum/mind/H in ticker.mode.cult)
		if (H.current)
			to_chat(H.current, "<span class='game say'><b>[user.real_name]</b>'s voice echoes in your head, <B><span class='sinister'>[input]</span></B></span>")//changed from red to purple - Deity Link


	for(var/mob/dead/observer/O in player_list)
		to_chat(O, "<span class='game say'><b>[user.real_name]</b> communicates, <span class='sinister'>[input]</span></span>")

	log_cultspeak("[key_name(user)] Cult Communicate Rune: [input]")

	qdel(src)
	return 1

/////////////////////////////////////////FIFTEENTH RUNE

/obj/effect/rune/proc/sacrifice()
	var/list/mob/living/cultsinrange = list()
	var/ritualresponse = ""
	var/sacrificedone = 0

	//how many cultists do we have near the rune
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			cultsinrange += C
			C.say("Barhah hra zar[pick("'","`")]garis!")

	//checking for null rods
	nullblock = 0
	for(var/turf/T in range(src,1))
		findNullRod(T)
	if(nullblock)
		to_chat(usr, "<span class='warning'>The presence of a null rod is perturbing the ritual.</span>")
		return

	var/datum/game_mode/cult/cult_round = find_active_mode("cult")

	for(var/atom/A in loc)
		if(iscultist(A))
			continue
		var/satisfaction = 0
//Humans and Animals
		if(istype(A,/mob/living/carbon) || istype(A,/mob/living/simple_animal))//carbon mobs and simple animals
			var/mob/living/M = A
			if (cult_round && (M.mind == cult_round.sacrifice_target))
				if(cultsinrange.len >= 3)
					cult_round.sacrificed += M.mind
					M.gib()
					sacrificedone = 1
					invocation("rune_sac")
					ritualresponse += "The Geometer of Blood gladly accepts this sacrifice, your objective is now complete."
					spawn(10)	//so the messages for the new phase get received after the feedback for the sacrifice
						cult_round.additional_phase()
				else
					ritualresponse += "You need more cultists to perform the ritual and complete your objective."
			else
				if(M.stat != DEAD)
					if(cultsinrange.len >= 3)
						if(M.mind)				//living players
							ritualresponse += "The Geometer of Blood gladly accepts this sacrifice."
							satisfaction = 100
						else					//living NPCs
							ritualresponse += "The Geometer of Blood accepts this being in sacrifice. Somehow you get the feeling that beings with souls would make a better offering."
							satisfaction = 50
						sacrificedone = 1
						invocation("rune_sac")
						M.gib()
					else
						ritualresponse += "The victim is still alive, you will need more cultists chanting for the sacrifice to succeed."
				else
					if(M.mind)					//dead players
						ritualresponse += "The Geometer of Blood accepts this sacrifice."
						satisfaction = 50
					else						//dead NPCs
						ritualresponse += "The Geometer of Blood accepts your meager sacrifice."
						satisfaction = 10
					sacrificedone = 1
					invocation("rune_sac")
					M.gib()
//Borgs and MoMMis
		else if(istype(A, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/B = A
			var/obj/item/device/mmi/O = locate() in B
			if(O)
				if(cult_round && (O.brainmob.mind == cult_round.sacrifice_target))
					if(cultsinrange.len >= 3)
						cult_round.sacrificed += O.brainmob.mind
						ritualresponse += "The Geometer of Blood accepts this sacrifice, your objective is now complete."
						sacrificedone = 1
						invocation("rune_sac")
						B.dust()
						spawn(10)	//so the messages for the new phase get received after the feedback for the sacrifice
							cult_round.additional_phase()
					else
						ritualresponse += "You need more cultists to perform the ritual and complete your objective."
				else
					if(B.stat != DEAD)
						if(cultsinrange.len >= 3)
							ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
							sacrificedone = 1
							invocation("rune_sac")
							B.dust()
						else
							ritualresponse += "That machine is still working, you will need more cultists chanting for the sacrifice to destroy it."
					else
						ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
						sacrificedone = 1
						invocation("rune_sac")
						B.dust()
//MMI
		else if(istype(A, /obj/item/device/mmi))
			var/obj/item/device/mmi/I = A
			var/mob/living/carbon/brain/N = I.brainmob
			if(N)//the MMI has a player's brain in it
				if(cult_round && (N.mind == cult_round.sacrifice_target))
					ritualresponse += "You need to place that brain back inside a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that pile of machinery."
					sacrificedone = 1
					invocation("rune_sac")
					I.on_fire = 1
					I.ashify()
//Brain
		else if(istype(A, /obj/item/organ/brain))
			var/obj/item/organ/brain/R = A
			var/mob/living/carbon/brain/N = R.brainmob
			if(N)//the brain is a player's
				if(cult_round && (N.mind == cult_round.sacrifice_target))
					ritualresponse += "You need to place that brain back inside a body before you can complete your objective."
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that brain."
					sacrificedone = 1
					invocation("rune_sac")
					R.on_fire = 1
					R.ashify()
//Carded AIs
		else if(istype(A, /obj/item/device/aicard))
			var/obj/item/device/aicard/D = A
			var/mob/living/silicon/ai/T = locate() in D
			if(T)//there is an AI on the card
				if(cult_round && (T.mind == cult_round.sacrifice_target))//what are the odds this ever happens?
					cult_round.sacrificed += T.mind
					ritualresponse += "With a sigh, the Geometer of Blood accepts this sacrifice, your objective is now complete."//since you cannot debrain an AI.
					spawn(10)	//so the messages for the new phase get received after the feedback for the sacrifice
						cult_round.additional_phase()
				else
					ritualresponse += "The Geometer of Blood accepts to destroy that piece of technological garbage."
				sacrificedone = 1
				invocation("rune_sac")
				D.on_fire = 1
				D.ashify()

		else
			continue

//feedback
		for(var/mob/living/C in cultsinrange)
			if(ritualresponse != "")
				to_chat(C, "<span class='sinister'>[ritualresponse]</span>")
				if(prob(satisfaction))
					ticker.mode:grant_runeword(C)

	if(!sacrificedone)
		for(var/mob/living/C in cultsinrange)
			to_chat(C, "<span class='warning'>There is nothing fit for sacrifice on the rune.</span>")

/////////////////////////////////////////SIXTEENTH RUNE

/obj/effect/rune/proc/revealrunes(var/obj/W as obj)
	var/go=0
	var/rad
	var/S=0
	if(istype(W,/obj/effect/rune))
		rad = 6
		go = 1
	if (istype(W,/obj/item/weapon/paper/talisman))
		rad = 4
		go = 1
	if (istype(W,/obj/item/weapon/nullrod))
		rad = 1
		go = 1
	if(go)
		for(var/obj/effect/rune/R in orange(rad,src))
			if(R!=src)
				R:visibility=15
			S=1
	if(S)
		if(istype(W,/obj/item/weapon/nullrod))
			to_chat(usr, "<span class='warning'>Arcane markings suddenly glow from underneath a thin layer of dust!</span>")
			return
		if(istype(W,/obj/effect/rune))
			usr.say("Nikt[pick("'","`")]o barada kla'atu!")
			for (var/mob/V in viewers(src))
				V.show_message("<span class='warning'>The rune turns into red dust, revealing the surrounding runes.</span>", 1)
			qdel(src)
			return
		if(istype(W,/obj/item/weapon/paper/talisman))
			usr.whisper("Nikt[pick("'","`")]o barada kla'atu!")
			to_chat(usr, "<span class='warning'>Your talisman turns into red dust, revealing the surrounding runes.</span>")
			for (var/mob/V in orange(1,usr.loc))
				if(V!=usr)
					V.show_message("<span class='warning'>Red dust emanates from [usr]'s hands for a moment.</span>", 1)
			return
		return
	if(istype(W,/obj/effect/rune))
		return	fizzle()
	if(istype(W,/obj/item/weapon/paper/talisman))
		call(/obj/effect/rune/proc/fizzle)()
		return

/////////////////////////////////////////SEVENTEENTH RUNE

/obj/effect/rune/proc/wall()
	usr.say("Khari[pick("'","`")]d! Eske'te tannin!")
	src.density = !src.density
	var/mob/living/user = usr
	user.take_organ_damage(2, 0)
	if(src.density)
		to_chat(usr, "<span class='warning'>Your blood flows into the rune, and you feel that the very space over the rune thickens.</span>")
	else
		to_chat(usr, "<span class='warning'>Your blood flows into the rune, and you feel as the rune releases its grasp on space.</span>")
	return

/////////////////////////////////////////EIGHTTEENTH RUNE

/obj/effect/rune/proc/freedom()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C

	var/list/possible_targets = list()
	for(var/mob/living/carbon/cultistarget in (cultists - users))
		if (cultistarget.handcuffed)
			possible_targets += cultistarget
		else if (cultistarget.legcuffed)
			possible_targets += cultistarget
		else if (istype(cultistarget.wear_mask, /obj/item/clothing/mask/muzzle))
			possible_targets += cultistarget
		else if (istype(cultistarget.loc, /obj/structure/closet))
			var/obj/structure/closet/closet = cultistarget.loc
			if(closet.welded)
				possible_targets += cultistarget
		else if (istype(cultistarget.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/secure_closet = cultistarget.loc
			if (secure_closet.locked)
				possible_targets += cultistarget
		else if (istype(cultistarget.loc, /obj/machinery/dna_scannernew))
			var/obj/machinery/dna_scannernew/dna_scannernew = cultistarget.loc
			if (dna_scannernew.locked)
				possible_targets += cultistarget

	if(!possible_targets.len)
		to_chat(user, "<span class='warning'>None of the cultists are currently under restraints.</span>")
		return fizzle()

	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to free", "Followers of Geometer") as null|anything in possible_targets
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(!(cultist.locked_to || \
			cultist.handcuffed || \
			istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle) || \
			(istype(cultist.loc, /obj/structure/closet)&&cultist.loc:welded) || \
			(istype(cultist.loc, /obj/structure/closet/secure_closet)&&cultist.loc:locked) || \
			(istype(cultist.loc, /obj/machinery/dna_scannernew)&&cultist.loc:locked) \
		))
			to_chat(user, "<span class='warning'>The [cultist] is already free.</span>")
			return
		cultist.unlock_from()
		if (cultist.handcuffed)
			cultist.drop_from_inventory(cultist.handcuffed)
		if (cultist.legcuffed)
			cultist.drop_from_inventory(cultist.legcuffed)
		if (istype(cultist.wear_mask, /obj/item/clothing/mask/muzzle))
			cultist.u_equip(cultist.wear_mask, 1)
		if(istype(cultist.loc, /obj/structure/closet))
			var/obj/structure/closet/closet = cultist.loc
			if(closet.welded)
				closet.welded = 0
		if(istype(cultist.loc, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/secure_closet = cultist.loc
			if (secure_closet.locked)
				secure_closet.locked = 0
		if(istype(cultist.loc, /obj/machinery/dna_scannernew))
			var/obj/machinery/dna_scannernew/dna_scannernew = cultist.loc
			if (dna_scannernew.locked)
				dna_scannernew.locked = 0
		for(var/mob/living/carbon/C in users)
			user.take_overall_damage(10, 0)
			C.say("Khari[pick("'","`")]d! Gual'te nikka!")
		to_chat(cultist, "<span class='warning'>You feel a tingle as you find yourself freed from your restraints.</span>")
		qdel(src)
	else
		var/text = "<span class='sinister'>The following cultists are currently under restraints:</span>"
		for(var/mob/living/carbon/cultist in possible_targets)
			text += "<br><b>[cultist]</b>"
		to_chat(user, text)
		user.say("Khari[pick("'","`")]d!")
		return

	return fizzle()

/////////////////////////////////////////NINETEENTH RUNE

/obj/effect/rune/proc/cultsummon()
	var/mob/living/user = usr
	var/list/mob/living/carbon/cultists = new
	for(var/datum/mind/H in ticker.mode.cult)
		if (istype(H.current,/mob/living/carbon))
			cultists+=H.current
	var/list/mob/living/carbon/users = new
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			users+=C
	if(users.len>=3)
		var/mob/living/carbon/cultist = input("Choose the one who you want to summon", "Followers of Geometer") as null|anything in (cultists - user)
		if(!cultist)
			return fizzle()
		if (cultist == user) //just to be sure.
			return
		if(cultist.locked_to || cultist.handcuffed || (!isturf(cultist.loc) && !istype(cultist.loc, /obj/structure/closet)))
			to_chat(user, "<span class='warning'>You cannot summon the [cultist], for his shackles of blood are strong</span>")
			return fizzle()
		var/turf/T = get_turf(cultist)
		T.turf_animation('icons/effects/effects.dmi',"rune_teleport")
		cultist.loc = src.loc
		cultist.lying = 1
		cultist.regenerate_icons()
		to_chat(T, visible_message("<span class='warning'>[cultist] suddenly disappears in a flash of red light!</span>"))
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("N'ath reth sh'yro eth d[pick("'","`")]rekkathnor!")
				C.take_overall_damage(15, 0)
				if(C != cultist)
					to_chat(C, "<span class='warning'>Your body take its toll as you drag your fellow cultist through dimensions.</span>")
				else
					to_chat(C, "<span class='warning'>You feel a sharp pain as your body gets dragged through dimensions.</span>")
		user.visible_message("<span class='warning'>The rune disappears with a flash of red light, and in its place now a body lies.</span>", \
		"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that now instead of the rune there's a body.</span>", \
		"<span class='warning'>You hear a pop and smell ozone.</span>")
		qdel(src)
	else
		var/text = "<span class='sinister'>The following individuals are living and conscious followers of the Geometer of Blood:</span>"
		for(var/mob/living/L in player_list)
			if(L.stat != DEAD)
				if(L.mind in ticker.mode.cult)
					text += "<br><b>[L]</b>"
		to_chat(user, text)
		user.say("N'ath reth!")
		return

	return fizzle()

/////////////////////////////////////////TWENTIETH RUNES

/obj/effect/rune/proc/deafen()
	var/affected = 0
	for(var/mob/living/carbon/C in range(7,src))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.ear_deaf += 50
		C.show_message("<span class='warning'>The world around you suddenly becomes quiet.</span>")
		affected++
		if(prob(1))
			C.sdisabilities |= DEAF
	if(affected)
		usr.say("Sti[pick("'","`")] kaliedir!")
		to_chat(usr, "<span class='warning'>The world becomes quiet as the deafening rune dissipates into fine dust.</span>")
		qdel(src)
	else
		return fizzle()

/obj/effect/rune/proc/blind()
	var/affected = 0
	for(var/mob/living/carbon/C in viewers(src))
		if (iscultist(C))
			continue
		nullblock = 0
		for(var/turf/T in range(C,1))
			findNullRod(T)
		if(nullblock)
			continue
		C.eye_blurry += 50
		C.eye_blind += 20
		if(prob(5))
			C.disabilities |= NEARSIGHTED
			if(prob(10))
				C.sdisabilities |= BLIND
		to_chat(C, "<span class='warning'>Suddenly you see red flash that blinds you.</span>")
		affected++
	if(affected)
		usr.say("Sti[pick("'","`")] kaliesin!")
		to_chat(usr, "<span class='warning'>The rune flashes, blinding those who not follow the Nar-Sie, and dissipates into fine dust.</span>")
		qdel(src)
	else
		return fizzle()


/obj/effect/rune/proc/bloodboil() //cultists need at least one DANGEROUS rune. Even if they're all stealthy.
/*
			var/list/mob/living/carbon/cultists = new
			for(var/datum/mind/H in ticker.mode.cult)
				if (istype(H.current,/mob/living/carbon))
					cultists+=H.current
*/
	var/culcount = 0 //also, wording for it is old wording for obscure rune, which is now hide-see-blood.
//	var/list/cultboil = list(cultists-usr) //and for this words are destroy-see-blood.
	for(var/mob/living/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount>=3)
		for(var/mob/living/carbon/M in viewers(usr))
			if(iscultist(M))
				continue
			nullblock = 0
			for(var/turf/T in range(M,1))
				findNullRod(T)
			if(nullblock)
				continue
			M.take_overall_damage(51,51)
			to_chat(M, "<span class='warning'>Your blood boils!</span>")
			if(prob(5))
				spawn(5)
					M.gib()
		for(var/obj/effect/rune/R in view(src))
			if(prob(10))
				explosion(R.loc, -1, 0, 1, 5)
		for(var/mob/living/carbon/human/C in orange(1,src))
			if(iscultist(C) && !C.stat)
				C.say("Dedo ol[pick("'","`")]btoh!")
				C.take_overall_damage(15, 0)
		qdel(src)
	else
		return fizzle()
	return

// WIP rune, I'll wait for Rastaf0 to add limited blood.

/obj/effect/rune/proc/burningblood()
	var/culcount = 0
	for(var/mob/living/carbon/C in orange(1,src))
		if(iscultist(C) && !C.stat)
			culcount++
	if(culcount >= 5)
		for(var/obj/effect/rune/R in rune_list)
			if(R.blood_DNA == src.blood_DNA)
				for(var/mob/living/M in orange(2,R))
					M.take_overall_damage(0,15)
					if (R.invisibility>M.see_invisible)
						to_chat(M, "<span class='warning'>Aargh it burns!</span>")
					else
						to_chat(M, "<span class='warning'>The rune suddenly ignites, burning you!</span>")
					var/turf/T = get_turf(R)
					T.hotspot_expose(700,125,surfaces=1)
		for(var/obj/effect/decal/cleanable/blood/B in world)
			if(B.blood_DNA == src.blood_DNA)
				for(var/mob/living/M in orange(1,B))
					M.take_overall_damage(0,5)
					to_chat(M, "<span class='warning'>The blood suddenly ignites, burning you!</span>")
					var/turf/T = get_turf(B)
					T.hotspot_expose(700,125,surfaces=1)
					qdel(B)
		qdel(src)

//////////             Rune 24 (counting burningblood, which kinda doesnt work yet.)

/obj/effect/rune/proc/runestun(var/mob/living/T as mob)///When invoked as rune, flash and stun everyone around.
	usr.say("Fuu ma[pick("'","`")]jin!")
	for(var/mob/living/L in viewers(src))

		nullblock = 0
		for(var/turf/TU in range(L,1))
			findNullRod(TU)
		if(!nullblock)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.flash_eyes(visual = 1)
				if(C.stuttering < 1 && (!(M_HULK in C.mutations)))
					C.stuttering = 1
				C.Weaken(1)
				C.Stun(1)
				C.visible_message("<span class='warning'>The rune explodes in a bright flash.</span>")

			else if(issilicon(L))
				var/mob/living/silicon/S = L
				S.Weaken(5)
				S.visible_message("<span class='warning'>BZZZT... The rune has exploded in a bright flash.</span>")
	qdel(src)
	return

/////////////////////////////////////////TWENTY-FIFTH RUNE

/obj/effect/rune/proc/armor()
	var/mob/living/user = usr
	if(!istype(src,/obj/effect/rune))
		usr.whisper("Sa tatha najin")
		if(ishuman(user))
			usr.visible_message("<span class='warning'> In flash of red light, a set of armor appears on [usr]...</span>", \
			"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
			var/datum/game_mode/cult/mode_ticker = ticker.mode
			if((istype(mode_ticker) && mode_ticker.narsie_condition_cleared) || (universe.name == "Hell Rising"))
				user.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/cult(user), slot_head)
				user.equip_to_slot_or_del(new /obj/item/clothing/suit/space/cult(user), slot_wear_suit)
			else
				user.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(user), slot_head)
				user.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(user), slot_wear_suit)
			user.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(user), slot_shoes)
			user.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(user), slot_back)
			//the above update their overlay icons cache but do not call update_icons()
			//the below calls update_icons() at the end, which will update overlay icons by using the (now updated) cache
			user.put_in_hands(new /obj/item/weapon/melee/cultblade(user))	//put in hands or on floor
		else if(ismonkey(user))
			var/mob/living/carbon/monkey/K = user
			K.visible_message("<span class='warning'> The rune disappears with a flash of red light, [K] now looks like the cutest of all followers of Nar-Sie...</span>", \
			"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor. Might not offer much protection due to its size though.</span>")
			K.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes, slot_w_uniform)
			K.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood/alt, slot_head)
			K.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/cultpack, slot_back)
			K.put_in_hands(new /obj/item/weapon/melee/cultblade(K))
		return
	else
		usr.say("Sa tatha najin")
		for(var/mob/living/M in src.loc)
			if(iscultist(M))
				if(ishuman(M))
					M.visible_message("<span class='warning'> In flash of red light, and a set of armor appears on [M]...</span>", \
					"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor.</span>")
					var/datum/game_mode/cult/mode_ticker = ticker.mode
					if((istype(mode_ticker) && mode_ticker.narsie_condition_cleared) || (universe.name == "Hell Rising"))
						M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/cult(M), slot_head)
						M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/cult(M), slot_wear_suit)
					else
						M.equip_to_slot_or_del(new /obj/item/clothing/head/culthood/alt(M), slot_head)
						M.equip_to_slot_or_del(new /obj/item/clothing/suit/cultrobes/alt(M), slot_wear_suit)
					M.equip_to_slot_or_del(new /obj/item/clothing/shoes/cult(M), slot_shoes)
					M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/cultpack(M), slot_back)
					M.put_in_hands(new /obj/item/weapon/melee/cultblade(M))
				else if(ismonkey(M))
					var/mob/living/carbon/monkey/K = M
					K.visible_message("<span class='warning'> The rune disappears with a flash of red light, [K] now looks like the cutest of all followers of Nar-Sie...</span>", \
					"<span class='warning'>You are blinded by the flash of red light! After you're able to see again, you see that you are now wearing a set of armor. Might not offer much protection due to its size though.</span>")
					K.equip_to_slot_or_drop(new /obj/item/clothing/monkeyclothes/cultrobes, slot_w_uniform)
					K.equip_to_slot_or_drop(new /obj/item/clothing/head/culthood/alt, slot_head)
					K.equip_to_slot_or_drop(new /obj/item/weapon/storage/backpack/cultpack, slot_back)
					K.put_in_hands(new /obj/item/weapon/melee/cultblade(K))
				else if(isconstruct(M))
					var/construct_class
					if(universe.name == "Hell Rising")
						var/list/construct_types = list("Artificer", "Wraith", "Juggernaut", "Harvester")
						construct_class = input("Please choose which type of construct you wish [M] to become.", "Construct Transformation") in construct_types
						switch(construct_class)
							if("Juggernaut")
								var/mob/living/simple_animal/construct/armoured/C = new /mob/living/simple_animal/construct/armoured (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now a Juggernaut. Though slow, your shell can withstand extreme punishment, create temporary walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Wraith")
								var/mob/living/simple_animal/construct/wraith/C = new /mob/living/simple_animal/construct/wraith (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are a now Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Artificer")
								var/mob/living/simple_animal/construct/builder/C = new /mob/living/simple_animal/construct/builder (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now an Artificer. You are incredibly weak and fragile, but you are able to construct new floors and walls, to break some walls apart, to repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Harvester")
								var/mob/living/simple_animal/construct/harvester/C = new /mob/living/simple_animal/construct/harvester (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now an Harvester. You are as fast and powerful as Wraiths, but twice as durable.<br>No living (or dead) creature can hide from your eyes, and no door or wall shall place itself between you and your victims.<br>Your role consists of neutralizing any non-cultist living being in the area and transport them to Nar-Sie. To do so, place yourself above an incapacited target and use your \"Harvest\" spell.")
								ticker.mode.update_cult_icons_added(C.mind)
					else
						var/list/construct_types = list("Artificer", "Wraith", "Juggernaut")
						construct_class = input("Please choose which type of construct you wish [M] to become.", "Construct Transformation") in construct_types
						switch(construct_class)
							if("Juggernaut")
								var/mob/living/simple_animal/construct/armoured/C = new /mob/living/simple_animal/construct/armoured (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now a Juggernaut. Though slow, your shell can withstand extreme punishment, create temporary walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Wraith")
								var/mob/living/simple_animal/construct/wraith/C = new /mob/living/simple_animal/construct/wraith (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are a now Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
								ticker.mode.update_cult_icons_added(C.mind)
							if("Artificer")
								var/mob/living/simple_animal/construct/builder/C = new /mob/living/simple_animal/construct/builder (get_turf(src.loc))
								M.mind.transfer_to(C)
								qdel(M)
								M = null
								to_chat(C, "<B>You are now an Artificer. You are incredibly weak and fragile, but you are able to construct new floors and walls, to break some walls apart, to repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>")
								ticker.mode.update_cult_icons_added(C.mind)
				qdel(src)
				return
			else
				to_chat(usr, "<span class='warning'>Only the followers of Nar-Sie may be given their armor.</span>")
				to_chat(M, "<span class='warning'>Only the followers of Nar-Sie may be given their armor.</span>")
	to_chat(user, "<span class='note'>You have to be standing on top of the rune.</span>")
	return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
