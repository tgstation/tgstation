GLOBAL_VAR_INIT(servants_active, FALSE) //This var controls whether or not a lot of the cult's structures work or not

/*

CLOCKWORK CULT: Based off of the failed pull requests from /vg/

While Nar-Sie is the oldest and most prominent of the elder gods, there are other forces at work in the universe.
Ratvar, the Clockwork Justiciar, a homage to Nar-Sie granted sentience by its own power, is one such other force.
Imprisoned within a massive construct known as the Celestial Derelict - or Reebe - an intense hatred of the Blood God festers.
Ratvar, unable to act in the mortal plane, seeks to return and forms covenants with mortals in order to bolster his influence.
Due to his mechanical nature, Ratvar is also capable of influencing silicon-based lifeforms, unlike Nar-Sie, who can only influence natural life.

This is a team-based gamemode, and the team's objective is shared by all cultists. Their goal is to defend an object called the Ark on a separate z-level.

The clockwork version of an arcane tome is the clockwork slab.

This file's folder contains:
	clock_cult.dm: Core gamemode files.
	clock_effect.dm: The base clockwork effect code.
	- Effect files are in game/gamemodes/clock_cult/clock_effects/
	clock_item.dm: The base clockwork item code.
	- Item files are in game/gamemodes/clock_cult/clock_items/
	clock_mobs.dm: Hostile clockwork creatures.
	clock_scripture.dm: The base Scripture code.
	- Scripture files are in game/gamemodes/clock_cult/clock_scripture/
	clock_structure.dm: The base clockwork structure code, including clockwork machines.
	- Structure files, and Ratvar, are in game/gamemodes/clock_cult/clock_structures/

	game/gamemodes/clock_cult/clock_helpers/ contains several helper procs, including the Ratvarian language.

	clockcult defines are in __DEFINES/clockcult.dm

Credit where due:
1. VelardAmakar from /vg/ for the entire design document, idea, and plan. Thank you very much.
2. SkowronX from /vg/ for MANY of the assets
3. FuryMcFlurry from /vg/ for many of the assets
4. PJB3005 from /vg/ for the failed continuation PR
5. Xhuis from /tg/ for coding the first iteration of the mode, and the new, reworked version
6. ChangelingRain from /tg/ for maintaining the gamemode for months after its release prior to its rework

*/

///////////
// PROCS //
///////////

/proc/is_servant_of_ratvar(mob/M)
	return istype(M) && !isobserver(M) && M.mind && M.mind.has_antag_datum(/datum/antagonist/clockcult)

/proc/is_eligible_servant(mob/M)
	if(!istype(M))
		return FALSE
	if(M.mind)
		if(ishuman(M) && (M.mind.assigned_role in list("Captain", "Chaplain")))
			return FALSE
		if(M.mind.enslaved_to && !is_servant_of_ratvar(M.mind.enslaved_to))
			return FALSE
		if(M.mind.unconvertable)
			return FALSE
	else
		return FALSE
	if(iscultist(M) || isconstruct(M) || M.isloyal() || ispAI(M))
		return FALSE
	if(ishuman(M) || isbrain(M) || isguardian(M) || issilicon(M) || isclockmob(M) || istype(M, /mob/living/simple_animal/drone/cogscarab) || istype(M, /mob/camera/eminence))
		return TRUE
	return FALSE

/proc/add_servant_of_ratvar(mob/L, silent = FALSE, create_team = TRUE)
	if(!L || !L.mind)
		return
	var/update_type = /datum/antagonist/clockcult
	if(silent)
		update_type = /datum/antagonist/clockcult/silent
	var/datum/antagonist/clockcult/C = new update_type(L.mind)
	C.make_team = create_team
	C.show_in_roundend = create_team //tutorial scarabs begone

	if(iscyborg(L))
		var/mob/living/silicon/robot/R = L
		if(R.deployed)
			var/mob/living/silicon/ai/AI = R.mainframe
			R.undeploy()
			to_chat(AI, "<span class='userdanger'>Anomaly Detected. Returned to core!</span>") //The AI needs to be in its core to properly be converted

	. = L.mind.add_antag_datum(C)

	if(!silent && L)
		if(.)
			to_chat(L, "<span class='heavy_brass'>The world before you suddenly glows a brilliant yellow. [issilicon(L) ? "You cannot compute this truth!" : \
			"Your mind is racing!"] You hear the whooshing steam and cl[pick("ank", "ink", "unk", "ang")]ing cogs of a billion billion machines, and all at once it comes to you.<br>\
			Ratvar, the Clockwork Justiciar, [GLOB.ratvar_awakens ? "has been freed from his eternal prison" : "lies in exile, derelict and forgotten in an unseen realm"].</span>")
			flash_color(L, flash_color = list("#BE8700", "#BE8700", "#BE8700", rgb(0,0,0)), flash_time = 50)
		else
			L.visible_message("<span class='boldwarning'>[L] seems to resist an unseen force!</span>", null, null, 7, L)
			to_chat(L, "<span class='heavy_brass'>The world before you suddenly glows a brilliant yellow. [issilicon(L) ? "You cannot compute this truth!" : \
			"Your mind is racing!"] You hear the whooshing steam and cl[pick("ank", "ink", "unk", "ang")]ing cogs of a billion billion machines, and the sound</span> <span class='boldwarning'>\
			is a meaningless cacophony.</span><br>\
			<span class='userdanger'>You see an abomination of rusting parts[GLOB.ratvar_awakens ? ", and it is here.<br>It is too late" : \
			" in an endless grey void.<br>It cannot be allowed to escape"].</span>")
			L.playsound_local(get_turf(L), 'sound/ambience/antag/clockcultalr.ogg', 40, TRUE, frequency = 100000, pressure_affected = FALSE)
			flash_color(L, flash_color = list("#BE8700", "#BE8700", "#BE8700", rgb(0,0,0)), flash_time = 5)




/proc/remove_servant_of_ratvar(mob/L, silent = FALSE)
	if(!L || !L.mind)
		return
	var/datum/antagonist/clockcult/clock_datum = L.mind.has_antag_datum(/datum/antagonist/clockcult)
	if(!clock_datum)
		return FALSE
	clock_datum.silent = silent
	clock_datum.on_removal()
	return TRUE

///////////////
// GAME MODE //
///////////////

/datum/game_mode
	var/list/servants_of_ratvar = list() //The Enlightened servants of Ratvar
	var/clockwork_explanation = "Defend the Ark of the Clockwork Justiciar and free Ratvar." //The description of the current objective

/datum/game_mode/clockwork_cult
	name = "clockwork cult"
	config_tag = "clockwork_cult"
	antag_flag = ROLE_SERVANT_OF_RATVAR
	false_report_weight = 10
	required_players = 24
	required_enemies = 4
	recommended_enemies = 4
	enemy_minimum_age = 14
	protected_jobs = list("AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain") //Silicons can eventually be converted
	restricted_jobs = list("Chaplain", "Captain")
	announce_span = "brass"
	announce_text = "Servants of Ratvar are trying to summon the Justiciar!\n\
	<span class='brass'>Servants</span>: Construct defenses to protect the Ark. Sabotage the station!\n\
	<span class='notice'>Crew</span>: Stop the servants before they can summon the Clockwork Justiciar."
	var/servants_to_serve = list()
	var/roundstart_player_count
	var/ark_time //In minutes, how long the Ark waits before activation; this is equal to 30 + (number of players / 5) (max 40 mins.)

	var/datum/team/clockcult/main_clockcult

/datum/game_mode/clockwork_cult/pre_setup()
	var/list/errorList = list()
	SSmapping.LoadGroup(errorList, "Reebe", "map_files/generic", "City_of_Cogs.dmm", default_traits = ZTRAITS_REEBE, silent = TRUE)
	if(errorList.len)	// reebe failed to load
		message_admins("Reebe failed to load!")
		log_game("Reebe failed to load!")
		return FALSE
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs
	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"
	var/starter_servants = 4 //Guaranteed four servants
	var/number_players = num_players()
	roundstart_player_count = number_players
	if(number_players > 30) //plus one servant for every additional 10 players above 30
		number_players -= 30
		starter_servants += round(number_players / 10)
	starter_servants = min(starter_servants, 8) //max 8 servants (that sould only happen with a ton of players)
	while(starter_servants)
		var/datum/mind/servant = antag_pick(antag_candidates)
		servants_to_serve += servant
		antag_candidates -= servant
		servant.assigned_role = ROLE_SERVANT_OF_RATVAR
		servant.special_role = ROLE_SERVANT_OF_RATVAR
		starter_servants--
	ark_time = 30 + round((roundstart_player_count / 5)) //In minutes, how long the Ark will wait before activation
	ark_time = min(ark_time, 35) //35 minute maximum for the activation timer
	return 1

/datum/game_mode/clockwork_cult/post_setup()
	for(var/S in servants_to_serve)
		var/datum/mind/servant = S
		log_game("[key_name(servant)] was made an initial servant of Ratvar")
		var/mob/living/L = servant.current
		var/turf/T = pick(GLOB.servant_spawns)
		L.forceMove(T)
		GLOB.servant_spawns -= T
		greet_servant(L)
		equip_servant(L)
		add_servant_of_ratvar(L, TRUE)
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar //that's a mouthful
	G.final_countdown(ark_time)
	..()
	return 1

/datum/game_mode/clockwork_cult/proc/greet_servant(mob/M) //Description of their role
	if(!M)
		return 0
	to_chat(M, "<span class='bold large_brass'>You are a servant of Ratvar, the Clockwork Justiciar!</span>")
	to_chat(M, "<span class='brass'>You have approximately <b>[ark_time]</b> minutes until the Ark activates.</span>")
	to_chat(M, "<span class='brass'>Unlock <b>Script</b> scripture by converting a new servant.</span>")
	to_chat(M, "<span class='brass'><b>Application</b> scripture will be unlocked halfway until the Ark's activation.</span>")
	M.playsound_local(get_turf(M), 'sound/ambience/antag/clockcultalr.ogg', 100, FALSE, pressure_affected = FALSE)
	return 1

/datum/game_mode/proc/equip_servant(mob/living/M) //Grants a clockwork slab to the mob, with one of each component
	if(!M || !ishuman(M))
		return FALSE
	var/mob/living/carbon/human/L = M
	L.equipOutfit(/datum/outfit/servant_of_ratvar)
	var/obj/item/clockwork/slab/S = new
	var/slot = "At your feet"
	var/list/slots = list("In your left pocket" = SLOT_L_STORE, "In your right pocket" = SLOT_R_STORE, "In your backpack" = SLOT_IN_BACKPACK, "On your belt" = SLOT_BELT)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		slot = H.equip_in_one_of_slots(S, slots)
		if(slot == "In your backpack")
			slot = "In your [H.back.name]"
	if(slot == "At your feet")
		if(!S.forceMove(get_turf(L)))
			qdel(S)
	if(S && !QDELETED(S))
		to_chat(L, "<span class='bold large_brass'>There is a paper in your backpack! It'll tell you if anything's changed, as well as what to expect.</span>")
		to_chat(L, "<span class='alloy'>[slot] is a <b>clockwork slab</b>, a multipurpose tool used to construct machines and invoke ancient words of power. If this is your first time \
		as a servant, you can find a concise tutorial in the Recollection category of its interface.</span>")
		to_chat(L, "<span class='alloy italics'>If you want more information, you can read <a href=\"https://tgstation13.org/wiki/Clockwork_Cult\">the wiki page</a> to learn more.</span>")
		return TRUE
	return FALSE

/datum/game_mode/clockwork_cult/check_finished()
	if(GLOB.ark_of_the_clockwork_justiciar && !GLOB.ratvar_awakens) // Doesn't end until the Ark is destroyed or completed
		return FALSE
	return ..()

/datum/game_mode/clockwork_cult/proc/check_clockwork_victory()
	return main_clockcult.check_clockwork_victory()

/datum/game_mode/clockwork_cult/set_round_result()
	..()
	if(GLOB.clockwork_gateway_activated)
		SSticker.news_report = CLOCK_SUMMON
		SSticker.mode_result = "win - servants completed their objective (summon ratvar)"
	else
		SSticker.news_report = CULT_FAILURE
		SSticker.mode_result = "loss - servants failed their objective (summon ratvar)"

/datum/game_mode/clockwork_cult/generate_report()
	return "Bluespace monitors near your sector have detected a continuous stream of patterned fluctuations since the station was completed. It is most probable that a powerful entity \
	from a very far distance away is using to the station as a vector to cross that distance through bluespace. The theoretical power required for this would be monumental, and if \
	the entity is hostile, it would need to rely on a single central power source - disrupting or destroying that power source would be the best way to prevent said entity from causing \
	harm to company personnel or property.<br><br>Keep a sharp on any crew that appear to be oddly-dressed or using what appear to be magical powers, as these crew may be defectors \
	working for this entity and utilizing highly-advanced technology to cross the great distance at will. If they should turn out to be a credible threat, the task falls on you and \
	your crew to dispatch it in a timely manner."

/datum/game_mode/proc/update_servant_icons_added(datum/mind/M)
	var/datum/atom_hud/antag/A = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	A.join_hud(M.current)
	set_antag_hud(M.current, "clockwork")

/datum/game_mode/proc/update_servant_icons_removed(datum/mind/M)
	var/datum/atom_hud/antag/A = GLOB.huds[ANTAG_HUD_CLOCKWORK]
	A.leave_hud(M.current)
	set_antag_hud(M.current, null)



//Servant of Ratvar outfit
/datum/outfit/servant_of_ratvar
	name = "Servant of Ratvar"
	uniform = /obj/item/clothing/under/chameleon/ratvar
	shoes = /obj/item/clothing/shoes/sneakers/black
	back = /obj/item/storage/backpack
	ears = /obj/item/radio/headset
	gloves = /obj/item/clothing/gloves/color/yellow
	belt = /obj/item/storage/belt/utility/servant
	backpack_contents = list(/obj/item/storage/box/engineer = 1, \
	/obj/item/clockwork/replica_fabricator = 1, /obj/item/stack/tile/brass/fifty = 1, /obj/item/paper/servant_primer = 1)
	id = /obj/item/pda
	var/plasmaman //We use this to determine if we should activate internals in post_equip()

/datum/outfit/servant_of_ratvar/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(H.dna.species.id == "plasmaman") //Plasmamen get additional equipment because of how they work
		head = /obj/item/clothing/head/helmet/space/plasmaman
		uniform = /obj/item/clothing/under/plasmaman //Plasmamen generally shouldn't need chameleon suits anyways, since everyone expects them to wear their fire suit
		r_hand = /obj/item/tank/internals/plasmaman/belt/full
		mask = /obj/item/clothing/mask/breath
		plasmaman = TRUE

/datum/outfit/servant_of_ratvar/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/card/id/W = new(H)
	var/obj/item/pda/PDA = H.wear_id
	W.assignment = "Assistant"
	W.access += ACCESS_MAINT_TUNNELS
	W.registered_name = H.real_name
	W.update_label()
	if(plasmaman && !visualsOnly) //If we need to breathe from the plasma tank, we should probably start doing that
		H.internal = H.get_item_for_held_index(2)
		H.update_internals_hud_icon(1)
	PDA.owner = H.real_name
	PDA.ownjob = "Assistant"
	PDA.update_label()
	PDA.id_check(H, W)
	H.sec_hud_set_ID()


//This paper serves as a quick run-down to the cult as well as a changelog to refer to.
//Check strings/clockwork_cult_changelog.txt for the changelog, and update it when you can!
/obj/item/paper/servant_primer
	name = "The Ark And You: A Primer On Servitude"
	color = "#DAAA18"
	info = "<b>DON'T PANIC.</b><br><br>\
	Here's a quick primer on what you should know here.\
	<ol>\
	<li>You're in a place called Reebe right now. The crew can't get here normally.</li>\
	<li>In the north is your base camp, with supplies, consoles, and the Ark. In the south is an inaccessible area that the crew can walk between \
	once they arrive (more on that later.) Everything between that space is an open area.</li>\
	<li>Your job as a servant is to build fortifications and defenses to protect the Ark and your base once the Ark activates. You can do this \
	however you like, but work with your allies and coordinate your efforts.</li>\
	<li>Once the Ark activates, the station will be alerted. Portals to Reebe will open up in nearly every room. When they take these portals, \
	the crewmembers will arrive in the area that you can't access, but can get through it freely - whereas you can't. Treat this as the \"spawn\" of the \
	crew and defend it accordingly.</li>\
	</ol>\
	<hr>\
	Here is the layout of Reebe, from left to right:\
	<ul>\
	<li><b>Dressing Room:</b> Contains clothing, a dresser, and a mirror. There are spare slabs and absconders here.</li>\
	<li><b>Listening Station:</b> Contains intercoms, a telecomms relay, and a list of frequencies.</li>\
	<li><b>Ark Chamber:</b> Houses the Ark.</li>\
	<li><b>Observation Room:</b> Contains five camera observers. These can be used to watch the station through its cameras, as well as to teleport down \
	to most areas. To do this, use the Warp action while hovering over the tile you want to warp to.</li>\
	<li><b>Infirmary:</b> Contains sleepers and basic medical supplies for superficial wounds. The sleepers can consume Vitality to heal any occupants. \
	This room is generally more useful during the preparation phase; when defending the Ark, scripture is more useful.</li>\
	</ul>\
	<hr>\
	<h2>Things that have changed:</h2>\
	<ul>\
	CLOCKCULTCHANGELOG\
	</ul>\
	<hr>\
	<b>Good luck!</b>"

/obj/item/paper/servant_primer/Initialize()
	. = ..()
	var/changelog = world.file2list("strings/clockwork_cult_changelog.txt")
	var/changelog_contents = ""
	for(var/entry in changelog)
		changelog_contents += "<li>[entry]</li>"
	info = replacetext(info, "CLOCKCULTCHANGELOG", changelog_contents)

/obj/item/paper/servant_primer/examine(mob/user)
	if(!is_servant_of_ratvar(user) && !isobserver(user))
		to_chat(user, "<span class='danger'>You can't understand any of the words on [src].</span>")
	..()
