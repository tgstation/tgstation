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
	var/cultist_desc = "A basic rune with no function." //This is shown to cultists who examine the rune in order to determine its true purpose.
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	unacidable = 1
	layer = TURF_LAYER + 0.08
	color = rgb(255,0,0)
	mouse_opacity = 2

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/rune_in_use = 0 // Used for some runes, this is for when you want a rune to not be usable when in use.

	var/req_pylons = 0
	var/req_forges = 0
	var/req_archives = 0
	var/req_altars = 0

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
		user << "<b>Effects:</b> [cultist_desc]"
		user << "<b>Required Acolytes:</b> [req_cultists]"
		if(req_keyword && keyword)
			user << "<b>Keyword:</b> [keyword]"

/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		user << "<span class='notice'>You carefully erase [src].</span>"
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
	if(can_invoke(user))
		invoke(user)
		var/oldtransform = transform
		animate(src, transform = matrix()*2, alpha = 0, time = 5) //fade out
		animate(transform = oldtransform, alpha = 255, time = 0)
	else
		fail_invoke(user)

/*

There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.

*/

/obj/effect/rune/proc/can_invoke(var/mob/living/user)
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	if(!structure_check(req_pylons, req_forges, req_archives, req_altars))
		return 0
	if(!keyword && req_keyword)
		return 0
	if(req_cultists <= 1)
		if(invocation)
			user.say(invocation)
		return 1
	else
		var/cultists_in_range = 0
		for(var/mob/living/L in range(1, src))
			if(iscultist(L))
				var/mob/living/carbon/human/H = L
				if(!istype(H))
					if(istype(L, /mob/living/simple_animal/hostile/construct))
						if(invocation)
							L.say(invocation)
						cultists_in_range++
					continue
				if(L.stat || (H.disabilities & MUTE) || H.silent)
					continue
				if(invocation)
					L.say(invocation)
				cultists_in_range++
		if(cultists_in_range >= req_cultists)
			return 1
		else
			return 0

/obj/effect/rune/proc/invoke(var/mob/living/user)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.

/obj/effect/rune/proc/fail_invoke(var/mob/living/user)
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message("<span class='warning'>The markings pulse with a small flash of red light, then fall dark.</span>")

/obj/effect/rune/proc/structure_check(var/rpylons, var/rforges, var/rarchives, var/raltars)
	var/pylons = 0
	var/forges = 0
	var/archives = 0
	var/altars = 0
	for(var/obj/structure/cult/pylon in orange(3,src))
		pylons++
	for(var/obj/structure/cult/forge in orange(3,src))
		forges++
	for(var/obj/structure/cult/tome in orange(3,src))
		archives++
	for(var/obj/structure/cult/talisman in orange(3,src))
		altars++
	if(pylons >= rpylons && forges >= rforges && archives >= rarchives && altars >= raltars)
		return 1
	return 0


//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "malformed rune"
	cultist_desc = "A senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"

/obj/effect/rune/malformed/New()
	..()
	icon_state = "[rand(1,6)]"
	color = rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/effect/rune/malformed/invoke(mob/living/user)
	user << "<span class='cultitalic'><b>You feel your life force draining. The Geometer is displeased.</b></span>"
	user.apply_damage(30, BRUTE)
	qdel(src)

/mob/proc/null_rod_check() //The null rod, if equipped, will protect the holder from the effects of most runes
	var/obj/item/weapon/nullrod/N = locate() in src
	if(N)
		return N
	return 0

//Rite of Binding: Turns a nearby rune and a paper on top of the rune to a talisman, if both are valid.
/obj/effect/rune/imbue
	cultist_name = "Create Talisman"
	cultist_desc = "Transforms paper into powerful magic talismans."
	invocation = null //no talisman made, no invocation.
	icon_state = "3"
	color = rgb(0, 0, 255)

/obj/effect/rune/imbue/invoke(mob/living/user)
	var/turf/T = get_turf(src)
	var/list/papers_on_rune = list()
	var/entered_talisman_name
	var/obj/item/weapon/paper/talisman/talisman_type
	var/list/possible_talismans = list()
	for(var/obj/item/weapon/paper/P in T)
		if(!P.info)
			papers_on_rune.Add(P)
	if(!papers_on_rune.len)
		user << "<span class='cultitalic'>There must be a blank paper on top of [src]!</span>"
		fail_invoke()
		log_game("Talisman Imbue rune failed - no blank papers on rune")
		return
	if(rune_in_use)
		user << "<span class='cultitalic'>[src] can only support one ritual at a time!</span>"
		fail_invoke()
		log_game("Talisman Imbue rune failed - more than one user")
		return
	var/obj/item/weapon/paper/paper_to_imbue = pick(papers_on_rune)
	for(var/I in subtypesof(/obj/item/weapon/paper/talisman) - /obj/item/weapon/paper/talisman/malformed - /obj/item/weapon/paper/talisman/supply)
		var/obj/item/weapon/paper/talisman/J = I
		var/talisman_cult_name = initial(J.cultist_name)
		if(talisman_cult_name)
			possible_talismans[talisman_cult_name] = J //This is to allow the menu to let cultists select talismans by name
	entered_talisman_name = input(user, "Choose a talisman to imbue.", "Talisman Choices") as null|anything in possible_talismans
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	talisman_type = possible_talismans[entered_talisman_name]
	user.say("H'drak v'loso, mir'kanas verbot!")
	visible_message("<span class='warning'>Dark power begins to channel into the paper!.</span>")
	rune_in_use = 1
	if(!do_after(user, 100, target = get_turf(user)))
		rune_in_use = 0
		return
	new talisman_type(get_turf(src))
	visible_message("<span class='warning'>[src] glows with power, and bloody images form themselves on [paper_to_imbue].</span>")
	qdel(paper_to_imbue)
	rune_in_use = 0

var/list/teleport_runes = list()
/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "Warps everything above it to another chosen teleport rune."
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

/obj/effect/rune/teleport/invoke(mob/living/user)
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
	var/turf/UT = get_turf(user)
	var/movedsomething = 0
	for(var/atom/movable/A in T)
		if(!A.anchored)
			movedsomething = 1
			A.forceMove(get_turf(actual_selected_rune))
	if(movedsomething)
		visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>")
		user << "<span class='cult'>You[user.loc == UT ? " send everything above the rune away":"r vision blurs, and you suddenly appear somewhere else"].</span>"
	else
		fail_invoke()


//Rite of Enlightenment: Converts a normal crewmember to the cult. Faster for every cultist nearby.
/obj/effect/rune/convert
	cultist_name = "Convert"
	cultist_desc = "Converts a normal crewmember on top of it to the cult. Does not work on loyalty-implanted crew."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = rgb(255, 0, 0)
	req_cultists = 2

/obj/effect/rune/convert/invoke(mob/living/user)
	var/list/convertees = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T.contents)
		if(!iscultist(M) && !isloyal(M))
			convertees.Add(M)
	if(!convertees.len)
		fail_invoke()
		log_game("Convert rune failed - no eligible convertees")
		return
	var/mob/living/new_cultist = pick(convertees)
	if(!is_convertable_to_cult(new_cultist.mind) || new_cultist.null_rod_check())
		user << "<span class='warning'>Something is shielding [new_cultist]'s mind!</span>"
		fail_invoke()
		log_game("Convert rune failed - convertee could not be converted")
		if(is_sacrifice_target(new_cultist.mind))
			for(var/mob/living/M in orange(1,src))
				if(iscultist(M))
					M << "<span class='cultlarge'>\"I desire this one for myself. <i>SACRIFICE THEM!</i>\"</span>"
		return
	new_cultist.visible_message("<span class='warning'>[new_cultist] writhes in pain as the markings below them glow a bloody red!</span>", \
					  			"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
	ticker.mode.add_cultist(new_cultist.mind)
	new /obj/item/weapon/tome(get_turf(src))
	new_cultist.mind.special_role = "Cultist"
	new_cultist << "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
	and something evil takes root.</b></span>"
	new_cultist << "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve the Geometer above all else. Bring it back.\
	</b></span>"

//Rite of Tribute: Sacrifices a crew member to Nar-Sie. Places them into a soul shard if they're in their body.
/obj/effect/rune/sacrifice
	cultist_name = "Sacrifice"
	cultist_desc = "Sacrifices a crew member to the Geometer. May place them into a soul shard if their spirit remains in their body."
	icon_state = "3"
	invocation = "Barhah hra zar'garis!"
	color = rgb(255, 255, 255)
	rune_in_use = 0

/obj/effect/rune/sacrifice/New()
	..()
	icon_state = "[rand(1,6)]"

/obj/effect/rune/sacrifice/invoke(mob/living/user)
	if(rune_in_use)
		return
	rune_in_use = 1
	var/turf/T = get_turf(src)
	var/list/possible_targets = list()
	for(var/mob/living/M in T.contents)
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
		var/cultists_nearby = 1
		for(var/mob/living/M in range(1,src))
			if(iscultist(M) && M != user)
				cultists_nearby++
				M.say(invocation)
		if(cultists_nearby < 3)
			user << "<span class='cultitalic'>[offering] is too greatly linked to the world! You need three acolytes!</span>"
			fail_invoke()
			log_game("Sacrifice rune failed - not enough acolytes and target is living")
			rune_in_use = 0
			return
	visible_message("<span class='warning'>[src] pulses blood red!</span>")
	color = rgb(126, 23, 23)
	spawn(5)
		color = initial(color)
	sac(offering)

/obj/effect/rune/sacrifice/proc/sac(mob/living/T)
	var/sacrifice_fulfilled
	if(T)
		if(istype(T, /mob/living/simple_animal/pet/dog))
			for(var/mob/living/carbon/C in range(3,src))
				if(iscultist(C))
					C << "<span class='cultlarge'>\"Even I have standards, such as they are!\"</span>"
					if(C.reagents)
						C.reagents.add_reagent("hell_water", 2)
		if(T.mind)
			sacrificed.Add(T.mind)
			if(is_sacrifice_target(T.mind))
				sacrifice_fulfilled = 1
		PoolOrNew(/obj/effect/overlay/temp/cult/sac, src.loc)
		for(var/mob/living/M in range(3,src))
			if(iscultist(M))
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
	cultist_desc = "Tears apart dimensional barriers, calling forth the avatar of the Geometer."
	invocation = null
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	var/used

/obj/effect/rune/narsie/invoke(mob/living/user)
	if(used)
		return
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/cult_mode = ticker.mode
		if(!("eldergod" in cult_mode.cult_objectives))
			message_admins("[usr.real_name]([user.ckey]) tried to summon Nar-Sie when the objective was wrong")
			for(var/mob/living/M in range(1,src))
				if(iscultist(M))
					M << "<span class='cultlarge'><i>\"YOUR SOUL BURNS WITH YOUR ARROGANCE!!!\"</i></span>"
					if(M.reagents)
						M.reagents.add_reagent("hell_water", 10)
					M.Weaken(7)
					M.Stun(7)
			fail_invoke()
			log_game("Summon Nar-Sie rune failed - improper objective")
			return
		else
			if(cult_mode.sacrifice_target && !(cult_mode.sacrifice_target in sacrificed))
				for(var/mob/living/M in orange(1,src))
					if(iscultist(M))
						M << "<span class='warning'>The sacrifice is not complete. The portal lacks the power to open!</span>"
				fail_invoke()
				log_game("Summon Nar-Sie rune failed - sacrifice not complete")
				return
		if(!cult_mode.eldergod)
			for(var/mob/living/M in orange(1,src))
				if(iscultist(M))
					M << "<span class='warning'>The avatar of Nar-Sie is already on this plane!</span>"
				log_game("Summon Nar-Sie rune failed - already summoned")
				return
		//BEGIN THE SUMMONING
		used = 1
		for(var/mob/living/M in range(1,src))
			if(iscultist(M))
				M.say("TOK-LYR RQA-NAP G'OLT-ULOFT!!")
		world << 'sound/effects/dimensional_rend.ogg'
		world << "<span class='cultitalic'><b>The veil... <span class='big'>is...</span> <span class='reallybig'>TORN!!!--</span></b></span>"
		sleep(40)
		new /obj/singularity/narsie/large(get_turf(user)) //Causes Nar-Sie to spawn even if the rune has been removed
		cult_mode.eldergod = 0
	else
		fail_invoke()
		log_game("Summon Nar-Sie rune failed - gametype is not cult")
		return

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
	cultist_desc = "Requires two corpses. One on the rune and one adjacent to the rune. The one placed upon the rune is brought to life, the other is turned to ash."
	invocation = null //Depends on the name of the user - see below
	icon_state = "1"
	color = rgb(255, 0, 0)

/obj/effect/rune/raise_dead/invoke(mob/living/user)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_sacrifice
	var/mob/living/mob_to_revive
	var/list/potential_sacrifice_mobs = list()
	var/list/potential_revive_mobs = list()
	if(rune_in_use)
		return
	for(var/mob/living/M in orange(1,src))
		if(!(M in T.contents) && M.stat == DEAD)
			potential_sacrifice_mobs.Add(M)
	if(!potential_sacrifice_mobs.len)
		user << "<span class='cultitalic'>There are no eligible sacrifices nearby!</span>"
		log_game("Raise Dead rune failed - no catalyst corpse")
		return
	mob_to_sacrifice = input(user, "Choose a corpse to sacrifice.", "Corpse to Sacrifice") as null|anything in potential_sacrifice_mobs
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated() || !mob_to_revive || !mob_to_sacrifice)
		return
	for(var/mob/living/M in T.contents)
		if(M.stat == DEAD)
			potential_revive_mobs.Add(M)
	if(rune_in_use)
		return
	if(!potential_revive_mobs.len)
		user << "<span class='cultitalic'>There is no eligible revival target on the rune!</span>"
		log_game("Raise Dead rune failed - no corpse to revived")
		return
	mob_to_revive = input(user, "Choose a corpse to revive.", "Corpse to Revive") as null|anything in potential_revive_mobs
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	revive(mob_to_revive, mob_to_sacrifice, user, T)

	//Begin revival
/obj/effect/rune/raise_dead/proc/revive(mob/living/mob_to_revive, mob/living/mob_to_sacrifice, mob/living/user, turf/T)
	if(rune_in_use)
		return
	if(!in_range(mob_to_sacrifice,src))
		user << "<span class='cultitalic'>The sacrificial target has been moved!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - catalyst corpse moved")
		return
	if(!(mob_to_revive in T.contents))
		user << "<span class='cultitalic'>The corpse to revive has been moved!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - revival target moved")
		return
	if(mob_to_sacrifice.stat != DEAD)
		user << "<span class='cultitalic'>The sacrificial target must be dead!</span>"
		fail_invoke()
		log_game("Raise Dead rune failed - catalyst corpse is not dead")
		return
	rune_in_use = 1
	if(user.name == "Herbert West")
		user.say("To life, to life, I bring them!")
	else
		user.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice]'s body rises into the air, connected to [mob_to_revive] by a glowing tendril!</span>")
	mob_to_revive.Beam(mob_to_sacrifice,icon_state="sendbeam",icon='icons/effects/effects.dmi',time=20)
	sleep(20)
	if(!mob_to_sacrifice || !in_range(mob_to_sacrifice, src))
		mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice] disintegrates into a pile of bones</span>")
		return
	mob_to_sacrifice.dust()
	if(!mob_to_revive || mob_to_revive.stat != DEAD)
		visible_message("<span class='warning'>The glowing tendril snaps against the rune with a shocking crack.</span>")
		rune_in_use = 0
		return
	mob_to_revive.revive() //This does remove disabilities and such, but the rune might actually see some use because of it!
	mob_to_revive << "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>"
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from their eyes.</span>", \
								  "<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = 0


/obj/effect/rune/raise_dead/fail_invoke()
	for(var/mob/living/M in orange(1,src))
		if(M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")


//Rite of Disruption: Emits an EMP blast.
/obj/effect/rune/emp
	cultist_name = "Electromagnetic Disruption"
	cultist_desc = "Emits a large electromagnetic pulse, hindering electronics and disabling silicons."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	icon_state = "5"
	color = rgb(77, 148, 255)

/obj/effect/rune/emp/invoke(mob/living/user)
	var/turf/E = get_turf(src)
	var/emp_strength = 0
	for(var/mob/living/L in range(1, src))
		if(iscultist(L))
			var/mob/living/carbon/human/H = L
			if(!istype(H))
				if(istype(L, /mob/living/simple_animal/hostile/construct))
					if(invocation)
						L.say(invocation)
					emp_strength++
					continue
			if(L.stat || (H.disabilities & MUTE) || H.silent)
				continue
			emp_strength++
	visible_message("<span class='warning'>[src] glows blue for a moment before vanishing.</span>")
	for(var/mob/living/carbon/C in range(1,src))
		switch(emp_strength)
			if(1 to 2)
				C << "<span class='warning'>You feel a minute vibration pass through you...</span>"
				playsound(E, 'sound/items/Welder2.ogg', 25, 1)
			if(3 to 6)
				C << "<span class='danger'>Your hair stands on end as a shockwave eminates from the rune!</span>"
				playsound(E, 'sound/magic/Disable_Tech.ogg', 50, 1)
			if(7 to INFINITY)
				C << "<span class=userdanger'>You chant in unison and a colossal burst of energy knocks you backward!</span>"
				playsound(E, 'sound/magic/Disable_Tech.ogg', 100, 1)
				C.Weaken(2)
	qdel(src) //delete before pulsing because it's a delay reee
	empulse(E, 9*emp_strength, 12*emp_strength) // Scales now, from a single room to most of the station depending on # of chanters

//Rite of Astral Communion: Separates one's spirit from their body. They will take damage while it is active.
/obj/effect/rune/astral
	cultist_name = "Astral Communion"
	cultist_desc = "Severs the link between one's spirit and body. This effect is taxing and one's physical body will take damage while this is active."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	icon_state = "6"
	color = rgb(126, 23, 23)
	rune_in_use = 0 //One at a time, please!
	var/mob/living/affecting = null

/obj/effect/rune/astral/examine(mob/user)
	..()
	if(affecting)
		user << "<span class='cultitalic'>A translucent field encases [user] above the rune!</span>"

/obj/effect/rune/astral/invoke(mob/living/user)
	if(rune_in_use)
		user << "<span class='cultitalic'>[src] cannot support more than one body!</span>"
		fail_invoke()
		log_game("Astral Communion rune failed - more than one user")
		return
	var/turf/T = get_turf(src)
	if(!user in T.contents)
		user << "<span class='cultitalic'>You must be standing on top of [src]!</span>"
		fail_invoke()
		log_game("Astral Communion rune failed - user not standing on rune")
		return
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
	cultist_desc = "When invoked, makes an invisible wall to block passage. Can be invoked again to reverse this."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "1"
	color = rgb(255, 0, 0)

/obj/effect/rune/wall/examine(mob/user)
	..()
	if(density)
		user << "<span class='cultitalic'>There is a barely perceptible shimmering of the air above [src].</span>"

/obj/effect/rune/wall/invoke(mob/living/user)
	density = !density
	user.visible_message("<span class='warning'>[user] places their hands on [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cultitalic'>You channel your life energy into [src], [density ? "preventing" : "allowing"] passage above it.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick("l_arm", "r_arm"))


//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Summon Cultist"
	cultist_desc = "Summons a single cultist to the rune."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	icon_state = "5"
	color = rgb(0, 255, 0)

/obj/effect/rune/summon/invoke(mob/living/user)
	var/list/cultists = list()
	for(var/datum/mind/M in ticker.mode.cult)
		cultists.Add(M.current)
	var/mob/living/cultist_to_summon = input("Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in (cultists - user)
	if(!Adjacent(user) || !src || qdeleted(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		user << "<span class='cultitalic'>You require a summoning target!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(!iscultist(cultist_to_summon))
		user << "<span class='cultitalic'>[cultist_to_summon] is not a follower of the Geometer!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.z > ZLEVEL_SPACEMAX)
		user << "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>"
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	if(cultist_to_summon.buckled)
		cultist_to_summon.buckled.unbuckle_mob(cultist_to_summon,force=1)
	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
									  "<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
	visible_message("<span class='warning'>A foggy shape materializes atop [src] and solidifes into [cultist_to_summon]!</span>")
	user.apply_damage(10, BRUTE, "head")
	cultist_to_summon.forceMove(get_turf(src))
	qdel(src)

//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "Boils the blood of non-believers who can see the rune, dealing extreme amounts of damage. Requires 3 chanters."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	color = rgb(255, 0, 0)
	req_cultists = 3

/obj/effect/rune/blood_boil/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] briefly bubbles before exploding!</span>")
	for(var/mob/living/carbon/C in viewers(src))
		if(!iscultist(C))
			var/obj/item/weapon/nullrod/N = C.null_rod_check()
			if(N)
				C << "<span class='userdanger'>\The [N] suddenly burns hotly before returning to normal!</span>"
				continue
			C << "<span class='cultlarge'>Your blood boils in your veins!</span>"
			C.take_overall_damage(45,45)
			C.Stun(7)
	for(var/mob/living/carbon/M in range(1,src))
		if(iscultist(M))
			M.apply_damage(15, BRUTE, pick("l_arm", "r_arm"))
			M << "<span class='cultitalic'>[src] saps your strength!</span>"
	explosion(get_turf(src), -1, 0, 1, 5)
	qdel(src)


//Rite of Spectral Manifestation: Summons a ghost on top of the rune as a cultist human with no items. User must stand on the rune at all times, and takes damage for each summoned ghost.
/obj/effect/rune/manifest
	cultist_name = "Manifest Spirit"
	cultist_desc = "Manifests a spirit as a servant of the Geometer. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "6"
	color = rgb(255, 0, 0)

/obj/effect/rune/manifest/New(loc)
	..()
	notify_ghosts("Manifest rune created in [get_area(src)].", 'sound/effects/ghost2.ogg', source = src)

/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(!(user in get_turf(src)))
		user << "<span class='cultitalic'>You must be standing on [src]!</span>"
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return 0
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	if(!ghosts_on_rune.len)
		user << "<span class='cultitalic'>There are no spirits near [src]!</span>"
		fail_invoke()
		log_game("Manifest rune failed - no nearby ghosts")
		return 0
	return ..()

/obj/effect/rune/manifest/invoke(mob/living/user)
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
	var/mob/living/carbon/human/new_human = new(get_turf(src))
	new_human.real_name = ghost_to_spawn.real_name
	new_human.alpha = 150 //Makes them translucent
	visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a man.</span>")
	user << "<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>"
	var/obj/machinery/shield/N = new(get_turf(src))
	N.name = "Invoker's Shield"
	N.desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals"
	N.color = "red"
	N.health = 20
	N.mouse_opacity = 0
	new_human.key = ghost_to_spawn.key
	ticker.mode.add_cultist(new_human.mind)
	new_human << "<span class='cultitalic'><b>You are a servant of the Geometer. You have been made semi-corporeal by the cult of Nar-Sie, and you are to serve them at all costs.</b></span>"

	while(user in get_turf(src))
		if(user.stat)
			break
		user.apply_damage(1, BRUTE)
		sleep(30)

	qdel(N)
	if(new_human)
		new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>", \
								  "<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
		for(var/obj/I in new_human)
			new_human.unEquip(I)
		new_human.dust()
/*
//Rite of Dimensional Corruption: Stops time around the rune for all non-cultists.
/obj/effect/rune/timestop
	cultist_name = "Time Stop"
	cultist_desc = "Stops time around the rune for all non-cultists. Requires 3 chanters."
	invocation = "T'ak ot'marzah oahr'du!"
	icon_state = "2"
	color = rgb(0, 0, 255)
	req_cultists = 3

/obj/effect/rune/timestop/invoke(mob/living/user)
	visible_message("<span class='warning'>[src] flares up for a moment, and then disappears into itself!</span>")
	new /obj/effect/timestop/cult(get_turf(src))
	for(var/mob/living/carbon/M in range(1,src))
		if(iscultist(M))
			M.apply_damage(20, BRUTE, "chest")
			M << "<span class='cultitalic'>[src] temporarily stops your heart from beating!</span>"
	qdel(src)

/obj/effect/timestop/cult
	name = "Dimensional Corruption"
	desc = "Something not from this world has corrupted the spacetime continuum in this exact spot."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "rune_large"
	pixel_x = -32
	pixel_y = -32
	duration = 50
	alpha = 0
	color = rgb(255, 0, 0)

/obj/effect/timestop/cult/timestop()
	animate(src, alpha = 255, time = 5, loop = -1)
	SpinAnimation(speed = 5)
	for(var/mob/living/M in player_list)
		if(iscultist(M) || M.null_rod_check())
			immune |= M
	..()
*/
