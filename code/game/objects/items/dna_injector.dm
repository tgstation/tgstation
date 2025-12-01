/obj/item/dnainjector
	name = "\improper DNA injector"
	desc = "A cheap single use autoinjector that injects the user with DNA."
	icon = 'icons/obj/medical/syringe.dmi'
	icon_state = "dnainjector"
	inhand_icon_state = "dnainjector"
	worn_icon_state = "pen"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY

	var/damage_coeff = 1
	var/list/fields
	var/list/add_mutations = list()
	var/list/remove_mutations = list()

	var/used = FALSE

/obj/item/dnainjector/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	if(used)
		update_appearance()

/obj/item/dnainjector/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, used))
		update_appearance()

/obj/item/dnainjector/update_icon_state()
	. = ..()
	icon_state = inhand_icon_state = "[initial(icon_state)][used ? "0" : null]"

/obj/item/dnainjector/update_desc(updates)
	. = ..()
	desc = "[initial(desc)][used ? "This one is used up." : null]"

/obj/item/dnainjector/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/item/dnainjector/proc/inject(mob/living/carbon/target, mob/user)
	if(!target.can_mutate())
		return FALSE
	for(var/removed_mutation in remove_mutations)
		target.dna.remove_mutation(removed_mutation, list(MUTATION_SOURCE_ACTIVATED, MUTATION_SOURCE_MUTATOR))
	for(var/added_mutation in add_mutations)
		if(added_mutation == /datum/mutation/race)
			message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(target)] with \the [src] [span_danger("(MONKEY)")]")
		if(target.dna.mutation_in_sequence(added_mutation))
			target.dna.activate_mutation(added_mutation)
		else
			target.dna.add_mutation(added_mutation, MUTATION_SOURCE_MUTATOR)
	if(fields)
		if(fields["name"] && fields["UE"] && fields["blood_type"])
			target.real_name = fields["name"]
			target.dna.unique_enzymes = fields["UE"]
			target.name = target.real_name
			target.set_blood_type(fields["blood_type"])
		if(fields["UI"]) //UI+UE
			target.dna.unique_identity = merge_text(target.dna.unique_identity, fields["UI"])
		if(fields["UF"])
			target.dna.unique_features = merge_text(target.dna.unique_features, fields["UF"])
		if(fields["UI"] || fields["UF"])
			target.updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)
	return TRUE

/obj/item/dnainjector/attack(mob/target, mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	if(used)
		to_chat(user, span_warning("This injector is used up!"))
		return
	if(ishuman(target))
		var/mob/living/carbon/human/humantarget = target
		if (!humantarget.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
			return
	log_combat(user, target, "attempted to inject", src)

	if(target != user)
		target.visible_message(span_danger("[user] is trying to inject [target] with [src]!"), \
			span_userdanger("[user] is trying to inject you with [src]!"))
		if(!do_after(user, 3 SECONDS, target) || used)
			return
		target.visible_message(span_danger("[user] injects [target] with the syringe with [src]!"), \
						span_userdanger("[user] injects you with the syringe with [src]!"))

	else
		to_chat(user, span_notice("You inject yourself with [src]."))

	log_combat(user, target, "injected", src)

	if(!inject(target, user)) //Now we actually do the heavy lifting.
		to_chat(user, span_notice("It appears that [target] does not have compatible DNA."))
		return

	used = TRUE
	update_appearance()

/obj/item/dnainjector/timed
	var/duration = 60 SECONDS

/obj/item/dnainjector/timed/inject(mob/living/carbon/target, mob/user)
	if(target.stat == DEAD) //prevents dead people from having their DNA changed
		to_chat(user, span_notice("You can't modify [target]'s DNA while [target.p_theyre()] dead."))
		return FALSE
	if(!target.can_mutate())
		return FALSE
	var/endtime = world.time + duration
	for(var/mutation in remove_mutations)
		target.dna.remove_mutation(mutation, list(MUTATION_SOURCE_ACTIVATED, MUTATION_SOURCE_MUTATOR))
	for(var/mutation in add_mutations)
		if(target.dna.get_mutation(mutation))
			continue //Skip permanent mutations we already have.
		if(mutation == /datum/mutation/race && !ismonkey(target))
			message_admins("[ADMIN_LOOKUPFLW(user)] injected [key_name_admin(target)] with \the [src] [span_danger("(MONKEY)")]")
		target.dna.add_mutation(mutation, MUTATION_SOURCE_TIMED_INJECTOR)
		addtimer(CALLBACK(target.dna, TYPE_PROC_REF(/datum/dna, remove_mutation), mutation, MUTATION_SOURCE_TIMED_INJECTOR), duration)
	if(fields)
		if(fields["name"] && fields["UE"] && fields["blood_type"])
			if(!target.dna.previous["name"])
				target.dna.previous["name"] = target.real_name
			if(!target.dna.previous["UE"])
				target.dna.previous["UE"] = target.dna.unique_enzymes
			if(!target.dna.previous["blood_type"])
				target.dna.previous["blood_type"] = target.get_bloodtype()
			target.real_name = fields["name"]
			target.dna.unique_enzymes = fields["UE"]
			target.name = target.real_name
			target.set_blood_type(fields["blood_type"])
			target.dna.temporary_mutations[UE_CHANGED] = endtime
		if(fields["UI"]) //UI+UE
			if(!target.dna.previous["UI"])
				target.dna.previous["UI"] = target.dna.unique_identity
			target.dna.unique_identity = merge_text(target.dna.unique_identity, fields["UI"])
			target.dna.temporary_mutations[UI_CHANGED] = endtime
		if(fields["UF"]) //UI+UE
			if(!target.dna.previous["UF"])
				target.dna.previous["UF"] = target.dna.unique_features
			target.dna.unique_features = merge_text(target.dna.unique_features, fields["UF"])
			target.dna.temporary_mutations[UF_CHANGED] = endtime
		if(fields["UI"] || fields["UF"])
			target.updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)
	return TRUE

/obj/item/dnainjector/timed/hulk
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations = list(/datum/mutation/hulk)

/obj/item/dnainjector/timed/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations = list(/datum/mutation/race)

/obj/item/dnainjector/activator
	name = "\improper DNA activator"
	desc = "Activates the current mutation on injection, if the subject has it."
	var/force_mutate = FALSE
	var/research = FALSE //Set to true to get expended and filled injectors for chromosomes
	var/filled = FALSE
	var/crispr_charge = FALSE // Look for viruses, look at symptoms, if research and Dormant DNA Activator or Viral Evolutionary Acceleration, set to true

/obj/item/dnainjector/activator/inject(mob/living/carbon/target, mob/user)
	if(!target.can_mutate())
		return FALSE
	for(var/mutation in add_mutations)
		var/datum/mutation/added_mutation = mutation
		if(istype(added_mutation, /datum/mutation))
			mutation = added_mutation.type
		if(!target.dna.activate_mutation(added_mutation))
			if(force_mutate)
				target.dna.add_mutation(added_mutation, MUTATION_SOURCE_MUTATOR)
		else if(research && target.client)
			filled = TRUE
		for(var/datum/disease/advance/disease in target.diseases)
			for(var/datum/symptom/symp in disease.symptoms)
				if((symp.type == /datum/symptom/genetic_mutation) || (symp.type == /datum/symptom/viralevolution))
					crispr_charge = TRUE
		log_combat(user, target, "[!force_mutate ? "failed to inject" : "injected"]", "[src] ([mutation])[crispr_charge ? " with CRISPR charge" : ""]")
	return TRUE

/// DNA INJECTORS

/obj/item/dnainjector/acidflesh
	name = "\improper DNA injector (Acid Flesh)"
	add_mutations = list(/datum/mutation/acidflesh)

/obj/item/dnainjector/antiacidflesh
	name = "\improper DNA injector (Acid Flesh)"
	remove_mutations = list(/datum/mutation/acidflesh)

/obj/item/dnainjector/antenna
	name = "\improper DNA injector (Antenna)"
	add_mutations = list(/datum/mutation/antenna)

/obj/item/dnainjector/antiantenna
	name = "\improper DNA injector (Anti-Antenna)"
	remove_mutations = list(/datum/mutation/antenna)

/obj/item/dnainjector/antiglow
	name = "\improper DNA injector (Antiglowy)"
	add_mutations = list(/datum/mutation/glow/anti)

/obj/item/dnainjector/removeantiglow
	name = "\improper DNA injector (Anti-Antiglowy)"
	remove_mutations = list(/datum/mutation/glow/anti)

/obj/item/dnainjector/blindmut
	name = "\improper DNA injector (Blind)"
	desc = "Makes you not see anything."
	add_mutations = list(/datum/mutation/blind)

/obj/item/dnainjector/antiblind
	name = "\improper DNA injector (Anti-Blind)"
	desc = "IT'S A MIRACLE!!!"
	remove_mutations = list(/datum/mutation/blind)

/obj/item/dnainjector/chameleonmut
	name = "\improper DNA injector (Chameleon)"
	add_mutations = list(/datum/mutation/chameleon)

/obj/item/dnainjector/antichameleon
	name = "\improper DNA injector (Anti-Chameleon)"
	remove_mutations = list(/datum/mutation/chameleon)

/obj/item/dnainjector/chavmut
	name = "\improper DNA injector (Chav)"
	add_mutations = list(/datum/mutation/chav)

/obj/item/dnainjector/antichav
	name = "\improper DNA injector (Anti-Chav)"
	remove_mutations = list(/datum/mutation/chav)

/obj/item/dnainjector/clumsymut
	name = "\improper DNA injector (Clumsy)"
	desc = "Makes clown minions."
	add_mutations = list(/datum/mutation/clumsy)

/obj/item/dnainjector/anticlumsy
	name = "\improper DNA injector (Anti-Clumsy)"
	desc = "Apply this for Security Clown."
	remove_mutations = list(/datum/mutation/clumsy)

/obj/item/dnainjector/coughmut
	name = "\improper DNA injector (Cough)"
	desc = "Will bring forth a sound of horror from your throat."
	add_mutations = list(/datum/mutation/cough)

/obj/item/dnainjector/anticough
	name = "\improper DNA injector (Anti-Cough)"
	desc = "Will stop that awful noise."
	remove_mutations = list(/datum/mutation/cough)

/obj/item/dnainjector/cryokinesis
	name = "\improper DNA injector (Cryokinesis)"
	add_mutations = list(/datum/mutation/cryokinesis)

/obj/item/dnainjector/anticryokinesis
	name = "\improper DNA injector (Anti-Cryokinesis)"
	remove_mutations = list(/datum/mutation/cryokinesis)

/obj/item/dnainjector/deafmut
	name = "\improper DNA injector (Deaf)"
	desc = "Sorry, what did you say?"
	add_mutations = list(/datum/mutation/deaf)

/obj/item/dnainjector/antideaf
	name = "\improper DNA injector (Anti-Deaf)"
	desc = "Will make you hear once more."
	remove_mutations = list(/datum/mutation/deaf)

/obj/item/dnainjector/dwarf
	name = "\improper DNA injector (Dwarfism)"
	desc = "It's a small world after all."
	add_mutations = list(/datum/mutation/dwarfism)

/obj/item/dnainjector/antidwarf
	name = "\improper DNA injector (Anti-Dwarfism)"
	desc = "Helps you grow big and strong."
	remove_mutations = list(/datum/mutation/dwarfism)

/obj/item/dnainjector/elvismut
	name = "\improper DNA injector (Elvis)"
	add_mutations = list(/datum/mutation/elvis)

/obj/item/dnainjector/antielvis
	name = "\improper DNA injector (Anti-Elvis)"
	remove_mutations = list(/datum/mutation/elvis)

/obj/item/dnainjector/epimut
	name = "\improper DNA injector (Epi.)"
	desc = "Shake shake shake the room!"
	add_mutations = list(/datum/mutation/epilepsy)

/obj/item/dnainjector/antiepi
	name = "\improper DNA injector (Anti-Epi.)"
	desc = "Will fix you up from shaking the room."
	remove_mutations = list(/datum/mutation/epilepsy)

/obj/item/dnainjector/geladikinesis
	name = "\improper DNA injector (Geladikinesis)"
	add_mutations = list(/datum/mutation/geladikinesis)

/obj/item/dnainjector/antigeladikinesis
	name = "\improper DNA injector (Anti-Geladikinesis)"
	remove_mutations = list(/datum/mutation/geladikinesis)

/obj/item/dnainjector/gigantism
	name = "\improper DNA injector (Gigantism)"
	add_mutations = list(/datum/mutation/gigantism)

/obj/item/dnainjector/antigigantism
	name = "\improper DNA injector (Anti-Gigantism)"
	remove_mutations = list(/datum/mutation/gigantism)

/obj/item/dnainjector/glassesmut
	name = "\improper DNA injector (Glasses)"
	desc = "Will make you need dorkish glasses."
	add_mutations = list(/datum/mutation/nearsight)

/obj/item/dnainjector/antiglasses
	name = "\improper DNA injector (Anti-Glasses)"
	desc = "Toss away those glasses!"
	remove_mutations = list(/datum/mutation/nearsight)

/obj/item/dnainjector/glow
	name = "\improper DNA injector (Glowy)"
	add_mutations = list(/datum/mutation/glow)

/obj/item/dnainjector/removeglow
	name = "\improper DNA injector (Anti-Glowy)"
	remove_mutations = list(/datum/mutation/glow)

/obj/item/dnainjector/hulkmut
	name = "\improper DNA injector (Hulk)"
	desc = "This will make you big and strong, but give you a bad skin condition."
	add_mutations = list(/datum/mutation/hulk)

/obj/item/dnainjector/antihulk
	name = "\improper DNA injector (Anti-Hulk)"
	desc = "Cures green skin."
	remove_mutations = list(/datum/mutation/hulk)

/obj/item/dnainjector/h2m
	name = "\improper DNA injector (Human > Monkey)"
	desc = "Will make you a flea bag."
	add_mutations = list(/datum/mutation/race)

/obj/item/dnainjector/m2h
	name = "\improper DNA injector (Monkey > Human)"
	desc = "Will make you...less hairy."
	remove_mutations = list(/datum/mutation/race)

/obj/item/dnainjector/illiterate
	name = "\improper DNA injector (Illiterate)"
	add_mutations = list(/datum/mutation/illiterate)

/obj/item/dnainjector/antiilliterate
	name = "\improper DNA injector (Anti-Illiterate)"
	remove_mutations = list(/datum/mutation/illiterate)

/obj/item/dnainjector/insulated
	name = "\improper DNA injector (Insulated)"
	add_mutations = list(/datum/mutation/insulated)

/obj/item/dnainjector/antiinsulated
	name = "\improper DNA injector (Anti-Insulated)"
	remove_mutations = list(/datum/mutation/insulated)

/obj/item/dnainjector/lasereyesmut
	name = "\improper DNA injector (Laser Eyes)"
	add_mutations = list(/datum/mutation/laser_eyes)

/obj/item/dnainjector/antilasereyes
	name = "\improper DNA injector (Anti-Laser Eyes)"
	remove_mutations = list(/datum/mutation/laser_eyes)

/obj/item/dnainjector/mindread
	name = "\improper DNA injector (Mindread)"
	add_mutations = list(/datum/mutation/mindreader)

/obj/item/dnainjector/antimindread
	name = "\improper DNA injector (Anti-Mindread)"
	remove_mutations = list(/datum/mutation/mindreader)

/obj/item/dnainjector/mutemut
	name = "\improper DNA injector (Mute)"
	add_mutations = list(/datum/mutation/mute)

/obj/item/dnainjector/antimute
	name = "\improper DNA injector (Anti-Mute)"
	remove_mutations = list(/datum/mutation/mute)

/obj/item/dnainjector/olfaction
	name = "\improper DNA injector (Olfaction)"
	add_mutations = list(/datum/mutation/olfaction)

/obj/item/dnainjector/antiolfaction
	name = "\improper DNA injector (Anti-Olfaction)"
	remove_mutations = list(/datum/mutation/olfaction)

/obj/item/dnainjector/piglatinmut
	name = "\improper DNA injector (Pig Latin)"
	add_mutations = list(/datum/mutation/piglatin)

/obj/item/dnainjector/antipiglatin
	name = "\improper DNA injector (Anti-Pig Latin)"
	remove_mutations = list(/datum/mutation/piglatin)

/obj/item/dnainjector/paranoia
	name = "\improper DNA injector (Paranoia)"
	add_mutations = list(/datum/mutation/paranoia)

/obj/item/dnainjector/antiparanoia
	name = "\improper DNA injector (Anti-Paranoia)"
	remove_mutations = list(/datum/mutation/paranoia)

/obj/item/dnainjector/pressuremut
	name = "\improper DNA injector (Pressure Adaptation)"
	desc = "Gives you fire."
	add_mutations = list(/datum/mutation/adaptation/pressure)

/obj/item/dnainjector/antipressure
	name = "\improper DNA injector (Anti-Pressure Adaptation)"
	desc = "Cures fire."
	remove_mutations = list(/datum/mutation/adaptation/pressure)

/obj/item/dnainjector/radioactive
	name = "\improper DNA injector (Radioactive)"
	add_mutations = list(/datum/mutation/radioactive)

/obj/item/dnainjector/antiradioactive
	name = "\improper DNA injector (Anti-Radioactive)"
	remove_mutations = list(/datum/mutation/radioactive)

/obj/item/dnainjector/shock
	name = "\improper DNA injector (Shock Touch)"
	add_mutations = list(/datum/mutation/shock)

/obj/item/dnainjector/antishock
	name = "\improper DNA injector (Anti-Shock Touch)"
	remove_mutations = list(/datum/mutation/shock)

/obj/item/dnainjector/spastic
	name = "\improper DNA injector (Spastic)"
	add_mutations = list(/datum/mutation/spastic)

/obj/item/dnainjector/antispastic
	name = "\improper DNA injector (Anti-Spastic)"
	remove_mutations = list(/datum/mutation/spastic)

/obj/item/dnainjector/spatialinstability
	name = "\improper DNA injector (Spatial Instability)"
	add_mutations = list(/datum/mutation/badblink)

/obj/item/dnainjector/antispatialinstability
	name = "\improper DNA injector (Anti-Spatial Instability)"
	remove_mutations = list(/datum/mutation/badblink)

/obj/item/dnainjector/stuttmut
	name = "\improper DNA injector (Stutt.)"
	desc = "Makes you s-s-stuttterrr."
	add_mutations = list(/datum/mutation/nervousness)

/obj/item/dnainjector/antistutt
	name = "\improper DNA injector (Anti-Stutt.)"
	desc = "Fixes that speaking impairment."
	remove_mutations = list(/datum/mutation/nervousness)

/obj/item/dnainjector/swedishmut
	name = "\improper DNA injector (Swedish)"
	add_mutations = list(/datum/mutation/swedish)

/obj/item/dnainjector/antiswedish
	name = "\improper DNA injector (Anti-Swedish)"
	remove_mutations = list(/datum/mutation/swedish)

/obj/item/dnainjector/telemut
	name = "\improper DNA injector (Tele.)"
	desc = "Super brain TK!"
	add_mutations = list(/datum/mutation/telekinesis)

/obj/item/dnainjector/telemut/darkbundle
	name = "\improper DNA injector"
	desc = "Good. Let the hate flow through you."

/obj/item/dnainjector/antitele
	name = "\improper DNA injector (Anti-Tele.)"
	desc = "Will make you not able to control your mind."
	remove_mutations = list(/datum/mutation/telekinesis)

/obj/item/dnainjector/firemut
	name = "\improper DNA injector (Temp Adaptation)"
	desc = "Gives you fire."
	add_mutations = list(/datum/mutation/adaptation/thermal)

/obj/item/dnainjector/antifire
	name = "\improper DNA injector (Anti-Temp Adaptation)"
	desc = "Cures fire."
	remove_mutations = list(/datum/mutation/adaptation/thermal)

/obj/item/dnainjector/thermal
	name = "\improper DNA injector (Thermal Vision)"
	add_mutations = list(/datum/mutation/thermal)

/obj/item/dnainjector/antithermal
	name = "\improper DNA injector (Anti-Thermal Vision)"
	remove_mutations = list(/datum/mutation/thermal)

/obj/item/dnainjector/tourmut
	name = "\improper DNA injector (Tour.)"
	desc = "Gives you a nasty case of Tourette's."
	add_mutations = list(/datum/mutation/tourettes)

/obj/item/dnainjector/antitour
	name = "\improper DNA injector (Anti-Tour.)"
	desc = "Will cure Tourette's."
	remove_mutations = list(/datum/mutation/tourettes)

/obj/item/dnainjector/twoleftfeet
	name = "\improper DNA injector (Two Left Feet)"
	add_mutations = list(/datum/mutation/extrastun)

/obj/item/dnainjector/antitwoleftfeet
	name = "\improper DNA injector (Anti-Two Left Feet)"
	remove_mutations = list(/datum/mutation/extrastun)

/obj/item/dnainjector/unintelligiblemut
	name = "\improper DNA injector (Unintelligible)"
	add_mutations = list(/datum/mutation/unintelligible)

/obj/item/dnainjector/antiunintelligible
	name = "\improper DNA injector (Anti-Unintelligible)"
	remove_mutations = list(/datum/mutation/unintelligible)

/obj/item/dnainjector/void
	name = "\improper DNA injector (Void)"
	add_mutations = list(/datum/mutation/void)

/obj/item/dnainjector/antivoid
	name = "\improper DNA injector (Anti-Void)"
	remove_mutations = list(/datum/mutation/void)

/obj/item/dnainjector/xraymut
	name = "\improper DNA injector (X-ray)"
	desc = "Finally you can see what the Captain does."
	add_mutations = list(/datum/mutation/xray)

/obj/item/dnainjector/antixray
	name = "\improper DNA injector (Anti-X-ray)"
	desc = "It will make you see harder."
	remove_mutations = list(/datum/mutation/xray)

/obj/item/dnainjector/wackymut
	name = "\improper DNA injector (Wacky)"
	add_mutations = list(/datum/mutation/wacky)

/obj/item/dnainjector/antiwacky
	name = "\improper DNA injector (Anti-Wacky)"
	remove_mutations = list(/datum/mutation/wacky)

/obj/item/dnainjector/webbing
	name = "\improper DNA injector (Webbing)"
	add_mutations = list(/datum/mutation/webbing)

/obj/item/dnainjector/antiwebbing
	name = "\improper DNA injector (Anti-Webbing)"
	remove_mutations = list(/datum/mutation/webbing)

/obj/item/dnainjector/clever
	name = "\improper DNA injector (Clever)"
	add_mutations = list(/datum/mutation/clever)

/obj/item/dnainjector/anticlever
	name = "\improper DNA injector (Anti-Clever)"
	remove_mutations = list(/datum/mutation/clever)
