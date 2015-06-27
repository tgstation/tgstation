/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	//Not on /clothing because for some reason any /obj/item can technically be "worn" with enough fuckery.
	var/icon/alternate_worn_icon = null//If this is set, update_icons() will find on mob (WORN, NOT INHANDS) states in this file instead, primary use: badminnery/events

	var/hitsound = null
	var/throwhitsound = null
	var/w_class = 3.0
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 3
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	//If this is set, The item will make an action button on the player's HUD when picked up.
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for
	var/datum/action/item_action/action = null

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	var/item_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/armour_penetration = 0 //percentage of armour effectiveness to remove
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/strip_delay = 40
	var/put_on_delay = 20
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/reliability = 100	//Used by SOME devices to determine how reliable they are.
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/needs_permit = 0			//Used by security bots to determine if this item is safe for public use.

	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/species_exception = list()	// even if a species cannot put items in a certain slot, if the species id is in the item's exception list, it will be able to wear that item

	var/suittoggled = 0
	var/hooded = 0

	/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER //the icon to indicate this object is being dragged

	//So items can have custom embedd values
	//Because customisation is king
	var/embed_chance = EMBED_CHANCE
	var/embedded_fall_chance = EMBEDDED_ITEM_FALLOUT
	var/embedded_pain_chance = EMBEDDED_PAIN_CHANCE
	var/embedded_pain_multiplier = EMBEDDED_PAIN_MULTIPLIER  //The coefficient of multiplication for the damage this item does while embedded (this*w_class)
	var/embedded_fall_pain_multiplier = EMBEDDED_FALL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when falling out of a limb (this*w_class)
	var/embedded_impact_pain_multiplier = EMBEDDED_IMPACT_PAIN_MULTIPLIER //The coefficient of multiplication for the damage this item does when first embedded (this*w_class)
	var/embedded_unsafe_removal_pain_multiplier = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER //The coefficient of multiplication for the damage removing this without surgery causes (this*w_class)
	var/embedded_unsafe_removal_time = EMBEDDED_UNSAFE_REMOVAL_TIME //A time in ticks, multiplied by the w_class.

	var/list/can_be_placed_into = list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/closet,
		/obj/item/weapon/storage,
		/obj/structure/safe,
		/obj/machinery/disposal,
		/obj/machinery/r_n_d/destructive_analyzer,
		/obj/machinery/r_n_d/experimentor,
		/obj/machinery/autolathe
	)

	var/flags_cover = 0 //for flags such as GLASSESCOVERSEYES

/obj/item/proc/check_allowed_items(atom/target, not_inside)
	if((src in target) || ((!istype(target.loc, /turf)) && (!istype(target, /turf)) && (not_inside)) || is_type_in_list(target, can_be_placed_into))
		return 0
	else
		return 1


/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/Destroy()
	if(ismob(loc))
		var/mob/m = loc
		m.unEquip(src, 1)
	return ..()

/obj/item/blob_act()
	qdel(src)

/obj/item/ex_act(severity, target)
	if(severity == 1 || target == src)
		qdel(src)
	if(!gc_destroyed)
		contents_explosion(severity, target)

//user: The mob that is suiciding
//damagetype: The type of damage the item will inflict on the user
//BRUTELOSS = 1
//FIRELOSS = 2
//TOXLOSS = 4
//OXYLOSS = 8
//Output a creative message and then return the damagetype done
/obj/item/proc/suicide_act(mob/user)
	return

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() || !usr.canmove)
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user) //This might be spammy. Remove?
	..()
	var/size
	switch(src.w_class)
		if(1.0)
			size = "tiny"
		if(2.0)
			size = "small"
		if(3.0)
			size = "normal-sized"
		if(4.0)
			size = "bulky"
		if(5.0)
			size = "huge"
		if(6.0)
			size = "gigantic"
		else
	//if ((CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"

	var/pronoun
	if(src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"

	user << "[pronoun] a [size] item." //e.g. They are a small item. or It is a bulky item.

/obj/item/attack_hand(mob/user as mob)
	if (!user) return
	if (istype(src.loc, /obj/item/weapon/storage))
		//If the item is in a storage item, take it out
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src, user.loc)

	src.throwing = 0
	if (loc == user)
		if(!user.unEquip(src))
			return
	else
		if(isliving(loc))
			return
	pickup(user)
	add_fingerprint(user)
	user.put_in_active_hand(src)
	return


/obj/item/attack_paw(mob/user as mob)

	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		if(!user.unEquip(src))
			return
	else
		if(istype(src.loc, /mob/living))
			return
		src.pickup(user)

	user.put_in_active_hand(src)
	return


/obj/item/attack_alien(mob/user as mob)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.unEquip(src)
		user << "<span class='warning'>Your claws aren't capable of such fine manipulation!</span>"
		return
	attack_paw(A)

/obj/item/attack_ai(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user)) return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect multiple items on a tile and we clicked on a valid one.
				if(isturf(src.loc))
					var/list/rejections = list()
					var/success = 0
					var/failure = 0

					for(var/obj/item/I in src.loc)
						if(S.collection_mode == 2 && !istype(I,src.type)) // We're only picking up items of the target type
							failure = 1
							continue
						if(I.type in rejections) // To limit bag spamming: any given type only complains once
							continue
						if(!S.can_be_inserted(I))	// Note can_be_inserted still makes noise when the answer is no
							rejections += I.type	// therefore full bags are still a little spammy
							failure = 1
							continue

						success = 1
						S.handle_item_insertion(I, 1)	//The 1 stops the "You put the [src] into [S]" insertion message from being displayed.
					if(success && !failure)
						user << "<span class='notice'>You put everything [S.preposition] [S].</span>"
					else if(success)
						user << "<span class='notice'>You put some things [S.preposition] [S].</span>"
					else
						user << "<span class='warning'>You fail to pick anything up with [S]!</span>"

			else if(S.can_be_inserted(src))
				S.handle_item_insertion(src)

	return

// afterattack() and attack() prototypes moved to _onclick/item_attack.dm for consistency

/obj/item/proc/talk_into(mob/M, input, channel, spans)
	return

/obj/item/proc/dropped(mob/user as mob)
	..()

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0)
	if(!M)
		return 0

	return M.can_equip(src, slot, disable_warning)


/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(usr.stat || usr.restrained() || !Adjacent(usr) || usr.stunned || usr.weakened || usr.lying)
		return

	if(ishuman(usr) || ismonkey(usr))
		if(usr.get_active_hand() == null)
			usr.UnarmedAttack(src) // Let me know if this has any problems -Giacom | Actually let me know now.  -Sayu
		/*
		if(usr.get_active_hand() == null)
			src.attack_hand(usr)
		else
			usr << "\red You already have something in your hand."
		*/
	else
		usr << "<span class='warning'>This mob type can't use this verb!</span>"

//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'action_button_name'.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	attack_self(usr)

/obj/item/proc/IsShield()
	return 0

/obj/item/proc/IsReflect(var/def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/is_human_victim = 0
	if(ishuman(M))
		is_human_victim = 1
		var/mob/living/carbon/human/H = M
		if((H.head && H.head.flags_cover & HEADCOVERSEYES) || \
			(H.wear_mask && H.wear_mask.flags_cover & MASKCOVERSEYES) || \
			(H.glasses && H.glasses.flags_cover & GLASSESCOVERSEYES))
			// you can't stab someone in the eyes wearing a mask!
			user << "<span class='danger'>You're going to need to remove that mask/helmet/glasses first!</span>"
			return

	if(ismonkey(M))
		var/mob/living/carbon/monkey/Mo = M
		if(Mo.wear_mask && Mo.wear_mask.flags_cover & MASKCOVERSEYES)
			// you can't stab someone in the eyes wearing a mask!
			user << "<span class='danger'>You're going to need to remove that mask/helmet/glasses first!</span>"
			return

	if(isalien(M))//Aliens don't have eyes./N     slimes also don't have eyes!
		user << "<span class='warning'>You cannot locate any eyes on this creature!</span>"
		return

	if(isbrain(M))
		user << "<span class='danger'>You cannot locate any organic eyes on this brain!</span>"
		return

	add_logs(user, M, "attacked", object="[src.name]", addition="(INTENT: [uppertext(user.a_intent)])")

	src.add_fingerprint(user)

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [src]!</span>")
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed themself in the eyes with [src]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [src]!</span>" \
		)
	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		var/obj/item/organ/limb/affecting = U.get_organ("head")
		if(affecting.take_damage(7))
			U.update_damage_overlays(0)

	else
		M.take_organ_damage(7)

	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(2,4)
	if (M.eye_stat >= 10)
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= NEARSIGHT
		if(M.stat != 2)
			M << "<span class='danger'>Your eyes start to bleed profusely!</span>"
		if(prob(50))
			if(M.stat != 2)
				if(M.drop_item())
					M << "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>"
			M.eye_blurry += 10
			M.Paralyse(1)
			M.Weaken(2)
		if (prob(M.eye_stat - 10 + 1))
			if(M.stat != 2)
				M << "<span class='danger'>You go blind!</span>"
			M.disabilities |= BLIND
	return

/obj/item/clean_blood()
	. = ..()
	if(.)
		if(initial(icon) && initial(icon_state))
			var/index = blood_splatter_index()
			var/icon/blood_splatter_icon = blood_splatter_icons[index]
			if(blood_splatter_icon)
				overlays -= blood_splatter_icon

/obj/item/clothing/gloves/clean_blood()
	. = ..()
	if(.)
		transfer_blood = 0
		bloody_hands_mob = null

/obj/item/singularity_pull(S, current_size)
	spawn(0) //this is needed or multiple items will be thrown sequentially and not simultaneously
		if(current_size >= STAGE_FOUR)
			throw_at(S,14,3)
		else ..()

/obj/item/acid_act(var/acidpwr, var/toxpwr, var/acid_volume)
	. = 1
	if(unacidable)
		return

	for(var/V in armor)
		if(armor[V] > 0)
			.-- //it survives the acid...
			break
	if(.)
		var/turf/T = get_turf(src)
		if(T)
			T.visible_message("<span class='danger'>[src] melts away!</span>")
			var/obj/effect/decal/cleanable/molten_item/I = new (T)
			I.pixel_x = rand(-16,16)
			I.pixel_y = rand(-16,16)
			I.desc = "Looks like this was \an [src] some time ago."
		qdel(src)
	else
		for(var/armour_value in armor) //but is weakened
			armor[armour_value] = max(armor[armour_value]-acidpwr,0)
		if(!findtext(desc, "it looks slightly melted...")) //it looks slightly melted... it looks slightly melted... it looks slightly melted... etc.
			desc += " it looks slightly melted..." //needs a space at the start, formatting



/obj/item/throw_impact(A)
	if(throw_speed >= EMBED_THROWSPEED_THRESHOLD)
		if(istype(A, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = A
			if(can_embed(src))
				if(prob(embed_chance) && !(PIERCEIMMUNE in H.dna.species.specflags))
					H.throw_alert("embeddedobject")
					var/obj/item/organ/limb/L = pick(H.organs)
					L.embedded_objects |= src
					add_blood(H)//it embedded itself in you, of course it's bloody!
					loc = H
					L.take_damage(w_class*embedded_impact_pain_multiplier)
					H.visible_message("<span class='danger'>\the [name] embeds itself in [H]'s [L.getDisplayName()]!</span>","<span class='userdanger'>\the [name] embeds itself in your [L.getDisplayName()]!</span>")
					return

	//Reset regardless of if we hit a human.
	throw_speed = initial(throw_speed) //explosions change this.
	..()

/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/weapon/storage
	if(!newLoc)
		return 0
	if(istype(loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return 1
	return 0