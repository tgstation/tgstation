/*/obj/item/assembly
	name = "assembly"
	icon = 'icons/obj/assemblies.dmi'
	item_state = "assembly"
	var/status = 0.0
	throwforce = 10
	w_class = 3.0
	throw_speed = 4
	throw_range = 10

/obj/item/assembly/a_i_a
	name = "Health-Analyzer/Igniter/Armor Assembly"
	desc = "A health-analyzer, igniter and armor assembly."
	icon_state = "armor-igniter-analyzer"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/clothing/suit/armor/vest/part3 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/m_i_ptank
	desc = "A very intricate igniter and proximity sensor electrical assembly mounted onto top of a plasma tank."
	name = "Proximity/Igniter/Plasma Tank Assembly"
	icon_state = "prox-igniter-tank0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/prox_ignite
	name = "Proximity/Igniter Assembly"
	desc = "A proximity-activated igniter assembly."
	icon_state = "prox-igniter0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/r_i_ptank
	desc = "A very intricate igniter and signaller electrical assembly mounted onto top of a plasma tank."
	name = "Radio/Igniter/Plasma Tank Assembly"
	icon_state = "radio-igniter-tank"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/anal_ignite
	name = "Health-Analyzer/Igniter Assembly"
	desc = "A health-analyzer igniter assembly."
	icon_state = "timer-igniter0"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"

/obj/item/assembly/time_ignite
	name = "Timer/Igniter Assembly"
	desc = "A timer-activated igniter assembly."
	icon_state = "timer-igniter0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/t_i_ptank
	desc = "A very intricate igniter and timer assembly mounted onto top of a plasma tank."
	name = "Timer/Igniter/Plasma Tank Assembly"
	icon_state = "timer-igniter-tank0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_ignite
	name = "Radio/Igniter Assembly"
	desc = "A radio-activated igniter assembly."
	icon_state = "radio-igniter"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_infra
	name = "Signaller/Infrared Assembly"
	desc = "An infrared-activated radio signaller"
	icon_state = "infrared-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/infra/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_prox
	name = "Signaller/Prox Sensor Assembly"
	desc = "A proximity-activated radio signaller."
	icon_state = "prox-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/prox_sensor/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_time
	name = "Signaller/Timer Assembly"
	desc = "A radio signaller activated by a count-down timer."
	icon_state = "timer-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/timer/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
*/

/obj/item/assembly/time_ignite/premade/New()
	..()
	part1 = new(src)
	part2 = new(src)
	part1.master = src
	part2.master = src
	//part2.status = 0

/obj/item/assembly/time_ignite/Del()
	del(part1)
	del(part2)
	..()

/obj/item/assembly/time_ignite/attack_self(mob/user as mob)
	if (src.part1)
		src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_ignite/receive_signal()
	if (!status)
		return
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.Activate()
	return

/obj/effect/decal/ash/attack_hand(mob/user as mob)
	usr << "\blue The ashes slip through your fingers."
	del(src)
	return

/obj/item/assembly/time_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part1.master = null
		src.part1 = null
		src.part2.loc = T
		src.part2.master = null
		src.part2 = null

		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The timer is now secured!", 1)
	else
		user.show_message("\blue The timer is now unsecured!", 1)
	src.part2.secured = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/time_ignite/c_state(n)
	src.icon_state = text("timer-igniter[]", n)
	return

//***********

/obj/item/assembly/anal_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part1.master = null
		src.part1 = null
		src.part2.loc = T
		src.part2.master = null
		src.part2 = null

		del(src)
		return
	if (( istype(W, /obj/item/weapon/screwdriver) ))
		src.status = !( src.status )
		if (src.status)
			user.show_message("\blue The analyzer is now secured!", 1)
		else
			user.show_message("\blue The analyzer is now unsecured!", 1)
		src.part2.secured = src.status
		src.add_fingerprint(user)
	if(( istype(W, /obj/item/clothing/suit/armor/vest) ) && src.status)
		var/obj/item/assembly/a_i_a/R = new
		R.part1 = part1
		R.part1.master = R
		part1 = null

		R.part2 = part2
		R.part2.master = R
		part2 = null

		user.put_in_hand(R)
		user.before_take_item(W)
		R.part3 = W
		R.part3.master = R
		del(src)

/* WTF THIS SHIT? It is working? Shouldn't. --rastaf0
		W.loc = R
		R.part1 = W
		R.part2 = W
		W.layer = initial(W.layer)
		if (user.client)
			user.client.screen -= W
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = R
		else
			user.u_equip(W)
			user.l_hand = R
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part3 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)
*/
	return
/*	else if ((istype(W, /obj/item/device/timer) && !( src.status )))

		var/obj/item/assembly/time_ignite/R = new /obj/item/assembly/time_ignite( user )
		W.loc = R
		R.part1 = W
		W.layer = initial(W.layer)
		if (user.client)
			user.client.screen -= W
		if (user.r_hand == W)
			user.u_equip(W)
			user.r_hand = R
		else
			user.u_equip(W)
			user.l_hand = R
		W.master = R
		src.master = R
		src.layer = initial(src.layer)
		user.u_equip(src)
		if (user.client)
			user.client.screen -= src
		src.loc = R
		R.part2 = src
		R.layer = 20
		R.loc = user
		src.add_fingerprint(user)
*/

/obj/item/assembly/proc/c_state(n, O as obj)
	return

/obj/item/assembly/a_i_a/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part1.master = null
		src.part1 = null
		src.part2.loc = T
		src.part2.master = null
		src.part2 = null
		src.part3.loc = T
		src.part3.master = null
		src.part3 = null

		del(src)
		return
	if (( istype(W, /obj/item/weapon/screwdriver) ))
		if (!src.status && (!part1||!part2||!part3))
			user << "\red You cannot finish the assembly, not all components are in place!"
			return
		src.status = !( src.status )
		if (src.status)
			user.show_message("\blue The armor is now secured!", 1)
		else
			user.show_message("\blue The armor is now unsecured!", 1)
		src.add_fingerprint(user)

/obj/item/assembly/a_i_a/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	del(src.part3)
	..()
	return
//*****

/obj/item/assembly/rad_time/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/assembly/rad_time/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The signaler is now secured!", 1)
	else
		user.show_message("\blue The signaler is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_time/receive_signal(datum/signal/signal)
	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return
//*******************
/obj/item/assembly/rad_prox/c_state(n)
	src.icon_state = "prox-radio[n]"
	return

/obj/item/assembly/rad_prox/Del()
	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	..()
	return

/obj/item/assembly/rad_prox/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/effect/beam))
		return
	if (AM.move_speed < 12)
		src.part2.sense()
	return

/obj/item/assembly/rad_prox/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The proximity sensor is now secured!", 1)
	else
		user.show_message("\blue The proximity sensor is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_prox/receive_signal(datum/signal/signal)
	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_prox/Move()
	..()
	src.part2.sense()
	return

/obj/item/assembly/rad_prox/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/assembly/rad_prox/dropped()
	spawn( 0 )
		src.part2.sense()
		return
	return
//************************
/obj/item/assembly/rad_infra/c_state(n)
	src.icon_state = text("infrared-radio[]", n)
	return

/obj/item/assembly/rad_infra/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/assembly/rad_infra/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The infrared laser is now secured!", 1)
	else
		user.show_message("\blue The infrared laser is now unsecured!", 1)
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_infra/attack_self(mob/user as mob)
	src.part1.attack_self(user, src.status)
	src.part2.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_infra/receive_signal(datum/signal/signal)

	if (signal.source == src.part2)
		src.part1.send_signal("ACTIVATE")
	return

/obj/item/assembly/rad_infra/verb/rotate()
	set name = "Rotate Assembly"
	set category = "Object"
	set src in usr

	src.dir = turn(src.dir, 90)
	src.part2.dir = src.dir
	src.add_fingerprint(usr)
	return

/obj/item/assembly/rad_infra/Move()

	var/t = src.dir
	..()
	src.dir = t
	//src.part2.first = null
	del(src.part2.first)
	return

/obj/item/assembly/rad_infra/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/item/assembly/rad_infra/attack_hand(M)
	del(src.part2.first)
	..()
	return

/obj/item/assembly/prox_ignite/HasProximity(atom/movable/AM as mob|obj)

	if (istype(AM, /obj/effect/beam))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return

/obj/item/assembly/prox_ignite/dropped()
	spawn( 0 )
		src.part1.sense()
		return
	return

/obj/item/assembly/prox_ignite/Del()
	del(src.part1)
	del(src.part2)
	..()
	return

/obj/item/assembly/prox_ignite/c_state(n)
	src.icon_state = text("prox-igniter[]", n)
	return

/obj/item/assembly/prox_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The proximity sensor is now secured! The igniter now works!", 1)
	else
		user.show_message("\blue The proximity sensor is now unsecured! The igniter will not work.", 1)
	src.part2.secured = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/prox_ignite/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/prox_ignite/receive_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.Activate()
	return

/obj/item/assembly/rad_ignite/Del()
	del(src.part1)
	del(src.part2)
	..()
	return



/obj/item/assembly/rad_ignite/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/turf/T = src.loc
		if (ismob(T))
			T = T.loc
		src.part1.loc = T
		src.part2.loc = T
		src.part1.master = null
		src.part2.master = null
		src.part1 = null
		src.part2 = null
		//SN src = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/screwdriver) ))
		return
	src.status = !( src.status )
	if (src.status)
		user.show_message("\blue The radio is now secured! The igniter now works!", 1)
	else
		user.show_message("\blue The radio is now unsecured! The igniter will not work.", 1)
	src.part2.secured = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/attack_self(mob/user as mob)

	if (src.part1)
		src.part1.attack_self(user, src.status)
	src.add_fingerprint(user)
	return

/obj/item/assembly/rad_ignite/receive_signal()
	for(var/mob/O in hearers(1, src.loc))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
	src.part2.Activate()
	return

/obj/item/assembly/m_i_ptank/c_state(n)

	src.icon_state = text("prox-igniter-tank[]", n)
	return

/obj/item/assembly/m_i_ptank/HasProximity(atom/movable/AM as mob|obj)
	if (istype(AM, /obj/effect/beam))
		return
	if (AM.move_speed < 12 && src.part1)
		src.part1.sense()
	return


//*****RM
/obj/item/assembly/m_i_ptank/Bump(atom/O)
	spawn(0)
		//world << "miptank bumped into [O]"
		if(src.part1.secured)
			//world << "sending signal"
			receive_signal()
		else
			//world << "not active"
	..()

/obj/item/assembly/m_i_ptank/proc/prox_check()
	if(!part1 || !part1.secured)
		return
	for(var/atom/A in view(1, src.loc))
		if(A!=src && !istype(A, /turf/space) && !isarea(A))
			//world << "[A]:[A.type] was sensed"
			src.part1.sense()
			break

	spawn(10)
		prox_check()


//*****


/obj/item/assembly/m_i_ptank/dropped()

	spawn( 0 )
		part1.sense()
		return
	return

/obj/item/assembly/m_i_ptank/examine()
	..()
	part3.examine()

/obj/item/assembly/m_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/assembly/m_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/device/analyzer))
		src.part3.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/prox_ignite/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part3)
		else
			part3.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool)&&W:welding ))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a prox bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a prox bomb. Temp: [src.part3.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		bombers += "[key_name(user)] unwelded a prox bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		user << "\blue The hole has been closed."
	src.part2.secured = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/m_i_ptank/attack_self(mob/user as mob)

	playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
	src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/m_i_ptank/receive_signal()
	//world << "miptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)

	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
			src.part1.secured = 0.0

	return

/obj/item/assembly/m_i_ptank/emp_act(severity)

	if(istype(part3,/obj/item/weapon/tank/plasma) && prob(100/severity))
		part3.ignite()
	..()

//*****RM

/obj/item/assembly/t_i_ptank/c_state(n)

	src.icon_state = text("timer-igniter-tank[]", n)
	return

/obj/item/assembly/t_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/assembly/t_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/assembly/t_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/device/analyzer))
		src.part3.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/time_ignite/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part3)
		else
			part3.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) && W:welding))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a time bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a time bomb. Temp: [src.part3.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		if(src)
			src.status = 0
			bombers += "[key_name(user)] unwelded a time bomb. Temp: [src.part3.air_contents.temperature-T0C]"
			user << "\blue The hole has been closed."
	src.part2.secured = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/t_i_ptank/attack_self(mob/user as mob)

	src.part1.attack_self(user, 1)
	playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/t_i_ptank/receive_signal()
	//world << "tiptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)
	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
	return

/obj/item/assembly/t_i_ptank/emp_act(severity)
	if(istype(part3,/obj/item/weapon/tank/plasma) && prob(100/severity))
		part3.ignite()
	..()

/obj/item/assembly/r_i_ptank/examine()
	..()
	src.part3.examine()

/obj/item/assembly/r_i_ptank/Del()

	//src.part1 = null
	del(src.part1)
	//src.part2 = null
	del(src.part2)
	//src.part3 = null
	del(src.part3)
	..()
	return

/obj/item/assembly/r_i_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (istype(W, /obj/item/device/analyzer))
		src.part3.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/rad_ignite/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part3)
		else
			part3.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		del(src)
		return
	if (!( istype(W, /obj/item/weapon/weldingtool) && W:welding ))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a radio bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a radio bomb. Temp: [src.part3.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		bombers += "[key_name(user)] unwelded a radio bomb. Temp: [src.part3.air_contents.temperature-T0C]"
		user << "\blue The hole has been closed."
	src.part2.secured = src.status
	src.part1.b_stat = !( src.status )
	src.add_fingerprint(user)
	return

/obj/item/assembly/r_i_ptank/emp_act(severity)
	if(istype(part3,/obj/item/weapon/tank/plasma) && prob(100/severity))
		part3.ignite()
	..()


/obj/item/clothing/suit/armor/a_i_a_ptank/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()
	if (istype(W, /obj/item/device/analyzer))
		src.part4.attackby(W, user)
		return
	if ((istype(W, /obj/item/weapon/wrench) && !( src.status )))
		var/obj/item/assembly/a_i_a/R = new(get_turf(src.loc))
		R.part1 = src.part1
		R.part1.master = R
		R.part1.loc = R
		R.part2 = src.part2
		R.part2.master = R
		R.part2.loc = R
		R.part3 = src.part3
		R.part3.master = R
		R.part3.loc = R
		if (user.get_inactive_hand()==src)
			user.put_in_inactive_hand(part4)
		else
			part4.loc = src.loc
		src.part1 = null
		src.part2 = null
		src.part3 = null
		src.part4 = null
		del(src)
		return
	if (( istype(W, /obj/item/weapon/weldingtool) && W:welding))
		return
	if (!( src.status ))
		src.status = 1
		bombers += "[key_name(user)] welded a suicide bomb. Temp: [src.part4.air_contents.temperature-T0C]"
		message_admins("[key_name_admin(user)] welded a suicide bomb. Temp: [src.part4.air_contents.temperature-T0C]")
		user.show_message("\blue A pressure hole has been bored to the plasma tank valve. The plasma tank can now be ignited.", 1)
	else
		src.status = 0
		bombers += "[key_name(user)] unwelded a suicide bomb. Temp: [src.part4.air_contents.temperature-T0C]"
		user << "\blue The hole has been closed."
//	src.part3.status = src.status
	src.add_fingerprint(user)
	return

/obj/item/assembly/r_i_ptank/attack_self(mob/user as mob)
	playsound(src.loc, 'sound/weapons/armbomb.ogg', 100, 1)
	src.part1.attack_self(user, 1)
	src.add_fingerprint(user)
	return

/obj/item/assembly/r_i_ptank/receive_signal()
	//world << "riptank [src] got signal"
	for(var/mob/O in hearers(1, null))
		O.show_message(text("\icon[] *beep* *beep*", src), 3, "*beep* *beep*", 2)
		//Foreach goto(19)
	if ((src.status && prob(90)))
		//world << "sent ignite() to [src.part3]"
		src.part3.ignite()
	else
		if(!src.status)
			src.part3.release()
	return


//*****RM