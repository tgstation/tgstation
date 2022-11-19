/// List of bodypart_ids that are "normal" to prioritize replacing when splicing in a new limb.
GLOBAL_LIST_INIT(standard_limb_types, list(
	SPECIES_ETHEREAL,
	SPECIES_FELINE,
	SPECIES_HUMAN,
	SPECIES_LIZARD,
	SPECIES_MOTH,
	SPECIES_PLASMAMAN,
	SPECIES_MONKEY,
))

/// What mobs can be spliced into what limbs?
GLOBAL_LIST_INIT(splice_results, list(
	/mob/living/basic/stickman = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/stickman,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/stickman,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/stickman,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/stickman,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/stickman,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/stickman,
	),
))

/obj/machinery/splicer
	name = "splicer button"
	desc = "press da button"
	icon = 'icons/obj/genetics_splicer.dmi'
	icon_state = "fuck"
	var/obj/machinery/splicer_holder/human/human_holder
	var/obj/machinery/splicer_holder/dead_mob/corpse_holder

/obj/machinery/splicer/interact(mob/user, special_state)
	. = ..()
	if(!human_holder || QDELETED(human_holder))
		var/turf/potential_human_holder_turf = get_step(src, EAST)
		for(var/obj/machinery/splicer_holder/human/potential_human_holder in potential_human_holder_turf)
			human_holder = potential_human_holder
			break
		if(!human_holder)
			balloon_alert(user, "missing machinery!")
			return
	if(!corpse_holder || QDELETED(corpse_holder))
		var/turf/potential_corpse_holder_turf = get_step(src, WEST)
		for(var/obj/machinery/splicer_holder/human/potential_corpse_holder in potential_corpse_holder_turf)
			corpse_holder = potential_corpse_holder
			break
		if(!corpse_holder)
			balloon_alert(user, "missing machinery!")
			return
	if(!human_holder.occupant || !human_holder.state_open)
		balloon_alert(user, "missing humanoid!")
		return
	if(!corpse_holder.occupant || !corpse_holder.state_open)
		balloon_alert(user, "missing corpse!")
		return
	var/mob/living/corpse = corpse_holder.occupant
	if(corpse.stat != DEAD)
		balloon_alert(user, "corpse not dead yet!")
		return
	if(!(corpse.type in GLOB.splice_results))
		balloon_alert(user, "corpse not splicable!")
		return
	var/mob/living/carbon/human/splice_target = human_holder.occupant
	var/list/applicable_bodyparts = list()
	var/list/body_zones_to_check = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)
	for(var/body_part_zone in body_zones_to_check)
		var/obj/item/bodypart/body_part = splice_target.get_bodypart(body_part_zone)
		if(body_part.limb_id in GLOB.standard_limb_types)
			applicable_bodyparts += body_part // We want to only replace parts that haven't been genesliced yet.
	if(!length(applicable_bodyparts))
		applicable_bodyparts = body_zones_to_check // Gotta replace something at this point.
	var/obj/item/bodypart/new_part = new GLOB.splice_results[corpse.type][pick(applicable_bodyparts)]
	new_part.replace_limb(splice_target, TRUE) // Apply the new limb.
	qdel(corpse_holder.occupant)
	var/turf/lightning_source = get_step(get_step(src, NORTH), NORTH)
	lightning_source.Beam(src, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(get_turf(src), 'sound/magic/lightningbolt.ogg', 50, TRUE)
	splice_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)
	corpse_holder.open_machine()
	human_holder.open_machine()

/obj/machinery/splicer_holder
	name = "splicer holder"
	desc = "Abstract, you shouldn't see this"
	icon = 'icons/obj/genetics_splicer.dmi'
	base_icon_state = "fuck"

/obj/machinery/splicer_holder/human
	name = "splicer human holder"
	desc = "Stand in here to become awesome."
	base_icon_state = "human_holder"
	icon_state = "human_holder"
	occupant_typecache = list(/mob/living/carbon/human)

/obj/machinery/splicer_holder/dead_mob
	name = "splicer corpse holder"
	desc = "Deposit a dead animal in here to become awesome using it."
	base_icon_state = "corpse_holder"
	icon_state = "corpse_holder"
	occupant_typecache = list(/mob/living/basic, /mob/living/simple_animal)

/obj/machinery/splicer_holder/update_icon_state()

	if(occupant)
		icon_state = "[base_icon_state]_occupied"
		return ..()

	//running
	icon_state = "[base_icon_state][state_open ? "_open" : null]"
	return ..()

/obj/machinery/splicer_holder/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, span_notice("Close the maintenance panel first."))
		return

	if(state_open)
		close_machine()
		return

	open_machine()

/obj/machinery/splicer_holder/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE
	..(user)
	return TRUE

/obj/machinery/splicer_holder/open_machine()
	if(state_open)
		return FALSE

	..()
	return TRUE

/obj/machinery/splicer_holder/relaymove(mob/living/user, direction)
	open_machine()

/obj/machinery/splicer_holder/interact(mob/user)
	toggle_open(user)
