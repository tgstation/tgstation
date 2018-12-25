#define SPAN_JESUS "jesus"
/mob/living/carbon/human/jesus
	status_flags = GODMODE//|GOTTAGOREALLYFAST|IGNORESLOWDOWN these 2 removed. fix later
	anchored = 1
	incorporeal_move = 1
	omnipotent_access = 1

/mob/living/carbon/human/jesus/update_canmove()
	..()
	anchored = 1

/mob/living/carbon/human/jesus/verb/disappear()
	set category = " Space Jesus"
	set name = "Disappear"
	set desc = "You've finished your job. Time to disappear."

	new /obj/effect/particle_effect/smoke(get_turf(src))
	playsound(get_turf(src), 'sound/effects/smoke.ogg', 50, 0, 0, 0, 0)
	visible_message("<font size=3 color=red><b>Space Jesus has returned to heaven!</b></font>")
	qdel(src)

/mob/living/carbon/human/jesus/verb/hallelujah()
	set category = " Space Jesus"
	set name = "Hallelujah"
	set desc = "Best used when performing miracles."

	playsound(get_turf(src), 'sound/effects/pray.ogg', 50, 0, 0, 0, 0)
	var/turf/T = get_turf(src)
	T.visible_message("<font size=3 color=blue><b>Hallelujah!</b></font>")

/mob/living/carbon/human/jesus/verb/heal(mob/living/carbon/M as mob in view(7))
	set category = " Space Jesus"
	set name = "Heal"
	set desc = "Perform a miracle."

	/*if (!check_rights(R_REJUVINATE))
		return*/

	var/mob/living/L = M
	if(!istype(L))
		to_chat(usr, "This can only be used on instances of type /mob/living.")
		return

	L.revive(full_heal = 1, admin_revive = 1)
	message_admins("<span class='danger'>Admin [key_name_admin(usr)] healed / revived [key_name_admin(L)]!</span>")
	log_admin("[key_name(usr)] healed / Revived [key_name(L)].")
	playsound(get_turf(src), 'sound/effects/pray.ogg', 50, 0, 0, 0, 0)
	var/turf/T = get_turf(src)
	T.visible_message("<font size=3 color=blue><b>Space Jesus heals [L]! Hallelujah!</b></font>")
	new /obj/effect/explosion(get_turf(L))

/mob/living/carbon/human/jesus/verb/togglecorporeal()
	set category = " Space Jesus"
	set name = "Toggle Corporeal Form"
	set desc = "Toggles your corporeal form."
	incorporeal_move = !incorporeal_move
	if(incorporeal_move)
		to_chat(src,"You are now non corporeal.")
	else
		to_chat(src,"You are now corporeal.")

/mob
	var/omnipotent_access = 0
/mob/living/carbon/human/jesus/New()
	..()
	name = "Space Jesus"
	real_name = "Space Jesus"
	equipOutfit(/datum/outfit/jesus)
	var/datum/dna/D = dna
	skin_tone = "caucasian3"
	lip_color = "white"
	eye_color = "000"
	facial_hair_style = "Full Beard"
	facial_hair_color = "000"
	hair_style = "Long Fringe"
	hair_color = "000"
	gender = MALE
	if (istype(D))
		D.update_dna_identity()
	updateappearance()

/mob/living/carbon/human/jesus/get_spans()
	. = ..()
	. |= SPAN_JESUS

/mob/living/carbon/human/jesus/ex_act()
	return

/mob/living/carbon/human/jesus/examine(mob/user)
		var/msg = "<span class='info'>*---------*\nThis is <EM><font size=3>Space Jesus</font></EM>, your Lord and Savior!</span>\n"
		msg += "<font color=red>He is the real deal.</font><br>"
		msg += "*---------*</span>"
		to_chat(user, msg)

/mob/living/carbon/human/jesus/gib()
	return

/mob/living/carbon/human/jesus/handle_hallucinations()
	if(hallucination > 0)
		hallucination = 0
		return


/datum/outfit/jesus
	name = "Space Jesus"
	uniform = /obj/item/clothing/under/waiter/jesus
	gloves = /obj/item/clothing/gloves/color/white/jesus
	shoes = /obj/item/clothing/shoes/jackboots/jesus
	glasses = /obj/item/clothing/glasses/godeye/jesus
	ears = /obj/item/device/radio/headset
	belt = /obj/item/storage/belt/utility/full

//00000050600012d5ab193
/mob/proc/jesusify()
	if(isnewplayer(src))
		to_chat(usr, "<span class='danger'>Cannot convert players who have not entered yet.</span>")
		return

	spawn(0)
		var/mob/living/carbon/human/jesus/M
		var/location = src.loc
		for(var/i=0, i<=7, i++)
			spawn(i*2)
				var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
				s.set_up(5, 1, location)
				s.start()
		playsound(get_turf(location), 'sound/effects/pray_chaplain.ogg', 50, 0, 0, 0, 0)
		var/obj/effect/forcefield/cult/C = new /obj/effect/forcefield/cult(get_turf(location))
		var/obj/effect/jesusportal/P = new /obj/effect/jesusportal(get_turf(location))
		var/savedkey = key
		spawn(15)
			qdel(P)
			qdel(C)
			new /obj/effect/explosion(get_turf(location))
			playsound(get_turf(location), 'sound/effects/explosion2.ogg', 25, 0, 0, 0, 0)
			var/turf/T = get_turf(location)
			T.visible_message("<font size=3 color=red><b>Your Lord, Space Jesus, descends upon the Earth!</b></font>")
			M = new /mob/living/carbon/human/jesus( location )
			if (!istype(M))
				to_chat(usr, "Oops! There was a problem. Contact a developer.")
				return

			M.key = savedkey
			if(M.mind)
				M.mind.assigned_role = "Space Jesus"
			QDEL_IN(src, 1)
		return M

/obj/item/clothing/under/waiter/jesus
	resistance_flags = INDESTRUCTIBLE

/obj/item/clothing/under/waiter/jesus/worn_overlays(isinhands)
    . = list()
    if(!isinhands)
        . += image(layer = LYING_MOB_LAYER-0.01, icon = 'icons/effects/effects.dmi', icon_state = "m_shield")

/obj/item/clothing/glasses/godeye/jesus
	icon_state = ""
	item_state = ""
	resistance_flags = INDESTRUCTIBLE

/obj/item/clothing/gloves/color/white/jesus
	resistance_flags = INDESTRUCTIBLE

/obj/item/clothing/shoes/jackboots/jesus
	resistance_flags = INDESTRUCTIBLE

/obj/effect/jesusportal
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"

/datum/admins/proc/space_jesus()
	set name = "Space Jesus"
	set category = "Special Verbs"
	var/userckey = usr.ckey
	var/confirm = alert(usr,"Do you wish to become Space Jesus?","Space Jesus","Yes","Cancel")
	if(confirm != "Yes")
		return
	if(!isturf(usr.loc))
		to_chat(usr,"Can't spawn Space Jesus here.")
		return
	if(!istype(usr,/mob/dead/observer) || usr.ckey != userckey)
		to_chat(usr,"You must be a ghost for this.")
		return
	usr.jesusify()


