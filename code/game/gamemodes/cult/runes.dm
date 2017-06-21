GLOBAL_LIST_EMPTY(sacrificed) //a mixed list of minds and mobs
GLOBAL_LIST(rune_types) //Every rune that can be drawn by tomes
GLOBAL_LIST_EMPTY(teleport_runes)
GLOBAL_LIST_EMPTY(wall_runes)
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
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = LOW_OBJ_LAYER
	color = RUNE_COLOR_RED

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/req_cultists_text //if we have a description override for required cultists to invoke
	var/rune_in_use = FALSE // Used for some runes, this is for when you want a rune to not be usable when in use.

	var/scribe_delay = 50 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it

	var/allow_excess_invokers = FALSE //if we allow excess invokers when being invoked
	var/invoke_damage = 0 //how much damage invokers take when invoking it
	var/construct_invoke = TRUE //if constructs can invoke it

	var/req_keyword = 0 //If the rune requires a keyword - go figure amirite
	var/keyword //The actual keyword for the rune

/obj/effect/rune/Initialize(mapload, set_keyword)
	. = ..()
	if(set_keyword)
		keyword = set_keyword

/obj/effect/rune/examine(mob/user)
	..()
	if(iscultist(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		to_chat(user, "<b>Name:</b> [cultist_name]")
		to_chat(user, "<b>Effects:</b> [capitalize(cultist_desc)]")
		to_chat(user, "<b>Required Acolytes:</b> [req_cultists_text ? "[req_cultists_text]":"[req_cultists]"]")
		if(req_keyword && keyword)
			to_chat(user, "<b>Keyword:</b> [keyword]")

/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))
		to_chat(user, "<span class='notice'>You carefully erase the [lowertext(cultist_name)] rune.</span>")
		qdel(src)
	else if(istype(I, /obj/item/weapon/nullrod))
		user.say("BEGONE FOUL MAGIKS!!")
		to_chat(user, "<span class='danger'>You disrupt the magic of [src] with [I].</span>")
		qdel(src)

/obj/effect/rune/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>You aren't able to understand the words of [src].</span>")
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
			to_chat(M, "<span class='warning'>You are unable to invoke the rune!</span>")

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
		chanters += user
		invokers += user
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
				invokers += L
		if(invokers.len >= req_cultists)
			invokers -= user
			if(allow_excess_invokers)
				chanters += invokers
			else
				shuffle_inplace(invokers)
				for(var/i in 1 to req_cultists)
					var/L = pick_n_take(invokers)
					if(L)
						chanters += L
	return chanters

/obj/effect/rune/proc/invoke(var/list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	for(var/M in invokers)
		var/mob/living/L = M
		if(invocation)
			L.say(invocation, language = /datum/language/common)
		if(invoke_damage)
			L.apply_damage(invoke_damage, BRUTE)
			to_chat(L, "<span class='cultitalic'>[src] saps your strength!</span>")
	do_invoke_glow()

/obj/effect/rune/proc/do_invoke_glow()
	set waitfor = FALSE
	var/oldtransform = transform
	animate(src, transform = matrix()*2, alpha = 0, time = 5) //fade out
	sleep(5)
	animate(src, transform = oldtransform, alpha = 255, time = 0)

/obj/effect/rune/proc/fail_invoke()
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message("<span class='warning'>The markings pulse with a small flash of red light, then fall dark.</span>")
	var/oldcolor = color
	color = rgb(255, 0, 0)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 5)

//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "malformed rune"
	cultist_desc = "a senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"
	invoke_damage = 30

/obj/effect/rune/malformed/Initialize(mapload, set_keyword)
	. = ..()
	icon_state = "[rand(1,7)]"
	color = rgb(rand(0,255), rand(0,255), rand(0,255))

/obj/effect/rune/malformed/invoke(var/list/invokers)
	..()
	qdel(src)

/mob/proc/null_rod_check() //The null rod, if equipped, will protect the holder from the effects of most runes
	var/obj/item/weapon/nullrod/N = locate() in src
	if(N && !GLOB.ratvar_awakens) //If Nar-Sie or Ratvar are alive, null rods won't protect you
		return N
	return 0

/mob/proc/bible_check() //The bible, if held, might protect against certain things
	var/obj/item/weapon/storage/book/bible/B = locate() in src
	if(is_holding(B))
		return B
	return 0

//Rite of Binding: A paper on top of the rune to a talisman.
/obj/effect/rune/imbue
	cultist_name = "Create Talisman"
	cultist_desc = "transforms paper into powerful magic talismans."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "3"
	color = RUNE_COLOR_TALISMAN

/obj/effect/rune/imbue/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/papers_on_rune = checkpapers()
	var/entered_talisman_name
	var/obj/item/weapon/paper/talisman/talisman_type
	var/list/possible_talismans = list()
	if(!papers_on_rune.len)
		to_chat(user, "<span class='cultitalic'>There must be a blank paper on top of [src]!</span>")
		fail_invoke()
		log_game("Talisman Creation rune failed - no blank papers on rune")
		return
	if(rune_in_use)
		to_chat(user, "<span class='cultitalic'>[src] can only support one ritual at a time!</span>")
		fail_invoke()
		log_game("Talisman Creation rune failed - already in use")
		return

	for(var/I in subtypesof(/obj/item/weapon/paper/talisman) - /obj/item/weapon/paper/talisman/malformed - /obj/item/weapon/paper/talisman/supply - /obj/item/weapon/paper/talisman/supply/weak - /obj/item/weapon/paper/talisman/summon_tome)
		var/obj/item/weapon/paper/talisman/J = I
		var/talisman_cult_name = initial(J.cultist_name)
		if(talisman_cult_name)
			possible_talismans[talisman_cult_name] = J //This is to allow the menu to let cultists select talismans by name
	entered_talisman_name = input(user, "Choose a talisman to imbue.", "Talisman Choices") as null|anything in possible_talismans
	talisman_type = possible_talismans[entered_talisman_name]
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || rune_in_use || !talisman_type)
		return
	papers_on_rune = checkpapers()
	if(!papers_on_rune.len)
		to_chat(user, "<span class='cultitalic'>There must be a blank paper on top of [src]!</span>")
		fail_invoke()
		log_game("Talisman Creation rune failed - no blank papers on rune")
		return
	var/obj/item/weapon/paper/paper_to_imbue = papers_on_rune[1]
	..()
	visible_message("<span class='warning'>Dark power begins to channel into the paper!</span>")
	rune_in_use = TRUE
	if(do_after(user, initial(talisman_type.creation_time), target = paper_to_imbue))
		new talisman_type(get_turf(src))
		visible_message("<span class='warning'>[src] glows with power, and bloody images form themselves on [paper_to_imbue].</span>")
		qdel(paper_to_imbue)
	rune_in_use = FALSE

/obj/effect/rune/imbue/proc/checkpapers()
	. = list()
	for(var/obj/item/weapon/paper/P in get_turf(src))
		if(!P.info && !istype(P, /obj/item/weapon/paper/talisman))
			. |= P

/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "warps everything above it to another chosen teleport rune."
	invocation = "Sas'so c'arta forbici!"
	icon_state = "2"
	color = RUNE_COLOR_TELEPORT
	req_keyword = TRUE
	var/listkey

/obj/effect/rune/teleport/Initialize(mapload, set_keyword)
	. = ..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = set_keyword ? "[set_keyword] [locname]":"[locname]"
	GLOB.teleport_runes += src

/obj/effect/rune/teleport/Destroy()
	GLOB.teleport_runes -= src
	return ..()

/obj/effect/rune/teleport/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	for(var/R in GLOB.teleport_runes)
		var/obj/effect/rune/teleport/T = R
		if(T != src && (T.z <= ZLEVEL_SPACEMAX))
			potential_runes[avoid_assoc_duplicate_keys(T.listkey, teleportnames)] = T

	if(!potential_runes.len)
		to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
		log_game("Teleport rune failed - no other teleport runes")
		fail_invoke()
		return

	if(user.z > ZLEVEL_SPACEMAX)
		to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
		log_game("Teleport rune failed - user in away mission")
		fail_invoke()
		return

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || !actual_selected_rune)
		fail_invoke()
		return

	var/turf/T = get_turf(src)
	var/turf/target = get_turf(actual_selected_rune)
	if(is_blocked_turf(target, TRUE))
		to_chat(user, "<span class='warning'>The target rune is blocked. Attempting to teleport to it would be massively unwise.</span>")
		fail_invoke()
		return
	var/movedsomething = FALSE
	var/moveuserlater = FALSE
	for(var/atom/movable/A in T)
		if(A == user)
			moveuserlater = TRUE
			movedsomething = TRUE
			continue
		if(!A.anchored)
			movedsomething = TRUE
			A.forceMove(target)
	if(movedsomething)
		..()
		visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>", null, "<i>You hear a sharp crack.</i>")
		to_chat(user, "<span class='cult'>You[moveuserlater ? "r vision blurs, and you suddenly appear somewhere else":" send everything above the rune away"].</span>")
		if(moveuserlater)
			user.forceMove(target)
		target.visible_message("<span class='warning'>There is a boom of outrushing air as something appears above the rune!</span>", null, "<i>You hear a boom.</i>")
	else
		fail_invoke()


//Rite of Offering: Converts or sacrifices a target.
/obj/effect/rune/convert
	cultist_name = "Offer"
	cultist_desc = "offers a noncultist above it to Nar-Sie, either converting them or sacrificing them."
	req_cultists_text = "2 for conversion, 3 for living sacrifices and sacrifice targets."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = RUNE_COLOR_OFFER
	req_cultists = 1
	allow_excess_invokers = TRUE
	rune_in_use = FALSE

/obj/effect/rune/convert/do_invoke_glow()
	return

/obj/effect/rune/convert/invoke(var/list/invokers)
	if(rune_in_use)
		return
	var/list/myriad_targets = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(!iscultist(M))
			myriad_targets |= M
	if(!myriad_targets.len)
		fail_invoke()
		log_game("Offer rune failed - no eligible targets")
		return
	rune_in_use = TRUE
	visible_message("<span class='warning'>[src] pulses blood red!</span>")
	var/oldcolor = color
	color = RUNE_COLOR_DARKRED
	var/mob/living/L = pick(myriad_targets)
	var/is_clock = is_servant_of_ratvar(L)
	var/is_convertable = is_convertable_to_cult(L)
	if(L.stat != DEAD && (is_clock || is_convertable))
		invocation = "Mah'weyh pleggh at e'ntrath!"
		..()
		if(is_clock)
			L.visible_message("<span class='warning'>[L]'s eyes glow a defiant yellow!</span>", \
			"<span class='cultlarge'>\"Stop resisting. You <i>will</i> be mi-\"</span>\n\
			<span class='large_brass'>\"Give up and you will feel pain unlike anything you've ever felt!\"</span>")
			L.Knockdown(80)
		else if(is_convertable)
			do_convert(L, invokers)
	else
		invocation = "Barhah hra zar'garis!"
		..()
		do_sacrifice(L, invokers)
	animate(src, color = oldcolor, time = 5)
	addtimer(CALLBACK(src, /atom/proc/update_atom_colour), 5)
	rune_in_use = FALSE

/obj/effect/rune/convert/proc/do_convert(mob/living/convertee, list/invokers)
	if(invokers.len < 2)
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>You need more invokers to convert [convertee]!</span>")
		log_game("Offer rune failed - tried conversion with one invoker")
		return 0
	if(convertee.null_rod_check())
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>Something is shielding [convertee]'s mind!</span>")
		log_game("Offer rune failed - convertee had null rod")
		return 0
	var/brutedamage = convertee.getBruteLoss()
	var/burndamage = convertee.getFireLoss()
	if(brutedamage || burndamage)
		convertee.adjustBruteLoss(-(brutedamage * 0.75))
		convertee.adjustFireLoss(-(burndamage * 0.75))
	convertee.visible_message("<span class='warning'>[convertee] writhes in pain \
	[brutedamage || burndamage ? "even as [convertee.p_their()] wounds heal and close" : "as the markings below [convertee.p_them()] glow a bloody red"]!</span>", \
 	"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
	SSticker.mode.add_cultist(convertee.mind, 1)
	new /obj/item/weapon/tome(get_turf(src))
	convertee.mind.special_role = "Cultist"
	to_chat(convertee, "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
	and something evil takes root.</b></span>")
	to_chat(convertee, "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve the Geometer above all else. Bring it back.\
	</b></span>")
	return 1

/obj/effect/rune/convert/proc/do_sacrifice(mob/living/sacrificial, list/invokers)
	var/big_sac = FALSE
	if((((ishuman(sacrificial) || iscyborg(sacrificial)) && sacrificial.stat != DEAD) || is_sacrifice_target(sacrificial.mind)) && invokers.len < 3)
		for(var/M in invokers)
			to_chat(M, "<span class='cultitalic'>[sacrificial] is too greatly linked to the world! You need three acolytes!</span>")
		log_game("Offer rune failed - not enough acolytes and target is living or sac target")
		return FALSE
	if(sacrificial.mind)
		GLOB.sacrificed += sacrificial.mind
		if(is_sacrifice_target(sacrificial.mind))
			GLOB.sac_complete = TRUE
			big_sac = TRUE
	else
		GLOB.sacrificed += sacrificial

	new /obj/effect/temp_visual/cult/sac(get_turf(src))
	for(var/M in invokers)
		if(big_sac)
			to_chat(M, "<span class='cultlarge'>\"Yes! This is the one I desire! You have done well.\"</span>")
		else
			if(ishuman(sacrificial) || iscyborg(sacrificial))
				to_chat(M, "<span class='cultlarge'>\"I accept this sacrifice.\"</span>")
			else
				to_chat(M, "<span class='cultlarge'>\"I accept this meager sacrifice.\"</span>")

	var/obj/item/device/soulstone/stone = new /obj/item/device/soulstone(get_turf(src))
	if(sacrificial.mind)
		stone.invisibility = INVISIBILITY_MAXIMUM //so it's not picked up during transfer_soul()
		stone.transfer_soul("FORCE", sacrificial, usr)
		stone.invisibility = 0

	if(sacrificial)
		if(iscyborg(sacrificial))
			playsound(sacrificial, 'sound/magic/disable_tech.ogg', 100, 1)
			sacrificial.dust() //To prevent the MMI from remaining
		else
			playsound(sacrificial, 'sound/magic/disintegrate.ogg', 100, 1)
			sacrificial.gib()
	return TRUE

//Ritual of Dimensional Rending: Calls forth the avatar of Nar-Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Summon Nar-Sie"
	cultist_desc = "tears apart dimensional barriers, calling forth the Geometer. Requires 9 invokers."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_DARKRED
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	scribe_delay = 500 //how long the rune takes to create
	scribe_damage = 40.1 //how much damage you take doing it
	var/used = FALSE

/obj/effect/rune/narsie/Initialize(mapload, set_keyword)
	. = ..()
	GLOB.poi_list |= src

/obj/effect/rune/narsie/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/effect/rune/narsie/talismanhide() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/narsie/invoke(var/list/invokers)
	if(used)
		return
	if(z != ZLEVEL_STATION)
		return

	if(locate(/obj/singularity/narsie) in GLOB.poi_list)
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>Nar-Sie is already on this plane!</span>")
		log_game("Summon Nar-Sie rune failed - already summoned")
		return
	//BEGIN THE SUMMONING
	used = TRUE
	..()
	send_to_playing_players('sound/effects/dimensional_rend.ogg')
	var/turf/T = get_turf(src)
	sleep(40)
	if(src)
		color = RUNE_COLOR_RED
	SSticker.mode.eldergod = FALSE
	new /obj/singularity/narsie/large/cult(T) //Causes Nar-Sie to spawn even if the rune has been removed

/obj/effect/rune/narsie/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/weapon/tome) && iscultist(user)))
		user.visible_message("<span class='warning'>[user.name] begins erasing the [src]...</span>", "<span class='notice'>You begin erasing the [src]...</span>")
		if(do_after(user, 50, target = src))	//Prevents accidental erasures.
			log_game("Summon Narsie rune erased by [user.mind.key] (ckey) with a tome")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a tome")
			..()
	else
		if(istype(I, /obj/item/weapon/nullrod))	//Begone foul magiks. You cannot hinder me.
			log_game("Summon Narsie rune erased by [user.mind.key] (ckey) using a null rod")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a null rod")
			..()

//Rite of Resurrection: Requires the corpse of a cultist and that there have been less revives than the number of people GLOB.sacrificed
/obj/effect/rune/raise_dead
	cultist_name = "Resurrect Cultist"
	cultist_desc = "requires the corpse of a cultist placed upon the rune. Provided there have been sufficient sacrifices, they will be revived."
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!" //Depends on the name of the user - see below
	icon_state = "1"
	color = RUNE_COLOR_MEDIUMRED
	var/static/revives_used = 0

/obj/effect/rune/raise_dead/examine(mob/user)
	..()
	if(iscultist(user) || user.stat == DEAD)
		var/revive_number = LAZYLEN(GLOB.sacrificed) - revives_used
		to_chat(user, "<b>Revives Remaining:</b> [revive_number]")

/obj/effect/rune/raise_dead/invoke(var/list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_revive
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	rune_in_use = TRUE
	for(var/mob/living/M in T.contents)
		if(iscultist(M) && M.stat == DEAD)
			potential_revive_mobs |= M
	if(!potential_revive_mobs.len)
		to_chat(user, "<span class='cultitalic'>There are no dead cultists on the rune!</span>")
		log_game("Raise Dead rune failed - no corpses to revive")
		fail_invoke()
		rune_in_use = FALSE
		return
	if(LAZYLEN(GLOB.sacrificed) <= revives_used)
		to_chat(user, "<span class='warning'>You have sacrificed too few people to revive a cultist!</span>")
		fail_invoke()
		rune_in_use = FALSE
		return
	if(potential_revive_mobs.len > 1)
		mob_to_revive = input(user, "Choose a cultist to revive.", "Cultist to Revive") as null|anything in potential_revive_mobs
	else
		mob_to_revive = potential_revive_mobs[1]
	if(!src || QDELETED(src) || rune_in_use || !validness_checks(mob_to_revive, user))
		rune_in_use = FALSE
		return
	if(user.name == "Herbert West")
		invocation = "To life, to life, I bring them!"
	else
		invocation = initial(invocation)
	..()
	revives_used++
	mob_to_revive.revive(1, 1) //This does remove disabilities and such, but the rune might actually see some use because of it!
	mob_to_revive.grab_ghost()
	to_chat(mob_to_revive, "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>")
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from [mob_to_revive.p_their()] eyes.</span>", \
								  "<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = FALSE

/obj/effect/rune/raise_dead/proc/validness_checks(mob/living/target_mob, mob/living/user)
	var/turf/T = get_turf(src)
	if(QDELETED(user))
		return FALSE
	if(!Adjacent(user) || user.incapacitated())
		return FALSE
	if(QDELETED(target_mob))
		fail_invoke()
		return FALSE
	if(!(target_mob in T.contents))
		to_chat(user, "<span class='cultitalic'>The cultist to revive has been moved!</span>")
		fail_invoke()
		log_game("Raise Dead rune failed - revival target moved")
		return FALSE
	var/mob/dead/observer/ghost = target_mob.get_ghost(TRUE)
	if(!ghost && (!target_mob.mind || !target_mob.mind.active))
		to_chat(user, "<span class='cultitalic'>The corpse to revive has no spirit!</span>")
		fail_invoke()
		log_game("Raise Dead rune failed - revival target has no ghost")
		return FALSE
	if(!GLOB.sacrificed.len || GLOB.sacrificed.len <= revives_used)
		to_chat(user, "<span class='warning'>You have sacrificed too few people to revive a cultist!</span>")
		fail_invoke()
		log_game("Raise Dead rune failed - too few sacrificed")
		return FALSE
	return TRUE

/obj/effect/rune/raise_dead/fail_invoke()
	..()
	for(var/mob/living/M in range(1,src))
		if(iscultist(M) && M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")


//Rite of Disruption: Emits an EMP blast.
/obj/effect/rune/emp
	cultist_name = "Electromagnetic Disruption"
	cultist_desc = "emits a large electromagnetic pulse, increasing in size for each cultist invoking it, hindering electronics and disabling silicons."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	icon_state = "5"
	allow_excess_invokers = TRUE
	color = RUNE_COLOR_EMP

/obj/effect/rune/emp/invoke(var/list/invokers)
	var/turf/E = get_turf(src)
	..()
	visible_message("<span class='warning'>[src] glows blue for a moment before vanishing.</span>")
	switch(invokers.len)
		if(1 to 2)
			playsound(E, 'sound/items/welder2.ogg', 25, 1)
			for(var/M in invokers)
				to_chat(M, "<span class='warning'>You feel a minute vibration pass through you...</span>")
		if(3 to 6)
			playsound(E, 'sound/magic/disable_tech.ogg', 50, 1)
			for(var/M in invokers)
				to_chat(M, "<span class='danger'>Your hair stands on end as a shockwave emanates from the rune!</span>")
		if(7 to INFINITY)
			playsound(E, 'sound/magic/disable_tech.ogg', 100, 1)
			for(var/M in invokers)
				var/mob/living/L = M
				to_chat(L, "<span class='userdanger'>You chant in unison and a colossal burst of energy knocks you backward!</span>")
				L.Knockdown(40)
	qdel(src) //delete before pulsing because it's a delay reee
	empulse(E, 9*invokers.len, 12*invokers.len) // Scales now, from a single room to most of the station depending on # of chanters

//Rite of Spirit Sight: Separates one's spirit from their body. They will take damage while it is active.
/obj/effect/rune/spirit
	cultist_name = "Spirit Sight"
	cultist_desc = "severs the link between one's spirit and body. This effect is taxing and one's physical body will take damage while this is active."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	icon_state = "7"
	color = RUNE_COLOR_DARKRED
	rune_in_use = FALSE //One at a time, please!
	construct_invoke = FALSE
	var/mob/living/affecting = null

/obj/effect/rune/spirit/Destroy()
	affecting = null
	return ..()

/obj/effect/rune/spirit/examine(mob/user)
	..()
	if(affecting)
		to_chat(user, "<span class='cultitalic'>A translucent field encases [affecting] above the rune!</span>")

/obj/effect/rune/spirit/can_invoke(mob/living/user)
	if(rune_in_use)
		to_chat(user, "<span class='cultitalic'>[src] cannot support more than one body!</span>")
		log_game("Spirit Sight rune failed - more than one user")
		return list()
	var/turf/T = get_turf(src)
	if(!(user in T))
		to_chat(user, "<span class='cultitalic'>You must be standing on top of [src]!</span>")
		log_game("Spirit Sight rune failed - user not standing on rune")
		return list()
	return ..()

/obj/effect/rune/spirit/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	..()
	var/turf/T = get_turf(src)
	rune_in_use = TRUE
	affecting = user
	affecting.add_atom_colour(RUNE_COLOR_DARKRED, ADMIN_COLOUR_PRIORITY)
	affecting.visible_message("<span class='warning'>[affecting] freezes statue-still, glowing an unearthly red.</span>", \
						 "<span class='cult'>You see what lies beyond. All is revealed. While this is a wondrous experience, your physical form will waste away in this state. Hurry...</span>")
	affecting.ghostize(1)
	while(!QDELETED(affecting))
		affecting.apply_damage(0.1, BRUTE)
		if(!(affecting in T))
			user.visible_message("<span class='warning'>A spectral tendril wraps around [affecting] and pulls [affecting.p_them()] back to the rune!</span>")
			Beam(affecting, icon_state="drainbeam", time=2)
			affecting.forceMove(get_turf(src)) //NO ESCAPE :^)
		if(affecting.key)
			affecting.visible_message("<span class='warning'>[affecting] slowly relaxes, the glow around [affecting.p_them()] dimming.</span>", \
								 "<span class='danger'>You are re-united with your physical form. [src] releases its hold over you.</span>")
			affecting.remove_atom_colour(ADMIN_COLOUR_PRIORITY, RUNE_COLOR_DARKRED)
			affecting.Knockdown(60)
			break
		if(affecting.stat == UNCONSCIOUS)
			if(prob(1))
				var/mob/dead/observer/G = affecting.get_ghost()
				to_chat(G, "<span class='cultitalic'>You feel the link between you and your body weakening... you must hurry!</span>")
		else if(affecting.stat == DEAD)
			affecting.remove_atom_colour(ADMIN_COLOUR_PRIORITY, RUNE_COLOR_DARKRED)
			var/mob/dead/observer/G = affecting.get_ghost()
			to_chat(G, "<span class='cultitalic'><b>You suddenly feel your physical form pass on. [src]'s exertion has killed you!</b></span>")
			break
		sleep(1)
	affecting = null
	rune_in_use = FALSE

//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Form Barrier"
	cultist_desc = "when invoked, makes a temporary invisible wall to block passage. Can be invoked again to reverse this."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "1"
	color = RUNE_COLOR_MEDIUMRED
	CanAtmosPass = ATMOS_PASS_DENSITY
	var/density_timer
	var/recharging = FALSE

/obj/effect/rune/wall/Initialize(mapload, set_keyword)
	. = ..()
	GLOB.wall_runes += src

/obj/effect/rune/wall/examine(mob/user)
	..()
	if(density)
		to_chat(user, "<span class='cultitalic'>There is a barely perceptible shimmering of the air above [src].</span>")

/obj/effect/rune/wall/Destroy()
	density = 0
	GLOB.wall_runes -= src
	air_update_turf(1)
	return ..()

/obj/effect/rune/wall/BlockSuperconductivity()
	return density

/obj/effect/rune/wall/invoke(var/list/invokers)
	if(recharging)
		return
	var/mob/living/user = invokers[1]
	..()
	density = !density
	update_state()
	if(density)
		spread_density()
	var/carbon_user = iscarbon(user)
	user.visible_message("<span class='warning'>[user] [carbon_user ? "places [user.p_their()] hands on":"stares intently at"] [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cultitalic'>You channel [carbon_user ? "your life ":""]energy into [src], [density ? "temporarily preventing" : "allowing"] passage above it.</span>")
	if(carbon_user)
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick("l_arm", "r_arm"))

/obj/effect/rune/wall/proc/spread_density()
	for(var/R in GLOB.wall_runes)
		var/obj/effect/rune/wall/W = R
		if(W.z == z && get_dist(src, W) <= 2 && !W.density && !W.recharging)
			W.density = TRUE
			W.update_state()
			W.spread_density()
	density_timer = addtimer(CALLBACK(src, .proc/lose_density), 900, TIMER_STOPPABLE)

/obj/effect/rune/wall/proc/lose_density()
	if(density)
		recharging = TRUE
		density = FALSE
		update_state()
		var/oldcolor = color
		add_atom_colour("#696969", FIXED_COLOUR_PRIORITY)
		animate(src, color = oldcolor, time = 50, easing = EASE_IN)
		addtimer(CALLBACK(src, .proc/recharge), 50)

/obj/effect/rune/wall/proc/recharge()
	recharging = FALSE
	add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

/obj/effect/rune/wall/proc/update_state()
	deltimer(density_timer)
	air_update_turf(1)
	if(density)
		var/mutable_appearance/shimmer = mutable_appearance('icons/effects/effects.dmi', "barriershimmer", ABOVE_MOB_LAYER)
		shimmer.appearance_flags |= RESET_COLOR
		shimmer.alpha = 60
		shimmer.color = "#701414"
		add_overlay(shimmer)
		add_atom_colour(RUNE_COLOR_RED, FIXED_COLOUR_PRIORITY)
	else
		cut_overlays()
		add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Summon Cultist"
	cultist_desc = "summons a single cultist to the rune. Requires 2 invokers."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	invoke_damage = 10
	icon_state = "5"
	color = RUNE_COLOR_SUMMON

/obj/effect/rune/summon/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/cultists = list()
	for(var/datum/mind/M in SSticker.mode.cult)
		if(!(M.current in invokers) && M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_summon = input(user, "Who do you wish to call to [src]?", "Followers of the Geometer") as null|anything in cultists
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		to_chat(user, "<span class='cultitalic'>You require a summoning target!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.stat == DEAD)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] has died!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target died")
		return
	if(!iscultist(cultist_to_summon))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not a follower of the Geometer!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target was deconverted")
		return
	if(cultist_to_summon.z > ZLEVEL_SPACEMAX)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
									  "<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
	..()
	visible_message("<span class='warning'>A foggy shape materializes atop [src] and solidifes into [cultist_to_summon]!</span>")
	cultist_to_summon.forceMove(get_turf(src))
	qdel(src)

//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "boils the blood of non-believers who can see the rune, rapidly dealing extreme amounts of damage. Requires 3 invokers."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	color = RUNE_COLOR_MEDIUMRED
	light_color = LIGHT_COLOR_LAVA
	req_cultists = 3
	invoke_damage = 10
	construct_invoke = FALSE
	var/tick_damage = 25
	rune_in_use = FALSE

/obj/effect/rune/blood_boil/do_invoke_glow()
	return

/obj/effect/rune/blood_boil/invoke(var/list/invokers)
	if(rune_in_use)
		return
	..()
	rune_in_use = TRUE
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] turns a bright, glowing orange!</span>")
	color = "#FC9B54"
	set_light(6, 1, color)
	for(var/mob/living/L in viewers(T))
		if(!iscultist(L) && L.blood_volume)
			var/obj/item/weapon/nullrod/N = L.null_rod_check()
			if(N)
				to_chat(L, "<span class='userdanger'>\The [N] suddenly burns hotly before returning to normal!</span>")
				continue
			to_chat(L, "<span class='cultlarge'>Your blood boils in your veins!</span>")
			if(is_servant_of_ratvar(L))
				to_chat(L, "<span class='userdanger'>You feel an unholy darkness dimming the Justiciar's light!</span>")
	animate(src, color = "#FCB56D", time = 4)
	sleep(4)
	if(QDELETED(src))
		return
	do_area_burn(T, 0.5)
	animate(src, color = "#FFDF80", time = 5)
	sleep(5)
	if(QDELETED(src))
		return
	do_area_burn(T, 1)
	animate(src, color = "#FFFDF4", time = 6)
	sleep(6)
	if(QDELETED(src))
		return
	do_area_burn(T, 1.5)
	new /obj/effect/hotspot(T)
	qdel(src)

/obj/effect/rune/blood_boil/proc/do_area_burn(turf/T, multiplier)
	set_light(6, 1, color)
	for(var/mob/living/L in viewers(T))
		if(!iscultist(L) && L.blood_volume)
			var/obj/item/weapon/nullrod/N = L.null_rod_check()
			if(N)
				continue
			L.take_overall_damage(tick_damage*multiplier, tick_damage*multiplier)
			if(is_servant_of_ratvar(L))
				L.adjustStaminaLoss(tick_damage*0.5)

//Rite of Spectral Manifestation: Summons a ghost on top of the rune as a cultist human with no items. User must stand on the rune at all times, and takes damage for each summoned ghost.
/obj/effect/rune/manifest
	cultist_name = "Manifest Spirit"
	cultist_desc = "manifests a spirit as a servant of the Geometer. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "6"
	invoke_damage = 10
	construct_invoke = FALSE
	color = RUNE_COLOR_MEDIUMRED
	var/ghost_limit = 5
	var/ghosts = 0

/obj/effect/rune/manifest/Initialize()
	. = ..()
	notify_ghosts("Manifest rune created in [get_area(src)].", 'sound/effects/ghost2.ogg', source = src)

/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(!(user in get_turf(src)))
		to_chat(user, "<span class='cultitalic'>You must be standing on [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return list()
	if(user.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='cultitalic'>Ghosts can't summon more ghosts!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user is a ghost")
		return list()
	if(ghosts >= ghost_limit)
		to_chat(user, "<span class='cultitalic'>You are sustaining too many ghosts to summon more!</span>")
		fail_invoke()
		log_game("Manifest rune failed - too many summoned ghosts")
		return list()
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST))
			ghosts_on_rune |= O
	if(!ghosts_on_rune.len)
		to_chat(user, "<span class='cultitalic'>There are no spirits near [src]!</span>")
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
	new_human.equipOutfit(/datum/outfit/ghost_cultist) //give them armor
	new_human.apply_status_effect(STATUS_EFFECT_SUMMONEDGHOST) //ghosts can't summon more ghosts
	..()
	ghosts++
	playsound(src, 'sound/magic/exit_blood.ogg', 50, 1)
	visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a [new_human.gender == FEMALE ? "wo":""]man.</span>")
	to_chat(user, "<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>")
	var/turf/T = get_turf(src)
	var/obj/structure/emergency_shield/invoker/N = new(T)

	new_human.key = ghost_to_spawn.key
	SSticker.mode.add_cultist(new_human.mind, 0)
	to_chat(new_human, "<span class='cultitalic'><b>You are a servant of the Geometer. You have been made semi-corporeal by the cult of Nar-Sie, and you are to serve them at all costs.</b></span>")

	while(!QDELETED(src) && !QDELETED(user) && !QDELETED(new_human) && (user in T))
		if(user.stat || new_human.InCritical())
			break
		user.apply_damage(0.1, BRUTE)
		sleep(1)

	qdel(N)
	ghosts--
	if(new_human)
		new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>", \
								  "<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
		for(var/obj/I in new_human)
			new_human.dropItemToGround(I, TRUE)
		new_human.dust()
