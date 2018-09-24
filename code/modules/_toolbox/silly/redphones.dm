/obj/item/phone
	flags_1 = HEAR_1
	var/broken = 0 //broken phones can be fixed by adding 2 wires, and made broken by using a wirecutter. Cutting its wires yields 2 wires on the floor below your mob.
	var/phonenumber = 0 //The phones number, 4 digits. If left 0 then a random number is selected in New(). This allows you to create static numbers when mapping by replacing 0 with any 4 digit number.
	var/obj/item/phone/linkedphone = null
	var/ringing = 0
	var/area/label_text = "" //This is the phones label that appears in the list when making a call. When left empty the phone copies the area name in New(), but only if label var is enabled.
	var/list/multivoice_list = list()
	var/labeled = 1 //having this start set to 0 allows someone to label the phone to whatever they want with a pen.
	var/can_call_out = 1 //setting this to 0 makes it so the phone cannot make calls, only recieve calls. Good for prison cells and things like that. Can be toggled with a multitool.

/obj/item/phone/Destroy()
	disconnect()
	return ..()

//New() attempts to generate a random phonenumber if no phonenumber is given and copies the areas name for the label if not flagged as labeled. This will create a phone named something like (5398 - Captain's Office Phone.)
/obj/item/phone/New()
	desc = "It's a Telephone."
	if(!labeled)
		label_text = "Unknown"
	if(!label_text)
		var/area/thearea = get_area(src)
		if(thearea)
			label_text = thearea.name
	if(labeled)
		name = "[label_text] phone"
	if(((!phonenumber)|(phonenumber > 9999)|(phonenumber < 1000)))
		phonenumber = rand(1000,9999)
	var/list/phonebook = list()
	for(var/obj/item/phone/P in world)
		if(P == src)
			continue
		phonebook += P.phonenumber
	if(phonenumber in phonebook)
		var/duplicate = 1
		while(duplicate)
			if(phonenumber in phonebook)
				phonenumber = rand(1000,9999)
			else
				duplicate = 0
	..()

/obj/item/phone/examine()
	..()
	if(broken)
		to_chat(usr,"<span class='warning'>It appears to be broken!</span>")
	else
		to_chat(usr,"<span class='notice'>The phone number is '<b>[phonenumber]</b>'.</span>")
		if(linkedphone && !ringing)
			to_chat(usr,"\red The line is open with number <B>[linkedphone.phonenumber]</B>.</span>")

/obj/item/phone/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(istype(O,/obj/item/stack/cable_coil) && broken)
		var/obj/item/stack/cable_coil/coil = O
		if(coil.amount >= 2)
			coil.use(2)
			broken = 0
			to_chat(user,"<span class='notice'>You wire the [src].</span>")
		else
			to_chat(user,"<span class='warning'>You need two wires!</span>")
		return
	if(istype(O, /obj/item/wirecutters) && !broken)
		var/obj/item/stack/cable_coil/coil = new(get_turf(src))
		broken = 1
		coil.amount = 2
		coil.update_icon()
		to_chat(user,"<span class='notice'>You cut the wires out of the [src].</span>")
		disconnect(1)
		return
	if(istype(O,/obj/item/pen))
		if(labeled)
			to_chat(user,"\red This already has a label.")
			return
		var/thelabel
		var/new_label = input(user, thelabel, "Phone Label")
		if(length(new_label) > 32)
			to_chat(user,"\red That label is too long. 32 characters max.")
			return
		if(get_dist(get_turf(src),get_turf(user)) > 1)
			return
		new_label = strip_html_simple(new_label, 32)
		label_text = new_label
		to_chat(user,"\blue You label the [src.name].")
		name = "[label_text] phone"
		labeled = 1
		return
	if(istype(O,/obj/item/device/multitool))
		if(!can_call_out)
			to_chat(user,"\blue This phone can now call out.")
		else
			to_chat(user,"\blue You disable this phones ability to call out.")
		can_call_out = !can_call_out
		return

/obj/item/phone/proc/message_user(var/message = "")
	if(!message)
		return
	for(var/mob/M in viewers(7,get_turf(src)))
		if(M.stat && istype(M,/mob/living))
			continue
		if(!M.can_hear())
			to_chat(M,"<I>A voice speaks on the [name] but you can't hear it.</I>")
			continue
		if(istype(M, /mob/living/carbon) && !istype(M, /mob/living/carbon/human) && !istype(M, /mob/living/simple_animal/slime))
			to_chat(M,"A voice speaks on the [name] but you don't understand it.")
			continue
		to_chat(M,"<B>[name]:</B> [message]")

/obj/item/phone/on_enter_storage(obj/item/storage/S as obj)
	if(linkedphone)
		var/atom/A = src
		while(A.loc && !istype(A,/mob) && !istype(A,/turf))
			A = A.loc
		if(istype(A,/mob))
			to_chat(A,"\red <I>No one can hear you on the phone while it is in the [S.name].</I>")
	return ..()

/obj/item/phone/attack_self(mob/user as mob)
	src.add_fingerprint(user)
	if(broken)
		to_chat(user,"<span class='warning'>This phone appears to be broken!</b>.</span>")
		return
	if(!linkedphone)
		ringing = 0
		var/list/phone_list = list()
		for(var/obj/item/phone/P in world)
			if(((P == src)|(P.broken)))
				continue
			var/phonename = "[P.phonenumber] - [P.label_text]"
			phone_list += phonename
			phone_list[phonename] = P
		var/obj/item/phone/selected = input("Select a phone to call.", null) as null|anything in phone_list
		selected = phone_list[selected]
		if(linkedphone)
			to_chat(user,"<span class='warning'>Call Cancled.</span>")
			return
		if(((!istype(selected,/obj/item/phone)|(loc != user && get_dist(src,user) > 1))))
			to_chat(user,"<span class='warning'>Call Cancled.</span>")
			return
		if(!can_call_out)
			to_chat(user,"<span class='warning'>This phone cannot call out.</span>")
			return
		if(selected.linkedphone)
			to_chat(user,"<span class='warning'>The line is busy.</span>")
			return
		to_chat(user,"\blue Calling number [selected.phonenumber].")
		Call_Phone(selected)
		return
	else
		if(ringing)
			ringing = 0
			to_chat(user,"<span class='notice'>You answer the phone. The caller id reads [linkedphone.phonenumber].</span>")
			to_chat(user,"<I></B>Anyone on the other end can now hear your voice.</B></I>")
			linkedphone.message_user("Someone has answered on the other end of the line.")
			return
		else
			to_chat(user,"<span class='notice'>You hang up the phone.</span>")
			if(!linkedphone.ringing)
				linkedphone.message_user("The person on the other end has hung up.")
			disconnect()
			return

/obj/item/phone/proc/Call_Phone(var/obj/item/phone/phone)
	if(((!phone)|(phone.linkedphone)|(phone.ringing)|(ringing)))
		return
	if(phone.Receive_Call(src))
		linkedphone = phone

/obj/item/phone/proc/Receive_Call(var/obj/item/phone/phone)
	if(!phone)
		return 0
	if(linkedphone)
		return 0
	linkedphone = phone
	ringing = 1
	var/phonesave = phone
	spawn(150)
		if(linkedphone && ringing && phonesave == linkedphone)
			ringing = 0
			linkedphone.message_user("No answer from [phonenumber].")
			disconnect()
			return
	spawn(0)
		var/xsave = pixel_x
		var/ysave = pixel_y
		while(ringing && linkedphone)
			playsound(loc, 'sound/weapons/ring.ogg', 50, 0)
			for(var/mob/M in viewers(7,get_turf(src)))
				to_chat(M,"\red [name] is ringing.")
			spawn(0)
				for(var/i=5,i>0,i--)
					pixel_x = rand(-1,1)
					pixel_y = rand(-1,1)
					sleep(1)
				pixel_x = xsave
				pixel_y = ysave
			sleep(20)
	return 1


/obj/item/phone/proc/disconnect(var/alert_linkedphone = 0)
	if(!linkedphone)
		return
	ringing = 0
	multivoice_list = list()
	if(alert_linkedphone)
		linkedphone.message_user("Line abruptly disconnected.")
	var/obj/item/phone/phone = linkedphone
	linkedphone = null
	phone.disconnect()

//this proc is already in ss13 source and is called by all objects around a mob when they speak including all objects inside other mobs. But only 1 loc deep. This proc will not be called on objects inside a mobs backpack.
/obj/item/phone/Hear(message, atom/movable/user, message_langs, raw_message, radio_freq, spans, message_mode)
	if(!istype(user,/mob/living))
		return
	if(raw_message)
		message = raw_message
	send_voice(user, message)

/obj/item/phone/proc/send_voice(var/mob/user, var/message)//The phone has its own hear proc to be called by Hear(). This prevents any issues caused when an admin uses the phonesay verb as a ghost.
	if(((!user)|(!message)))
		return
	if(linkedphone && !ringing && !linkedphone.ringing)
		var/number = ""
		if(!(user in multivoice_list))
			multivoice_list += user
			number = "[multivoice_list.len]"
			multivoice_list[user] = number
		number = multivoice_list[user]
		if(number == "1")
			number = ""
		else
			number = " [number]"
		if(istype(user, /mob/living/carbon) && !istype(user, /mob/living/carbon/human) && !istype(user, /mob/living/simple_animal/slime))
			if(istype(user, /mob/living/carbon/monkey))
				message = "Chimper!"
				linkedphone.message_user("<I>Anonymous Voice[number] says,</I> \"[message]\"")
			else if(istype(user, /mob/living/carbon/alien/humanoid))
				var/numberofs = rand(2,5)
				var/thehis = "Hi"
				for(var/i=numberofs,i>0,i--)
					thehis += "s"
				message = "[thehis]!"
				linkedphone.message_user("<I>Anonymous Voice[number] says,</I> \"[message]\"")
			else
				message = "something unintelligible"
				linkedphone.message_user("<I>Anonymous Voice[number] says [message].</I>")
		else
			linkedphone.message_user("<I>Anonymous Voice[number] says,</I> \"[message]\"")

		//log game
		var/list/Listeners = list()
		if(((istype(loc, /turf))|(istype(loc, /mob))))
			for(var/mob/living/G in viewers(7,get_turf(linkedphone)))
				if(!G.client)
					continue
				if(!G.can_hear())
					continue
				if(istype(G, /mob/living/carbon) && !istype(G, /mob/living/carbon/human) && !istype(G, /mob/living/simple_animal/slime))
					continue
				Listeners += G
		var/listener_text = ""
		for(var/mob/M in Listeners)
			listener_text += "([M.real_name]/[M.key])"
		if(!listener_text)
			listener_text = "No body"
		log_game("TELEPHONE: Message:\"[message]\". Sender:([user.real_name]/[user.key]). Listeners:[listener_text].")

		//if noone hears because they walked away or its in their backpack
		if(!Listeners.len)
			var/isadmin = 0
			//checking to see if the caller was an admin ghost.
			for(var/mob/dead/observer/O in world)
				if(!O.client)
					continue
				if(!O.client.holder)
					continue
				if(linkedphone.fingerprintslast == O.ckey)
					isadmin = 1
					break
			if(!isadmin)
				spawn(20)
					to_chat(user,"You hear nothing but silence from the phone.")


/*
Adminverb allowing an admin to use a phone as a ghost. Giving no message will call attack_hand() allowing you to make the call or hang up.
Typing a message will send the message typed to the phone. To use this, hover your ghost over a phone and type phonesay.
The phone will be detected by this verb if it's carried by a mob or sitting on a turf under your ghost.
*/
/client/proc/phonesay(var/message as text)
	set name = "phonesay"
	set category = "Fun"
	//Verb is hidden. You can change this if that is your preference
	set hidden = 1
	if(!holder)
		return
	if(!istype(mob, /mob/dead/observer))
		return
	var/location = get_turf(mob)
	if(!location)
		return
	var/obj/item/phone/phone = null
	for(var/obj/item/phone/P in world)
		if(get_turf(P) != location)
			continue
		phone = P
		break
	if(phone)
		if(!message)
			if(phone.linkedphone && !phone.ringing)
				var/hangup = alert(mob, "Do you want to hang up?","Hang up?","Yes","No")
				if(hangup != "Yes")
					return
			return phone.attack_self(usr)
		if(phone.linkedphone && !phone.ringing && message)
			to_chat(mob,"<font color='blue'>The phone hears: <B>[mob.name]</B> says, \"[message]\"</font>")
			return phone.send_voice(mob, message, 1)
		return
	else
		to_chat(usr,"<span class='warning'>There is no phone under you.</span>")

//A phone that spawns broken and unlabeled. This could be used for things like cargo crate orders.
/obj/item/phone/broken
	broken = 1
	labeled = 0

/datum/supply_pack/misc/phones
	name = "Phones"
	cost = 1000
	contains = list(
		/obj/item/phone/broken,
		/obj/item/phone/broken,
		/obj/item/phone/broken)
	crate_name = "phone crate"