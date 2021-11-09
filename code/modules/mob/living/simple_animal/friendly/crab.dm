//Look Sir, free crabs!
/mob/living/basic/crab
	name = "crab"
	desc = "Free crabs!"
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	butcher_results = list(/obj/item/food/meat/rawcrab = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "stomps"
	response_harm_simple = "stomp"
	friendly_verb_continuous = "pinches"
	friendly_verb_simple = "pinch"
	var/obj/item/inventory_head
	var/obj/item/inventory_mask
	gold_core_spawnable = FRIENDLY_SPAWN
	///In the case 'melee_damage_upper' is somehow raised above 0
	attack_verb_continuous = "snips"
	attack_verb_simple = "snip"
	attack_sound = 'sound/weapons/slash.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	damage_coeff = list(BRUTE = 0.3, BURN = 0.3, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 0.7) //stronk shell
	ai_controller = /datum/ai_controller/basic_controller/crab

/mob/living/basic/crab/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

//COFFEE! SQUEEEEEEEEE!
/mob/living/basic/crab/coffee
	name = "Coffee"
	real_name = "Coffee"
	desc = "It's Coffee, the other pet!"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/evil
	name = "Evil Crab"
	real_name = "Evil Crab"
	desc = "Unnerving, isn't it? It has to be planning something nefarious..."
	icon_state = "evilcrab"
	icon_living = "evilcrab"
	icon_dead = "evilcrab_dead"
	gold_core_spawnable = FRIENDLY_SPAWN
	health = 40
	maxHealth = 40 //slightly more effective health than a human.
	melee_damage_lower = 2
	melee_damage_upper = 5
	var/obj/effect/proc_holder/evil_pinch/pinch

/mob/living/basic/crab/evil/Initialize(mapload)
	. = ..()
	pinch = new(src, src)
	AddAbility(pinch)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_EVIL_CRAB, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/mob/living/basic/crab/evil/melee_attack(atom/target)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/toe_ape = target
	var/obj/item/footwear = toe_ape.get_item_by_slot(ITEM_SLOT_FEET)
	if(!footwear || QDELETED(footwear))
		return
	footwear.take_damage(75)
	new /obj/effect/decal/cleanable/shreds(get_turf(toe_ape))

/mob/living/basic/crab/evil/Destroy()
	. = ..()
	QDEL_NULL(pinch)

/obj/effect/proc_holder/evil_pinch
	name = "Pinch of Inequity"
	desc = "Pinch a barefooted human's toes, grabbing and immobilizing them for 10 seconds."
	active = FALSE
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "evil_pinch"
	action_background_icon_state = "bg_cult"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	base_action = /datum/action/cooldown/spell_like
	///How long cooldown before we can use the ability again
	var/cooldown = 20 SECONDS

/obj/effect/proc_holder/evil_pinch/Initialize(mapload, mob/living/new_owner)
	. = ..()
	if(!action)
		return
	var/datum/action/cooldown/our_action = action
	our_action.cooldown_time = cooldown

/obj/effect/proc_holder/evil_pinch/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	fire(usr)

/obj/effect/proc_holder/evil_pinch/fire(mob/living/user)
	if(active)
		remove_ranged_ability(span_notice("You relax your pinching claw."))
	else
		add_ranged_ability(user, span_notice("You prepare your pinching claw. <B>Left-click to pinch a stupid human!</B>"), TRUE)

/obj/effect/proc_holder/evil_pinch/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	var/mob/living/sinister_creature = owner.resolve()
	if(.)
		return
	if(!sinister_creature)
		return
	if(!ismob(target))
		return
	if(sinister_creature.stat)
		return
	if(!sinister_creature.Adjacent(target))
		return
	if(!ishuman(target))
		remove_ranged_ability()
		to_chat(caller, span_warning("This creature does not have suitable toes!"))
		return

	var/mob/living/carbon/human/human_target = target
	var/obj/item/kicks = human_target.get_item_by_slot(ITEM_SLOT_FEET)

	if(kicks)
		remove_ranged_ability()
		to_chat(caller, span_warning("These feet are protected by shoes, you need to snip them apart before you can pinch their toes!"))
		return
	if(!action.IsAvailable())
		remove_ranged_ability()
		to_chat(caller, span_notice("This ability is still on cooldown."))
		return

	sinister_creature.visible_message("<span class='warning>[sinister_creature] cruelly pinches [human_target]'s toes with its dominant claw! It looks like it got a good grip!</span>", span_nicegreen("You pinch [human_target]'s disgusting toes with your big claw. You feel like you got a good grip on them."))
	sinister_creature.start_pulling(human_target, force = MOVE_FORCE_EXTREMELY_STRONG)
	human_target.apply_status_effect(STATUS_EFFECT_IMMOBILIZING_GRAB, 10 SECONDS)
	playsound(owner, 'sound/effects/wounds/crack1.ogg', 70)
	addtimer(CALLBACK(human_target, /mob/proc/emote, "scream"), 1 SECONDS)
	remove_ranged_ability()

	var/datum/action/cooldown/our_action = action
	our_action.StartCooldown()

	return TRUE

/mob/living/basic/crab/kreb
	name = "Kreb"
	desc = "This is a real crab. The other crabs are simply gubbucks in disguise!"
	real_name = "Kreb"
	icon_state = "kreb"
	icon_living = "kreb"
	icon_dead = "kreb_dead"
	gold_core_spawnable = NO_SPAWN

/mob/living/basic/crab/evil/kreb
	name = "Evil Kreb"
	real_name = "Evil Kreb"
	icon_state = "evilkreb"
	icon_living = "evilkreb"
	icon_dead = "evilkreb_dead"
	gold_core_spawnable = NO_SPAWN

/datum/ai_controller/basic_controller/crab
	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_crab
	planning_subtrees = list(
		/datum/ai_planning_subtree/random_speech/crab,
	)
