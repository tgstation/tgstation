/obj/item/britnotes
	name = "RD's Personal Tablet"
	desc = "It smells vaguely of plasma-burned hay."
	icon = 'icons/obj/modular_tablet.dmi'
	var/icon_state_unpowered = null
	var/icon_state_powered = null
	icon_state_unpowered = "tablet-blue"
	icon_state_powered = "tablet-secret"
	w_class = WEIGHT_CLASS_SMALL
	force = 0.1
	var/has_light = TRUE
	light_on = FALSE						//If that light is enabled
	var/comp_light_luminosity = 2.3				//The brightness of that light
	var/enabled = 0
	attack_verb_simple = list("tapped", "slapped", "hit")
	attack_verb_continuous = list("taps", "slaps", "hits")
	var/password = "Rose"


/obj/item/britnotes/Initialize()
	. = ..()
	ask_for_pass()
	update_icon()
	update_icon_state()

/obj/item/britnotes/update_icon_state()
	if(!enabled)
		icon_state = icon_state_unpowered
	else
		icon_state = icon_state_powered

/obj/item/britnotes/attack_self(mob/user)
	add_fingerprint(user)
	. = ..()
	if(enabled)
		if(ask_for_pass(user))
			open()
	else
		to_chat(user, "<span class='notice'>You press the power button, the screen shining with a dim grey light.</span>")
		enabled = 1
	update_icon()
	update_icon_state()

/obj/item/britnotes/proc/ask_for_pass(mob/user)
	var/guess = stripped_input(user,"Please insert password:", "Password", "")
	if(guess == password)
		return TRUE
	return FALSE

/obj/item/britnotes/proc/open(mob/user)
	var/rulesurl = CONFIG_GET(string/rulesurl)
	if(rulesurl)
		if(alert("You are about to open a new window.",,"Ok","No")!="Ok")
			return
		usr << link(rulesurl)
	else
		to_chat(src, "<span class='danger'>The notes URL is not set in the server configuration.</span>")
	return

/obj/item/britevidence
	icon = 'icons/obj/britevidence.dmi'
	w_class = WEIGHT_CLASS_SMALL
	force = 0.1
	attack_verb_simple = list("hit", "smashed")
	attack_verb_continuous = list("hits", "smashes")


/obj/item/britevidence/suit
	name = "damaged HEV suit"
	desc = "Covered in green and red goop, it has holes in its left arm and abdomen. Half of it appears charred. Its helmet is retracted."
	icon_state = "HEV"
	inhand_icon_state = "HEVRD"
	lefthand_file = 'icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing_righthand.dmi'
	var/handled = FALSE

/obj/item/britevidence/suit/attack_self(mob/user)
	add_fingerprint(user)
	. = ..()
	if(!handled)
		src.visible_message("<span class='warning'>Its helmet uncollapses, revealing a giant charred hole which takes up a quarter of its surface area.</span.?>")
		playsound(src, 'sound/effects/servostep.ogg', 75, 6)
		icon_state = "HEV_open"
		desc = "Covered in green and red goop, it has holes in its left arm and abdomen. Half of it appears charred. Its helmet has a massive hole in the side."
		handled = TRUE
	update_icon()

/obj/item/britevidence/flamethrower
	name = "decommissioned flamethrower"
	desc = "A makeshift flamethrower, rendered unusable from three large claw marks running across its barrel."
	icon_state = "flamethrower"
	inhand_icon_state = "flamethrower_0"
	lefthand_file = 'icons/mob/inhands/weapons/flamethrower_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/flamethrower_righthand.dmi'

/obj/item/britevidence/flamethrower/attack_self(mob/user)
	add_fingerprint(user)
	. = ..()
	playsound(src, 'sound/items/change_drill.ogg', 50, 6)

/obj/item/britevidence/contract
	name = "cursed manilla envelope"
	desc = "A manilla envelope, slightly larger than a standard piece of printer paper. Its seal glows blood red."
	icon_state = "folder"
	var/opened = FALSE

/obj/item/britevidence/contract/attackby(obj/item/I,mob/living/user,params)
	if(istype(I, /obj/item/britevidence/key) && !opened)
		user.visible_message("<span class='notice'>The envelope is opened through hard work, allowing a piece of paper to be taken out. The envelope promptly turns to ashes.</span>", "<span class='notice'>[src] is no match for your relentless onslaught of cuts, as it turns to ash in your hands, revealing a piece of paper inside.</span>")
		playsound(src, 'sound/spookoween/hellscream.ogg', 75, 6)
		opened = TRUE
		name = "infernal contract"
		desc = "A contract which promises \"a second chance\", it is covered in splotches of eternally fresh blood."
		icon_state = "paper"

/obj/item/britevidence/key
	name = "letter opener of eternal torment"
	desc = "Named by an intern that was thusly thrown into the pits of despair. Used to open cursed manilla envelopes."
	icon_state = "boxcutter"

/obj/item/britevidence/scan
	name = "CT scan"
	desc = "A scan of a brain. An object is lodged into its right hemisphere."
	icon_state = "CT"

/obj/item/britevidence/card
	name = "broken ID card"
	desc = "An ID card, half of it is snapped off, with the other half covered in dried blood, rendering it nearly unreadable."
	icon_state = "id"

/obj/item/britevidence/gun
	name = "outdated laser gun"
	desc = "An empty grey laser gun, stained two shades of red. It looks ancient."
	icon_state = "oldlaser"

/obj/item/britevidence/gun/attack_self(mob/user)
	add_fingerprint(user)
	. = ..()
	playsound(src, 'sound/effects/sparks3.ogg', 75, 6)

/obj/item/britevidence/photo
	name = "grainy polaroid"
	desc = "A photo of a security camera's view in what appears to be a loungue of some sort. A supermatter crystal is visible in the center, surrounded by a red glow."
	icon_state = "photo"
