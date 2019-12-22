///AI Upgrades


//Malf Picker
/obj/item/malf_upgrade
	name = "combat software upgrade"
	desc = "A highly illegal, highly dangerous upgrade for artificial intelligence units, granting them a variety of powers as well as the ability to hack APCs.<br>This upgrade does not override any active laws, and must be applied directly to an active AI core."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"


/obj/item/malf_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(AI))
		return
	if(AI.malf_picker)
		AI.malf_picker.processing_time += 50
		to_chat(AI, "<span class='userdanger'>[user] has attempted to upgrade you with combat software that you already possess. You gain 50 points to spend on Malfunction Modules instead.</span>")
	else
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with combat software!</span>")
		to_chat(AI, "<span class='userdanger'>Your current laws and objectives remain unchanged.</span>") //this unlocks malf powers, but does not give the license to plasma flood
		AI.add_malf_picker()
		AI.hack_software = TRUE
		log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
		message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with a [src].")
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	qdel(src)


//Lipreading
/obj/item/surveillance_upgrade
	name = "surveillance software upgrade"
	desc = "An illegal software package that will allow an artificial intelligence to 'hear' from its cameras via lip reading and hidden microphones."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/surveillance_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(AI))
		return
	if(AI.eyeobj)
		AI.eyeobj.relay_speech = TRUE
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with surveillance software!</span>")
		to_chat(AI, "Via a combination of hidden microphones and lip reading software, you are able to use your cameras to listen in on conversations.")
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with a [src].")
	qdel(src)


//Forced Suit Sensors. If anyone adds more of these, you should probably make them subtypes, but two isn't enough to be worthwhile.
/obj/item/suitsensors_upgrade
	name = "suit sensors virus upgrade"
	desc = "An illegal software package that will allow an artificial intelligence to distribute a virus to all sensor-enabled clothing, permanently enabling their vital sensors and tracking beacons."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/suitsensors_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(AI))
		return
	if(!GLOB.force_sensors)
		GLOB.force_sensors = TRUE
		to_chat(AI, "<span class='userdanger'>[user] has upgraded you with a suit sensor virus!</span>")
		to_chat(AI, "Thanks to a powerful virus package, all suit sensors will be permanently enabled, allowing you to monitor the condition of the crew and track them.")
	to_chat(user, "<span class='notice'>You upgrade [AI]. [src] is consumed in the process.</span>")
	log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] has upgraded [ADMIN_LOOKUPFLW(AI)] with a [src].")
	qdel(src)

