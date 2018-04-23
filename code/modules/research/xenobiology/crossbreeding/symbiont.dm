/*
Symbiont extracts:
	Creates a specialized organ with a unique effect.
*/

/obj/item/slimecross/symbiont
	name = "symbiont extract"
	desc = "It beats with unnatural life. You can see something inside."
	effect = "symbiont"
	icon_state = "stabilized"
	var/slime_organ

/obj/item/slimecross/symbiont/attack_self(mob/user)
	var/obj/item/organ/new_organ = new slime_organ(get_turf(user))
	after_spawn(new_organ, user)

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
/*
/obj/item/slimecross/symbiont/darkblue
	colour = "dark blue"
	slime_organ =

/obj/item/slimecross/symbiont/silver
	colour = "silver"
	slime_organ =

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
	. = ..()
	breathweapon.Remove(owner)

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
	. = ..()
	action.Remove(owner)

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
				to_chat(owner, "<span class='notice'>You feel a tingling sensation as your hand begins to glow purple</span>")
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
	safe_toxins_max = 0
	safe_co2_max = 0
	SA_para_min = INFINITY
	SA_sleep_min = INFINITY
	BZ_trip_balls_min = INFINITY

//Industrial heart - Has a built-in autolathe that can't be upgraded or hacked.

/obj/item/organ/heart/industrial
	name = "industrial heart"
	desc = "It looks more like an engine than an organ. Sieze the means of production!"
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
	. = ..()
	action.Remove(owner)

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
	zone = BODY_ZONE_R_LEG
	slot = ORGAN_SLOT_RIGHT_LEG
	var/datum/action/cooldown/joltjump/action

/obj/item/organ/joltfoot/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg.</span>")

/obj/item/organ/joltfoot/Initialize()
	. = ..()
	action = new

/obj/item/organ/joltfoot/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/joltfoot/Remove()
	. = ..()
	action.Remove(owner)

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
				if(A.density)
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
	. = ..()
	snap_action.Remove(owner)
	hand_action.Remove(owner)
	burn_action.Remove(owner)
	owner.clear_alert("plasmaliver")
	linked_alert = null

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
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_HAND
	var/datum/action/cooldown/frozenhand/action

/obj/item/organ/frozenhand/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>It looks like a [zone == BODY_ZONE_R_ARM ? "right" : "left"] hand.</span>")

/obj/item/organ/frozenhand/Initialize()
	. = ..()
	action = new

/obj/item/organ/frozenhand/Insert()
	. = ..()
	action.Grant(owner)

/obj/item/organ/frozenhand/Remove()
	. = ..()
	action.Remove(owner)

/datum/action/cooldown/frozenhand