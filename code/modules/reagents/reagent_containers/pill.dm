////////////////////////////////////////////////////////////////////////////////
/// Pills.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/pill
	name = "pill"
	desc = "A small capsule of dried chemicals, used to administer medicine and poison alike in one easy serving."
	icon = 'icons/obj/chemical.dmi'
	icon_state = null
	item_state = "pill"
	possible_transfer_amounts = null
	volume = 50
	m_amt = 5
	w_type = RECYK_METAL

	New()
		..()
		if(!icon_state)
			icon_state = "pill[rand(1,20)]"

/obj/item/weapon/reagent_containers/pill/attack_self(mob/user as mob)

	return attack(user, user) //Dealt with in attack code

/obj/item/weapon/reagent_containers/pill/attack(mob/M as mob, mob/user as mob, def_zone)

	if(M == user) //Someone swallowing a pill
		user.visible_message("<span class='notice'>[user] swallows \the [src].</span>", \
		"<span class='notice'>You swallow \the [src].</span>")
		M.drop_from_inventory(src) //Icon update
		if(reagents.total_volume) //Is there anything in the pill ?
			reagents.reaction(M, INGEST) //Ready up
			spawn(5)
				reagents.trans_to(M, reagents.total_volume) //Transfer whatever is good to go
				del(src)
		else //Nothing in the pill, just get rid of it
			del(src)
		return 1

	else if(istype(M, /mob/living/carbon/human)) //Feeding to someone else

		user.visible_message("<span class='warning'>[user] attempts to force [M] to swallow \the [src].</span>", \
		"<span class='notice'>You attempt to force [M] to swallow \the [src].</span>")

		if(!do_mob(user, M))
			return

		user.drop_from_inventory(src) //Icon update
		user.visible_message("<span class='warning'>[user] forces [M] to swallow \the [src].</span>", \
		"<span class='notice'>You force [M] to swallow \the [src].</span>")

		M.attack_log += "\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [key_name(user)] Reagents: [reagentlist(src)]</font>"
		user.attack_log += "\[[time_stamp()]\] <font color='red'>Fed [key_name(M)] by [src.name] Reagents: [reagentlist(src)]</font>"
		msg_admin_attack("[key_name_admin(user)] fed [key_name_admin(M)] with [src.name] Reagents: [reagentlist(src)] (INTENT: [uppertext(user.a_intent)]) ([formatJumpTo(user)])")

		if(!iscarbon(user))
			M.LAssailant = null
		else
			M.LAssailant = user

		if(reagents.total_volume)
			reagents.reaction(M, INGEST)
			spawn(5)
				reagents.trans_to(M, reagents.total_volume)
				del(src)
		else
			del(src)

		return 1
	return 0

/obj/item/weapon/reagent_containers/pill/afterattack(obj/target, mob/user , flag) //Attacking anything but a mob

	if(target.is_open_container() != 0 && target.reagents && !ismob(target)) //We're working with containers, and we do NOT want mobs here
		var/hadContents = target.reagents.total_volume
		var/trans = reagents.trans_to(target, reagents.total_volume)

		// /vg/: Logging transfers of bad things
		if(istype(reagents_to_log) && reagents_to_log.len && target.log_reagents)
			var/list/badshit = list()
			for(var/bad_reagent in reagents_to_log)
				if(reagents.has_reagent(bad_reagent))
					badshit += reagents_to_log[bad_reagent]
			if(badshit.len)
				var/hl="<span class='danger'>([english_list(badshit)])</span>"
				message_admins("[user.name] ([user.ckey]) added [trans]U to \a [target] with [src].[hl] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
				log_game("[user.name] ([user.ckey]) added [trans]U to \a [target] with [src].")

		if(trans)
			if(reagents.total_volume == 0) //Total transfer case
				if(hadContents)
					user << "<span class='notice'>You dissolve the pill into \the [target]</span>"
				else
					user << "<span class='notice'>You crush the pill into \the [target]</span>"
				spawn(1)
					qdel(src)
			else //Partial transfer case
				if(hadContents)
					user << "<span class='notice'>You partially dissolve the pill into \the [target], filling it</span>"
				else
					user << "<span class='notice'>You crush part of the pill into \the [target], filling it</span>"
			user.visible_message("<span class='warning'>[user] puts something in \the [target].</span>", \
			"<span class='notice'>You put \the [src] in \the [target].</span>")
		else //No transfer case
			user << "<span class='notice'>\The [target] is full!</span>"

	return

////////////////////////////////////////////////////////////////////////////////
/// Pills. END
////////////////////////////////////////////////////////////////////////////////

//Pills
/obj/item/weapon/reagent_containers/pill/creatine
	name = "Creatine Suicide Pill (50 units)"
	desc = "WILL ALSO KILL YOU VIOLENTLY."
	icon_state = "pill5"

	New()
		..()
		reagents.add_reagent("creatine", 50)

/obj/item/weapon/reagent_containers/pill/antitox
	name = "Anti-toxins pill"
	desc = "Neutralizes many common toxins."
	icon_state = "pill17"

	New()
		..()
		reagents.add_reagent("anti_toxin", 25)

/obj/item/weapon/reagent_containers/pill/tox
	name = "Toxins pill"
	desc = "Highly toxic."
	icon_state = "pill5"

	New()
		..()
		reagents.add_reagent("toxin", 50)

/obj/item/weapon/reagent_containers/pill/cyanide
	name = "Cyanide pill"
	desc = "Don't swallow this."
	icon_state = "pill5"

	New()
		..()
		reagents.add_reagent("cyanide", 50)

/obj/item/weapon/reagent_containers/pill/adminordrazine
	name = "Adminordrazine pill"
	desc = "It's magic. We don't have to explain it."
	icon_state = "pill16"

	New()
		..()
		reagents.add_reagent("adminordrazine", 50)

/obj/item/weapon/reagent_containers/pill/stox
	name = "Sleeping pill"
	desc = "Commonly used to treat insomnia."
	icon_state = "pill8"

	New()
		..()
		reagents.add_reagent("stoxin", 30)

/obj/item/weapon/reagent_containers/pill/kelotane
	name = "Kelotane pill"
	desc = "Used to treat burns."
	icon_state = "pill11"

	New()
		..()
		reagents.add_reagent("kelotane", 30)

/obj/item/weapon/reagent_containers/pill/tramadol
	name = "Tramadol pill"
	desc = "A simple painkiller."
	icon_state = "pill8"

	New()
		..()
		reagents.add_reagent("tramadol", 15)


/obj/item/weapon/reagent_containers/pill/methylphenidate
	name = "Methylphenidate pill"
	desc = "Improves the ability to concentrate."
	icon_state = "pill8"

	New()
		..()
		reagents.add_reagent("methylphenidate", 15)

/obj/item/weapon/reagent_containers/pill/citalopram
	name = "Citalopram pill"
	desc = "Mild anti-depressant."
	icon_state = "pill8"

	New()
		..()
		reagents.add_reagent("citalopram", 15)


/obj/item/weapon/reagent_containers/pill/inaprovaline
	name = "Inaprovaline pill"
	desc = "Used to stabilize patients."
	icon_state = "pill20"

	New()
		..()
		reagents.add_reagent("inaprovaline", 30)

/obj/item/weapon/reagent_containers/pill/dexalin
	name = "Dexalin pill"
	desc = "Used to treat oxygen deprivation."
	icon_state = "pill16"

	New()
		..()
		reagents.add_reagent("dexalin", 30)

/obj/item/weapon/reagent_containers/pill/bicaridine
	name = "Bicaridine pill"
	desc = "Used to treat physical injuries."
	icon_state = "pill18"

	New()
		..()
		reagents.add_reagent("bicaridine", 30)

/obj/item/weapon/reagent_containers/pill/happy
	name = "Happy pill"
	desc = "Happy happy joy joy!"
	icon_state = "pill18"

	New()
		..()
		reagents.add_reagent("space_drugs", 15)
		reagents.add_reagent("sugar", 15)

/obj/item/weapon/reagent_containers/pill/zoom
	name = "Zoom pill"
	desc = "Zoooom!"
	icon_state = "pill18"

	New()
		..()
		reagents.add_reagent("impedrezene", 10)
		reagents.add_reagent("synaptizine", 1)
		reagents.add_reagent("hyperzine", 10)

/obj/item/weapon/reagent_containers/pill/hyperzine
	name = "Hyperzine pill"
	desc = "Gotta go fast!"

	icon_state = "pill18"
	New()
		..()
		reagents.add_reagent("hyperzine", 10)
