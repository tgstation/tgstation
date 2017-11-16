//The Eminence is a unique mob that functions like the leader of the cult. It's incorporeal but can interact with the world in several ways.
/mob/camera/eminence
	name = "\improper Emininence"
	real_name = "\improper Eminence"
	desc = "The leader-elect of the servants of Ratvar."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "eminence"
	mouse_opacity = MOUSE_OPACITY_ICON
	move_on_shuttle = TRUE
	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	layer = FLY_LAYER

	faction = list("ratvar")
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/static/superheated_walls = 0

/mob/camera/eminence/Initialize()
	if(SSticker.mode.eminence)
		return INITIALIZE_HINT_QDEL
	. = ..()

/mob/camera/eminence/Destroy(force)
	if(!force && SSticker.mode.eminence)
		return QDEL_HINT_LETMELIVE
	return ..()

/mob/camera/eminence/CanPass(atom/movable/mover, turf/target)
	return TRUE

/mob/camera/eminence/Move(NewLoc, direct)
	var/OldLoc = loc
	if(NewLoc && z == ZLEVEL_CITYOFCOGS && !istype(NewLoc, /turf/open/indestructible/reebe_void))
		forceMove(get_turf(NewLoc))
	Moved(OldLoc, direct)

/mob/camera/eminence/Login()
	..()
	add_servant_of_ratvar(src, TRUE)
	to_chat(src, "<span class='bold large_brass'>You have been selected as the Eminence!</span>")
	to_chat(src, "<span class='brass'>As the Eminence, you lead the servants. Anything you say will be heard by the entire cult.</span>")
	to_chat(src, "<span class='brass'>You can move and see through walls, but you can't leave Reebe.</span>")
	SSticker.mode.eminence = mind
	eminence_help()
	var/datum/action/innate/eminence/E
	for(var/V in subtypesof(/datum/action/innate/eminence))
		E = new V
		E.Grant(src)
	for(var/datum/action/innate/hierophant/H in actions)
		H.Remove(src) //Any normal speech of ours is forwarded to the Hierophant network

/mob/camera/eminence/say(message)
	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message)
		return
	log_talk(src, "[key_name(src)] : [message]", LOGSAY)
	hierophant_message("<span class='large_brass'><b>The Eminence:</b> \"[message]\"</span>")

/mob/camera/eminence/Life()
	..()
	if(z != ZLEVEL_CITYOFCOGS && GLOB.ark_of_the_clockwork_justiciar)
		forceMove(get_turf(GLOB.ark_of_the_clockwork_justiciar))
		to_chat(src, "<span class='boldwarning'>The Ark pulls you back as the strain of your distance becomes fatal!</span>")

/mob/camera/eminence/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["shift"])
		A.examine(src)
		return
	if(modifiers["alt"] && istype(A, /turf/closed/wall/clockwork))
		superheat_wall(A)
		return
	if(GLOB.ark_of_the_clockwork_justiciar == A)
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
		if(G.recalling)
			return
		if(!G.recalls_remaining)
			to_chat(src, "<span class='warning'>The Ark can no longer recall!</span>")
			return
		if(alert(src, "Initiate mass recall?", "Mass Recall", "Yes", "No") != "Yes" || QDELETED(src) || QDELETED(G) || !G.obj_integrity)
			return
		G.initiate_mass_recall() //wHOOPS LOOKS LIKE A HULK GOT THROUGH

/mob/camera/eminence/proc/superheat_wall(turf/closed/wall/clockwork/wall)
	if(!istype(wall))
		return
	if(superheated_walls >= SUPERHEATED_CLOCKWORK_WALL_LIMIT && !wall.heated)
		to_chat(src, "<span class='warning'>You're exerting all of your power superheating this many walls already! Cool some down first!</span>")
		return
	wall.turn_up_the_heat()
	if(wall.heated)
		superheated_walls++
		to_chat(src, "<span class='neovgre_small'>You superheat [wall]. <b>Superheated walls:</b> [superheated_walls]/[SUPERHEATED_CLOCKWORK_WALL_LIMIT]")
	else
		superheated_walls--
		to_chat(src, "<span class='neovgre_small'>You cool [wall]. <b>Superheated walls:</b> [superheated_walls]/[SUPERHEATED_CLOCKWORK_WALL_LIMIT]")

/mob/camera/eminence/proc/eminence_help()
	to_chat(src, "<span class='bold alloy'>You can make use of certain shortcuts to perform different actions:</span>")
	to_chat(src, "<span class='alloy'><b>Alt-Click a clockwork wall</b> to superheat or cool it down. \
	Superheated walls can't be destroyed by hulks or mechs and are much slower to deconstruct, and are marked by a bright red glow. \
	This lasts indefinitely, but only [SUPERHEATED_CLOCKWORK_WALL_LIMIT] clockwork walls can be superheated at once.</span>")
	to_chat(src, "<span class='alloy'><b>Interact with the Ark</b> to initiate an emergency recall that teleports all servants directly to its location after a short delay. \
	This can only be used a single time, or twice if the herald's beacon was activated,</span>")


//Eminence actions below this point
/datum/action/innate/eminence
	name = "Eminence Action"
	desc = "You shouldn't see this. File a bug report"
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	background_icon_state = "bg_clock"
	buttontooltipstyle = "clockcult"

/datum/action/innate/eminence/IsAvailable()
	if(!iseminence(owner))
		qdel(src)
		return
	return ..()

//Returns to the Ark
/datum/action/innate/eminence/ark_jump
	name = "Return to Ark"
	desc = "Warps you to the Ark."
	button_icon_state = "Abscond"

/datum/action/innate/eminence/ark_jump/Activate()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
	if(G)
		owner.forceMove(get_turf(G))
		owner.playsound_local(owner, 'sound/magic/magic_missile.ogg', 50, TRUE)
		flash_color(owner, flash_color = "#AF0AAF", flash_time = 25)

//A quick-use button for recalling the servants to the Ark
/datum/action/innate/eminence/mass_recall
	name = "Mass Recall"
	desc = "Initiates a mass recall, warping all servants to the Ark after a short delay. This can only be used once."
	button_icon_state = "Spatial Gateway"

/datum/action/innate/eminence/mass_recall/IsAvailable()
	. = ..()
	if(.)
		var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
		if(G)
			return G.recalls_remaining && !G.recalling
		return FALSE

/datum/action/innate/eminence/mass_recall/Activate()
	var/obj/structure/destructible/clockwork/massive/celestial_gateway/G = GLOB.ark_of_the_clockwork_justiciar
	if(G && !G.recalling && G.recalls_remaining)
		if(alert(owner, "Initiate mass recall?", "Mass Recall", "Yes", "No") != "Yes" || QDELETED(owner) || QDELETED(G) || !G.obj_integrity)
			return
		G.initiate_mass_recall()
