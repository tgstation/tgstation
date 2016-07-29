<<<<<<< HEAD
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
	pressure_resistance = 4
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

/obj/item/proc/open_flame(flame_heat=700)
	var/turf/location = loc
	if(ismob(location))
		var/mob/M = location
		var/success = FALSE
		if(src == M.get_item_by_slot(slot_l_hand))
			success = TRUE
		else if(src == M.get_item_by_slot(slot_r_hand))
			success = TRUE
		else if(src == M.get_item_by_slot(slot_wear_mask))
			success = TRUE
		if(success)
			location = get_turf(M)
	if(isturf(location))
		location.hotspot_expose(flame_heat, 5)

/obj/item/proc/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = "<span class='notice'>[user] lights [A] with [src].</span>"
	else
		. = ""
=======
/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/abstract = 0
	var/item_state = null
	var/list/inhand_states = list("left_hand" = 'icons/mob/in-hand/left/items_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/items_righthand.dmi')
	var/r_speed = 1.0
	var/health = null
	var/hitsound = null

	var/w_class = W_CLASS_MEDIUM
	var/attack_delay = 10 //Delay between attacking with this item, in 1/10s of a second (default = 1 second)

	flags = FPRINT
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/obj/item/offhand/wielded = null
	pass_flags = PASSTABLE
	pressure_resistance = 5
//	causeerrorheresoifixthis
	var/obj/item/master = null

	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/heat_conductivity = 0.5 // how conductive an item is to heat a player (ie how quickly someone will lose heat) on a scale of 0 - 1. - 1 is fully conductive, 0 is fully insulative, this is a range, not binary.
	//If this is set, The item will make an action button on the player's HUD when picked up.
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.

	//Since any item can now be a piece of clothing, this has to be put here so all items share it.
	var/_color = null
	var/body_parts_covered = 0 //see setup.dm for appropriate bit flags
	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit) - 0 is not conductive, 1 is conductive - this is a range, not binary
	var/slowdown = 0 // How much clothing is slowing you down. Negative values speeds you up

	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/cant_drop = 0 //If 1, can't drop it from hands!

	var/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)

	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.
	var/list/species_fit = null //This object has a different appearance when worn by these species
	var/surgery_speed = 1 //When this item is used as a surgery tool, multiply the delay of the surgery step by this much.
	var/nonplant_seed_type

	var/list/attack_verb // used in attack() to say how something was attacked "[x] [z.attack_verb] [y] with [z]". Present tense.



	var/vending_cat = null// subcategory for vending machines.
	var/list/dynamic_overlay[0] //For items which need to slightly alter their on-mob appearance while being worn.

/obj/item/proc/return_thermal_protection()
	return return_cover_protection(body_parts_covered) * (1 - src.heat_conductivity)

/obj/item/Destroy()
	if(istype(src.loc, /mob))
		var/mob/H = src.loc
		H.drop_from_inventory(src) // items at the very least get unequipped from their mob before being deleted
	if(hasvar(src, "holder"))
		src:holder = null
	/*  BROKEN, FUCK BYOND
	if(hasvar(src, "my_atom"))
		src:my_atom = null*/
	..()


	/* Species-specific sprite sheets for inventory sprites
	Works similarly to worn sprite_sheets, except the alternate sprites are used when the clothing/refit_for_species() proc is called.
	*/
	//var/list/sprite_sheets_obj = null

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				qdel(src)
				return
		else
	return

/obj/item/blob_act()
	..()
	qdel(src)

/obj/item/proc/restock() //used for borg recharging
	return

/obj/item/projectile_check()
	return PROJREACT_OBJS

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

	if(!istype(src.loc, /turf) || usr.isUnconscious() || usr.restrained())
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user)
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
		if(5.0 to INFINITY)
			size = "huge"
	//if ((M_CLUMSY in usr.mutations) && prob(50)) t = "funny-looking"
	var/pronoun
	if (src.gender == PLURAL)
		pronoun = "They are"
	else
		pronoun = "It is"
	..(user, " [pronoun] a [size] item.")
	if((cant_drop > 0) && user.is_holding_item(src)) //Item can't be dropped, and is either in left or right hand!
		user << "<span class='danger'>It's stuck to your hands!</span>"


/obj/item/attack_ai(mob/user as mob)
	..()
	if(isMoMMI(user))
		var/in_range = in_range(src, user) || src.loc == user
		if(in_range)
			if(src == user:tool_state)
				return 0
			attack_hand(user)
	else if(isrobot(user))
		if(!istype(src.loc, /obj/item/weapon/robot_module)) return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attack_hand(mob/user as mob)
	if (!user) return

	if (istype(src.loc, /obj/item/weapon/storage))
		//If the item is in a storage item, take it out.
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src, user)

	src.throwing = 0
	if (src.loc == user)
		if(src == user.get_inactive_hand())
			if(src.flags & TWOHANDABLE)
				return src.wield(user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(!src.canremove)
			return
		else
			user.u_equip(src,0)
	else
		if(isliving(src.loc))
			return
		//user.next_move = max(user.next_move+2,world.time + 2)
	add_fingerprint(user)
	user.put_in_active_hand(src)
	return

/obj/item/requires_dexterity(mob/user)
	return 1

/obj/item/attack_paw(mob/user as mob)

	if(isalien(user)) // -- TLE
		var/mob/living/carbon/alien/A = user

		if(!A.has_fine_manipulation || w_class >= W_CLASS_LARGE)
			if(src in A.contents) // To stop Aliens having items stuck in their pockets
				A.drop_from_inventory(src)
			to_chat(user, "Your claws aren't capable of such fine manipulation.")
			return

	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		//canremove==0 means that object may not be removed. You can still wear it. This only applies to clothing. /N
		if(istype(src, /obj/item/clothing) && !src:canremove)
			return
		else
			user.u_equip(src,0)
	else
		if(istype(src.loc, /mob/living))
			return
		//user.next_move = max(user.next_move+2,world.time + 2)

	user.put_in_active_hand(src)
	return

// Due to storage type consolidation this should get used more now.
// I have cleaned it up a little, but it could probably use more.  -Sayu
/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)
	return

/obj/item/proc/talk_into(var/datum/speech/speech, var/channel=null)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/dropped(mob/user as mob)
	layer = initial(layer) //nothing bad can come from this right?
	plane = initial(plane) //wrong
	if(wielded)
		unwield(user)

///called when an item is stripped off by another person, called BEFORE it is dropped. return 1 to prevent it from actually being stripped.
/obj/item/proc/before_stripped(mob/wearer as mob, mob/stripper as mob, slot)
	if(slot in list(slot_l_store, slot_r_store)) //is in pockets
		on_found(wearer, stripper)

///called when an item is stripped off by another person, called AFTER it is on the ground
/obj/item/proc/stripped(mob/wearer as mob, mob/stripper as mob, slot)
	return unequipped(wearer)

// called just as an item is picked up (loc is not yet changed). return 1 to prevent the item from being actually picked up.
/obj/item/proc/prepickup(mob/user)
	return

// called after an item is picked up (loc has already changed)
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
/obj/item/proc/equipped(var/mob/user, var/slot, hand_index = 0)
	if(cant_drop) //Item can't be dropped
		if(hand_index) //Item was equipped in a hand slot
			to_chat(user, "<span class='notice'>\The [src] sticks to your hand!</span>")

	return

// called after an item is unequipped or stripped
/obj/item/proc/unequipped(mob/user)
	return

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
/obj/item/proc/mob_can_equip(mob/M, slot, disable_warning = 0, automatic = 0)
	if(!slot) return CANNOT_EQUIP
	if(!M) return CANNOT_EQUIP

	if(wielded)
		if(!disable_warning)
			if(flags & MUSTTWOHAND)
				M.show_message("\The [src] is too cumbersome to carry in anything other than your hands.")
			else
				M.show_message("You have to unwield \the [wielded.wielding] first.")
		return CANNOT_EQUIP

	if(cant_drop > 0)
		if(!disable_warning)
			to_chat(M, "<span class='danger'>It's stuck to your hands!</span>")
		return CANNOT_EQUIP

	if(ishuman(M)) //Crimes Against OOP: This is first on the list if anybody ever feels like unfucking inventorycode
		//START HUMAN
		var/mob/living/carbon/human/H = M

		if(istype(src, /obj/item/clothing/under) || istype(src, /obj/item/clothing/suit))
			if(M_FAT in H.mutations)
				//testing("[M] TOO FAT TO WEAR [src]!")
				if(!(flags & ONESIZEFITSALL))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You're too fat to wear the [name].</span>")
					return CANNOT_EQUIP

			for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
				if(!OE.species) //Organ has same species as body
					if(H.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL)) //Use the body's base species
						if(!disable_warning)
							to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
						return CANNOT_EQUIP
				else //Organ's species is different from body
					if(OE.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL))
						if(!disable_warning)
							to_chat(H, "<span class='warning'>You can't get \the [src] to fit over your bulky exterior!</span>")
						return CANNOT_EQUIP

		switch(slot)
			if(slot_wear_mask)
				if( !(slot_flags & SLOT_MASK) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your thick head!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your thick head!</span>")
							return CANNOT_EQUIP

				if(H.wear_mask)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.wear_mask.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_back)
				if( !(slot_flags & SLOT_BACK) )
					return CANNOT_EQUIP
				if(H.back)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.back.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_suit)
				if( !(slot_flags & SLOT_OCLOTHING) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky exterior!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky exterior!</span>")
							return CANNOT_EQUIP

				if(H.wear_suit)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.wear_suit.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_gloves)
				if( !(slot_flags & SLOT_GLOVES) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky fingers!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky fingers!</span>")
							return CANNOT_EQUIP

				if(H.gloves)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.gloves.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_shoes)
				if( !(slot_flags & SLOT_FEET) )
					return CANNOT_EQUIP

				for(var/datum/organ/external/OE in get_organs_by_slot(slot, H))
					if(!OE.species) //Organ has same species as body
						if(H.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL)) //Use the body's base species
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky feet!</span>")
							return CANNOT_EQUIP
					else //Organ's species is different from body
						if(OE.species.flags & IS_BULKY && !(flags & ONESIZEFITSALL))
							if(!disable_warning)
								to_chat(H, "<span class='warning'>You can't get \the [src] to fasten around your bulky feet!</span>")
							return CANNOT_EQUIP

				if(H.shoes)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.shoes.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_belt)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_BELT) )
					return CANNOT_EQUIP
				if(H.belt)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.belt.canremove && !istype(H.belt, /obj/item/weapon/storage/belt))
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_glasses)
				if( !(slot_flags & SLOT_EYES) )
					return CANNOT_EQUIP
				if(H.glasses)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.glasses.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_head)
				if( !(slot_flags & SLOT_HEAD) )
					return CANNOT_EQUIP
				if(H.head)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.head.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP

			if(slot_ears)
				if( !(slot_flags & SLOT_EARS) )
					return CANNOT_EQUIP
				if(H.ears)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.ears.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			/* In case it's ever unfucked.
			if(slot_ears)
				if( !(slot_flags & SLOT_EARS) )
					return CANNOT_EQUIP
				if( (slot_flags & SLOT_TWOEARS) && H.r_ear )
					return CANNOT_EQUIP
				if(H.l_ear)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.l_ear.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				if( w_class < W_CLASS_SMALL	)
					return CAN_EQUIP
				return CAN_EQUIP
			if(slot_r_ear)
				if( !(slot_flags & SLOT_EARS) )
					return CANNOT_EQUIP
				if( (slot_flags & SLOT_TWOEARS) && H.l_ear )
					return CANNOT_EQUIP
				if(H.r_ear)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.r_ear.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				if( w_class < W_CLASS_SMALL )
					return CAN_EQUIP
				return CAN_EQUIP
			*/
			if(slot_w_uniform)
				if( !(slot_flags & SLOT_ICLOTHING) )
					return CANNOT_EQUIP
				if(H.w_uniform)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.w_uniform.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_id)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_ID) )
					return CANNOT_EQUIP
				if(H.wear_id)
					if(automatic)
						if(H.check_for_open_slot(src))
							return CANNOT_EQUIP
					if(H.wear_id.canremove)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_l_store)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if(automatic)
					if(H.l_store)
						return CANNOT_EQUIP
					else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
						return CAN_EQUIP
				else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					if(H.l_store)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CAN_EQUIP
			if(slot_r_store)
				if(!H.w_uniform)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a jumpsuit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if(slot_flags & SLOT_DENYPOCKET)
					return
				if(automatic)
					if(H.r_store)
						return CANNOT_EQUIP
					else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
						return CAN_EQUIP
				else if( w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET) )
					if(H.r_store)
						return CAN_EQUIP_BUT_SLOT_TAKEN
					else
						return CAN_EQUIP
			if(slot_s_store)
				if(!H.wear_suit)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>You need a suit before you can attach this [name].</span>")
					return CANNOT_EQUIP
				if(!H.wear_suit.allowed)
					if(!disable_warning)
						to_chat(usr, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
					return CANNOT_EQUIP
				if(src.w_class > W_CLASS_MEDIUM && !H.wear_suit.allowed.len)
					if(!disable_warning)
						to_chat(usr, "The [name] is too big to attach.")
					return CANNOT_EQUIP
				if( istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed) )
					if(H.s_store)
						if(automatic)
							if(H.check_for_open_slot(src))
								return CANNOT_EQUIP
						if(H.s_store.canremove)
							return CAN_EQUIP_BUT_SLOT_TAKEN
						else
							return CANNOT_EQUIP
					else
						return CAN_EQUIP
				return CANNOT_EQUIP
			if(slot_handcuffed)
				if(H.handcuffed)
					return CANNOT_EQUIP
				if(!istype(src, /obj/item/weapon/handcuffs))
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_legcuffed)
				if(H.legcuffed)
					return CANNOT_EQUIP
				if(!istype(src, /obj/item/weapon/legcuffs))
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_in_backpack)
				if (H.back && istype(H.back, /obj/item/weapon/storage/backpack))
					var/obj/item/weapon/storage/backpack/B = H.back
					if(B.contents.len < B.storage_slots && w_class <= B.fits_max_w_class)
						return CAN_EQUIP
				return CANNOT_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END HUMAN

	else if(ismonkey(M))
		//START MONKEY
		var/mob/living/carbon/monkey/MO = M
		switch(slot)
			if(slot_head)
				if(!MO.canWearHats)
					return CANNOT_EQUIP
				if(MO.hat)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_HEAD) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_mask)
				if(MO.wear_mask)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_MASK) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_glasses)
				if(!MO.canWearGlasses)
					return CANNOT_EQUIP
				if(MO.glasses)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_EYES) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_w_uniform)
				if(!MO.canWearClothes)
					return CANNOT_EQUIP
				if(MO.uniform)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_ICLOTHING) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_back)
				if(MO.back)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_BACK) )
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END MONKEY

	else if(isalienadult(M))
		//START ALIEN HUMANOID
		var/mob/living/carbon/alien/humanoid/AH = M
		switch(slot)
			//Maybe when someone sprites an "alien lying down" version of every exosuit and hat in the game.
			/*if(slot_head)
				if(AH.head)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_HEAD) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_wear_suit)
				if(AH.wear_suit)
					return CANNOT_EQUIP
				if( !(slot_flags & SLOT_OCLOTHING) )
					return CANNOT_EQUIP
				return CAN_EQUIP*/
			if(slot_l_store)
				if(slot_flags & SLOT_DENYPOCKET)
					return CANNOT_EQUIP
				if(AH.l_store)
					return CANNOT_EQUIP
				if( !(w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET)) )
					return CANNOT_EQUIP
				return CAN_EQUIP
			if(slot_r_store)
				if(slot_flags & SLOT_DENYPOCKET)
					return CANNOT_EQUIP
				if(AH.r_store)
					return CANNOT_EQUIP
				if( !(w_class <= W_CLASS_SMALL || (slot_flags & SLOT_POCKET)) )
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END ALIEN HUMANOID

	else if(isMoMMI(M))
		//START MOMMI ALSO THIS SO FUCKING SILLY
		var/mob/living/silicon/robot/mommi/MoM = M
		switch(slot)
			if(slot_head)
				if(MoM.head_state)
					return CANNOT_EQUIP
				return CAN_EQUIP
		return CANNOT_EQUIP //Unsupported slot
		//END MOMMI

/obj/item/can_pickup(mob/living/user)
	if(!(user) || !isliving(user)) //BS12 EDIT
		return 0
	if(user.incapacitated() || !Adjacent(user))
		return 0
	if((!istype(user, /mob/living/carbon) && !isMoMMI(user)) || istype(user, /mob/living/carbon/brain)) //Is not a carbon being, MoMMI, or is a brain
		to_chat(user, "You can't pick things up!")
	if(src.anchored) //Object isn't anchored
		to_chat(user, "<span class='warning'>You can't pick that up!</span>")
		return 0
	if(!istype(src.loc, /turf)) //Object is not on a turf
		to_chat(user, "<span class='warning'>You can't pick that up!</span>")
		return 0
	return 1

/obj/item/verb_pickup(mob/living/user)
	//set src in oview(1)
	//set category = "Object"
	//set name = "Pick up"

	if(!can_pickup(user))
		return 0

	if(user.get_active_hand())
		to_chat(user, "<span class='warning'>Your [user.get_index_limb_name(user.active_hand)] is full.</span>")
		return

	//All checks are done, time to pick it up!
	if(isMoMMI(user))
		// Otherwise, we get MoMMIs changing their own laws.
		if(istype(src,/obj/item/weapon/aiModule))
			to_chat(src, "<span class='warning'>Your firmware prevents you from picking up [src]!</span>")
			return
		if(user.get_active_hand() == null)
			user.put_in_hands(src)
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/h_user = user
		if(h_user.can_use_hand())
			src.attack_hand(h_user)
		else
			src.attack_stump(h_user)
	if(istype(user, /mob/living/carbon/alien))
		src.attack_alien(user)
	if(istype(user, /mob/living/carbon/monkey))
		src.attack_paw(user)
	return

//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'action_button_name'.
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	if(src in usr)
		attack_self(usr)

//Used in twohanding
/obj/item/proc/wield(mob/user, var/inactive = 0)
	if(!user.can_wield())
		user.show_message("You can't wield \the [src] as it's too heavy.")
		return

	if(!wielded)
		wielded = getFromPool(/obj/item/offhand)

		//Long line ahead, let's break that up!
		//
		//((user.get_active_hand() in list(null, src)) && user.put_in_inactive_hand(wielded))
		//By default this proc assumes that the wielded item is held in the ACTIVE hand!
		//(user.get_active_hand() in list(null, src)) is the part which checks whether the ACTIVE hand is either nothing, or the wielded item. Otherwise, abort!

		//The second half is the same, except that the proc assumes that the wielded item is held in the INACTIVE hand. So the INACTIVE hand is checked for holding either nothing or wielded item.
		//if(((user.get_active_hand() in list(null, src)) && user.put_in_inactive_hand(wielded)) || (!inactive && ((user.get_inactive_hand() in list(null, src)) && user.put_in_active_hand(wielded))))

		for(var/i = 1 to user.held_items.len)
			if(user.held_items[i]) continue
			if(user.active_hand == i) continue

			if(user.put_in_hand(i, wielded))
				wielded.attach_to(src)
				update_wield(user)
				return 1

		unwield(user)
		return

/obj/item/proc/unwield(mob/user)
	if(flags & MUSTTWOHAND && src in user)
		user.drop_from_inventory(src)
	if(istype(wielded))
		user.u_equip(wielded,1)
		if(wielded)
			wielded.wielding = null
			returnToPool(wielded)
			wielded = null
	update_wield(user)

/obj/item/proc/update_wield(mob/user)

/obj/item/proc/IsShield()
	return 0

//Called when the item blocks an attack. Return 1 to stop the hit, return 0 to let the hit go through
/obj/item/proc/on_block(damage, attack_text = "the attack")
	if(ismob(loc))
		if(prob(50 - round(damage / 3)))
			visible_message("<span class='danger'>[loc] blocks [attack_text] with \the [src]!</span>")
			return 1

	return 0

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)


	var/mob/living/carbon/human/H = M
	if(istype(H))
		var/obj/item/eye_protection = H.get_body_part_coverage(EYES)
		if(eye_protection)
			to_chat(user, "<span class='warning'>You're going to need to remove that [eye_protection] first.</span>")
			return

	var/mob/living/carbon/monkey/Mo = M
	if(istype(Mo) && ( \
			(Mo.wear_mask && Mo.wear_mask.body_parts_covered & EYES) \
		))
		// you can't stab someone in the eyes wearing a mask!
		to_chat(user, "<span class='warning'>You're going to need to remove that mask first.</span>")
		return

	if(!M.has_eyes())
		to_chat(user, "<span class='warning'>You cannot locate any eyes on [M]!</span>")
		return

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>"
	msg_admin_attack("ATTACK: [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])") //BS12 EDIT ALG
	log_attack("<font color='red'> [user.name] ([user.ckey]) attacked [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")
	if(!iscarbon(user))
		M.LAssailant = null
	else
		M.LAssailant = user

	src.add_fingerprint(user)
	//if((M_CLUMSY in user.mutations) && prob(50))
	//	M = user
		/*
		to_chat(M, "<span class='warning'>You stab yourself in the eye.</span>")
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)
		*/

	if(istype(M, /mob/living/carbon/human))

		var/datum/organ/internal/eyes/eyes = H.internal_organs_by_name["eyes"]

		if(M != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message("<span class='danger'>[user] stabs [M] in the eye with \the [src].</span>", 1)
			to_chat(M, "<span class='userdanger'>[user] stabs you in the eye with \the [src]!</span>")
			to_chat(user, "<span class='attack'>You stab [M] in the eye with \the [src]!</span>")
		else
			user.visible_message( \
				"<span class='attack'>[user] stabs themself with \the [src]!</span>", \
				"<span class='userdanger'>You stab yourself in the eyes with \the [src]!</span>" \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(eyes.robotic <= 1) //robot eyes bleeding might be a bit silly
					to_chat(M, "<span class='warning'>Your eyes start to bleed profusely!</span>")
			if(prob(50))
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You drop what you're holding and clutch at your eyes!</span>")
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, "<span class='warning'>You go blind!</span>")
		var/datum/organ/external/affecting = M:get_organ(LIMB_HEAD)
		if(affecting.take_damage(7))
			M:UpdateDamageIcon(1)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0


/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0
	if(istype(src, /obj/item/weapon/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if(!blood_overlays[type])
		generate_blood_overlay()

	if(!blood_overlay)
		blood_overlay = blood_overlays[type]
	else
		overlays.Remove(blood_overlay)

	//apply the blood-splatter overlay if it isn't already in there, else it updates it.
	blood_overlay.color = blood_color
	overlays += blood_overlay

	//if this blood isn't already in the list, add it

	if(!M)
		return
	if(blood_DNA[M.dna.unique_enzymes])
		return 0 //already bloodied with this blood. Cannot add more.
	blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

var/global/list/image/blood_overlays = list()
/obj/item/proc/generate_blood_overlay()
	if(blood_overlays[type])
		return

	var/icon/I = new /icon(icon, icon_state)
	I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD) //fills the icon_state with white (except where it's transparent)
	I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY) //adds blood and the remaining white areas become transparant

	blood_overlays[type] = image(I)


/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF='?src=\ref[M];lookitem=\ref[src]'>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && !I.abstract)
		I.showoff(src)

// /vg/ Affects wearers.
/obj/item/proc/OnMobLife(var/mob/holder)
	return

/obj/item/proc/OnMobDeath(var/mob/holder)
	return

//handling the pulling of the item for singularity
/obj/item/singularity_pull(S, current_size)
	if(flags & INVULNERABLE)
		return
	spawn(0) //this is needed or multiple items will be thrown sequentially and not simultaneously
		if(current_size >= STAGE_FOUR)
			//throw_at(S, 14, 3)
			step_towards(src,S)
			sleep(1)
			step_towards(src,S)
		else if(current_size > STAGE_ONE)
			step_towards(src,S)
		else ..()

//Gets the rating of the item, used in stuff like machine construction.
/obj/item/proc/get_rating()
	return 0

/obj/item/kick_act(mob/living/carbon/human/H) //Kick items around!
	if(anchored || w_class > W_CLASS_MEDIUM + H.get_strength())
		H.visible_message("<span class='danger'>[H] attempts to kick \the [src]!</span>", "<span class='danger'>You attempt to kick \the [src]!</span>")
		if(prob(70))
			to_chat(H, "<span class='danger'>Dumb move! You strain a muscle.</span>")

			H.apply_damage(rand(1,4), BRUTE, pick(LIMB_RIGHT_LEG, LIMB_LEFT_LEG, LIMB_RIGHT_FOOT, LIMB_LEFT_FOOT))
		return

	var/kick_dir = get_dir(H, src)
	if(H.loc == src.loc) kick_dir = H.dir

	var/turf/T = get_edge_target_turf(loc, kick_dir)

	var/kick_power = max((H.get_strength() * 10 - (w_class ** 2)), 1) //The range of the kick is (strength)*10. Strength ranges from 1 to 3, depending on the kicker's genes. Range is reduced by w_class^2, and can't be reduced below 1.

	H.visible_message("<span class='danger'>[H] kicks \the [src]!</span>", "<span class='danger'>You kick \the [src]!</span>")

	if(kick_power > 6) //Fly in an arc!
		spawn()
			var/original_pixel_y = pixel_y
			animate(src, pixel_y = original_pixel_y + 32, time = 10, easing = CUBIC_EASING)

			while(loc)
				if(!throwing)
					animate(src, pixel_y = original_pixel_y, time = 5, easing = ELASTIC_EASING)
					break
				sleep(5)

	Crossed(H) //So you can't kick shards while naked without suffering
	throw_at(T, kick_power, 1)
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
