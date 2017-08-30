GLOBAL_VAR_INIT(highlander, FALSE)
/client/proc/only_one() //Gives everyone kilts, berets, claymores, and pinpointers, with the objective to hijack the emergency shuttle.
	if(!SSticker.HasRoundStarted())
		alert("The game hasn't started yet!")
		return
	GLOB.highlander = TRUE

	send_to_playing_players("<span class='boldannounce'><font size=6>THERE CAN BE ONLY ONE</font></span>")

	for(var/obj/item/disk/nuclear/N in GLOB.poi_list)
		N.relocate() //Gets it out of bags and such

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == DEAD || !(H.client))
			continue
		H.make_scottish()

	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used THERE CAN BE ONLY ONE.")
	addtimer(CALLBACK(SSshuttle.emergency, /obj/docking_port/mobile/emergency.proc/request, null, 1), 50)

/client/proc/only_one_delayed()
	send_to_playing_players("<span class='userdanger'>Bagpipes begin to blare. You feel Scottish pride coming over you.</span>")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)] used (delayed) THERE CAN BE ONLY ONE!</span>")
	log_admin("[key_name(usr)] used delayed THERE CAN BE ONLY ONE.")
	addtimer(CALLBACK(src, .proc/only_one), 420)

/mob/living/carbon/human/proc/make_scottish()
	SSticker.mode.traitors += mind
	mind.special_role = "highlander"
	dna.species.species_traits |= NOGUNS //nice try jackass

	var/datum/objective/steal/steal_objective = new
	steal_objective.owner = mind
	steal_objective.set_target(new /datum/objective_item/steal/nukedisc)
	mind.objectives += steal_objective

	var/datum/objective/hijack/hijack_objective = new
	hijack_objective.explanation_text = "Escape on the shuttle alone. Ensure that nobody else makes it out."
	hijack_objective.owner = mind
	mind.objectives += hijack_objective

	mind.announce_objectives()

	for(var/obj/item/I in get_equipped_items())
		qdel(I)
	for(var/obj/item/I in held_items)
		qdel(I)
	equip_to_slot_or_del(new /obj/item/clothing/under/kilt/highlander(src), slot_w_uniform)
	equip_to_slot_or_del(new /obj/item/device/radio/headset/heads/captain(src), slot_ears)
	equip_to_slot_or_del(new /obj/item/clothing/head/beret/highlander(src), slot_head)
	equip_to_slot_or_del(new /obj/item/clothing/shoes/combat(src), slot_shoes)
	equip_to_slot_or_del(new /obj/item/pinpointer(src), slot_l_store)
	for(var/obj/item/pinpointer/P in src)
		P.attack_self(src)
	var/obj/item/card/id/W = new(src)
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_all_centcom_access()
	W.assignment = "Highlander"
	W.registered_name = real_name
	W.flags_1 |= NODROP_1
	W.update_label(real_name)
	equip_to_slot_or_del(W, slot_wear_id)

	var/obj/item/claymore/highlander/H1 = new(src)
	if(!GLOB.highlander)
		H1.admin_spawned = TRUE //To prevent announcing
	put_in_hands(H1)
	H1.pickup(src) //For the stun shielding

	var/obj/item/bloodcrawl/antiwelder = new(src)
	antiwelder.name = "compulsion of honor"
	antiwelder.desc = "You are unable to hold anything in this hand until you're the last one left!"
	antiwelder.icon_state = "bloodhand_right"
	put_in_hands(antiwelder)

	to_chat(src, "<span class='boldannounce'>Your [H1.name] cries out for blood. Claim the lives of others, and your own will be restored!\n\
	Activate it in your hand, and it will lead to the nearest target. Attack the nuclear authentication disk with it, and you will store it.</span>")

