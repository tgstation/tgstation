/mob/living/silicon/pai
	name = "pAI"
	icon = 'icons/mob/pai.dmi'
	icon_state = "repairbot"
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	desc = "A generic pAI mobile hard-light holographics emitter. It seems to be deactivated."
	weather_immunities = list("ash")
	health = 500
	maxHealth = 500
	layer = BELOW_MOB_LAYER
	can_be_held = TRUE

	var/network = "ss13"
	var/obj/machinery/camera/current = null

	var/ram = 100	// Used as currency to purchase different abilities
	var/list/software = list()
	var/userDNA		// The DNA string of our assigned user
	var/obj/item/paicard/card	// The card we inhabit
	var/hacking = FALSE		//Are we hacking a door?

	var/speakStatement = "states"
	var/speakExclamation = "declares"
	var/speakDoubleExclamation = "alarms"
	var/speakQuery = "queries"

	var/obj/item/pai_cable/cable		// The cable we produce and use when door or camera jacking

	var/master				// Name of the one who commands us
	var/master_dna			// DNA string for owner verification

// Various software-specific vars

	var/temp				// General error reporting text contained here will typically be shown once and cleared
	var/screen				// Which screen our main window displays
	var/subscreen			// Which specific function of the main screen is being displayed

	var/obj/item/pda/ai/pai/pda = null

	var/secHUD = 0			// Toggles whether the Security HUD is active or not
	var/medHUD = 0			// Toggles whether the Medical  HUD is active or not

	var/datum/data/record/medicalActive1		// Datacore record declarations for record software
	var/datum/data/record/medicalActive2

	var/datum/data/record/securityActive1		// Could probably just combine all these into one
	var/datum/data/record/securityActive2

	var/obj/machinery/door/hackdoor		// The airlock being hacked
	var/hackprogress = 0				// Possible values: 0 - 100, >= 100 means the hack is complete and will be reset upon next check

	var/obj/item/integrated_signaler/signaler // AI's signaller

	var/holoform = FALSE
	var/canholo = TRUE
	var/obj/item/card/id/access_card = null
	var/chassis = "repairbot"
	var/list/possible_chassis = list("cat" = TRUE, "mouse" = TRUE, "monkey" = TRUE, "corgi" = FALSE, "fox" = FALSE, "repairbot" = TRUE, "rabbit" = TRUE)		//assoc value is whether it can be picked up.
	var/static/item_head_icon = 'icons/mob/pai_item_head.dmi'
	var/static/item_lh_icon = 'icons/mob/pai_item_lh.dmi'
	var/static/item_rh_icon = 'icons/mob/pai_item_rh.dmi'

	var/emitterhealth = 20
	var/emittermaxhealth = 20
	var/emitterregen = 0.25
	var/emittercd = 50
	var/emitteroverloadcd = 100
	var/emittersemicd = FALSE

	var/overload_ventcrawl = 0
	var/overload_bulletblock = 0	//Why is this a good idea?
	var/overload_maxhealth = 0
	canmove = FALSE
	var/silent = FALSE
	var/hit_slowdown = 0
	var/brightness_power = 5
	var/slowdown = 0

/mob/living/silicon/pai/movement_delay()
	. = ..()
	. += slowdown

/mob/living/silicon/pai/can_unbuckle()
	return FALSE

/mob/living/silicon/pai/can_buckle()
	return FALSE

/mob/living/silicon/pai/Destroy()
	if (loc != card)
		card.forceMove(drop_location())
	card.pai = null
	card.cut_overlays()
	card.add_overlay("pai-off")
	GLOB.pai_list -= src
	return ..()

/mob/living/silicon/pai/Initialize()
	var/obj/item/paicard/P = loc
	START_PROCESSING(SSfastprocess, src)
	GLOB.pai_list += src
	make_laws()
	canmove = 0
	if(!istype(P)) //when manually spawning a pai, we create a card to put it into.
		var/newcardloc = P
		P = new /obj/item/paicard(newcardloc)
		P.setPersonality(src)
	forceMove(P)
	card = P
	signaler = new(src)
	if(!radio)
		radio = new /obj/item/radio(src)

	//PDA
	pda = new(src)
	spawn(5)
		pda.ownjob = "pAI Messenger"
		pda.owner = text("[]", src)
		pda.name = pda.owner + " (" + pda.ownjob + ")"

	. = ..()

	var/datum/action/innate/pai/software/SW = new
	var/datum/action/innate/pai/shell/AS = new /datum/action/innate/pai/shell
	var/datum/action/innate/pai/chassis/AC = new /datum/action/innate/pai/chassis
	var/datum/action/innate/pai/rest/AR = new /datum/action/innate/pai/rest
	var/datum/action/innate/pai/light/AL = new /datum/action/innate/pai/light

	var/datum/action/language_menu/ALM = new
	SW.Grant(src)
	AS.Grant(src)
	AC.Grant(src)
	AR.Grant(src)
	AL.Grant(src)
	ALM.Grant(src)
	emittersemicd = TRUE
	addtimer(CALLBACK(src, .proc/emittercool), 600)

/mob/living/silicon/pai/Life()
	if(hacking)
		process_hack()
	return ..()

/mob/living/silicon/pai/proc/process_hack()

	if(cable && cable.machine && istype(cable.machine, /obj/machinery/door) && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
		hackprogress = CLAMP(hackprogress + 4, 0, 100)
	else
		temp = "Door Jack: Connection to airlock has been lost. Hack aborted."
		hackprogress = 0
		hacking = FALSE
		hackdoor = null
		return
	if(screen == "doorjack" && subscreen == 0) // Update our view, if appropriate
		paiInterface()
	if(hackprogress >= 100)
		hackprogress = 0
		var/obj/machinery/door/D = cable.machine
		D.open()
		hacking = FALSE

/mob/living/silicon/pai/make_laws()
	laws = new /datum/ai_laws/pai()
	return TRUE

/mob/living/silicon/pai/Login()
	..()
	usr << browse_rsc('html/paigrid.png')			// Go ahead and cache the interface resources as early as possible
	if(client)
		client.perspective = EYE_PERSPECTIVE
		if(holoform)
			client.eye = src
		else
			client.eye = card

/mob/living/silicon/pai/Stat()
	..()
	if(statpanel("Status"))
		if(!stat)
			stat(null, text("Emitter Integrity: [emitterhealth * (100/emittermaxhealth)]"))
		else
			stat(null, text("Systems nonfunctional"))

/mob/living/silicon/pai/restrained(ignore_grab)
	. = FALSE

// See software.dm for Topic()

/mob/living/silicon/pai/canUseTopic(atom/movable/M, be_close=FALSE, no_dextery=FALSE)
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/proc/makePAI(delold)
	var/obj/item/paicard/card = new /obj/item/paicard(get_turf(src))
	var/mob/living/silicon/pai/pai = new /mob/living/silicon/pai(card)
	pai.key = key
	pai.name = name
	card.setPersonality(pai)
	if(delold)
		qdel(src)

/datum/action/innate/pai
	name = "PAI Action"
	icon_icon = 'icons/mob/actions/actions_silicon.dmi'
	var/mob/living/silicon/pai/P

/datum/action/innate/pai/Trigger()
	if(!ispAI(owner))
		return 0
	P = owner

/datum/action/innate/pai/software
	name = "Software Interface"
	button_icon_state = "pai"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/software/Trigger()
	..()
	P.paiInterface()

/datum/action/innate/pai/shell
	name = "Toggle Holoform"
	button_icon_state = "pai_holoform"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/shell/Trigger()
	..()
	if(P.holoform)
		P.fold_in(0)
	else
		P.fold_out()

/datum/action/innate/pai/chassis
	name = "Holochassis Appearance Composite"
	button_icon_state = "pai_chassis"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/chassis/Trigger()
	..()
	P.choose_chassis()

/datum/action/innate/pai/rest
	name = "Rest"
	button_icon_state = "pai_rest"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/rest/Trigger()
	..()
	P.lay_down()

/datum/action/innate/pai/light
	name = "Toggle Integrated Lights"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "emp"
	background_icon_state = "bg_tech"

/datum/action/innate/pai/light/Trigger()
	..()
	P.toggle_integrated_light()

/mob/living/silicon/pai/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(!.)
		slowdown = 2
		return TRUE
	slowdown = initial(slowdown)
	return TRUE

/mob/living/silicon/pai/examine(mob/user)
	..()
	to_chat(user, "A personal AI in holochassis mode. Its master ID string seems to be [master].")

/mob/living/silicon/pai/Life()
	if(stat == DEAD)
		return
	if(cable)
		if(get_dist(src, cable) > 1)
			var/turf/T = get_turf(src.loc)
			T.visible_message("<span class='warning'>[src.cable] rapidly retracts back into its spool.</span>", "<span class='italics'>You hear a click and the sound of wire spooling rapidly.</span>")
			qdel(src.cable)
			cable = null
	silent = max(silent - 1, 0)
	. = ..()

/mob/living/silicon/pai/updatehealth()
	if(status_flags & GODMODE)
		return
	health = maxHealth - getBruteLoss() - getFireLoss()
	update_stat()


/mob/living/silicon/pai/process()
	emitterhealth = CLAMP((emitterhealth + emitterregen), -50, emittermaxhealth)
	hit_slowdown = CLAMP((hit_slowdown - 1), 0, 100)
