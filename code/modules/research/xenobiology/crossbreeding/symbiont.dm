/*
Symbiont extracts:
	Creates a specialized organ with a unique effect.
*/

/obj/item/slimecross/symbiont
	name = "symbiont extract"
	desc = "It beats with unnatural life. You can see something inside."
	effect = "symbiont"
	icon_state = "symbiont"
	var/slime_organ

/obj/item/slimecross/symbiont/attack_self(mob/user)
	var/obj/item/organ/new_organ = new slime_organ(get_turf(user))
	to_chat(user, "<span class='notice'>You mold [src] like clay, and shape it into [new_organ]!</span>")
	after_spawn(new_organ, user)
	qdel(src)

/obj/item/slimecross/symbiont/proc/after_spawn(obj/item/organ/new_organ, mob/user)
	return

/obj/item/slimecross/symbiont/grey
	colour = "grey"
	slime_organ = /obj/item/organ/stomach/slime

/obj/item/slimecross/symbiont/orange
	colour = "orange"
	slime_organ = /obj/item/organ/lungs/firebreath

/obj/item/slimecross/symbiont/purple
	colour = "purple"
	slime_organ = /obj/item/organ/healinghand

/obj/item/slimecross/symbiont/purple/after_spawn(obj/item/organ/new_organ, mob/user)
	new_organ.zone = (user.active_hand_index == 1 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	new_organ.slot = (user.active_hand_index == 1 ? ORGAN_SLOT_LEFT_HAND : ORGAN_SLOT_RIGHT_HAND)

/obj/item/slimecross/symbiont/blue
	colour = "blue"
	slime_organ = /obj/item/organ/lungs/omni

/obj/item/slimecross/symbiont/metal
	colour = "metal"
	slime_organ = /obj/item/organ/heart/industrial

/obj/item/slimecross/symbiont/yellow
	colour = "yellow"
	slime_organ = /obj/item/organ/joltfoot

/obj/item/slimecross/symbiont/yellow/after_spawn(obj/item/organ/new_organ, mob/user)
	new_organ.zone = (user.active_hand_index == 1 ? BODY_ZONE_L_LEG : BODY_ZONE_R_LEG)
	new_organ.slot = (user.active_hand_index == 1 ? ORGAN_SLOT_LEFT_LEG : ORGAN_SLOT_RIGHT_LEG)


/obj/item/slimecross/symbiont/darkpurple
	colour = "dark purple"
	slime_organ =/obj/item/organ/liver/plasmatic

/obj/item/slimecross/symbiont/darkblue
	colour = "dark blue"
	slime_organ =/obj/item/organ/frozenhand

/obj/item/slimecross/symbiont/silver
	colour = "silver"
	slime_organ = /obj/item/organ/stomach/autocannibal
/*
/obj/item/slimecross/symbiont/bluespace
	colour = "bluespace"
	slime_organ =

/obj/item/slimecross/symbiont/sepia
	colour = "sepia"
	slime_organ =

/obj/item/slimecross/symbiont/cerulean
	colour = "cerulean"
	slime_organ =

/obj/item/slimecross/symbiont/pyrite
	colour = "pyrite"
	slime_organ =

/obj/item/slimecross/symbiont/red
	colour = "red"
	slime_organ =

/obj/item/slimecross/symbiont/green
	colour = "green"
	slime_organ =

/obj/item/slimecross/symbiont/pink
	colour = "pink"
	slime_organ =

/obj/item/slimecross/symbiont/gold
	colour = "gold"
	slime_organ =

/obj/item/slimecross/symbiont/oil
	colour = "oil"
	slime_organ =

/obj/item/slimecross/symbiont/black
	colour = "black"
	slime_organ =

/obj/item/slimecross/symbiont/lightpink
	colour = "light pink"
	slime_organ =

/obj/item/slimecross/symbiont/adamantine
	colour = "adamantine"
	slime_organ =

/obj/item/slimecross/symbiont/rainbow
	colour = "rainbow"
	slime_organ =
*/
///////////////////////////
///		Slime Organs	///
///////////////////////////

//Slime stomach - Uses excess nutrition to regenerate.

/obj/item/organ/stomach/slime
	name = "slime stomach"
	desc = "A grey, gooey, stomach-like organ."
	icon_state = "slimestomach"

/obj/item/organ/stomach/slime/on_life()
	. = ..()
	if(owner.nutrition > NUTRITION_LEVEL_FULL)
		owner.nutrition -= 5
		owner.adjustBruteLoss(-0.3)
		owner.adjustFireLoss(-0.3)

//Burning lungs - Can breathe fire, both literally and as an attack.

/obj/item/organ/lungs/firebreath
	name = "burning lungs"
	desc = "They look like lungs, but they're hot to the touch, and smell violently of brimstone."
	icon_state = "burninglungs"
	safe_toxins_max = 0
	heat_level_1_threshold = INFINITY
	heat_level_2_threshold = INFINITY
	heat_level_3_threshold = INFINITY
	var/datum/action/cooldown/firebreath/breathweapon

/obj/item/organ/lungs/firebreath/Initialize()
	. = ..()
	breathweapon = new

/obj/item/organ/lungs/firebreath/Insert()
	. = ..()
	breathweapon.Grant(owner)

/obj/item/organ/lungs/firebreath/Remove()
	breathweapon.Remove(owner)
	. = ..()

/datum/action/cooldown/firebreath
	name = "Breathe Fire"
	desc = "Ignite your burning lungs and speak fire itself!"
	cooldown_time = 100
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "firebreath"

/datum/action/cooldown/firebreath/Trigger()
	. = ..()
	if(.)
		var/range = 4
		var/turf/E = get_edge_target_turf(owner, owner.dir)
		var/turf/previousturf = get_turf(owner)
		for(var/turf/J in getline(owner,E))
			if(!range || (J != previousturf && (!previousturf.atmos_adjacent_turfs || !previousturf.atmos_adjacent_turfs[J])))
				break
			range--
			if(!(owner in J.contents))
				new /obj/effect/hotspot(J)
				J.hotspot_expose(700,50,1)
			previousturf = J
		StartCooldown()

//Regenerative hand - Can heal others like a combination brute/burn kit, but not yourself.

/obj/item/organ/healinghand
	name = "regenerative hand"
	desc = "The palm glows with a hazy purple light."
	icon_state = "regenhand"
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_HAND
	var/datum/action/healinghand/action

/obj/item/organ/healinghand/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_ARM ? "right" : "left"] hand.</span>")

/obj/item/organ/healinghand/Initialize()
	. = ..()
	action = new
	action.linked_hand = src

/obj/item/organ/healinghand/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/healinghand/Remove()
	action.Remove(owner)
	. = ..()

/datum/action/healinghand
	name = "Healing Hand"
	desc = "Charge your glowing palm with healing energies, or let them fade."
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "healinghand"
	var/obj/item/organ/healinghand/linked_hand
	var/obj/item/healingtouch/hand_item

/datum/action/healinghand/Trigger()
	. = ..()
	if(.)
		if(hand_item)
			qdel(hand_item)
			hand_item = null
			to_chat(owner, "<span class='notice'>You dismiss the healing energies in your palm.</span>")
		else
			var/hand_busy = (linked_hand.zone == BODY_ZONE_R_ARM ? owner.get_item_for_held_index(2) : owner.get_item_for_held_index(1))
			if(hand_busy)
				to_chat(owner, "<span class='warning'>Your hand must be empty for the energies to manifest.</span>")
				return
			hand_item = new /obj/item/healingtouch(owner)
			var/success = (linked_hand.zone == BODY_ZONE_R_ARM ? owner.put_in_r_hand(hand_item) : owner.put_in_l_hand(hand_item))
			if(success)
				to_chat(owner, "<span class='notice'>You feel a tingling sensation as your hand begins to glow purple.</span>")
				return
			to_chat(owner, "<span class='warning'>Your hand flickers slightly, but falls dim.</span>")
			qdel(hand_item)
			hand_item = null

/obj/item/healingtouch
	name = "Healing Hand"
	desc = "The glow of your palm. It seems to glow brighter as you bring it near others."
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "healing_hand"
	item_state = "healing_hand"

/obj/item/healingtouch/attack(mob/living/M, mob/user)
	if(M == user)
		to_chat(user, "<span class='warning'>You can't seem to bring the light to yourself.</span>")
		return
	if(M.stat == DEAD)
		to_chat(user, "<span class='warning'>No matter how you try, the light of your palm can't seem to touch the dead.</span>")
		return
	var/obj/item/bodypart/affecting
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		affecting = C.get_bodypart(check_zone(user.zone_selected))
		if(!affecting) //Missing limb?
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
			return
		if(affecting.status == BODYPART_ORGANIC) //Limb must be organic to be healed
			if(affecting.heal_damage(5, 5))
				C.update_damage_overlays()
		else
			to_chat(user, "<span class='warning'>The light reflects off the inorganic material!</span>")
			return
	else
		M.adjustBruteLoss(-5)
		M.adjustFireLoss(-5)
	user.visible_message("<span class='notice'>[user] holds their hand to [M], their palm glowing with a healing aura.</span>")
	return

//Stable lungs - Can breathe any gas safely and without consequence, as long as temperature and pressure are okay.

/obj/item/organ/lungs/omni
	name = "stable lungs"
	desc = "A set of clear, blue lungs. They seem to glow slightly in any condition."
	icon_state = "stablelung"
	safe_toxins_max = 0
	safe_co2_max = 0
	SA_para_min = INFINITY
	SA_sleep_min = INFINITY
	BZ_trip_balls_min = INFINITY

//Industrial heart - Has a built-in autolathe that can't be upgraded or hacked.

/obj/item/organ/heart/industrial
	name = "industrial heart"
	desc = "It looks more like an engine than an organ. Sieze the means of production!"
	icon_base = "industrialheart"
	icon_state = "industrialheart-on"
	var/datum/action/internal_autolathe/action
	var/obj/machinery/autolathe/internal/internal_lathe

/obj/item/organ/heart/industrial/Initialize()
	. = ..()
	internal_lathe = new(src)
	action = new
	action.linked_lathe = internal_lathe
	internal_lathe.linked_organ = src

/obj/item/organ/heart/industrial/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/heart/industrial/Remove()
	action.Remove(owner)
	. = ..()

/datum/action/internal_autolathe
	name = "Internal Autolathe"
	desc = "Interact with the autolathe that makes up your heart."
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "int_autolathe"
	var/obj/machinery/autolathe/internal/linked_lathe

/datum/action/internal_autolathe/Trigger()
	. = ..()
	if(.)
		if(owner.get_active_held_item())
			owner.visible_message("<span class='notice'>[owner] opens a panel in [owner.p_their()] chest, and holds [owner.get_active_held_item()] against it.</span>")
			linked_lathe.attackby(owner.get_active_held_item(), owner)
		else
			linked_lathe.ui_interact(owner)

/obj/machinery/autolathe/internal
	name = "internal autolathe"
	desc = "This should be inside an organ, so you shouldn't ever see this,"
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	requires_prox = FALSE
	var/obj/item/organ/heart/industrial/linked_organ

/obj/machinery/autolathe/internal/can_interact()
	return TRUE

/obj/machinery/autolathe/internal/attackby(obj/item/O, mob/user, params)
	if (busy)
		to_chat(user, "<span class=\"alert\">Your internal autolathe is busy. Please wait for completion of previous operation.</span>")
		return TRUE

	if(istype(O, /obj/item/disk/design_disk))
		to_chat(user, "<span class='alert'>Your internal autolathe can't accept more designs!</span>")
		return
	..()

/obj/machinery/autolathe/internal/make_item(power, metal_cost, glass_cost, multiplier, coeff, is_stack)
	linked_organ.owner.visible_message("<span class='notice'>A grinding noise comes from [linked_organ.owner]'s chest as a panel opens and dispenses an item.</span>",
		"<span class='notice'>You feel a grinding sensation as your internal autolathe completes its order.</span>")
	return ..()

/obj/machinery/autolathe/internal/drop_location()
	return get_turf(linked_organ.owner)

//Joltfoot - Flash step forwards up to 3 spaces.

/obj/item/organ/joltfoot
	name = "jolt foot"
	desc = "It arcs with electricity."
	icon_state = "joltfoot"
	zone = BODY_ZONE_R_LEG
	slot = ORGAN_SLOT_RIGHT_LEG
	var/datum/action/cooldown/joltjump/action

/obj/item/organ/joltfoot/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_LEG ? "right" : "left"] foot.</span>")

/obj/item/organ/joltfoot/Initialize()
	. = ..()
	action = new

/obj/item/organ/joltfoot/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/joltfoot/Remove()
	action.Remove(owner)
	. = ..()

/datum/action/cooldown/joltjump
	name = "Jolt Jump"
	desc = "Become electricity and flashstep forwards!"
	cooldown_time = 150
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "joltjump"

/datum/action/cooldown/joltjump/Trigger()
	. = ..()
	if(.)
		var/range = 4
		var/turf/E = get_edge_target_turf(owner, owner.dir)
		var/turf/previousturf = get_turf(owner)
		for(var/turf/J in getline(owner,E))
			if(!range || J.density)
				break
			var/blocked = FALSE
			for(var/atom/A in J)
				if(!A.CanPass(owner,J) && !isliving(A))
					blocked = TRUE
					break
			if(blocked)
				break
			range--
			new /obj/effect/particle_effect/sparks(J)
			new /obj/effect/particle_effect/sparks(J)
			previousturf = J
		owner.visible_message("<span class='warning'>[owner] leaps fowards, and briefly becomes an electric blur!</span>")
		owner.forceMove(previousturf)
		StartCooldown()

//Plasmatic liver - Absorbs all plasma in the bloodstream, uses it to power three different abilities.

/obj/item/organ/liver/plasmatic
	name = "plasmatic liver"
	desc = "It's a sick, purple color, and seems to have liquid sloshing around inside..."
	icon_state = "plasma_liver"
	toxTolerance = 10 //Not quite upgraded cyberliver level, but this thing does process toxins regularly.
	var/stored_plasma = 0
	var/datum/action/cooldown/plasma_use/sparksnap/snap_action //Snap your fingers and produce a spark. 5 second cooldown.
	var/datum/action/cooldown/plasma_use/firehand/hand_action //Use your hand to ignite people or things. 10 second cooldown.
	var/datum/action/cooldown/plasma_use/wallburn/burn_action //Vomit lit thermite onto a wall to burn it down. 20 second cooldown.
	var/obj/screen/alert/plasma_liver/linked_alert

/obj/item/organ/liver/plasmatic/Initialize()
	. = ..()
	snap_action = new
	snap_action.linked_organ = src
	hand_action = new
	hand_action.linked_organ = src
	burn_action = new
	burn_action.linked_organ = src

/obj/item/organ/liver/plasmatic/Insert()
	. = ..()
	snap_action.Grant(owner)
	hand_action.Grant(owner)
	burn_action.Grant(owner)
	linked_alert = owner.throw_alert("plasmaliver",/obj/screen/alert/plasma_liver)

/obj/item/organ/liver/plasmatic/Remove()
	snap_action.Remove(owner)
	hand_action.Remove(owner)
	burn_action.Remove(owner)
	owner.clear_alert("plasmaliver")
	linked_alert = null
	. = ..()

/obj/item/organ/liver/plasmatic/on_life()
	var/mob/living/carbon/C = owner
	if(istype(C))
		var/plasma_amount = (C.reagents.has_reagent("plasma") ? C.reagents.has_reagent("plasma").volume : 0)
		var/stable_plasma_amount = (C.reagents.has_reagent("stable_plasma") ? C.reagents.has_reagent("stable_plasma").volume : 0)
		if(plasma_amount)
			C.reagents.remove_reagent("plasma", plasma_amount)
			stored_plasma += plasma_amount
		if(stable_plasma_amount)
			C.reagents.remove_reagent("stable_plasma", stable_plasma_amount)
			stored_plasma += stable_plasma_amount * 0.25 //Significantly decreased value for lesser plasma.
	if(linked_alert)
		linked_alert.desc = "You have [round(stored_plasma)] unit[round(stored_plasma) == 1 ? "" : "s"] of plasma stored."
	..()

/obj/screen/alert/plasma_liver
	name = "Storing Plasma"
	desc = "This will be updated later."
	icon_state = "plasmaliver"

/datum/action/cooldown/plasma_use
	name = "plasma use subtype"
	desc = "You shouldn't see this."
	var/plasma_cost = 0
	var/obj/item/organ/liver/plasmatic/linked_organ
	var/precheck = TRUE

/datum/action/cooldown/plasma_use/Trigger()
	. = ..()
	if(.)
		if(!precheck)
			return
		if(linked_organ.stored_plasma >= plasma_cost)
			return TRUE
		else
			to_chat(owner, "<span class='warning'>You do not have enough plasma stored to do this.</span>")
	return FALSE

/datum/action/cooldown/plasma_use/proc/UsePlasma()
	linked_organ.stored_plasma -= plasma_cost

/datum/action/cooldown/plasma_use/sparksnap
	name = "Spark Snap"
	desc = "Secrete plasma in the pads of your fingers, and snap to let off a spark! (5)"
	cooldown_time = 50
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS //Don't need to move your wrists to snap.
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "sparksnap"
	plasma_cost = 5

/datum/action/cooldown/plasma_use/sparksnap/Trigger()
	. = ..()
	if(.)
		owner.visible_message("<span class='warning'>[owner] snaps [owner.p_their()] fingers, and sparks flash.</span>")
		playsound(owner, 'sound/effects/snap.ogg', 50, 1)
		do_sparks(3, FALSE, owner)
		UsePlasma()
		StartCooldown()

/datum/action/cooldown/plasma_use/firehand
	name = "Burning Palm"
	desc = "Secrete even more plasma in the palm of your hand, and ignite it! (15)"
	cooldown_time = 100
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "firehand"
	var/obj/item/firehand/linked_item
	precheck = FALSE
	plasma_cost = 15

/datum/action/cooldown/plasma_use/firehand/Trigger()
	. =..()
	if(.)
		if(linked_item)
			qdel(linked_item)
			linked_item = null
			linked_organ.stored_plasma += plasma_cost //Refund the plasma used to activate the ability.
			to_chat(owner, "<span class='notice'>You dismiss the burning energies in your hand.</span>")
			return
		else
			if(linked_organ.stored_plasma < plasma_cost)
				to_chat(owner, "<span class='warning'>You do not have enough plasma stored to do this.</span>")
				return
			UsePlasma()
			if(owner.get_active_held_item())
				to_chat(owner, "<span class='warning'>Your hand must be empty to ignite it.</span>")
				return
			linked_item = new(owner)
			linked_item.linked_action = src
			if(!owner.put_in_active_hand(linked_item))
				qdel(linked_item)
				linked_item = null
				to_chat(owner, "<span class='warning'>Your hand briefly sweats plasma, but it sublimates away.</span>")
				return

/obj/item/firehand
	name = "Flaming Hand"
	desc = "Oddly enough, you seem to be the only thing it <i>doesn't</i> burn."
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "flaming_hand"
	item_state = "disintegrate"
	var/datum/action/cooldown/plasma_use/firehand/linked_action

/obj/item/firehand/afterattack(atom/O, mob/user, proximity)
	if(!proximity)
		return
	O.visible_message("<span class='danger'>[user] presses their burning palm against [O]!</span>",
		"<span class='userdanger'>[user] presses their flaming palm against you!</span>")
	O.fire_act(1000, 500) //Like a bonfire. Ouch.
	playsound(src, 'sound/magic/fireball.ogg', 50, 1)
	linked_action.linked_item = null
	linked_action.StartCooldown()
	qdel(src)

/datum/action/cooldown/plasma_use/wallburn
	name = "Vomit Flames"
	desc = "Condense plasma into a highly volatile liquid, and vomit it on the wall in front of you! (40)"
	cooldown_time = 200
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "wallburn"
	plasma_cost = 40

/datum/action/cooldown/plasma_use/wallburn/Trigger()
	. = ..()
	if(.)
		var/turf/closed/wall/T = get_step(get_turf(owner),owner.dir)
		if(!istype(T))
			to_chat(owner, "<span class='warning'>You can only do this while facing a wall!</span>")
			return
		playsound(owner, 'sound/effects/splat.ogg', 50, 1)
		playsound(owner, 'sound/magic/fireball.ogg', 50, 1)
		UsePlasma()
		StartCooldown()
		owner.visible_message("<span class='danger'>[owner] vomits pure, condensed flame onto [T]!")
		var/datum/component/thermite/therm = T.AddComponent(/datum/component/thermite, 20)
		therm.thermite_melt()

//Frozen hand - Can freeze items on a 5 second cooldown, or people on a 20 second cooldown.

/obj/item/organ/frozenhand
	name = "frozen hand"
	desc = "Moisture in the air crystallizes around it."
	icon_state = "frozenhand"
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_HAND
	var/datum/action/cooldown/frozenhand/action

/obj/item/organ/frozenhand/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_ARM ? "right" : "left"] hand.</span>")

/obj/item/organ/frozenhand/Initialize()
	. = ..()
	action = new
	action.linked_hand = src

/obj/item/organ/frozenhand/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/frozenhand/Remove()
	action.Remove(owner)
	. = ..()

/datum/action/cooldown/frozenhand
	name = "Freezing Grasp"
	desc = "Freeze an item in your hand in a block of ice, or expend much more power to freeze someone entirely!"
	cooldown_time = 200
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "frozenhand"
	var/obj/item/frozenhand/linked_item
	var/obj/item/organ/frozenhand/linked_hand


/datum/action/cooldown/frozenhand/Trigger()
	. = ..()
	if(.)
		if(linked_item)
			qdel(linked_item)
			linked_item = null
			to_chat(owner, "<span class='notice'>Your hand heats back up.</span>")
		else
			var/hand_busy = (linked_hand.zone == BODY_ZONE_R_ARM ? owner.get_item_for_held_index(2) : owner.get_item_for_held_index(1))
			if(hand_busy)
				owner.dropItemToGround(hand_busy)
				freeze_item(hand_busy, owner)
				StartCooldown()
				next_use_time -= cooldown_time * 0.75 //With a cooldown of 20, sets the cooldown to 5 seconds.
				return
			linked_item = new /obj/item/frozenhand(owner)
			linked_item.linked_action = src
			var/success = (linked_hand.zone == BODY_ZONE_R_ARM ? owner.put_in_r_hand(linked_item) : owner.put_in_l_hand(linked_item))
			if(success)
				to_chat(owner, "<span class='notice'>You feel a prickly freezing sensation as your hand ices over.</span>")
				return
			to_chat(owner, "<span class='warning'>Your hand feels cool for a moment, but warms back up.</span>")
			qdel(linked_item)
			linked_item = null

/datum/action/cooldown/frozenhand/proc/freeze_item(obj/item/I, mob/user)
	to_chat(user, "<span class='notice'>You freeze [I] solid.</span>")
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, 1)
	var/obj/item/frozenitem/ice = new /obj/item/frozenitem(get_turf(user))
	ice.store(I)

/obj/item/frozenitem
	name = "ice cube"
	desc = "It's completely frozen solid! Might take something warm to melt it."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "ice"

/obj/item/frozenitem/proc/store(obj/item/I)
	name = "frozen [I.name]"
	switch(I.w_class)
		if(WEIGHT_CLASS_TINY)
			icon_state += "_tiny"
		if(WEIGHT_CLASS_SMALL)
			icon_state += "_small"
		if(WEIGHT_CLASS_NORMAL)
			icon_state += "_normal"
	I.forceMove(src)

/obj/item/frozenitem/attackby(obj/item/O, mob/user, params)
	. = ..()
	if(O.is_hot())
		to_chat(user, "<span class='notice'>[src] melts.</span>")
		qdel(src)

/obj/item/frozenitem/fire_act(exposed_temperature, exposed_volume)
	visible_message("<span class='notice'>[src] melts.</span>")
	qdel(src)

/obj/item/frozenitem/Destroy()
	for(var/atom/movable/M in contents)
		M.forceMove(get_turf(src))
	..()

/obj/item/frozenhand
	name = "Frozen Hand"
	desc = "Surprisingly, it's more of a pleasant chill than anything else."
	flags_1 = ABSTRACT_1 | NODROP_1 | DROPDEL_1
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "frozen_hand"
	item_state = "frozenhand"
	var/datum/action/cooldown/frozenhand/linked_action

/obj/item/frozenhand/afterattack(atom/O, mob/user, proximity)
	if(!proximity)
		return
	O.visible_message("<span class='danger'>[user] presses their frozen hand against [O]!</span>",
		"<span class='userdanger'>[user] presses their frozen hand against you!</span>")
	playsound(src, 'sound/magic/ethereal_exit.ogg', 50, 1)
	linked_action.linked_item = null
	linked_action.StartCooldown()
	if(istype(O, /obj/item))
		var/obj/item/I = O
		linked_action.freeze_item(I, user)
		linked_action.next_use_time -= linked_action.cooldown_time * 0.75 //Just freezing an item, same as normal.
	if(isliving(O))
		var/mob/living/L = O
		L.apply_status_effect(/datum/status_effect/freon)
	qdel(src)

//Autocannibalistic Stomach - If below NUTRITION_LEVEL_FED, starts draining blood and adding hunger. Stops when at or above NUTRITION_LEVEL_WELL_FED.

/obj/item/organ/stomach/autocannibal
	name = "autocannibalistic stomach"
	desc = "It's disturbingly pale, and seems to be oddly active, even outside a body."
	icon_state = "autocstomach"
	var/draining = FALSE

/obj/item/organ/stomach/autocannibal/on_life()
	. = ..()
	if(owner.nutrition < NUTRITION_LEVEL_FED && !draining && owner.blood_volume > (BLOOD_VOLUME_BAD + 10))
		draining = TRUE
		owner.throw_alert("autocannibal",/obj/screen/alert/stomach_autocannibal)
	if((owner.nutrition >= NUTRITION_LEVEL_WELL_FED || owner.blood_volume <= BLOOD_VOLUME_BAD) && draining)
		draining = FALSE
		owner.clear_alert("autocannibal")
	if(draining)
		owner.blood_volume -= 3 //For the most part, this is roughly 6 times the blood regeneration rate for this level, but it won't be active always.
		owner.nutrition += 6 //Two times the blood used.

/obj/item/organ/stomach/autocannibal/Remove()
	if(draining)
		owner.clear_alert("autocannibal")
	. = ..()

/obj/screen/alert/stomach_autocannibal
	name = "Autocannibalism"
	desc = "Your stomach is drinking your blood to maintain nutrition."
	icon_state = "autocstomach"

//Warping Palm - You can pickup and place items anywhere on your screen.

/obj/item/organ/warpingpalm
	name = "warping palm"
	desc = "There's a strange, blue-ish energy field in the center of the palm."
	icon_state = "warpingpalm"
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_HAND
	var/datum/action/cooldown/frozenhand/action

/obj/item/organ/warpingpalm/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_ARM ? "right" : "left"] hand.</span>")

/obj/item/organ/warpingpalm/Insert()
	. = ..()
	var/datum/component/bluespace_hand/component = owner.GetComponent(/datum/component/bluespace_hand)
	if(!component)
		component = owner.AddComponent(/datum/component/bluespace_hand)
	component.hand_indices |= (zone == BODY_ZONE_R_ARM ? 2 : 1)


/obj/item/organ/warpingpalm/Remove()
	var/datum/component/bluespace_hand/component = owner.GetComponent(/datum/component/bluespace_hand)
	component.hand_indices -= (zone == BODY_ZONE_R_ARM ? 2 : 1)
	if(!component.hand_indices.len)
		qdel(component)
	. = ..()

/obj/item/organ/chronalfoot
	name = "chronal foot"
	desc = "Time is on your side - or, in this case, on your leg."
	icon_state = "chronalfoot"
	zone = BODY_ZONE_R_LEG
	slot = ORGAN_SLOT_RIGHT_LEG
	var/datum/component/redirect/component
	var/obj/effect/chrono_echo/echo
	var/datum/action/cooldown/timestep/cstep
	var/datum/action/cooldown/timekick/kick

/obj/item/organ/chronalfoot/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_LEG ? "right" : "left"] foot.</span>")

/obj/item/organ/chronalfoot/Initialize()
	. = ..()
	cstep = new
	kick = new
	cstep.linked_organ = src
	kick.linked_organ = src

/obj/item/organ/chronalfoot/Insert()
	. = ..()
	cstep.Grant(owner)
	kick.Grant(owner)
	echo = new /obj/effect/chrono_echo(get_turf(owner), owner)
	component = owner.AddComponent(/datum/component/redirect, list(COMSIG_MOVABLE_MOVED), CALLBACK(echo, /obj/effect/chrono_echo.proc/QueueMove))

/obj/item/organ/chronalfoot/Remove()
	cstep.Remove(owner)
	kick.Remove(owner)
	qdel(component)
	component = null
	qdel(echo)
	echo = null
	. = ..()

/obj/effect/chrono_echo
	name = "chronal echo"
	desc = "An imprint in time itself."
	var/image/overlay

/obj/effect/chrono_echo/Initialize(mapload, mob/living/L)
	. = ..()
	var/image/I = image(icon = 'icons/effects/effects.dmi', icon_state = "blank", layer = ABOVE_MOB_LAYER, loc = src)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/onePerson, "echo", I, L)
	I.alpha = 150
	I.appearance_flags = RESET_ALPHA
	overlay = I

/obj/effect/chrono_echo/proc/QueueMove(atom/A, _dir)
	addtimer(CALLBACK(src, /obj/effect/chrono_echo.proc/MoveTo, get_turf(A), _dir), 50)

/obj/effect/chrono_echo/proc/MoveTo(turf/T, _dir)
	forceMove(T)
	dir = _dir

/obj/item/organ/chronalfoot/proc/EchoCooldown()
	echo.overlay.alpha = 0
	addtimer(CALLBACK(src, .proc/EchoResetAlpha), 50)

/obj/item/organ/chronalfoot/proc/EchoResetAlpha()
	echo.overlay.alpha = 150

/datum/action/cooldown/timestep
	name = "Time Step"
	desc = "Step backwards through time, to where you once were."
	cooldown_time = 55
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "timestep"
	var/obj/item/organ/chronalfoot/linked_organ

/datum/action/cooldown/timestep/Trigger()
	. = ..()
	if(!.)
		return
	owner.visible_message("<span class='warning'>[owner] steps into time itself!</span>", "<span class='notice'>You step backwards in time.</span>")
	playsound(owner, 'sound/magic/timeparadox2.ogg', 50, TRUE, frequency = -1)
	owner.forceMove(linked_organ.echo.loc)
	StartCooldown()
	linked_organ.kick.StartCooldown()
	linked_organ.EchoCooldown()

/datum/action/cooldown/timekick
	name = "Time Kick"
	desc = "Kick someone so hard, they feel it five seconds ago."
	cooldown_time = 55
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "timekick"
	background_icon_state = "bg_default"
	var/obj/item/organ/chronalfoot/linked_organ

/datum/action/cooldown/timekick/Trigger()
	. = ..()
	if(!.)
		return
	var/mob/living/M = owner
	if(!owner || !owner.client)
		return
	if(M.click_intercept)
		if(M.click_intercept != src)
			return
		M.click_intercept = null
		background_icon_state = "bg_default"
		UpdateButtonIcon()
		to_chat(owner, "<span class='notice'>You decide not to kick anyone.</span>")
	else
		M.click_intercept = src
		M.click_intercept = src
		background_icon_state = "bg_default_on"
		UpdateButtonIcon()
		to_chat(owner, "<span class='notice'>You prepare to kick someone through time.</span>")

/datum/action/cooldown/timekick/proc/InterceptClickOn(mob/living/caller, params, atom/A)
	if(caller.click_intercept && caller.click_intercept != src)
		to_chat(caller, "<span class='warning'>Your click interceptor has been disabled. Call a coder!</span>")
		caller.click_intercept = null
		return TRUE
	caller.face_atom(A)
	if(get_dist(caller, A) > 1)
		return TRUE
	if(!isliving(A))
		return TRUE
	var/mob/living/L = A
	caller.next_click = world.time + CLICK_CD_CLICK_ABILITY
	L.adjustBruteLoss(15)
	L.visible_message("<span class='danger'>[caller] kicks [L] with their chronal foot, sending [L] back in time!</span>",
		"<span class='userdanger'>[caller] kicks you, and suddenly time flows backwards for a few moments!</span>")
	playsound(L, 'sound/effects/hit_kick.ogg', 50)
	playsound(L, 'sound/magic/timeparadox2.ogg', 50, TRUE, frequency = -1)
	L.forceMove(linked_organ.echo.loc)
	caller.click_intercept = null
	background_icon_state = "bg_default"
	StartCooldown()
	linked_organ.cstep.StartCooldown()
	linked_organ.EchoCooldown()
	return FALSE

//Replicant Eyes - Can produce a small eye thing that you can see out of, like a camera bug.

/obj/item/organ/eyes/replicant
	name = "replicant eyes"
	desc = "They look <i>exactly</i> the same..."
	icon_state = "replicant_eye"
	var/list/eyes = list()
	var/list/ids = list()
	var/datum/action/cooldown/produce_eye/produce
	var/datum/action/look_eye/look

/obj/item/organ/eyes/replicant/Initialize()
	. = ..()
	produce = new
	produce.linked_organ = src
	look = new
	look.linked_organ = src

/obj/item/organ/eyes/replicant/Insert()
	. = ..()
	produce.Grant(owner)
	look.Grant(owner)

/obj/item/organ/eyes/replicant/Remove()
	owner.reset_perspective(null)
	produce.Remove(owner)
	look.Remove(owner)
	. = ..()

/datum/action/cooldown/produce_eye
	name = "Replicate Eye"
	desc = "Replicate one of your eyes, to see through later."
	cooldown_time = 600
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "produce_eye"
	var/obj/item/organ/eyes/replicant/linked_organ

/datum/action/cooldown/produce_eye/Trigger()
	. = ..()
	if(.)
		to_chat(owner, "<span class='notice'>You start to replicate your eye.</span>")
		if(do_after(owner, 50, target = get_turf(owner)))
			owner.visible_message("<span class='notice'[owner] leans forwards, and an eye drops from [p_their(owner)] socket, swelling to a massive size!</span>")
			var/obj/structure/replicant_eye/eye = new (get_turf(owner), linked_organ)
			eye.name = "[owner]'s [eye.name]"
			var/new_id = "no id"
			new_id = sanitize(input(owner, "What is this eye's ID?", "Replicant Eye") as null|text)
			while(new_id == "Reset View")
				new_id = sanitize(input(owner, "Please choose a different ID.", "Replicant Eye",) as null|text)
			var/id_choice = new_id
			var/index = 0
			while(id_choice in linked_organ.ids)
				index++
				id_choice = new_id + " \[[index]\]"
			eye.idtag = id_choice
			linked_organ.eyes += eye
			linked_organ.ids += eye.idtag
			StartCooldown()

/datum/action/look_eye
	name = "Cerulean Eyes"
	desc = "Peer through one of your replicated eyes."
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "look_eye"
	var/obj/item/organ/eyes/replicant/linked_organ
	var/obj/structure/replicant_eye/current_eye

/datum/action/look_eye/Trigger()
	. = ..()
	if(.)
		var/list/id_list = list("Reset View")
		id_list += linked_organ.ids
		var/mob/living/preowner = owner
		var/choice = input(owner, "Select an eye ID", "Replicant Eyes") as null|anything in id_list
		if(preowner != owner)
			return
		if(!choice)
			return
		if(choice == "Reset View")
			to_chat(owner, "<span class='notice'>You stop looking through your replicant eyes.</span>")
			owner.reset_perspective(null)
			if(current_eye)
				current_eye.Deactivate()
		else
			var/index = linked_organ.ids.Find(choice)
			if(!index)
				return
			to_chat(owner, "<span class='notice'>You start to look through the eye labeled [choice].</span>")
			current_eye = linked_organ.eyes[index]
			owner.reset_perspective(current_eye)
			current_eye.Activate(src)

/obj/structure/replicant_eye
	name = "replicant eye"
	desc = "A strange, disembodied cerulean eye."
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "replicant_eye_closed"
	density = FALSE
	anchored = TRUE
	max_integrity = 12
	var/active = FALSE
	var/idtag = "eye"
	var/datum/action/look_eye/linked_action
	var/obj/item/organ/eyes/replicant/linked_organ

/obj/structure/replicant_eye/Initialize(mapload, obj/item/organ/eyes/replicant/organ)
	linked_organ = organ

/obj/structure/replicant_eye/examine(mob/user)
	..()
	to_chat(user, "<span class = 'notice'>It is currently [active ? "open" : "closed"].</span>")

/obj/structure/replicant_eye/proc/Activate(datum/action/look_eye/action)
	active = TRUE
	icon_state = "replicant_eye_open"
	linked_action = action

/obj/structure/replicant_eye/proc/Deactivate()
	active = FALSE
	icon_state = "replicant_eye_closed"
	linked_action = null

/obj/structure/replicant_eye/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.visible_message("<span class='warning'>[user] pokes [src] in the [pick("pupil", "sclera")].</span>",
		"<span class='warning'>You poke [src]. It tears up slightly.</span>")
	obj_integrity -= 4

/obj/structure/replicant_eye/Destroy()
	visible_message("<span class='danger'>[src] falls apart into a puddle of good.</span>")
	if(active)
		to_chat(linked_action.owner,"<span class='warning'>Your replicant eye was destroyed!</span>")
		linked_action.owner.reset_perspective(null)
	linked_organ.eyes -= src
	linked_organ.ids -= idtag
	. =  ..()

//Prism Appendix - Allows you to paint an object you're holding any color you please.

/obj/item/organ/appendix/prism
	name = "prism appendix"
	desc = "Now you can be colorful <i>and</i> useless!"
	icon_state = "prism_appendix"
	var/datum/action/coloritem/action

/obj/item/organ/appendix/prism/Initialize()
	action = new

/obj/item/organ/appendix/prism/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/appendix/prism/Remove()
	action.Remove(owner)
	. = ..()

/datum/action/coloritem
	name = "Color Held Item"
	desc = "Secrete paint from your prism appendix! Eugh!"
	icon_icon = 'icons/obj/slimecrossing.dmi'
	button_icon_state = "coloritem"
	check_flags = AB_CHECK_STUN | AB_CHECK_CONSCIOUS | AB_CHECK_RESTRAINED

/datum/action/coloritem/Trigger()
	var/obj/item/I = owner.get_active_held_item()
	if(!I)
		return
	var/newcolor = input(owner, "Choose the new color:", "Color change") as color|null
	if(!newcolor)
		return
	I.add_atom_colour(newcolor, WASHABLE_COLOUR_PRIORITY)
	return