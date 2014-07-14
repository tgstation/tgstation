/obj/item/device/assembly/speaker
	name = "speaker"
	var/real_name = "speaker" //speakers can be renamed with a pen
	desc = "Used to play pre-recorded messages."
	icon_state = "speaker"
	item_state = "speaker"
	m_amt = 800
	g_amt = 100
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"

	var/message = "Thank you for using NanoSpeaker!"

/obj/item/device/assembly/speaker/activate()
	var/tmp/location = get_turf(src)
	for(var/mob/O in hearers(location, null))
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[message]\"",2)

/obj/item/device/assembly/speaker/attack_self(mob/user as mob)
	message = sanitize(input(user,"Enter new message for the [src]","NanoSpeaker Settings",message))
	src.say("New message: [message]")

/obj/item/device/assembly/speaker/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(istype(W,/obj/item/weapon/pen)) //pen
		var/tmp/new_name = sanitize(input(user,"Enter new name for the [src]","NanoSpeaker Settings",name))
		if(new_name != "")
			name = "[real_name] ([new_name])"
		else
			name = real_name

/obj/item/device/assembly/speaker/proc/say(var/msg=message as text)
	var/tmp/location = get_turf(src)
	for(var/mob/O in hearers(location, null)) //to all living
		O.show_message("<span class='game say'><span class='name'>[src]</span> beeps, \"[msg]\"",2)