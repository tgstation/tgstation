#define NOSIGNAL_CODE 30

/obj/item/device/deskbell
	name = "desk bell"
	desc = "ding. ding."
	icon_state = "deskbell_2"
	force = 5
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	attack_verb = list("rang")
	hitsound = 'sound/machines/ding2.ogg'
	m_amt = 3750
	w_type = RECYK_METAL
	melt_temperature=MELTPOINT_STEEL
	anchored = 1
	origin_tech = "materials=1"

	var/frequency = 1457
	var/code = 0	//since no remote signaling device can set its code to 0, deskbells spawned manually(like those existing at round start) won't trigger any signaler (but they'll still trigger the PDA ringer app)

	var/ring_delay = 20
	var/last_ring_time = 0

/obj/item/device/deskbell/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/wrench))
		user.visible_message(	"[user] begins to [anchored ? "undo" : "wrench"] \the [src]'s securing bolts.",
							"You begin to [anchored ? "undo" : "wrench"] \the [src]'s securing bolts...")
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 30))
			anchored = !anchored
			user.visible_message(	"<span class='notice'>[user] [anchored ? "wrench" : "unwrench"]es \the [src] [anchored ? "in place" : "from its fixture"]</span>",
									"<span class='notice'>\icon[src] You [anchored ? "wrench" : "unwrench"] \the [src] [anchored ? "in place" : "from its fixture"].</span>",
									"<span class='notice'>You hear a ratchet.</span>")
		return

	if(istype(W,/obj/item/weapon/screwdriver))
		if(anchored)
			user << "You need to unwrench \the [src] first."
			return
		var/obj/item/device/deskbell_assembly/A = new /obj/item/device/deskbell_assembly(get_turf(src))
		A.frequency = frequency
		A.has_signaler = 0
		A.build_step = 1
		A.final_name = name
		A.update_icon()
		qdel(src)
		return

	ring(user)
	..()

/obj/item/device/deskbell/attack_self(mob/living/carbon/user)
	return attack_hand(user)

/obj/item/device/deskbell/attack_paw(var/mob/user)
	return attack_hand(user)

/obj/item/device/deskbell/attack_animal(var/mob/user)
	return attack_hand(user)

/obj/item/device/deskbell/attack_hand(var/mob/user)
	ring()
	add_fingerprint(user)
	return

/obj/item/device/deskbell/proc/ring()
	if(world.time - last_ring_time >= ring_delay)
		last_ring_time = world.time
		flick("[icon_state]-push", src)
		playsound(src, 'sound/machines/ding2.ogg', 50, 1)
		return 1
	return 0

/obj/item/device/deskbell/MouseDrop(mob/user as mob)
	if((user == usr && (!( usr.restrained() ) && (!( usr.stat ) && (usr.contents.Find(src) || in_range(src, usr))))))
		if(istype(user, /mob/living/carbon/human) || istype(user, /mob/living/carbon/monkey))
			if(anchored)
				user << "You must undo the securing bolts before you can pick it up."
				return
			if( !user.get_active_hand() )		//if active hand is empty
				src.loc = user
				user.put_in_hands(src)
				user.visible_message("<span class='notice'>[user] picks up the [src].</span>", "<span class='notice'>You grab [src] from the floor!</span>")

	return

/////////////////

/obj/item/device/deskbell/signaler
	desc = "When calling on the radio isn't working anymore."
	icon_state = "deskbell_2alt"
	origin_tech = "materials=1;magnets=1"

	var/datum/radio_frequency/radio_connection

/obj/item/device/deskbell/signaler/New()
	..()
	spawn(40)//giving time for the radio_controller to initialize
		if(!radio_controller)
			spawn(20)
				if(!radio_controller)
					visible_message("Cannot initialize the radio_controller, this is a bug, tell a coder")
					return
				else
					radio_controller.remove_object(src, frequency)
					radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)
		else
			radio_controller.remove_object(src, frequency)
			radio_connection = radio_controller.add_object(src, frequency, RADIO_CHAT)

/obj/item/device/deskbell/signaler/attackby(obj/item/W, mob/user)
	if(istype(W,/obj/item/weapon/wrench))
		user.visible_message(	"[user] begins to [anchored ? "undo" : "wrench"] \the [src]'s securing bolts.",
							"You begin to [anchored ? "undo" : "wrench"] \the [src]'s securing bolts...")
		playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 30))
			anchored = !anchored
			user.visible_message(
				"<span class='notice'>[user] [anchored ? "wrench" : "unwrench"]es \the [src] [anchored ? "in place" : "from its fixture"]</span>",
				"<span class='notice'>\icon[src] You [anchored ? "wrench" : "unwrench"] \the [src] [anchored ? "in place" : "from its fixture"].</span>",
				"<span class='notice'>You hear a ratchet.</span>"
				)
		return

	if(istype(W,/obj/item/weapon/screwdriver))
		if(anchored)
			user << "You need to unwrench \the [src] first."
			return
		var/obj/item/device/deskbell_assembly/A = new /obj/item/device/deskbell_assembly(get_turf(src))
		A.frequency = frequency
		A.code = code
		A.has_signaler = 1
		A.build_step = 1
		A.update_icon()
		radio_controller.remove_object(src, frequency)
		qdel(src)
		return

	ring(user)
	..()

/obj/item/device/deskbell/signaler/ring()
	if(..())
		for(var/obj/item/device/pda/ring_pda in PDAs)
			if(!ring_pda.owner || (ring_pda == src) || ring_pda.hidden)
				continue
			var/datum/pda_app/ringer/ringerdatum = locate(/datum/pda_app/ringer) in ring_pda.applications
			if(!ringerdatum || !(ringerdatum.status))
				continue
			if(frequency == ringerdatum.frequency)
				playsound(ring_pda, 'sound/machines/notify.ogg', 50, 1)
				visible_message("\icon[ring_pda] *[src.name]*")


		if(!radio_connection) return	//the desk bell also works like a simple send-only signaler.

		var/datum/signal/signal = new
		signal.source = src
		signal.encryption = code					//Since its default code is 0, which cannot be set on a remote signaling device,
		signal.data["message"] = "ACTIVATE"			//there is no risk that one of the desk bells already there at round start could trigger a signaler
		radio_connection.post_signal(src, signal)	//(unless it's been deconstructed-reconstructed of course)

		var/time = time2text(world.realtime,"hh:mm:ss")
		var/turf/T = get_turf(src)
		if(usr)
			var/mob/user = usr
			if(user)
				lastsignalers.Add("[time] <B>:</B> [user.key] used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")
			else
				lastsignalers.Add("[time] <B>:</B> (<span class='danger'>NO USER FOUND</span>) used [src] @ location ([T.x],[T.y],[T.z]) <B>:</B> [format_frequency(frequency)]/[code]")
		return

//////////////////

/obj/item/device/deskbell/signaler/hop
	name = "HoP desk bell"

/obj/item/device/deskbell/signaler/hop/New()
	. = ..()
	frequency = deskbell_freq_hop

/obj/item/device/deskbell/signaler/medbay
	name = "Medbay lobby bell"

/obj/item/device/deskbell/signaler/medbay/New()
	. = ..()
	frequency = deskbell_freq_medbay

/obj/item/device/deskbell/signaler/brig
	name = "Brig entrance bell"

/obj/item/device/deskbell/signaler/brig/New()
	. = ..()
	frequency = deskbell_freq_brig

/obj/item/device/deskbell/signaler/rnd
	name = "R&D counter bell"

/obj/item/device/deskbell/signaler/rnd/New()
	. = ..()
	frequency = deskbell_freq_rnd

/////ASSEMBLY/////

/obj/item/device/deskbell_assembly
	name = "desk bell shell"
	desc = "An unfinished desk bell."
	icon_state = "deskbell_0"
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 3750
	w_type = RECYK_METAL
	melt_temperature=MELTPOINT_STEEL

	var/frequency = 1457
	var/code = 0

	var/build_step = 0
	var/has_signaler = 0

	var/final_name = ""

/obj/item/device/deskbell_assembly/update_icon()
	icon_state = "deskbell_[build_step][has_signaler ? "alt" : ""]"
	if(final_name)
		name = "[initial(name)] labelled as \"[final_name]\""

/obj/item/device/deskbell_assembly/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new desk bell name", src.name, final_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, user) && src.loc != user)
			return
		final_name = t
	else
		switch(build_step)
			if(0)
				if(istype(W,/obj/item/weapon/wrench))
					user << "<span class='notice'>You deconstruct \the [src].</span>"
					playsound(get_turf(src), 'sound/items/Ratchet.ogg', 50, 1)
					new /obj/item/stack/sheet/metal( get_turf(src.loc), 2)
					qdel(src)
					return
				if(istype(W,/obj/item/weapon/cable_coil))
					var/obj/item/weapon/cable_coil/C=W
					user.visible_message(
						"<span class='warning'>[user.name] has added cables to \the [src]!</span>",
						"You add cables to \the [src].")
					playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 50, 1)
					C.use(1)
					build_step++
					update_icon()
					return
				if(istype(W,/obj/item/device/assembly/signaler))
					user << "<span class='warning'>You must add wires first.</span>"
					return
			if(1)
				if(istype(W,/obj/item/weapon/wirecutters))
					if(has_signaler)
						user << "<span class='warning'>You must remove the signaler first.</span>"
						return
					new /obj/item/weapon/cable_coil(get_turf(src),1)
					user.visible_message(
						"<span class='warning'>[user.name] cut the cables.</span>",
						"You cut the cables.")
					build_step--
					update_icon()
					return
				if(istype(W,/obj/item/weapon/screwdriver))
					var/obj/item/device/deskbell/D = null
					if(has_signaler)
						D = new /obj/item/device/deskbell/signaler(get_turf(src))
					else
						D = new /obj/item/device/deskbell(get_turf(src))
					D.anchored = 0
					D.frequency = frequency
					D.code = code
					if(final_name)
						D.name = final_name
					user << "<span class='notice'>You finish \the [D].</span>"
					qdel(src)
					return
				if(istype(W,/obj/item/device/assembly/signaler) && !has_signaler)
					var/obj/item/device/assembly/signaler/S = W
					frequency = S.frequency
					if(S.code == NOSIGNAL_CODE)	//setting a code of "30" guarantees that you'll never be triggering any remote signaling devices.
						code = 0
					else
						code = S.code
					user.drop_item()
					del(W)
					has_signaler = 1
					update_icon()
					return

/obj/item/device/deskbell_assembly/attack_self(mob/living/carbon/user)
	if(has_signaler)
		user << "<span class='notice'>You remove the signaling device.</span>"
		var/obj/item/device/assembly/signaler/S = new /obj/item/device/assembly/signaler(get_turf(src))
		S.frequency = frequency
		if(code != 0)
			S.code = code
		else
			S.code = NOSIGNAL_CODE
		frequency = 1457
		code = 0
		has_signaler = 0
		update_icon()

//////////////////

//these frequencies are set by default on the PDAs of the corresponding jobs
//they are determined at roundstart, and unlike radio frequencies (yet) are randomized
var/global/list/deskbell_default_frequencies = list()
var/global/deskbell_freq_hop = call(/obj/item/device/deskbell/signaler/proc/get_new_bellfreq)()
var/global/deskbell_freq_medbay = call(/obj/item/device/deskbell/signaler/proc/get_new_bellfreq)()
var/global/deskbell_freq_brig = call(/obj/item/device/deskbell/signaler/proc/get_new_bellfreq)()
var/global/deskbell_freq_rnd = call(/obj/item/device/deskbell/signaler/proc/get_new_bellfreq)()

/obj/item/device/deskbell/signaler/proc/get_new_bellfreq()
	var/i = rand(MINIMUM_FREQUENCY,MAXIMUM_FREQUENCY)
	if ((i % 2) == 0) //Ensure the last digit is an odd number
		i += 1
	while(locate(i) in deskbell_default_frequencies)//To make sure that the round start desk bells don't ever share their frequencies
		i = rand(MINIMUM_FREQUENCY,MAXIMUM_FREQUENCY)
		if ((i % 2) == 0)
			i += 1
	deskbell_default_frequencies += i
	return i
