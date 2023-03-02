#define DNA_PROBE_SCAN_PLANTS (1<<0)
#define DNA_PROBE_SCAN_ANIMALS (1<<1)
#define DNA_PROBE_SCAN_HUMANS (1<<2)

/**
 * DNA Probe
 *
 * Used for scanning DNA, and can be uploaded to a DNA vault.
 */

/obj/item/dna_probe
	name = "DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of pretty much anything. Needs to be linked with a DNA vault first."
	icon = 'icons/obj/medical/syringe.dmi'
	inhand_icon_state = "sampler"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "sampler"
	item_flags = NOBLUDGEON
	///Whether we have Carp DNA
	var/carp_dna_loaded = FALSE
	///What sources of DNA this sampler can extract from.
	var/allowed_scans = DNA_PROBE_SCAN_PLANTS | DNA_PROBE_SCAN_ANIMALS | DNA_PROBE_SCAN_HUMANS
	///List of all Animal DNA scanned with this sampler.
	var/list/stored_dna_animal = list()
	///List of all Plant DNA scanned with this sampler.
	var/list/stored_dna_plants = list()
	///List of all Human DNA scanned with this sampler.
	var/list/stored_dna_human = list()
	///weak ref to the dna vault
	var/datum/weakref/dna_vault_ref

/obj/item/dna_probe/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !target)
		return .

	if (isitem(target))
		. |= AFTERATTACK_PROCESSED_ITEM

	if(istype(target, /obj/machinery/dna_vault) && !dna_vault_ref?.resolve())
		try_linking_vault(target, user)
	else
		scan_dna(target, user)

/obj/item/dna_probe/proc/try_linking_vault(atom/target, mob/user)
	var/obj/machinery/dna_vault/our_vault = dna_vault_ref?.resolve()
	if(!our_vault)
		dna_vault_ref = WEAKREF(target)//linking the dna vault with the probe
		balloon_alert(user, "vault linked")
		playsound(src, 'sound/machines/terminal_success.ogg', 50)
		return

/obj/item/dna_probe/proc/scan_dna(atom/target, mob/user)
	var/obj/machinery/dna_vault/our_vault = dna_vault_ref?.resolve()
	if(!our_vault)
		playsound(user, 'sound/machines/buzz-sigh.ogg', 50)
		balloon_alert(user, "need database!")
		return
	if((allowed_scans & DNA_PROBE_SCAN_PLANTS) && istype(target, /obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/hydro_tray = target
		if(!hydro_tray.myseed)
			return
		if(our_vault.plant_dna[hydro_tray.myseed.type])
			to_chat(user, span_notice("Plant data is already present in vault storage."))
			return
		if(stored_dna_plants[hydro_tray.myseed.type])
			to_chat(user, span_notice("Plant data already present in local storage."))
			return
		if(hydro_tray.plant_status != HYDROTRAY_PLANT_HARVESTABLE) // So it's bit harder.
			to_chat(user, span_alert("Plant needs to be ready to harvest to perform full data scan.")) //Because space dna is actually magic
			return .
		stored_dna_plants[hydro_tray.myseed.type] = TRUE
		playsound(src, 'sound/misc/compiler-stage2.ogg', 50)
		balloon_alert(user, "data added")
	else if((allowed_scans & DNA_PROBE_SCAN_HUMANS) && ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(our_vault.human_dna[human_target.dna.unique_identity])
			to_chat(user, span_notice("Humanoid data already present in vault storage."))
			return
		if(stored_dna_human[human_target.dna.unique_identity])
			to_chat(user, span_notice("Humanoid data already present in local storage."))
			return
		if(!(human_target.mob_biotypes & MOB_ORGANIC))
			to_chat(user, span_alert("No compatible DNA detected."))
			return .
		stored_dna_human[human_target.dna.unique_identity] = TRUE
		playsound(src, 'sound/misc/compiler-stage2.ogg', 50)
		balloon_alert(user, "data added")

	else if((allowed_scans & DNA_PROBE_SCAN_ANIMALS) && isliving(target))
		var/static/list/non_simple_animals = typecacheof(list(/mob/living/carbon/alien))
		if(isanimal_or_basicmob(target) || is_type_in_typecache(target, non_simple_animals) || ismonkey(target))
			var/mob/living/living_target = target
			if(our_vault.animal_dna[living_target.type])
				to_chat(user, span_notice("Animal data already present in vault storage."))
				return
			if(stored_dna_animal[living_target.type])
				to_chat(user, span_notice("Animal data already present in local storage."))
				return
			if(!(living_target.mob_biotypes & MOB_ORGANIC))
				to_chat(user, span_alert("No compatible DNA detected."))
				return .
			stored_dna_animal[living_target.type] = TRUE
			playsound(src, 'sound/misc/compiler-stage2.ogg', 50)
			balloon_alert(user, "data added")

#define CARP_MIX_DNA_TIMER (15 SECONDS)

///Used for scanning carps, and then turning yourself into one.
/obj/item/dna_probe/carp_scanner
	name = "Carp DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of animals."

/obj/item/dna_probe/carp_scanner/examine_more(mob/user)
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/traitor))
		. = list(span_notice("Using this on a Space Carp will harvest its DNA. Use it in-hand once complete to mutate it with yourself."))

/obj/item/dna_probe/carp_scanner/scan_dna(atom/target, mob/user)
	if(istype(target, /mob/living/basic/carp))
		carp_dna_loaded = TRUE
		playsound(src, 'sound/misc/compiler-stage2.ogg', 50)
		balloon_alert(user, "dna scanned")
	else
		return ..()

/obj/item/dna_probe/carp_scanner/attack_self(mob/user, modifiers)
	. = ..()
	if(!is_special_character(user))
		return
	if(!carp_dna_loaded)
		to_chat(user, span_notice("Space carp DNA is required to use the self-mutation mechanism!"))
		return
	to_chat(user, span_notice("You pull out the needle from [src] and flip the switch, and start injecting yourself with it."))
	if(!do_after(user, CARP_MIX_DNA_TIMER))
		return
	var/mob/living/simple_animal/hostile/space_dragon/new_dragon = user.change_mob_type(/mob/living/simple_animal/hostile/space_dragon, location = loc, delete_old_mob = TRUE)
	new_dragon.add_filter("anger_glow", 3, list("type" = "outline", "color" = "#ff330030", "size" = 5))
	new_dragon.add_movespeed_modifier(/datum/movespeed_modifier/dragon_rage)
	priority_announce("A large organic energy flux has been recorded near of [station_name()], please stand-by.", "Lifesign Alert")
	qdel(src)

#undef CARP_MIX_DNA_TIMER

#undef DNA_PROBE_SCAN_PLANTS
#undef DNA_PROBE_SCAN_ANIMALS
#undef DNA_PROBE_SCAN_HUMANS
