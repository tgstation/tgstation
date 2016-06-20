var/global/image/fire_overlay = image("icon" = 'icons/effects/fire.dmi', "icon_state" = "fire")

/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/item_state = null
	var/lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	var/righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	//Dimensions of the icon file used when this item is worn, eg: hats.dmi
	//eg: 32x32 sprite, 64x64 sprite, etc.
	//allows inhands/worn sprites to be of any size, but still centered on a mob properly
	var/worn_x_dimension = 32
	var/worn_y_dimension = 32
	//Same as above but for inhands, uses the lefthand_ and righthand_ file vars
	var/inhand_x_dimension = 32
	var/inhand_y_dimension = 32

	//Not on /clothing because for some reason any /obj/item can technically be "worn" with enough fuckery.
	var/icon/alternate_worn_icon = null//If this is set, update_icons() will find on mob (WORN, NOT INHANDS) states in this file instead, primary use: badminnery/events
	var/alternate_worn_layer = null//If this is set, update_icons() will force the on mob state (WORN, NOT INHANDS) onto this layer, instead of it's default

	var/hitsound = null
	var/throwhitsound = null
	var/w_class = 3
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	pass_flags = PASSTABLE
	pressure_resistance = 3
	var/obj/item/master = null

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, CHEST, GROIN, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/list/actions = list() //list of /datum/action's that this item has.
	var/list/actions_types = list() //list of paths of action datums to give to the item on New().

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/flags_inv //This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.

	var/item_color = null //this needs deprecating, soonish

	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up
	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/armour_penetration = 0 //percentage of armour effectiveness to remove
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null
	var/strip_delay = 40
	var/put_on_delay = 20
	var/breakouttime = 0
	var/list/materials = list()
	var/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/needs_permit = 0			//Used by security bots to determine if this item is safe for public use.

	var/list/attack_verb = list() //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/list/species_exception = null	// list() of species types, if a species cannot put items in a certain slot, but species type is in list, it will be able to wear that item

	var/suittoggled = 0
	var/hooded = 0

	var/mob/thrownby = null

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

	var/flags_cover = 0 //for flags such as GLASSESCOVERSEYES
	var/heat = 0
	var/sharpness = IS_BLUNT
	var/toolspeed = 1

	var/block_chance = 0
	var/hit_reaction_chance = 0 //If you want to have something unrelated to blocking/armour piercing etc. Maybe not needed, but trying to think ahead/allow more freedom

	//The list of slots by priority. equip_to_appropriate_slot() uses this list. Doesn't matter if a mob type doesn't have a slot.
	var/list/slot_equipment_priority = null // for default list, see /mob/proc/equip_to_appropriate_slot()

	// Needs to be in /obj/item because corgis can wear a lot of
	// non-clothing items
	var/datum/dog_fashion/dog_fashion = null


/obj/item/proc/check_allowed_items(atom/target, not_inside, target_self)
	if(((src in target) && !target_self) || (!istype(target.loc, /turf) && !istype(target, /turf) && not_inside))
		return 0
	else
		return 1

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/New()
	..()
	for(var/path in actions_types)
		new path(src)

/obj/item/Destroy()
	if(ismob(loc))
		var/mob/m = loc
		m.unEquip(src, 1)
	for(var/X in actions)
		qdel(X)
	return ..()

/obj/item/blob_act(obj/effect/blob/B)
	qdel(src)

/obj/item/ex_act(severity, target)
	if(severity == 1 || target == src)
		qdel(src)
	if(!qdeleted(src))
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
		if(1)
			size = "tiny"
		if(2)
			size = "small"
		if(3)
			size = "normal-sized"
		if(4)
			size = "bulky"
		if(5)
			size = "huge"
		if(6)
			size = "gigantic"
		else
	//if ((CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"

	var/pronoun
	if(src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"

	user << "[pronoun] a [size] item." //e.g. They are a small item. or It is a bulky item.

	if(user.research_scanner) //Mob has a research scanner active.
		var/msg = "*--------* <BR>"

		if(origin_tech)
			msg += "<span class='notice'>Testing potentials:</span><BR>"
			var/list/techlvls = params2list(origin_tech)
			for(var/T in techlvls) //This needs to use the better names.
				msg += "Tech: [CallTechName(T)] | magnitude: [techlvls[T]] <BR>"
		else
			msg += "<span class='danger'>No tech origins detected.</span><BR>"


		if(materials.len)
			msg += "<span class='notice'>Extractable materials:<BR>"
			for(var/mat in materials)
				msg += "[CallMaterialName(mat)]<BR>" //Capitize first word, remove the "$"
		else
			msg += "<span class='danger'>No extractable materials detected.</span><BR>"
		msg += "*--------*"
		user << msg


/obj/item/attack_self(mob/user)
	interact(user)

/obj/item/interact(mob/user)
	add_fingerprint(user)
	if(hidden_uplink && hidden_uplink.active)
		hidden_uplink.interact(user)
		return 1
	ui_interact(user)

/obj/item/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/item/attack_hand(mob/user)
	if(!user)
		return
	if(anchored)
		return

	if(burn_state == ON_FIRE)
		var/mob/living/carbon/human/H = user
		if(istype(H))
			if(H.gloves && (H.gloves.max_heat_protection_temperature > 360))
				extinguish()
				user << "<span class='notice'>You put out the fire on [src].</span>"
			else
				user << "<span class='warning'>You burn your hand on [src]!</span>"
				var/obj/item/bodypart/affecting = H.get_bodypart("[user.hand ? "l" : "r" ]_arm")
				if(affecting && affecting.take_damage( 0, 5 ))		// 5 burn damage
					H.update_damage_overlays(0)
				H.updatehealth()
				return
		else
			extinguish()

	if(istype(loc, /obj/item/weapon/storage))
		//If the item is in a storage item, take it out
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, user.loc)

	throwing = 0
	if(loc == user)
		if(!user.unEquip(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src))
		dropped(user)


/obj/item/attack_paw(mob/user)
	if(!user)
		return
	if(anchored)
		return

	if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, user.loc)

	throwing = 0
	if(loc == user)
		if(!user.unEquip(src))
			return

	pickup(user)
	add_fingerprint(user)
	if(!user.put_in_active_hand(src))
		dropped(user)

/obj/item/attack_alien(mob/user)
	var/mob/living/carbon/alien/A = user

	if(!A.has_fine_manipulation)
		if(src in A.contents) // To stop Aliens having items stuck in their pockets
			A.unEquip(src)
		user << "<span class='warning'>Your claws aren't capable of such fine manipulation!</span>"
		return
	attack_paw(A)

/obj/item/attack_ai(mob/user)
	if(istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		if(!R.low_power_mode) //can't equip modules with an empty cell.
			R.activate_module(src)
			R.hud_used.update_robot_modules_display()

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/weapon/W, mob/user, params)
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


// afterattack() and attack() prototypes moved to _onclick/item_attack.dm for consistency

/obj/item/proc/hit_reaction(mob/living/carbon/human/owner, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(prob(final_block_chance))
		owner.visible_message("<span class='danger'>[owner] blocks [attack_text] with [src]!</span>")
		return 1
	return 0

/obj/item/proc/talk_into(mob/M, input, channel, spans)
	return

/obj/item/proc/dropped(mob/user)
	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(user)
	if(DROPDEL & flags)
		qdel(src)

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return


// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder)
	return

// called after an item is placed in an equipment slot //NOPE, for example, if you put a helmet in slot_head, it is NOT in user's head variable yet, how stupid.
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	for(var/X in actions)
		var/datum/action/A = X
		if(item_action_slot_check(slot, user)) //some items only give their actions buttons when in a specific slot.
			A.Grant(user)

//sometimes we only want to grant the item's action if it's equipped in a specific slot.
obj/item/proc/item_action_slot_check(slot, mob/user)
	return 1

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

	if(usr.incapacitated() || !Adjacent(usr) || usr.lying)
		return

	if(usr.get_active_hand() == null) // Let me know if this has any problems -Yota
		usr.UnarmedAttack(src)

//This proc is executed when someone clicks the on-screen UI button.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click(mob/user, actiontype)
	attack_self(user)

/obj/item/proc/IsReflect(var/def_zone) //This proc determines if and at what% an object will reflect energy projectiles if it's in l_hand,r_hand or wear_suit
	return 0

/obj/item/proc/eyestab(mob/living/carbon/M, mob/living/carbon/user)

	var/is_human_victim = 0
	var/obj/item/bodypart/affecting = M.get_bodypart("head")
	if(ishuman(M))
		if(!affecting) //no head!
			return
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

	src.add_fingerprint(user)

	playsound(loc, src.hitsound, 30, 1, -1)

	if(M != user)
		M.visible_message("<span class='danger'>[user] has stabbed [M] in the eye with [src]!</span>", \
							"<span class='userdanger'>[user] stabs you in the eye with [src]!</span>")
		user.do_attack_animation(M)
	else
		user.visible_message( \
			"<span class='danger'>[user] has stabbed themself in the eyes with [src]!</span>", \
			"<span class='userdanger'>You stab yourself in the eyes with [src]!</span>" \
		)
	if(is_human_victim)
		var/mob/living/carbon/human/U = M
		if(affecting.take_damage(7))
			U.update_damage_overlays(0)

	else
		M.take_organ_damage(7)

	add_logs(user, M, "attacked", "[src.name]", "(INTENT: [uppertext(user.a_intent)])")

	M.adjust_blurriness(3)
	M.adjust_eye_damage(rand(2,4))
	if(M.eye_damage >= 10)
		M.adjust_blurriness(15)
		if(M.stat != DEAD)
			M << "<span class='danger'>Your eyes start to bleed profusely!</span>"
		if(!(M.disabilities & (NEARSIGHT | BLIND)))
			if(M.become_nearsighted())
				M << "<span class='danger'>You become nearsighted!</span>"
		if(prob(50))
			if(M.stat != DEAD)
				if(M.drop_item())
					M << "<span class='danger'>You drop what you're holding and clutch at your eyes!</span>"
			M.adjust_blurriness(10)
			M.Paralyse(1)
			M.Weaken(2)
		if (prob(M.eye_damage - 10 + 1))
			if(M.become_blind())
				M << "<span class='danger'>You go blind!</span>"

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

/obj/item/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		throw_at_fast(S,14,3, spin=0)
	else ..()

/obj/item/acid_act(acidpwr, acid_volume)
	. = 1
	if(unacidable)
		return

	var/meltingpwr = acid_volume*acidpwr
	var/melting_threshold = 100
	if(meltingpwr <= melting_threshold) // so a single unit can't melt items. You need 5.1+ unit for fluoro and 10.1+ for sulphuric
		return
	for(var/V in armor)
		if(armor[V] > 0)
			.-- //it survives the acid...
			break
	if(. && prob(min(meltingpwr/10,90))) //chance to melt depends on acid power and volume.
		var/turf/T = get_turf(src)
		if(T)
			var/obj/effect/decal/cleanable/molten_item/I = new (T)
			I.pixel_x = rand(-16,16)
			I.pixel_y = rand(-16,16)
			I.desc = "Looks like this was \an [src] some time ago."
		if(istype(src,/obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = src
			S.do_quick_empty() //melted storage item drops its content.
		qdel(src)
	else
		for(var/armour_value in armor) //but is weakened
			armor[armour_value] = max(armor[armour_value]-min(acidpwr,meltingpwr/10),0)
		if(!findtext(desc, "it looks slightly melted...")) //it looks slightly melted... it looks slightly melted... it looks slightly melted... etc.
			desc += " it looks slightly melted..." //needs a space at the start, formatting

/obj/item/throw_impact(atom/A)
	var/itempush = 1
	if(w_class < 4)
		itempush = 0 //too light to push anything
	return A.hitby(src, 0, itempush)

/obj/item/throw_at(atom/target, range, speed, mob/thrower, spin=1)
	thrownby = thrower
	. = ..()
	throw_speed = initial(throw_speed) //explosions change this.


/obj/item/proc/remove_item_from_storage(atom/newLoc) //please use this if you're going to snowflake an item out of a obj/item/weapon/storage
	if(!newLoc)
		return 0
	if(istype(loc,/obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src,newLoc)
		return 1
	return 0

/obj/item/proc/is_hot()
	return heat

/obj/item/proc/is_sharp()
	return sharpness

/obj/item/proc/get_dismemberment_chance(obj/item/bodypart/affecting)
	if(affecting.can_dismember(src))
		if((sharpness || damtype == BURN) && w_class >= 3)
			. = force*(w_class-1)

/obj/item/proc/get_dismember_sound()
	if(damtype == BURN)
		. = 'sound/weapons/sear.ogg'
	else
		. = pick('sound/misc/desceration-01.ogg', 'sound/misc/desceration-02.ogg', 'sound/misc/desceration-03.ogg')

/obj/item/proc/open_flame()
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		if(M.l_hand == src || M.r_hand == src)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(700, 5)
