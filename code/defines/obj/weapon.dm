/obj/item/weapon/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items.dmi'
	icon_state = "red_phone"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 3.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 4
	w_class = 2
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] wraps the cord of the [src.name] around \his neck! It looks like \he's trying to commit suicide.</b>"
		return(OXYLOSS)

/obj/item/weapon/rsp
	name = "\improper Rapid-Seed-Producer (RSP)"
	desc = "A device used to rapidly deploy seeds."
	icon = 'icons/obj/items.dmi'
	icon_state = "rcd"
	opacity = 0
	density = 0
	anchored = 0.0
	var/matter = 0
	var/mode = 1
	flags = TABLEPASS
	w_class = 3.0

/obj/item/weapon/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] drops the [src.name] on the ground and steps on it causing \him to crash to the floor, bashing \his head wide open. </b>"
		return(OXYLOSS)

/obj/item/weapon/corncob
	name = "corn cob"
	desc = "A reminder of meals gone by."
	icon = 'icons/obj/harvest.dmi'
	icon_state = "corncob"
	item_state = "corncob"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap
	name = "soap"
	desc = "A cheap bar of soap. Doesn't smell."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "soap"
	w_class = 1.0
	throwforce = 0
	throw_speed = 4
	throw_range = 20

/obj/item/weapon/soap/nanotrasen
	desc = "A Nanotrasen brand bar of soap. Smells of plasma."
	icon_state = "soapnt"

/obj/item/weapon/soap/deluxe
	desc = "A deluxe Waffle Co. brand bar of soap. Smells of condoms."
	icon_state = "soapdeluxe"

/obj/item/weapon/soap/syndie
	desc = "An untrustworthy bar of soap. Smells of fear."
	icon_state = "soapsyndie"

/obj/item/weapon/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = 1.0
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/spam_flag = 0


/obj/item/weapon/c_tube
	name = "cardboard tube"
	desc = "A tube... of cardboard."
	icon = 'icons/obj/items.dmi'
	icon_state = "c_tube"
	throwforce = 1
	w_class = 1.0
	throw_speed = 4
	throw_range = 5


/obj/item/weapon/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = 2.0
	m_amt = 50
	w_type = RECYK_MISC
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/weapon/disk
	name = "disk"
	icon = 'icons/obj/items.dmi'

/obj/item/weapon/disk/nuclear
	name = "nuclear authentication disk"
	desc = "Better keep this safe."
	icon_state = "nucleardisk"
	item_state = "card-id"
	w_class = 1.0

//TODO: Figure out wtf this is and possibly remove it -Nodrak
/obj/item/weapon/dummy
	name = "dummy"
	invisibility = 101.0
	anchored = 1.0
	flags = TABLEPASS

/obj/item/weapon/dummy/ex_act()
	return

/obj/item/weapon/dummy/blob_act()
	return


/*
/obj/item/weapon/game_kit
	name = "Gaming Kit"
	icon = 'icons/obj/items.dmi'
	icon_state = "game_kit"
	var/selected = null
	var/board_stat = null
	var/data = ""
	var/base_url = "http://svn.slurm.us/public/spacestation13/misc/game_kit"
	item_state = "sheet-metal"
	w_class = 5.0
*/

/obj/item/weapon/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items.dmi'
	icon_state = "gift3"
	var/size = 3.0
	var/obj/item/gift = null
	item_state = "gift"
	w_class = 4.0

/obj/item/weapon/legcuffs
	name = "legcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	flags = FPRINT | TABLEPASS | CONDUCT
	throwforce = 0
	w_class = 3.0
	origin_tech = "materials=1"
	var/breakouttime = 300	//Deciseconds = 30s = 0.5 minute

/obj/item/weapon/legcuffs/bolas
	name = "bolas"
	desc = "An entangling bolas. Throw at your foes to trip them and prevent them from running."
	gender = NEUTER
	icon = 'icons/obj/weapons.dmi'
	icon_state = "bolas"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	throwforce = 2
	w_class = 2
	w_type = RECYK_METAL
	origin_tech = "materials=1"
	attack_verb = list("lashed", "bludgeoned", "whipped")
	force = 4
	breakouttime = 50 //10 seconds
	throw_speed = 1
	throw_range = 10
	var/dispenser = 0
	var/throw_sound = 'sound/weapons/whip.ogg'
	var/trip_prob = 60
	var/thrown_from

/obj/item/weapon/legcuffs/bolas/suicide_act(mob/living/user)
		viewers(user) << "\red <b>[user] is wrapping the [src.name] around \his neck! It looks like \he's trying to commit suicide.</b>"
		return(OXYLOSS)

/obj/item/weapon/legcuffs/bolas/throw_at(var/atom/A, throw_range, throw_speed)
	if(usr && !istype(thrown_from, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas)) //if there is a user, but not a mech
		if(istype(usr, /mob/living/carbon/human)) //if the user is human
			var/mob/living/carbon/human/H = usr
			if((M_CLUMSY in H.mutations) && prob(50))
				H <<"\red You smack yourself in the face while swinging the [src]!"
				H.Stun(2)
				H.drop_item()
				return
	if (!thrown_from && usr) //if something hasn't set it already (like a mech does when it launches)
		thrown_from = usr //then the user must have thrown it
	if (!istype(thrown_from, /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/bolas))
		playsound(src, throw_sound, 20, 1) //because mechs play the sound anyways
	var/turf/target = get_turf(A)
	var/atom/movable/adjtarget = new /atom/movable
	var/xadjust = 0
	var/yadjust = 0
	var/scaler = 0 //used to changed the normalised vector to the proper size
	scaler = throw_range / max(abs(target.x - src.x), abs(target.y - src.y)) //whichever is larger magnitude is what we normalise to
	if (target.x - src.x != 0) //just to avoid fucking with math for no reason
		xadjust = round((target.x - src.x) * scaler) //normalised vector is now scaled up to throw_range
		adjtarget.x = src.x + xadjust //the new target at max range
	else
		adjtarget.x = src.x
	if (target.y - src.y != 0)
		yadjust = round((target.y - src.y) * scaler)
		adjtarget.y = src.y + yadjust
	else
		adjtarget.y = src.y
	// log_admin("Adjusted target of [adjtarget.x] and [adjtarget.y], adjusted with [xadjust] and [yadjust] from [scaler]")
	..(get_turf(adjtarget), throw_range, throw_speed)
	thrown_from = null

/obj/item/weapon/legcuffs/bolas/throw_impact(atom/hit_atom) //Pomf was right, I was wrong - Comic
	if(isliving(hit_atom) && hit_atom != usr) //if the target is a live creature other than the thrower
		var/mob/living/M = hit_atom
		if(ishuman(M)) //if they're a human species
			var/mob/living/carbon/human/H = M
			if(H.m_intent == "run") //if they're set to run (though not necessarily running at that moment)
				if(prob(trip_prob)) //this probability is up for change and mostly a placeholder - Comic
					step(H, H.dir)
					H.visible_message("<span class='warning'>[H] was tripped by the bolas!</span>","<span class='warning'>Your legs have been tangled!</span>");
					H.Stun(2) //used instead of setting damage in vars to avoid non-human targets being affected
					H.Weaken(4)
					H.legcuffed = src //applies legcuff properties inherited through legcuffs
					src.loc = H
					H.update_inv_legcuffed()
					if(!H.legcuffed) //in case it didn't happen, we need a safety net
						throw_failed()
			else if(H.legcuffed) //if the target is already legcuffed (has to be walking)
				throw_failed()
				return
			else //walking, but uncuffed, or the running prob() failed
				H << "\blue You stumble over the thrown bolas"
				step(H, H.dir)
				H.Stun(1)
				throw_failed()
				return
		else
			M.Stun(2) //minor stun damage to anything not human
			throw_failed()
			return

/obj/item/weapon/legcuffs/bolas/proc/throw_failed() //called when the throw doesn't entangle
	log_admin("Logged as [thrown_from]")
	if(!thrown_from || !istype(thrown_from, /mob/living)) //in essence, if we don't know whether a person threw it
		qdel(src) //destroy it, to stop infinite bolases

/obj/item/weapon/legcuffs/bolas/Bump()
	..()
	throw_failed() //allows a mech bolas to be destroyed

// /obj/item/weapon/legcuffs/bolas/cyborg To be implemented
//	dispenser = 1

/obj/item/weapon/legcuffs/bolas/cable
	name = "cable bolas"
	desc = "A poorly made bolas, tied together with cable."
	icon_state = ""
	throw_speed = 1
	throw_range = 6
	trip_prob = 10
	var/obj/item/weight1 = null //the two items that are attached to the cable
	var/obj/item/weight2 = null
	var/cable_color = ""
	var/desc_empty = "A poorly made bolas, tied together with cable. It has nothing on it."
	var/screw_state = "" //used for storing info about the screwdriver
	var/screw_istate = ""

/obj/item/weapon/legcuffs/bolas/cable/New()
	..()
	desc = desc_empty
	weight1 = null
	weight2 = null
	update_icon()

/obj/item/weapon/legcuffs/bolas/cable/update_icon()
	if (!weight1 && !weight2)
		icon_state = "cbolas_[cable_color]"
		overlays.Cut()
		desc = desc_empty
		trip_prob = 0
		return
	else
		overlays.Cut()
		if (weight1)
			trip_prob = 10
			overlays += icon("icons/obj/weapons.dmi", "cbolas_weight1")
		if (weight2)
			trip_prob = 30
			overlays += icon("icons/obj/weapons.dmi", "cbolas_weight2")
		desc = "A poorly made bolas, made out of \a [weight1] and [weight2 ? "\a [weight2]": "missing a second weight"], tied together with cable."

/obj/item/weapon/legcuffs/bolas/cable/throw_failed()
	if(prob(20))
		for (var/mob/V in viewers(src, null))
			V << "\red \The [src] falls to pieces on impact!"
		if(weight1)
			weight1.loc = src.loc
			weight1 = null
		if(weight2)
			weight2.loc = src.loc
			weight2 = null
		update_icon(src)

/obj/item/weapon/legcuffs/bolas/cable/attackby(var/obj/O)
	if(istype(O, /obj/item))
		var/obj/item/I = O
		if(istype(I, /obj/item/weapon/wirecutters)) //allows you to convert the wire back to a cable coil
			if(!weight1 && !weight2) //if there's nothing attached
				usr << "\blue You cut the knot in the [src]."
				playsound(usr, 'sound/items/Wirecutter.ogg', 50, 1)
				var /obj/item/weapon/cable_coil/C = new /obj/item/weapon/cable_coil(usr.loc) //we get back the wire lengths we put in
				var /obj/item/weapon/cable_coil/S = new /obj/item/weapon/screwdriver(src.loc)
				C.amount = 10
				C._color = cable_color
				C.icon_state = "coil_[C._color]"
				C.update_icon()
				S.item_state = screw_state
				S.icon_state = screw_istate
				S.update_icon()
				qdel(src)
				return
			else
				usr << "\blue You cut off [weight1] [weight2 ? "and [weight2]" : ""]." //you remove the items currently attached
				if(weight1)
					weight1.loc = get_turf(usr)
					weight1 = null
				if(weight2)
					weight2.loc = get_turf(usr)
					weight2 = null
				playsound(usr, 'sound/items/Wirecutter.ogg', 50, 1)
				update_icon()
				return
		if(I.w_class) //if it has a defined weight
			if(I.w_class == 2.0 || I.w_class == 3.0) //just one is too specific, so don't change this
				if(weight1 == null)
					usr.drop_item(I)
					weight1 = I
					I.forceMove(src)
					usr << "\blue You tie [weight1] to the [src]."
					update_icon()
					//del(I)
					return
				if(weight2 == null) //just in case
					usr.drop_item(I)
					weight2 = I
					I.forceMove(src)
					usr << "\blue You tie [weight2] to the [src]."
					update_icon()
					//del(I)
					return
				else
					usr << "\red There are already two weights on this [src]!"
					return
			else if (I.w_class < 2.0)
				usr << "\red \The [I] is too small to be used as a weight."
			else if (I.w_class > 3.0)
				usr << "\red \The [I] is [I.w_class > 4.0 ? "far " : ""] too big to be used a weight."
			else
				usr << "\red There are already two weights on this [src]!"

/obj/item/weapon/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 2
	throw_range = 1
	icon_state = "beartrap0"
	desc = "A trap used to catch bears and other legged creatures."
	var/armed = 0

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is putting the [src.name] on \his head! It looks like \he's trying to commit suicide.</b>"
		return (BRUTELOSS)

/obj/item/weapon/legcuffs/beartrap/attack_self(mob/user as mob)
	..()
	if(ishuman(user) && !user.stat && !user.restrained())
		armed = !armed
		icon_state = "beartrap[armed]"
		user << "<span class='notice'>[src] is now [armed ? "armed" : "disarmed"]</span>"

/obj/item/weapon/legcuffs/beartrap/Crossed(AM as mob|obj)
	if(armed)
		if(ishuman(AM))
			if(isturf(src.loc))
				var/mob/living/carbon/H = AM
				if(H.m_intent == "run")
					armed = 0
					H.legcuffed = src
					src.loc = H
					H.update_inv_legcuffed()
					H << "\red <B>You step on \the [src]!</B>"
					feedback_add_details("handcuffs","B") //Yes, I know they're legcuffs. Don't change this, no need for an extra variable. The "B" is used to tell them apart.
					for(var/mob/O in viewers(H, null))
						if(O == H)
							continue
						O.show_message("\red <B>[H] steps on \the [src].</B>", 1)
		if(isanimal(AM) && !istype(AM, /mob/living/simple_animal/parrot) && !istype(AM, /mob/living/simple_animal/construct) && !istype(AM, /mob/living/simple_animal/shade) && !istype(AM, /mob/living/simple_animal/hostile/viscerator))
			armed = 0
			var/mob/living/simple_animal/SA = AM
			SA.health -= 20
	..()



/obj/item/weapon/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	force = 1.0
	throwforce = 3.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS
	attack_verb = list("warned", "cautioned", "smashed")

	proximity_sign
		var/timing = 0
		var/armed = 0
		var/timepassed = 0

		attack_self(mob/user as mob)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.mind.assigned_role != "Janitor")
					return
				if(armed)
					armed = 0
					user << "\blue You disarm \the [src]."
					return
				timing = !timing
				if(timing)
					processing_objects.Add(src)
				else
					armed = 0
					timepassed = 0
				H << "\blue You [timing ? "activate \the [src]'s timer, you have 15 seconds." : "de-activate \the [src]'s timer."]"

		process()
			if(!timing)
				processing_objects.Remove(src)
			timepassed++
			if(timepassed >= 15 && !armed)
				armed = 1
				timing = 0

		HasProximity(atom/movable/AM as mob|obj)
			if(armed)
				if(istype(AM, /mob/living/carbon) && !istype(AM, /mob/living/carbon/brain))
					var/mob/living/carbon/C = AM
					if(C.m_intent != "walk")
						src.visible_message("The [src.name] beeps, \"Running on wet floors is hazardous to your health.\"")
						explosion(src.loc,-1,2,0)
						if(ishuman(C))
							dead_legs(C)
						if(src)
							del(src)

		proc/dead_legs(mob/living/carbon/human/H as mob)
			var/datum/organ/external/l = H.get_organ("l_leg")
			var/datum/organ/external/r = H.get_organ("r_leg")
			if(l && !(l.status & ORGAN_DESTROYED))
				l.status |= ORGAN_DESTROYED
			if(r && !(r.status & ORGAN_DESTROYED))
				r.status |= ORGAN_DESTROYED

/obj/item/weapon/caution/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon_state = "cone"

/obj/item/weapon/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items.dmi'
	icon_state = "rack_parts"
	flags = FPRINT | TABLEPASS| CONDUCT
	m_amt = 3750
	w_type = RECYK_METAL

/obj/item/weapon/shard
	name = "shard"
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	sharp = 1
	desc = "Could probably be used as ... a throwing weapon?"
	w_class = 1.0
	force = 5.0
	throwforce = 15.0
	item_state = "shard-glass"
	g_amt = 3750
	w_type = RECYK_GLASS
	attack_verb = list("stabbed", "slashed", "sliced", "cut")

	suicide_act(mob/user)
		viewers(user) << pick("\red <b>[user] is slitting \his wrists with the shard of glass! It looks like \he's trying to commit suicide.</b>", \
							"\red <b>[user] is slitting \his throat with the shard of glass! It looks like \he's trying to commit suicide.</b>")
		return (BRUTELOSS)

/obj/item/weapon/shard/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/*/obj/item/weapon/syndicate_uplink
	name = "station bounced radio"
	desc = "Remain silent about this..."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 10.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/mob/currentUser = null
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	w_class = 2.0
	item_state = "radio"
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	origin_tech = "magnets=2;syndicate=3"*/

/obj/item/weapon/shard/shrapnel
	name = "shrapnel"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shrapnellarge"
	desc = "A bunch of tiny bits of shattered metal."

/obj/item/weapon/shard/shrapnel/New()

	src.icon_state = pick("shrapnellarge", "shrapnelmedium", "shrapnelsmall")
	switch(src.icon_state)
		if("shrapnelsmall")
			src.pixel_x = rand(-12, 12)
			src.pixel_y = rand(-12, 12)
		if("shrapnelmedium")
			src.pixel_x = rand(-8, 8)
			src.pixel_y = rand(-8, 8)
		if("shrapnellarge")
			src.pixel_x = rand(-5, 5)
			src.pixel_y = rand(-5, 5)
		else
	return

/obj/item/weapon/SWF_uplink
	name = "station-bounced radio"
	desc = "used to comunicate it appears."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	var/temp = null
	var/uses = 4.0
	var/selfdestruct = 0.0
	var/traitor_frequency = 0.0
	var/obj/item/device/radio/origradio = null
	flags = FPRINT | TABLEPASS| CONDUCT
	slot_flags = SLOT_BELT
	item_state = "radio"
	throwforce = 5
	w_class = 2.0
	throw_speed = 4
	throw_range = 20
	m_amt = 100
	w_type = RECYK_ELECTRONIC
	origin_tech = "magnets=1"

/obj/item/weapon/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD
	attack_verb = list("bludgeoned", "whacked", "disciplined")

/obj/item/weapon/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"

/obj/item/weapon/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
	flags = FPRINT | TABLEPASS | NOSHIELD

/obj/item/weapon/table_parts
	name = "table parts"
	desc = "Parts of a table. Poor table."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "table_parts"
	m_amt = 3750
	w_type = RECYK_METAL
	flags = FPRINT | TABLEPASS| CONDUCT
	attack_verb = list("slammed", "bashed", "battered", "bludgeoned", "thrashed", "whacked")

/obj/item/weapon/table_parts/reinforced
	name = "reinforced table parts"
	desc = "Hard table parts. Well...harder..."
	icon = 'icons/obj/items.dmi'
	icon_state = "reinf_tableparts"
	m_amt = 7500
	w_type = RECYK_METAL
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/weapon/table_parts/wood
	name = "wooden table parts"
	desc = "Keep away from fire."
	icon_state = "wood_tableparts"
	flags = null

/obj/item/weapon/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon = 'icons/obj/power.dmi'
	icon_state = "item_wire"
	var/amount = 1.0
	var/laying = 0.0
	var/old_lay = null
	m_amt = 40
	w_type = RECYK_METAL
	attack_verb = list("whipped", "lashed", "disciplined", "tickled")

	suicide_act(mob/user)
		viewers(user) << "\red <b>[user] is strangling \himself with the [src.name]! It looks like \he's trying to commit suicide.</b>"
		return (OXYLOSS)

/obj/item/weapon/module
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS|CONDUCT
	var/mtype = 1						// 1=electronic 2=hardware

/obj/item/weapon/module/card_reader
	name = "card reader module"
	icon_state = "card_mod"
	desc = "An electronic module for reading data and ID cards."

/obj/item/weapon/module/power_control
	name = "power control module"
	icon_state = "power_mod"
	desc = "Heavy-duty switching circuits for power control."

/obj/item/weapon/module/id_auth
	name = "\improper ID authentication module"
	icon_state = "id_mod"
	desc = "A module allowing secure authorization of ID cards."

/obj/item/weapon/module/cell_power
	name = "power cell regulator module"
	icon_state = "power_mod"
	desc = "A converter and regulator allowing the use of power cells."

/obj/item/weapon/module/cell_power
	name = "power cell charger module"
	icon_state = "power_mod"
	desc = "Charging circuits for power cells."


/obj/item/device/camera_bug
	name = "camera bug"
	desc = "Tiny electronic device meant to bug cameras for viewing later."
	icon = 'icons/obj/device.dmi'
	icon_state = "implant_evil"
	w_class = 1.0
	item_state = ""
	throw_speed = 4
	throw_range = 20
/*unused
/obj/item/weapon/camera_bug/attack_self(mob/usr as mob)
	var/list/cameras = new/list()
	for (var/obj/machinery/camera/C in cameranet.cameras)
		if (C.bugged && C.status)
			cameras.Add(C)
	if (length(cameras) == 0)
		usr << "\red No bugged functioning cameras found."
		return

	var/list/friendly_cameras = new/list()

	for (var/obj/machinery/camera/C in cameras)
		friendly_cameras.Add(C.c_tag)

	var/target = input("Select the camera to observe", null) as null|anything in friendly_cameras
	if (!target)
		return
	for (var/obj/machinery/camera/C in cameras)
		if (C.c_tag == target)
			target = C
			break
	if (usr.stat == 2) return

	usr.client.eye = target
*/

/obj/item/weapon/syntiflesh
	name = "syntiflesh"
	desc = "Meat that appears...strange..."
	icon = 'icons/obj/food.dmi'
	icon_state = "meat"
	flags = FPRINT | TABLEPASS | CONDUCT
	w_class = 1.0
	origin_tech = "biotech=2"

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 12.0
	w_class = 2.0
	throwforce = 15.0
	throw_speed = 4
	throw_range = 4
	m_amt = 15000
	w_type = RECYK_METAL
	origin_tech = "materials=2;combat=1"
	attack_verb = list("chopped", "torn", "cut")

/obj/item/weapon/hatchet/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 3
	w_class = 4.0
	m_amt = 15000
	w_type = RECYK_METAL
	flags = FPRINT | TABLEPASS | NOSHIELD
	slot_flags = SLOT_BACK
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")

/obj/item/weapon/scythe/afterattack(atom/A, mob/user as mob)
	if(istype(A, /obj/effect/spacevine))
		for(var/obj/effect/spacevine/B in orange(A,1))
			if(prob(80))
				del B
		del A

/*
/obj/item/weapon/cigarpacket
	name = "Pete's Cuban Cigars"
	desc = "The most robust cigars on the planet."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarpacket"
	item_state = "cigarpacket"
	w_class = 1
	throwforce = 2
	var/cigarcount = 6
	flags = ONBELT | TABLEPASS */

/obj/item/weapon/pai_cable
	desc = "A flexible coated cable with a universal jack on one end."
	name = "data cable"
	icon = 'icons/obj/power.dmi'
	icon_state = "wire1"

	var/obj/machinery/machine

///////////////////////////////////////Stock Parts /////////////////////////////////

/obj/item/weapon/stock_parts
	name = "stock part"
	desc = "What?"
	gender = PLURAL
	icon = 'icons/obj/stock_parts.dmi'
	w_class = 2.0
	var/rating = 1

/obj/item/weapon/stock_parts/New()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

//Rank 1

/obj/item/weapon/stock_parts/console_screen
	name = "console screen"
	desc = "Used in the construction of computers and other devices with a interactive console."
	icon_state = "screen"
	origin_tech = "materials=1"
	g_amt = 200
	w_type = RECYK_GLASS

/obj/item/weapon/stock_parts/capacitor
	name = "capacitor"
	desc = "A basic capacitor used in the construction of a variety of devices."
	icon_state = "capacitor2_basic"
	origin_tech = "powerstorage=1"
	m_amt = 50
	g_amt = 50
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/scanning_module
	name = "scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=1"
	m_amt = 50
	g_amt = 20
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/manipulator
	name = "micro-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "micro_mani"
	origin_tech = "materials=1;programming=1"
	m_amt = 30
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/micro_laser
	name = "micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "micro_laser"
	origin_tech = "magnets=1"
	m_amt = 10
	g_amt = 20
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/stock_parts/matter_bin
	name = "matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "matter_bin"
	origin_tech = "materials=1"
	m_amt = 80
	w_type = RECYK_ELECTRONIC

//Rank 2

/obj/item/weapon/stock_parts/capacitor/adv
	name = "advanced capacitor"
	desc = "An advanced capacitor used in the construction of a variety of devices."
	icon_state = "capacitor2_adv"
	origin_tech = "powerstorage=3"
	rating = 2
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/adv
	name = "advanced scanning module"
	desc = "A compact, high resolution scanning module used in the construction of certain devices."
	icon_state = "scan_module"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/nano
	name = "nano-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "nano_mani"
	origin_tech = "materials=3;programming=2"
	rating = 2
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/high
	name = "high-power micro-laser"
	desc = "A tiny laser used in certain devices."
	icon_state = "high_micro_laser"
	origin_tech = "magnets=3"
	rating = 2
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/adv
	name = "advanced matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "advanced_matter_bin"
	origin_tech = "materials=3"
	rating = 2
	m_amt = 80

//Rating 3

/obj/item/weapon/stock_parts/capacitor/super
	name = "super capacitor"
	desc = "A super-high capacity capacitor used in the construction of a variety of devices."
	icon_state = "capacitor2_super"
	origin_tech = "powerstorage=5;materials=4"
	rating = 3
	m_amt = 50
	g_amt = 50

/obj/item/weapon/stock_parts/scanning_module/phasic
	name = "phasic scanning module"
	desc = "A compact, high resolution phasic scanning module used in the construction of certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 50
	g_amt = 20

/obj/item/weapon/stock_parts/manipulator/pico
	name = "pico-manipulator"
	desc = "A tiny little manipulator used in the construction of certain devices."
	icon_state = "pico_mani"
	origin_tech = "materials=5;programming=2"
	rating = 3
	m_amt = 30

/obj/item/weapon/stock_parts/micro_laser/ultra
	name = "ultra-high-power micro-laser"
	icon_state = "ultra_high_micro_laser"
	desc = "A tiny laser used in certain devices."
	origin_tech = "magnets=5"
	rating = 3
	m_amt = 10
	g_amt = 20

/obj/item/weapon/stock_parts/matter_bin/super
	name = "super matter bin"
	desc = "A container for hold compressed matter awaiting re-construction."
	icon_state = "super_matter_bin"
	origin_tech = "materials=5"
	rating = 3
	m_amt = 80

// Subspace stock parts

/obj/item/weapon/stock_parts/subspace/ansible
	name = "subspace ansible"
	icon_state = "subspace_ansible"
	desc = "A compact module capable of sensing extradimensional activity."
	origin_tech = "programming=3;magnets=5;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/filter
	name = "hyperwave filter"
	icon_state = "hyperwave_filter"
	desc = "A tiny device capable of filtering and converting super-intense radiowaves."
	origin_tech = "programming=4;magnets=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/amplifier
	name = "subspace amplifier"
	icon_state = "subspace_amplifier"
	desc = "A compact micro-machine capable of amplifying weak subspace transmissions."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/treatment
	name = "subspace treatment disk"
	icon_state = "treatment_disk"
	desc = "A compact micro-machine capable of stretching out hyper-compressed radio waves."
	origin_tech = "programming=3;magnets=2;materials=5;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/analyzer
	name = "subspace wavelength analyzer"
	icon_state = "wavelength_analyzer"
	desc = "A sophisticated analyzer capable of analyzing cryptic subspace wavelengths."
	origin_tech = "programming=3;magnets=4;materials=4;bluespace=2"
	m_amt = 30
	g_amt = 10

/obj/item/weapon/stock_parts/subspace/crystal
	name = "ansible crystal"
	icon_state = "ansible_crystal"
	desc = "A crystal made from pure glass used to transmit laser databursts to subspace."
	origin_tech = "magnets=4;materials=4;bluespace=2"
	g_amt = 50

/obj/item/weapon/stock_parts/subspace/transmitter
	name = "subspace transmitter"
	icon_state = "subspace_transmitter"
	desc = "A large piece of equipment used to open a window into the subspace dimension."
	origin_tech = "magnets=5;materials=5;bluespace=3"
	m_amt = 50

/obj/item/weapon/ectoplasm
	name = "ectoplasm"
	desc = "spooky"
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"
	w_type = RECYK_BIOLOGICAL

/*
/obj/item/weapon/research//Makes testing much less of a pain -Sieve
	name = "research"
	icon = 'icons/obj/stock_parts.dmi'
	icon_state = "capacitor"
	desc = "A debug item for research."
	origin_tech = "materials=8;programming=8;magnets=8;powerstorage=8;bluespace=8;combat=8;biotech=8;syndicate=8"
*/

/////////Random shit////////

/obj/item/weapon/lightning
	name = "lightning"
	icon = 'icons/obj/lightning.dmi'
	icon_state = "lightning"
	desc = "test lightning"
	flags = USEDELAY

	New()
		icon = midicon
		icon_state = "1"

	afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params)
		var/angle = get_angle(A, user)
		//world << angle
		angle = round(angle) + 45
		if(angle > 180)
			angle -= 180
		else
			angle += 180

		if(!angle)
			angle = 1
		//world << "adjusted [angle]"
		icon_state = "[angle]"
		//world << "[angle] [(get_dist(user, A) - 1)]"
		user.Beam(A, "lightning", 'icons/obj/zap.dmi', 50, 15)
/*Testing
proc/get_angle(atom/a, atom/b)
    return atan2(b.y - a.y, b.x - a.x)
proc/atan2(x, y)
    if(!x && !y) return 0
    return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))
proc
    //  creates an /icon object with 360 states of rotation
    rotate_icon(file, state, step = 1, aa = FALSE)
        var icon/base = icon(file, state)

        var w, h, w2, h2
        if(aa)
            aa ++
            w = base.Width()
            w2 = w * aa
            h = base.Height()
            h2 = h * aa

        var icon{result = icon(base); temp}

        for(var/angle in 0 to 360 step step)
            if(angle == 0  ) continue
            if(angle == 360)   continue

            temp = icon(base)

            if(aa) temp.Scale(w2, h2)
            temp.Turn(angle)
            if(aa) temp.Scale(w,   h)

            result.Insert(temp, "[angle]")

        return result*/