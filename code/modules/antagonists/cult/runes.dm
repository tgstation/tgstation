/obj/effect/rune
	name = "rune"
	var/cultist_name = "basic rune"
	desc = "An odd collection of symbols drawn in what seems to be blood."
	var/cultist_desc = "a basic rune with no function." //This is shown to cultists who examine the rune in order to determine its true purpose.
	anchored = TRUE
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	layer = SIGIL_LAYER
	color = RUNE_COLOR_RED

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/req_cultists_text //if we have a description override for required cultists to invoke
	var/rune_in_use = FALSE // Used for some runes, this is for when you want a rune to not be usable when in use.

	var/scribe_delay = 40 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it
	var/invoke_damage = 0 //how much damage invokers take when invoking it
	var/construct_invoke = TRUE //if constructs can invoke it

	var/req_keyword = 0 //If the rune requires a keyword - go figure amirite
	var/keyword //The actual keyword for the rune

/obj/effect/rune/Initialize(mapload, set_keyword)
	. = ..()
	if(set_keyword)
		keyword = set_keyword
	var/image/I = image(icon = 'icons/effects/blood.dmi', icon_state = null, loc = src)
	I.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_runes", I)

/obj/effect/rune/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		. += "<b>Name:</b> [cultist_name]\n"+\
		"<b>Effects:</b> [capitalize(cultist_desc)]\n"+\
		"<b>Required Acolytes:</b> [req_cultists_text ? "[req_cultists_text]":"[req_cultists]"]"
		if(req_keyword && keyword)
			. += "<b>Keyword:</b> [keyword]"

/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/nullrod))
		if(do_after(user, 100, target = src))
			user.say("BEGONE FOUL MAGIKS!!", forced = "nullrod")
			to_chat(user, "<span class='danger'>You disrupt the magic of [src] with [I].</span>")
			log_game("[src] erased by [key_name(user)] using a null rod")
			message_admins("[ADMIN_LOOKUPFLW(user)] erased a [src] with a null rod")
			qdel(src)

/obj/effect/rune/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>You aren't able to understand the words of [src].</span>")
		return
	var/list/invokers = can_invoke(user)
	if(invokers.len >= req_cultists)
		invoke(invokers)
	else
		to_chat(user, "<span class='danger'>You need [req_cultists - invokers.len] more adjacent cultists to use this rune in such a manner.</span>")
		fail_invoke()

/obj/effect/rune/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/shade) || istype(M, /mob/living/simple_animal/hostile/construct))
		if(istype(M, /mob/living/simple_animal/hostile/construct/wraith/angelic) || istype(M, /mob/living/simple_animal/hostile/construct/armored/angelic) || istype(M, /mob/living/simple_animal/hostile/construct/builder/angelic))
			to_chat(M, "<span class='warning'>You purge the rune!</span>")
			qdel(src)
		else if(construct_invoke || !iscultist(M)) //if you're not a cult construct we want the normal fail message
			attack_hand(M)
		else
			to_chat(M, "<span class='warning'>You are unable to invoke the rune!</span>")
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
	if(user)
		invokers += user
	if(req_cultists > 1)
		var/list/things_in_range = range(1, src)
		for(var/mob/living/L in things_in_range)
			if(iscultist(L))
				if(L == user)
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if((HAS_TRAIT(H, TRAIT_MUTE)) || H.silent)
						continue
				if(L.stat)
					continue
				invokers += L
	return invokers

/obj/effect/rune/proc/invoke(var/list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	for(var/M in invokers)
		if(isliving(M))
			var/mob/living/L = M
			if(invocation)
				L.say(invocation, language = /datum/language/common, ignore_spam = TRUE, forced = "cult invocation")
			if(invoke_damage)
				L.apply_damage(invoke_damage, BRUTE)
				to_chat(L, "<span class='cult italic'>[src] saps your strength!</span>")
		else if(istype(M, /obj/item/toy/plush/narplush))
			var/obj/item/toy/plush/narplush/P = M
			P.visible_message("<span class='cult italic'>[P] squeaks loudly!</span>")
	do_invoke_glow()

/obj/effect/rune/proc/do_invoke_glow()
	set waitfor = FALSE
	animate(src, transform = matrix()*2, alpha = 0, time = 5, flags = ANIMATION_END_NOW) //fade out
	sleep(5)
	animate(src, transform = matrix(), alpha = 255, time = 0, flags = ANIMATION_END_NOW)

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

//Ritual of Dimensional Rending: Calls forth the avatar of Nar'Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Nar'Sie"
	cultist_desc = "tears apart dimensional barriers, calling forth the Geometer. Repeatedly invoke the rune to call upon your god!"
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 1
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_DARKRED
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	scribe_delay = 500 //how long the rune takes to create
	scribe_damage = 40.1 //how much damage you take doing it
	light_range = 7
	light_color = "#FF0000"
	light_power = 0
	var/light_power_off = 0
	var/light_power_on = 5
	var/active = FALSE //if summoning has started
	var/used = FALSE //if has been invoked recently
	var/invocation_charges = 0
	var/summon_charges = 100 //time to summon: 200s with 1 cultist, to a minimum of 60s with 9 or more cultists
	var/list/random_chants = list(
		"sha", "mir", "sas", "mah", "hra", "zar", "tok", "lyr", "nqa", "nap", "olt", "val",
		"yam", "qha", "fel", "det", "fwe", "mah", "erl", "ath", "yro", "eth", "gal", "mud",
		"gib", "bar", "tea", "fuu", "jin", "kla", "atu", "kal", "lig",
		"yoka", "drak", "loso", "arta", "weyh", "ines", "toth", "fara", "amar", "nyag", "eske", "reth", "dedo", "btoh", "nikt", "neth", "abis"
	)
	var/invoke_sound = 'sound/magic/clockwork/narsie_attack.ogg'
	var/cooldown_sound = 'sound/magic/enter_blood.ogg'

/obj/effect/rune/narsie/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD)
		. += "<b>Invocation Power:</b> [invocation_charges] out of [summon_charges]"

/obj/effect/rune/narsie/Initialize(mapload, set_keyword)
	. = ..()
	GLOB.poi_list |= src

/obj/effect/rune/narsie/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/effect/rune/narsie/proc/reallow_invocation(turf)
	used = FALSE
	playsound(turf, cooldown_sound, 100)
	light_power = light_power_off
	update_light()

/obj/effect/rune/narsie/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	if(!is_station_level(z)) //Needed to prevent lavaland ruin with narsie rune from ending the round
		to_chat(user, "<span class='cultlarge'>You must summon me to the station.</span>")
		return
	if(used)
		to_chat(user, "<span class='cultitalic'>The rune has been invoked recently, try again soon!</span>")
		return
	if(active)
		var/nearby_cultists = 0
		var/selected_chant = pick(random_chants)
		for(var/mob/M in view_or_range(distance = 2, center = src, type = "range"))
			if(M.mind)
				if(M.mind.has_antag_datum(/datum/antagonist/cult, TRUE) && M.stat == CONSCIOUS)
					nearby_cultists += 1
					M.say("[selected_chant]!!", forced = TRUE)
		light_power = light_power_on
		update_light()
		fail_invoke() //makes rune flash red
		var/charges_gained = min(3.5+nearby_cultists*1.5, 17)
		to_chat(user, "<span class='cultitalic'>You progress the ritual by [charges_gained]!</span>")
		invocation_charges += charges_gained
		used = TRUE
		var/turf/T = get_turf(src)
		playsound(T, invoke_sound, 100)
		addtimer(CALLBACK(src, .proc/reallow_invocation, T), 100) //causes rune to be invocable again after a delay
		if(invocation_charges >= summon_charges)
			summon_narsie(T)
			qdel(src)
		return
	//attempting the summoning
	var/datum/antagonist/cult/user_antag = user.mind.has_antag_datum(/datum/antagonist/cult, TRUE)
	var/confirm_final = alert(user, "This is the FINAL step to summon Nar'Sie; it is a long, painful ritual and the crew will be alerted to your location", "Are you prepared for the final battle?", "My life for Nar'Sie!", "No")
	if(confirm_final == "No")
		to_chat(user, "<span class='cult'>You decide to prepare further before scribing the rune.</span>")
		return
	//BEGIN THE SUMMONING
	active = TRUE
	fail_invoke()
	..()
	var/area/A = get_area(src)
	priority_announce("Figments from an eldritch god are being summoned into [A.map_name] from an unknown dimension. Disrupt the ritual at all costs!","Central Command Higher Dimensional Affairs", 'sound/ai/spanomalies.ogg')
	notify_ghosts("\A [src] has been activated at [get_area(src)]!", source = src, action = NOTIFY_ORBIT)
	sound_to_playing_players('sound/hallucinations/im_here1.ogg')
	for(var/datum/mind/B in user_antag.cult_team.members)
		if(B.current)
			to_chat(B.current, "<span class='cultlarge'>Keep invoking the rune until I tear through.</span>")
			user_antag.cult_team.ascend(B.current)

/obj/effect/rune/narsie/proc/summon_narsie(turf/T)
	sound_to_playing_players('sound/effects/dimensional_rend.ogg')
	sleep(40)
	new /obj/singularity/narsie/large/cult(T)
