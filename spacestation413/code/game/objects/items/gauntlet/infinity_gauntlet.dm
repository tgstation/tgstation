/* ************************
	Sorry for the weird ASCII art headers, my mind was breaking trying to navigate the file.
   ************************/ 

/* ************************
	DEFINES
   ************************/ 
#define INFINITY_GEM "infinity_gem"

#define isinfinitygauntlet(A) (istype(A,/obj/item/storage/infinity_gauntlet))

#define isspacegem(A)         (istype(A,/obj/item/infinity_gem/space_gem))

#define istimegem(A)          (istype(A,/obj/item/infinity_gem/time_gem))

#define ismindgem(A)          (istype(A,/obj/item/infinity_gem/mind_gem))

#define issoulgem(A)          (istype(A,/obj/item/infinity_gem/soul_gem))

#define ispowergem(A)         (istype(A,/obj/item/infinity_gem/power_gem))

#define isrealitygem(A)       (istype(A,/obj/item/infinity_gem/reality_gem))

#define NO_GEMS 0
#define SPACE_GEM (1<<0)
#define TIME_GEM (1<<1)
#define MIND_GEM (1<<2)
#define SOUL_GEM (1<<3)
#define POWER_GEM (1<<4)
#define REALITY_GEM (1<<5)
#define ALL_GEMS (SPACE_GEM | TIME_GEM | MIND_GEM | SOUL_GEM | POWER_GEM | REALITY_GEM)

/* ************************
	GAUNTLET
   ************************/ 

/obj/item/storage/infinity_gauntlet
	name = "Infinity Gauntlet"
	desc = "A gauntlet which can hold the infinity gems."
	siemens_coefficient = 0
	strip_delay = 100
	permeability_coefficient = 0
	body_parts_covered = HAND_LEFT
	slot_flags = ITEM_SLOT_GLOVES
	alternate_worn_icon = 'spacestation413/icons/mob/hands.dmi'
	icon = 'spacestation413/icons/obj/wizard.dmi'
	icon_state = "infinity_gauntlet"
	var/transfer_blood = 0
	var/transfer_prints = FALSE
	var/already_snapped = FALSE
	var/gems_found = NO_GEMS
	component_type = /datum/component/storage/concrete/infinity_gauntlet

/obj/effect/proc_holder/spell/self/snap
	name = "Snap"
	desc = "Reality can be anything you want."
	clothes_req = FALSE
	charge_max = 1000000 //removes itself after
	action_icon = 'spacestation413/icons/mob/actions.dmi'
	action_icon_state = "infinity_snap"

/obj/effect/proc_holder/spell/self/snap/perform(list/targets, recharge = FALSE, mob/user = usr)
	var/list/shuffled_living = shuffle(GLOB.alive_mob_list)
	shuffled_living-=user
	shuffled_living.len = shuffled_living.len/2
	user.emote("snap")
	for(var/mob/living/M in shuffled_living)
		INVOKE_ASYNC(src, .proc/do_snap, M)
	if(user.mind)
		user.mind.RemoveSpell(src)
	else
		user.RemoveSpell(src)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isinfinitygauntlet(H.gloves))
			var/obj/item/storage/infinity_gauntlet/gauntlet = H.gloves
			gauntlet.already_snapped = TRUE

/obj/effect/proc_holder/spell/self/snap/proc/do_snap(mob/living/target)
	to_chat(target,"<span class='userdanger'>You don't feel so good...</span>")
	sleep(rand(0,50))
	target.visible_message("[target.name] begins turning to dust!")
	sleep(rand(10,50))
	target.dust()

/obj/item/storage/infinity_gauntlet/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/infinity_gauntlet/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	var/static/list/can_hold = typecacheof(list(
		/obj/item/infinity_gem
		))
	STR.set_holdable(can_hold)

/obj/item/storage/infinity_gauntlet/full/PopulateContents()
	new /obj/item/infinity_gem/power_gem(src)
	new /obj/item/infinity_gem/time_gem(src)
	new /obj/item/infinity_gem/space_gem(src)
	new /obj/item/infinity_gem/reality_gem(src)
	new /obj/item/infinity_gem/mind_gem(src)
	new /obj/item/infinity_gem/soul_gem(src)

/obj/item/storage/infinity_gauntlet/space_only/PopulateContents()
	new /obj/item/infinity_gem/space_gem(src)

/obj/item/storage/infinity_gauntlet/update_icon() //copy/pasted from belts mostly
	cut_overlays()
	for(var/obj/item/infinity_gem/gem in contents)
		var/mutable_appearance/M = gem.get_gauntlet_overlay()
		add_overlay(M)
	..()

/obj/item/storage/infinity_gauntlet/proc/clean_blood(datum/source, strength)
	if(strength < CLEAN_STRENGTH_BLOOD)
		return
	transfer_blood = 0

/obj/item/storage/infinity_gauntlet/proc/update_clothes_damaged_state(damaging = TRUE)
	..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_gloves()

/obj/item/storage/infinity_gauntlet/equipped(mob/user,slot)
	. = ..()
	if(slot == SLOT_GLOVES)
		add_gems_to_owner(user)
	else
		remove_gems_from_owner(user)

/obj/item/storage/infinity_gauntlet/dropped(mob/user)
	. = ..()
	remove_gems_from_owner(user)

/obj/item/storage/infinity_gauntlet/proc/remove_gems_from_owner(mob/user)
	for(var/obj/item/infinity_gem/gem in contents)
		gem.gem_remove(user)
	update_gem_flags(user)

/obj/item/storage/infinity_gauntlet/proc/add_gems_to_owner(mob/user)
	if(!sanity_check(user))
		return
	update_gem_flags(user)
	for(var/obj/item/infinity_gem/gem in contents)
		gem.gem_add(user)
		var/datum/component/stationloving/gem_stationlove = gem.GetComponent(/datum/component/stationloving)
		if(istype(gem_stationlove))
			gem_stationlove.RemoveComponent()

/obj/item/storage/infinity_gauntlet/proc/update_gem_flags(mob/user)
	gems_found = NO_GEMS
	for(var/obj/item/infinity_gem/gem in contents)
		gems_found |= gem.gem_flag
	for(var/obj/item/infinity_gem/gem in contents)
		gem.other_gems = gems_found
	var/obj/effect/proc_holder/spell/self/snap/snap_spell = new
	if(user.mind)
		user.mind.RemoveSpell(snap_spell)
	else
		user.RemoveSpell(snap_spell)
	if(gems_found == ALL_GEMS && sanity_check(user) && !already_snapped)
		if(user.mind)
			user.mind.AddSpell(snap_spell)
		else
			user.AddSpell(snap_spell)

/obj/item/storage/infinity_gauntlet/proc/sanity_check(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.gloves==src)
			return TRUE
	return FALSE

/obj/item/storage/infinity_gauntlet/suicide_act(mob/living/user)
	if(gems_found == ALL_GEMS)
		user.visible_message("<span class='suicide'>[user] is getting ready to snap, but pointing the finger at [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		user.dust()
		return MANUAL_SUICIDE
	else
		var/obj/item/infinity_gem/gem = pick(contents) //can't contain anything else anyway.
		return gem.suicide_act(user)

/* ************************
	BASE GEM CLASS
   ************************/ 

/obj/item/infinity_gem
	name = "Infinity Gem"
	desc = "You shouldn't see this!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	w_class=WEIGHT_CLASS_TINY
	icon = 'spacestation413/icons/obj/wizard.dmi'
	icon_state = "infinity_gem"
	var/gauntlet_gem = "error"
	var/gem_flag = NO_GEMS
	var/other_gems
	var/spells
	var/traits

/obj/item/infinity_gem/Initialize()
	. = ..()
	GLOB.poi_list |= src

/obj/item/infinity_gem/Destroy()
	. = ..()
	GLOB.poi_list -= src

/obj/item/infinity_gem/proc/get_gauntlet_overlay()
	return mutable_appearance('spacestation413/icons/obj/wizard.dmi', gauntlet_gem)

/obj/item/infinity_gem/equipped(mob/user,slot)
	. = ..()
	if(slot == SLOT_HANDS)
		gem_add(user)
	else
		gem_remove(user)

/obj/item/infinity_gem/proc/update_gems_in_hands(mob/user)
	var/gems_found = NO_GEMS
	for(var/obj/item/infinity_gem/gem in user.held_items)
		gems_found |= gem.gem_flag
	for(var/obj/item/infinity_gem/gem in user.held_items)
		gem.other_gems = gems_found

/obj/item/infinity_gem/proc/gem_add(mob/user)
	update_gems_in_hands(user)
	gem_remove(user)
	other_gem_actions(user)
	for(var/T in traits)
		ADD_TRAIT(user,T,INFINITY_GEM)
	if(user.mind)
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = new S(null)
			spell.charge_counter = 0
			user.mind.AddSpell(spell)
	else
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = new S(null)
			spell.charge_counter = 0
			user.AddSpell(spell)
			

/obj/item/infinity_gem/proc/gem_remove(mob/user)
	for(var/T in traits)
		REMOVE_TRAIT(user,T,INFINITY_GEM)
	if(user.mind)
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = S
			user.mind.RemoveSpell(spell)
	else
		for(var/S in spells)
			var/obj/effect/proc_holder/spell/spell = S
			user.RemoveSpell(spell)
	update_gems_in_hands(user)

/obj/item/infinity_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src], then gets confused upon realizing [user.p_they()] suddenly forgot what its power is! The coder didn't properly implement a suicide message for this one!</span>")
	return SHAME

/obj/item/infinity_gem/dropped(mob/user)
	. = ..()
	gem_remove(user)

/obj/item/infinity_gem/proc/other_gem_actions(mob/user)
	return

/obj/item/infinity_gem/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/stationloving, TRUE) //obviously could make admins not informed but i don't see the point


/* ************************
	SPACE GEM
   ************************/ 

/obj/item/infinity_gem/space_gem
	name = "Space Gem"
	desc = "A gem that allows the holder to be anywhere."
	gem_flag = SPACE_GEM
	color = "#009bff"
	gauntlet_gem = "space"
	spells = list(
		/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self,
		/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other
	)

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem
	name = "Space Gem Teleport"
	desc = "Use the gem to teleport you to an area of your selection."
	action_icon
	charge_max = 200
	sound1 = 'sound/magic/teleport_diss.ogg'
	sound2 = 'sound/magic/teleport_app.ogg'
	clothes_req = FALSE

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self
	name = "Space Gem Teleport (self)"
	range = -1
	include_user = TRUE

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other
	name = "Space Gem Teleport (other)"
	desc = "Use the space gem to teleport someone else to an area of your selection."
	range = 10
	include_user = FALSE

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self/empowered
	charge_max = 100

/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other/empowered
	charge_max = 100

/obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem
	name = "Space Gem Blink"
	desc = "Teleport to a nearby random location."
	range = -1
	selection_type = "range"
	include_user = TRUE
	clothes_req = FALSE
	charge_max = 10
	action_icon_state = "blink"

/obj/item/infinity_gem/space_gem/other_gem_actions(mob/user)
	if(other_gems & TIME_GEM)
		spells = list(
			/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self/empowered,
			/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other/empowered
		)
	else
		spells = list(
			/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/self,
			/obj/effect/proc_holder/spell/targeted/area_teleport/space_gem/other
		)
	if(other_gems & POWER_GEM)
		spells += /obj/effect/proc_holder/spell/targeted/turf_teleport/space_gem

/obj/item/infinity_gem/space_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src] and presses it up against [user.p_their()] head! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/bodypart/head/head = H.get_bodypart("head")
		head.dismember(BRUTE)
	return BRUTELOSS


/* ************************
	TIME GEM
   ************************/ 

/obj/item/infinity_gem/time_gem
	name = "Time Gem"
	desc = "A gem that allows the holder to be anytime."
	gem_flag = TIME_GEM
	color = "#26ff9b"
	gauntlet_gem = "time"
	spells = list(
		/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/time_gem,
		/obj/effect/proc_holder/spell/self/time_reverse
	)


/obj/effect/proc_holder/spell/self/time_reverse
	name = "Reverse Time"
	desc = "Stores your position and health at the current time, which you can then revert to at will."
	charge_max=1200
	clothes_req = FALSE
	action_icon = 'spacestation413/icons/mob/actions.dmi'
	action_icon_state = "time_reverse"
	var/time_stored = FALSE
	var/health_at_store
	var/turf/position_at_store

/obj/effect/proc_holder/spell/self/time_reverse/cast(list/targets,mob/user)
	. = ..()
	if(!isliving(user))
		return
	var/mob/living/living_user = user
	if(!time_stored)
		position_at_store=get_turf(living_user)
		health_at_store = living_user.health
		time_stored = TRUE
		charge_counter = 1200
		to_chat(user,"<span class='notice'>You save the current moment...</span>")
	else
		do_teleport(living_user,position_at_store,forceMove = TRUE, channel = TELEPORT_CHANNEL_FREE)
		to_chat(user,"<span class='danger'>You return to your saved moment! The shock exhausts you!</span>")
		var/health_right_now = living_user.health
		living_user.fully_heal()
		living_user.adjustStaminaLoss(max(0,((100-health_right_now)+(100-health_at_store))))
		time_stored = FALSE


/obj/effect/proc_holder/spell/self/time_reverse/empowered
	charge_max = 300
	stat_allowed = TRUE

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/time_gem
	invocation_type = "none" //hey why does this use strings instead of defines or an enum or something
	clothes_req = FALSE
	charge_max = 120

/obj/item/infinity_gem/time_gem/other_gem_actions(mob/user)
	if(other_gems & POWER_GEM)
		spells = list(
			/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/time_gem,
			/obj/effect/proc_holder/spell/self/time_reverse/empowered
		)
	else
		spells = list(
			/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/time_gem,
			/obj/effect/proc_holder/spell/self/time_reverse
		)

/obj/item/infinity_gem/time_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src]! It looks like [user.p_theyre()] trying to reverse evolution!</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.monkeyize()
	return TOXLOSS

/* ************************
	MIND GEM
   ************************/ 

/obj/item/infinity_gem/mind_gem
	name = "Mind Gem"
	desc = "A gem that gives the power to access the thoughts and dreams of other beings."
	gem_flag = MIND_GEM
	color = "#ffcc4f"
	gauntlet_gem = "mind"
	spells = list(
		/obj/effect/proc_holder/spell/targeted/telepathy,
		/obj/effect/proc_holder/spell/targeted/mindread
	)
	traits = list(TRAIT_THERMAL_VISION)

/obj/effect/proc_holder/spell/targeted/mind_transfer/mind_gem
	invocation_type = "none"
	unconscious_amount_victim = 200
	unconscious_amount_caster = 200

/obj/effect/proc_holder/spell/targeted/mind_transfer/mind_gem_empowered
	invocation_type = "none"
	unconscious_amount_victim = 0
	unconscious_amount_caster = 200

/obj/effect/proc_holder/spell/targeted/telepathy/mind_gem_empowered
	range = 100
	selection_type = "range"

/obj/effect/proc_holder/spell/targeted/mindread/mind_gem_empowered
	range = 100
	selection_type = "range"

/obj/item/infinity_gem/mind_gem/gem_add(mob/user)
	. = ..()
	user.update_sight()

/obj/item/infinity_gem/mind_gem/gem_remove(mob/user)
	. = ..()
	user.update_sight()

/obj/item/infinity_gem/mind_gem/other_gem_actions(mob/user)
	. = ..()
	if(other_gems & POWER_GEM)
		spells=list(
			/obj/effect/proc_holder/spell/targeted/telepathy/mind_gem_empowered,
			/obj/effect/proc_holder/spell/targeted/mindread/mind_gem_empowered
		)
	else
		spells = list(
			/obj/effect/proc_holder/spell/targeted/telepathy,
			/obj/effect/proc_holder/spell/targeted/mindread
		)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(other_gems & SPACE_GEM)
			H.dna.add_mutation(TK)
		else
			H.dna.remove_mutation(TK)
	if(other_gems & SOUL_GEM)
		if(other_gems & TIME_GEM)
			spells += /obj/effect/proc_holder/spell/targeted/mind_transfer/mind_gem_empowered
		else
			spells += /obj/effect/proc_holder/spell/targeted/mind_transfer/mind_gem

/obj/item/infinity_gem/time_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src]! It looks like [user.p_theyre()] opening their mind to everyone! It looks like too much to bear!</span>")
	return OXYLOSS

/* ************************
	SOUL GEM
   ************************/ 

/obj/item/infinity_gem/soul_gem
	name = "Soul Gem"
	desc = "A gem that gives power over souls."
	gem_flag = SOUL_GEM
	color = "#ff7732"
	gauntlet_gem = "soul"
	traits = list(TRAIT_SIXTHSENSE)
	spells = list(/obj/effect/proc_holder/spell/self/ghostify)

/obj/effect/proc_holder/spell/self/ghostify
	name = "Ghostize"
	desc = "Turns you into a ghost. Spooky!"
	clothes_req = FALSE
	action_icon = 'icons/mob/mob.dmi'
	action_icon_state = "ghost"
	charge_max=10

/obj/effect/proc_holder/spell/self/ghostify/cast(list/targets,mob/user = usr)
	. = ..()
	visible_message("<span class='danger'>[user] stares into the soul gem, their eyes glazing over.</span>")
	user.ghostize(1)

/obj/effect/proc_holder/spell/targeted/conjure_item/soulstone
	name = "Create Soulstone"
	desc = "Forges a soulstone using the soul gem."
	item_type = /obj/item/soulstone/anybody
	charge_max = 1200
	action_icon = 'icons/obj/wizard.dmi'
	action_icon_state = "soulstone"
	delete_old = FALSE
	clothes_req = FALSE

/obj/item/infinity_gem/soul_gem/other_gem_actions(mob/user)
	if(other_gems & REALITY_GEM)
		spells = list(
			/obj/effect/proc_holder/spell/self/ghostify,
			/obj/effect/proc_holder/spell/targeted/conjure_item/soulstone
		)
	else
		spells = list(/obj/effect/proc_holder/spell/self/ghostify)

/obj/item/infinity_gem/soul_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src]! It looks like [user.p_theyre()] blitzing their chakras and opening their third eye! They're becoming a spirit!</span>")
	return OXYLOSS

/* ************************
	POWER GEM
   ************************/ 

/obj/item/infinity_gem/power_gem
	name = "Power Gem"
	desc = "A gem granting dominion over power itself."
	gem_flag = POWER_GEM
	gauntlet_gem = "power"
	color = "#c673c5"

/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem
	anti_magic_check = FALSE
	clothes_req = FALSE
	invocation_type = "none"

/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem/space_empowered
	range = 8
	maxthrow = 8

/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem/reality_empowered
	repulse_force = MOVE_FORCE_OVERPOWERING

/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem/space_empowered/reality_empowered //lol
	repulse_force = MOVE_FORCE_OVERPOWERING

/obj/item/infinity_gem/power_gem/other_gem_actions(mob/user)
	if(other_gems & SPACE_GEM)
		if(other_gems & REALITY_GEM)
			spells = list(/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem/space_empowered/reality_empowered)
		else
			spells = list(/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem/space_empowered)
	else if(other_gems & REALITY_GEM)
		spells = list(/obj/effect/proc_holder/spell/aoe_turf/repulse/power_gem/reality_empowered)

/obj/item/infinity_gem/power_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src]! It looks like [user.p_theyre()] filling [user.p_them()]self with more power than [user.p_their()] body can handle!</span>")
	user.gib()
	return MANUAL_SUICIDE


/* ************************
	REALITY GEM
   ************************/ 

/obj/item/infinity_gem/reality_gem
	name = "Reality Gem"
	desc = "A gem granting dominion over reality."
	gem_flag = REALITY_GEM
	gauntlet_gem = "reality"
	color = "#ff1b3f"
	traits = list(TRAIT_NOSLIPALL)

/obj/item/infinity_gem/reality_gem/other_gem_actions(mob/user)
	traits=list(TRAIT_NOSLIPALL)
	to_chat(user, "<span class='notice'>You feel sure on your feet.</span>")
	if(other_gems & POWER_GEM)
		traits |= TRAIT_NOHARDCRIT
		to_chat(user, "<span class='notice'>You feel nearly unstoppable.</span>")
	if(other_gems & SOUL_GEM)
		traits |= TRAIT_NODEATH
		to_chat(user, "<span class='notice'>You know that you can never die!</span>")
	if(other_gems & SPACE_GEM)
		traits |= TRAIT_NODISMEMBER
		to_chat(user, "<span class='notice'>You feel sturdy.</span>")
	if(other_gems & TIME_GEM)
		traits |= TRAIT_NOCRITDAMAGE
		to_chat(user, "<span class='notice'>You keep yourself anchored.</span>")
	if(other_gems & MIND_GEM)
		traits |= TRAIT_XRAY_VISION
		to_chat(user, "<span class='notice'>You can see everything, forever!</span>")
		user.update_sight()

/obj/item/infinity_gem/reality_gem/gem_add(mob/user)
	. = ..()
	user.update_sight()

/obj/item/infinity_gem/reality_gem/gem_remove(mob/user)
	. = ..()
	user.update_sight()

/obj/item/infinity_gem/reality_gem/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] holds up the [src]! It looks like [user.p_theyre()] trying to unalive!</span>")
	return OXYLOSS

#undef INFINITY_GEM //maybe don't do this? hmm

#undef isspacegem

#undef istimegem

#undef ismindgem

#undef issoulgem

#undef ispowergem

#undef isrealitygem

#undef NO_GEMS
#undef SPACE_GEM
#undef TIME_GEM
#undef MIND_GEM
#undef SOUL_GEM
#undef POWER_GEM
#undef REALITY_GEM
#undef ALL_GEMS
