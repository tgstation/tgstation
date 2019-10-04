/obj/item/clothing/mask/gas
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH | PEPPERPROOF
	resistance_flags = NONE

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "welding mask"
	desc = "A gas mask with built-in welding goggles and a face shield. Looks like a skull - clearly designed by a nerd."
	icon_state = "weldingmask"
	materials = list(/datum/material/iron=4000, /datum/material/glass=2000)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 55)
	actions_types = list(/datum/action/item_action/toggle)
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = MASKCOVERSEYES
	visor_flags_inv = HIDEEYES
	visor_flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/mask/gas/welding/up

/obj/item/clothing/mask/gas/welding/up/Initialize()
	..()
	visor_toggling()

// ********************************************************************

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "plague doctor mask"
	desc = "A modernised version of the classic design, this mask will not only filter out toxins but it can also be connected to an air supply."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 2,"energy" = 2, "bomb" = 0, "bio" = 75, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/mask/gas/syndicate
	name = "syndicate mask"
	desc = "A close-fitting tactical mask that can be connected to an air supply."
	icon_state = "syndicate"
	strip_delay = 60

/obj/item/clothing/mask/gas/clown_hat
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	clothing_flags = MASKINTERNALS
	icon_state = "clown"
	item_state = "clown_hat"
	dye_color = "clown"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = /datum/dog_fashion/head/clown

/obj/item/clothing/mask/gas/clown_hat/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["True Form"] = "clown"
	options["The Feminist"] = "sexyclown"
	options["The Madman"] = "joker"
	options["The Rainbow Color"] ="rainbow"
	options["The Jester"] ="chaos" //Nepeta33Leijon is holding me captive and forced me to help with this please send help

	var/choice = input(user,"To what form do you wish to Morph this mask?","Morph Mask") in options

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(user, "<span class='notice'>Your Clown Mask has now morphed into [choice], all praise the Honkmother!</span>")
		return 1

/obj/item/clothing/mask/gas/sexyclown
	name = "sexy-clown wig and mask"
	desc = "A feminine clown mask for the dabbling crossdressers or female entertainers."
	clothing_flags = MASKINTERNALS
	icon_state = "sexyclown"
	item_state = "sexyclown"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/mime
	name = "mime mask"
	desc = "The traditional mime's mask. It has an eerie facial posture."
	clothing_flags = MASKINTERNALS
	icon_state = "mime"
	item_state = "mime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)


/obj/item/clothing/mask/gas/mime/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["Blanc"] = "mime"
	options["Triste"] = "sadmime"
	options["Effrayé"] = "scaredmime"
	options["Excité"] ="sexymime"

	var/choice = input(user,"To what form do you wish to Morph this mask?","Morph Mask") in options

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(user, "<span class='notice'>Your Mime Mask has now morphed into [choice]!</span>")
		return 1

/obj/item/clothing/mask/gas/monkeymask
	name = "monkey mask"
	desc = "A mask used when acting as a monkey."
	clothing_flags = MASKINTERNALS
	icon_state = "monkeymask"
	item_state = "monkeymask"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/screech)
	var/recent_uses = 0
	var/broken_hailer = 0
	var/gorilla = FALSE
	var/cooldown_special


/obj/item/clothing/mask/gas/monkeymask/ui_action_click(mob/user, action)
	screech()

/obj/item/clothing/mask/gas/monkeymask/attack_self()
	screech()
/obj/item/clothing/mask/gas/monkeymask/emag_act(mob/user as mob)
	if(!gorilla)
		to_chat(user, "<span class='warning'>You silently turn on [src]'s gorilla module with the cryptographic sequencer.</span>")
	else
		return

/obj/item/clothing/mask/gas/monkeymask/verb/screech()
	set category = "Object"
	set name = "Screech"
	set src in usr
	if(!isliving(usr))
		return
	if(!can_use(usr))
		return
	if(broken_hailer)
		to_chat(usr, "<span class='warning'>\The [src]'s screeching system is jammed full of bananas paste.</span>")
		return

	var/phrase = 0	//selects which phrase to use
	var/phrase_text = null
	var/phrase_sound = null


	if(cooldown < world.time - 30) // A cooldown, to stop people being jerks
		recent_uses++
		if(cooldown_special < world.time - 180) //A better cooldown that burns jerks
			recent_uses = initial(recent_uses)

		switch(recent_uses)
			if(3)
				to_chat(usr, "<span class='warning'>\The [src] is starting to smell weird.</span>")
			if(4)
				to_chat(usr, "<span class='userdanger'>\The [src] is smelling like burnt peanuts!</span>")
			if(5) //overload
				broken_hailer = 1
				to_chat(usr, "<span class='userdanger'>\The [src]'s the depleted banana module shorts.</span>")
				new /obj/item/grown/bananapeel(src)
				return

		phrase = rand(1,18)

		if(gorilla)
			phrase_text = "FUCK YOUR CUNT YOU SHIT EATING COCKSTORM AND EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND POO AND SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT."
			phrase_sound = "emag"
		else

			switch(phrase)	//sets the properties of the chosen phrase
				if(1)				// good cop
					phrase_text = "HALT! HALT! HALT!"
					phrase_sound = "monkey2"
				if(2)
					phrase_text = "Stop in the name of the Law."
					phrase_sound = "monkey1"
				if(3)
					phrase_text = "Compliance is in your best interest."
					phrase_sound = "monkey5"
				if(4)
					phrase_text = "Prepare for justice!"
					phrase_sound = "monkey3"
				if(5)
					phrase_text = "Running will only increase your sentence."
					phrase_sound = "monkey4"
				if(6)				// bad cop
					phrase_text = "Don't move, Creep!"
					phrase_sound = "monkey1"
				if(7)
					phrase_text = "Down on the floor, Creep!"
					phrase_sound = "monkey3"
				if(8)
					phrase_text = "Dead or alive you're coming with me."
					phrase_sound = "monkey2"
				if(9)
					phrase_text = "God made today for the crooks we could not catch yesterday."
					phrase_sound = "monkey1"
				if(10)
					phrase_text = "Freeze, Scum Bag!"
					phrase_sound = "monkey4"
				if(11)
					phrase_text = "Stop right there, criminal scum!"
					phrase_sound = "monkey5"
				if(12)				// LA-PD
					phrase_text = "Stop or I'll bash you."
					phrase_sound = "monkey3"
				if(13)
					phrase_text = "Go ahead, make my day."
					phrase_sound = "monkey2"
				if(14)
					phrase_text = "Stop breaking the law, ass hole."
					phrase_sound = "monkey4"
				if(15)
					phrase_text = "You have the right to shut the fuck up."
					phrase_sound = "monkey2"
				if(16)
					phrase_text = "Shut up crime!"
					phrase_sound = "monkey5"
				if(17)
					phrase_text = "Face the wrath of the golden bolt."
					phrase_sound = "monkey1"
				if(18)
					phrase_text = "I am, the LAW!"
					phrase_sound = "monkey3"

		usr.audible_message("[usr]'s Banana-tor:")
		var/list/hearers = get_hearers_in_view(DEFAULT_MESSAGE_RANGE, src)
		var/datum/language/monkeyspeak = GLOB.language_datum_instances[/datum/language/monkey]
		for(var/mob/hear in hearers)
			if(hear.has_language(/datum/language/monkey))
				if(gorilla)
					to_chat(hear, "<font color='brown' size='6'><b>[phrase_text]</b></font>")
				else
					to_chat(hear, "<font color='brown' size='4'><b>[phrase_text]</b></font>")
			if(!hear.has_language(/datum/language/monkey))
				if(gorilla)
					to_chat(hear, "<font color='brown' size='6'><b>[monkeyspeak.scramble(phrase_text)]</b></font>")
				else
					to_chat(hear, "<font color='brown' size='4'><b>[monkeyspeak.scramble(phrase_text)]</b></font>")
		playsound(src.loc, "sound/voice/complionator/monkey/[phrase_sound].ogg", 100, FALSE, 4)
		cooldown = world.time
		cooldown_special = world.time






/obj/item/clothing/mask/gas/sexymime
	name = "sexy mime mask"
	desc = "A traditional female mime's mask."
	clothing_flags = MASKINTERNALS
	icon_state = "sexymime"
	item_state = "sexymime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/death_commando
	name = "Death Commando Mask"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"

/obj/item/clothing/mask/gas/cyborg
	name = "cyborg visor"
	desc = "Beep boop."
	icon_state = "death"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "owl mask"
	desc = "Twoooo!"
	icon_state = "owl"
	clothing_flags = MASKINTERNALS
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/carp
	name = "carp mask"
	desc = "Gnash gnash."
	icon_state = "carp_mask"

/obj/item/clothing/mask/gas/tiki_mask
	name = "tiki mask"
	desc = "A creepy wooden mask. Surprisingly expressive for a poorly carved bit of wood."
	icon_state = "tiki_eyebrow"
	item_state = "tiki_eyebrow"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = null


/obj/item/clothing/mask/gas/tiki_mask/ui_action_click(mob/user)
	var/mob/M = usr
	var/list/options = list()
	options["Original Tiki"] = "tiki_eyebrow"
	options["Happy Tiki"] = "tiki_happy"
	options["Confused Tiki"] = "tiki_confused"
	options["Angry Tiki"] ="tiki_angry"

	var/choice = input(M,"To what form do you wish to change this mask?","Morph Mask") in options

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(M, "The Tiki Mask has now changed into the [choice] Mask!")
		return 1

/obj/item/clothing/mask/gas/tiki_mask/yalp_elor
	icon_state = "tiki_yalp"
	actions_types = list()

/obj/item/clothing/mask/gas/hunter
	name = "bounty hunting mask"
	desc = "A custom tactical mask with decals added."
	icon_state = "hunter"
	item_state = "hunter"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR
