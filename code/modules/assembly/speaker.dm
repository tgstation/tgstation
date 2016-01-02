/obj/item/device/assembly/speaker
	name = "speaker"
	var/real_name = "speaker" //speakers can be renamed with a pen
	desc = "Used to play pre-recorded messages."
	icon_state = "speaker"
	item_state = "speaker"
	starting_materials = list(MAT_IRON = 800, MAT_GLASS = 100)
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"

	var/message = "Thank you for using NanoSpeaker!"

	accessible_values = list("Message" = "message;text")

/obj/item/device/assembly/speaker/activate()
	src.say(message)

/obj/item/device/assembly/speaker/attack_self(mob/user as mob)
	var/new_msg = sanitize(input(user,"Enter new message for the [src]","NanoSpeaker Settings",message))
	if(!Adjacent(user)) return

	message = new_msg

	var/datum/language/language
	if(user.stat == DEAD) //ENGAGE SPOOKS!
		language = all_languages["Spooky"]
	src.say("New message: [message]", language)

/obj/item/device/assembly/speaker/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W,/obj/item/weapon/pen)) //pen
		var/tmp/new_name = sanitize(input(user,"Enter new name for the [src]","NanoSpeaker Settings",name))
		if(new_name != "")
			name = "[real_name] ([new_name])"
		else
			name = real_name

/obj/item/device/assembly/speaker/say(message, var/datum/language/speaking, var/atom/movable/radio=src)
	if(istype(loc, /obj/item/device/assembly_frame)) //When put in assembly frames, the speakers can't be heard.
		var/obj/item/device/assembly_frame/F = loc //This is a workaround
		F.say(message, speaking, radio)
	else
		return ..()

/obj/item/device/assembly/speaker/can_speak()
	return 1
/*
/obj/item/device/assembly/speaker/proc/say(var/msg=message as text)
	var/tmp/location = get_turf(src)
	for(var/mob/O in hearers(location, null)) //to all living
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[msg]\"",2)
*/