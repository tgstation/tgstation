

/obj/item/clothing/glasses/sunglasses/gar/dirk
	name = "anime shades"
	desc = "For when shit flies too far off the handle. AI not included."
    icon = 'spacestation413/icons/obj/clothing/glasses.dmi'
	icon_state = "dirk"
    var/item_state = "dirk"
    var/lefthand_file = 'spacestation413/icons/mob/inhands/items_lefthand.dmi'
    var/righthand_file = 'spacestation413/icons/mob/inhands/items_righthand.dmi'
	force = 10.25
	throwforce = 10.25
	throw_speed = 4.13
	//attack_verb = list("sliced")
	//hitsound = 'sound/weapons/bladeslice.ogg'
	//sharpness = IS_SHARP

/obj/item/clothing/glasses/smartdirk
	name = "robotic anime shades"
	desc = "For when shit flies too far off the handle. AI included. It's covered in thin, tiny dark red circuitry."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "dirk3"
	w_class = WEIGHT_CLASS_NORMAL
	var/next_ask
	var/askDelay = 612 //one minute
	var/searching = FALSE
	brainmob = null
	req_access = list(ACCESS_ROBOTICS)
	mecha = null//This does not appear to be used outside of reference in mecha.dm.
	braintype = "Android"
	var/autoping = TRUE //if it pings on creation immediately
	var/begin_activation_message = "<span class='notice'>You press a button on the underside of the shades and wait for the AI to boot up.</span>"
	var/success_message = "<span class='notice'>The circuitry in the shades flares a bright red for a moment, and a 'ding!' sound is heard. Success!</span>"
	var/fail_message = "<span class='notice'>The shades' circuitry grows darker for a moment, and a buzz sound is played. Perhaps you could try again?</span>"
	var/new_role = "Lil'Shades"
	var/welcome_message = "<span class='warning'>ALL PAST LIVES ARE FORGOTTEN.</span>\n\
	<b>You are an artifical intelligence inside a pair of shades, possibly with a small penchant for irony and mockery of your wearer.\n\
	As a synthetic intelligence, you answer to all crewmembers and the AI.\n\
	Remember, the purpose of your existence is to serve the crew and the station. Above all else, do no harm.</b>"
	var/new_mob_message = "<span class='notice'>The shades chime quietly.</span>"
	var/dead_message = "<span class='deadsay'>It appears to be completely inactive. The 'boot-up' light is blinking.</span>"
	var/recharge_message = "<span class='warning'>The artificial intelligence isn't ready to reboot again yet! Give it some time.</span>"
	var/list/possible_names //If you leave this blank, it will use the global posibrain names
	var/picked_name