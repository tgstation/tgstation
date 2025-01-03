/*!
 * Contains Heretic grenades
 */

/obj/item/grenade/chem_grenade/rust_sower
	name = "\improper Rust sower"
	desc = "A nifty little thing that explodes into rust. Causes borgs and mechs to get utterly obliterated"
	possible_fuse_time = list("3", "4", "5")
	stage = GRENADE_READY

/obj/item/grenade/chem_grenade/rust_sower/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/cup/beaker/large/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/consumable/heretic_rust, 25)
	beaker_one.reagents.add_reagent(/datum/reagent/toxin/spewium, 25)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 50)

	beakers += beaker_one
	beakers += beaker_two

/datum/reagent/consumable/heretic_rust
	name = "Eldritch Rust"
	description = "A slurry of some off-putting liquid. Just looking at it makes you feel sick."
	color = COLOR_CARGO_BROWN // Rust color
	taste_description = "scorching agony"
	penetrates_skin = NONE
	ph = 7.4
	chemical_flags = REAGENT_CAN_BE_SYNTHESIZED
	default_container = /obj/item/reagent_containers/cup/bottle/capsaicin

/datum/reagent/consumable/heretic_rust/expose_mob(mob/living/exposed_mob, methods=TOUCH, reac_volume)
	if(!ishuman(exposed_mob))
		if(issilicon(exposed_mob) || ismecha(exposed_mob))
			exposed_mob.adjustBruteLoss(500)
		return
	if(IS_HERETIC(exposed_mob))
		return
	if(exposed_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return

	var/mob/living/carbon/victim = exposed_mob
	if(methods & (TOUCH|VAPOR|INHALE))
		//check for protection
		//actually handle the pepperspray effects
		if(!victim.is_pepper_proof()) // you need both eye and mouth protection
			if(prob(5))
				victim.emote("scream")
			victim.emote("cry")
			victim.set_eye_blur_if_lower(10 SECONDS)
			victim.adjust_temp_blindness(6 SECONDS)
			victim.set_confusion_if_lower(5 SECONDS)
			victim.Knockdown(3 SECONDS)
			victim.add_movespeed_modifier(/datum/movespeed_modifier/reagent/pepperspray)
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/reagent/pepperspray), 10 SECONDS)
		victim.update_damage_hud()
		victim.adjust_disgust(5)
	if(methods & INGEST)
		if(!holder.has_reagent(/datum/reagent/consumable/milk))
			if(prob(15))
				to_chat(exposed_mob, span_danger("[pick("Your head pounds.", "Your mouth feels like it's on fire.", "You feel dizzy.")]"))
			if(prob(10))
				victim.set_eye_blur_if_lower(2 SECONDS)
			if(prob(10))
				victim.set_dizzy_if_lower(2 SECONDS)
			if(prob(5))
				victim.vomit(VOMIT_CATEGORY_DEFAULT)
	return ..()

/datum/reagent/consumable/heretic_rust/expose_turf(turf/exposed_turf, reac_volume)
	. = ..()
	exposed_turf.rust_turf()

/datum/reagent/consumable/heretic_rust/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(!holder.has_reagent(/datum/reagent/consumable/milk))
		if(SPT_PROB(5, seconds_per_tick))
			affected_mob.visible_message(span_warning("[affected_mob] [pick("dry heaves!","coughs!","splutters!")]"))
