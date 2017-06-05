
// **** Security gas mask ****

/obj/item/clothing/mask/gas/sechailer
	name = "security gas mask"
	desc = "A standard issue Security gas mask with integrated 'Compli-o-nator 3000' device. Plays over a dozen pre-recorded compliance phrases designed to get scumbags to stand still whilst you taze them. Do not tamper with the device."
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/adjust)
	icon_state = "sechailer"
	item_state = "sechailer"
	flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACIALHAIR|HIDEFACE
	w_class = WEIGHT_CLASS_SMALL
	visor_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	visor_flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	visor_flags_cover = MASKCOVERSMOUTH
	var/aggressiveness = 2
	var/cooldown_special
	var/recent_uses = 0
	var/broken_hailer = 0
	var/emagged = FALSE

/obj/item/clothing/mask/gas/sechailer/swat
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Compli-o-nator 3000."
	actions_types = list(/datum/action/item_action/halt)
	icon_state = "swat"
	item_state = "swat"
	aggressiveness = 3
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR
	visor_flags_inv = 0

/obj/item/clothing/mask/gas/sechailer/cyborg
	name = "security hailer"
	desc = "A set of recognizable pre-recorded messages for cyborgs to use when apprehending criminals."
	icon = 'icons/obj/device.dmi'
	icon_state = "taperecorder_idle"
	aggressiveness = 1 //Borgs are nicecurity!
	actions_types = list(/datum/action/item_action/halt)

/obj/item/clothing/mask/gas/sechailer/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		switch(aggressiveness)
			if(1)
				to_chat(user, "<span class='notice'>You set the restrictor to the middle position.</span>")
				aggressiveness = 2
			if(2)
				to_chat(user, "<span class='notice'>You set the restrictor to the last position.</span>")
				aggressiveness = 3
			if(3)
				to_chat(user, "<span class='notice'>You set the restrictor to the first position.</span>")
				aggressiveness = 1
			if(4)
				to_chat(user, "<span class='danger'>You adjust the restrictor but nothing happens, probably because it's broken.</span>")
			if(5)
				to_chat(user, "<span class='danger'>The [src]'s Big Guy synthesizer cannot be modified!</span>")
	else if(istype(W, /obj/item/weapon/wirecutters))
		if(emagged)
			to_chat(user, "<span class='danger'>The [src]'s Big Guy synthesizer cannot be broken!</span>")
		else if(aggressiveness != 4)
			to_chat(user, "<span class='danger'>You broke the restrictor!</span>")
			aggressiveness = 4
	else
		..()

/obj/item/clothing/mask/gas/sechailer/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/halt))
		halt()
	else
		adjustmask(user)

/obj/item/clothing/mask/gas/sechailer/attack_self()
	halt()
/obj/item/clothing/mask/gas/sechailer/emag_act(mob/user as mob)
	if(!emagged && aggressiveness != 4)
		var/mob/living/carbon/H = user
		if(H.wear_mask == src)
			emagged = TRUE
			flags |= NODROP // If I pull that off will you die?
			to_chat(user, "<span class='warning'>You overload \the [src]'s Big Guy synthesizer.")
			aggressiveness = 5
		else
			to_chat(user, "<span class='warning'>\The [src]'s Big Guy synthesizer detects it's not on your face and rejects the cryptographic sequencer.</span>")
	else
		return

/obj/item/clothing/mask/gas/sechailer/verb/halt()
	set category = "Object"
	set name = "HALT"
	set src in usr
	if(!isliving(usr))
		return
	if(!can_use(usr))
		return
	if(broken_hailer)
		to_chat(usr, "<span class='warning'>\The [src]'s hailing system is broken.</span>")
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
				to_chat(usr, "<span class='warning'>\The [src] is starting to heat up.</span>")
			if(4)
				to_chat(usr, "<span class='userdanger'>\The [src] is heating up dangerously from overuse!</span>")
			if(5) //overload
				broken_hailer = 1
				to_chat(usr, "<span class='userdanger'>\The [src]'s power modulator overloads and breaks.</span>")
				return

		switch(aggressiveness)		// checks if the user has unlocked the restricted phrases
			if(1)
				phrase = rand(1,5)	// set the upper limit as the phrase above the first 'bad cop' phrase, the mask will only play 'nice' phrases
			if(2)
				phrase = rand(1,11)	// default setting, set upper limit to last 'bad cop' phrase. Mask will play good cop and bad cop phrases
			if(3)
				phrase = rand(1,18)	// user has unlocked all phrases, set upper limit to last phrase. The mask will play all phrases
			if(4)
				phrase = rand(12,26)	// user has broke the restrictor, it will now only play shitcurity phrases and baneposts
			if(5)
				phrase = rand(19, 26)	// user has emagged the mask, it will now only banepost

		switch(phrase)	//sets the properties of the chosen phrase
			if(1)				// good cop
				phrase_text = "HALT! HALT! HALT!"
				phrase_sound = 'sound/voice/complionator/halt.ogg'
			if(2)
				phrase_text = "Stop in the name of the Law."
				phrase_sound = 'sound/voice/complionator/bobby.ogg'
			if(3)
				phrase_text = "Compliance is in your best interest."
				phrase_sound = 'sound/voice/complionator/compliance.ogg'
			if(4)
				phrase_text = "Prepare for justice!"
				phrase_sound = 'sound/voice/complionator/justice.ogg'
			if(5)
				phrase_text = "Running will only increase your sentence."
				phrase_sound = 'sound/voice/complionator/running.ogg'
			if(6)				// bad cop
				phrase_text = "Don't move, Creep!"
				phrase_sound = 'sound/voice/complionator/dontmove.ogg'
			if(7)
				phrase_text = "Down on the floor, Creep!"
				phrase_sound = 'sound/voice/complionator/floor.ogg'
			if(8)
				phrase_text = "Dead or alive you're coming with me."
				phrase_sound = 'sound/voice/complionator/robocop.ogg'
			if(9)
				phrase_text = "God made today for the crooks we could not catch yesterday."
				phrase_sound = 'sound/voice/complionator/god.ogg'
			if(10)
				phrase_text = "Freeze, Scum Bag!"
				phrase_sound = 'sound/voice/complionator/freeze.ogg'
			if(11)
				phrase_text = "Stop right there, criminal scum!"
				phrase_sound = 'sound/voice/complionator/imperial.ogg'
			if(12)				// LA-PD
				phrase_text = "Stop or I'll bash you."
				phrase_sound = 'sound/voice/complionator/bash.ogg'
			if(13)
				phrase_text = "Go ahead, make my day."
				phrase_sound = 'sound/voice/complionator/harry.ogg'
			if(14)
				phrase_text = "Stop breaking the law, ass hole."
				phrase_sound = 'sound/voice/complionator/asshole.ogg'
			if(15)
				phrase_text = "You have the right to shut the fuck up."
				phrase_sound = 'sound/voice/complionator/stfu.ogg'
			if(16)
				phrase_text = "Shut up crime!"
				phrase_sound = 'sound/voice/complionator/shutup.ogg'
			if(17)
				phrase_text = "Face the wrath of the golden bolt."
				phrase_sound = 'sound/voice/complionator/super.ogg'
			if(18)
				phrase_text = "I am, the LAW!"
				phrase_sound = 'sound/voice/complionator/dredd.ogg'
			if(19)				// Bane?
				phrase_text = "Well congratulations, you got yourself caught!"
				phrase_sound = 'hippiestation/sound/voice/complionator/bane1.ogg'
			if(20)
				phrase_text = "Now, what's the next step of your master plan?"
				phrase_sound = 'hippiestation/sound/voice/complionator/bane2.ogg'
			if(21)
				phrase_text = "No, this can't be happening! I'm in charge here!"
				phrase_sound = 'hippiestation/sound/voice/complionator/bane3.ogg'
			if(22)
				phrase_text = "They work for the mercenary... the masked man."
				phrase_sound = 'hippiestation/sound/voice/complionator/bane4.ogg'
			if(23)
				phrase_text = "He didn't fly so good! Who wants to try next?"
				phrase_sound = 'hippiestation/sound/voice/complionator/bane5.ogg'
			if(24)
				phrase_text = "First one to talk gets to stay on my station!"
				phrase_sound = 'hippiestation/sound/voice/complionator/bane6.ogg'
			if(25)
				phrase_text = "Dr. Pavel, I'm security."
				phrase_sound = 'hippiestation/sound/voice/complionator/bane7.ogg'
			if(26)
				phrase_text = "You're a big guy!"
				phrase_sound = 'hippiestation/sound/voice/complionator/bane8.ogg'

		usr.audible_message("[usr]'s Compli-o-Nator: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, phrase_sound, 100, 0, 4)
		cooldown = world.time
		cooldown_special = world.time