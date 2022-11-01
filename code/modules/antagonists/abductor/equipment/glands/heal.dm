/obj/item/organ/internal/heart/gland/heal
	abductor_hint = "organic replicator. Forcibly ejects damaged and robotic organs from the abductee and regenerates them. Additionally, forcibly removes reagents (via vomit) from the abductee if they have moderate toxin damage or poison within the bloodstream, and regenerates blood to a healthy threshold if too low. The abductee will also reject implants such as mindshields."
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	human_only = TRUE
	icon_state = "health"
	mind_control_uses = 3
	mind_control_duration = 3000

/obj/item/organ/internal/heart/gland/heal/activate()
	if(!(owner.mob_biotypes & MOB_ORGANIC))
		return

	for(var/implant in owner.implants)
		reject_implant(implant)
		return

	for(var/organ in owner.internal_organs)
		if(istype(organ, /obj/item/organ/internal/cyberimp))
			reject_cyberimp(organ)
			return

	var/obj/item/organ/internal/appendix/appendix = owner.getorganslot(ORGAN_SLOT_APPENDIX)
	if((!appendix && !HAS_TRAIT(owner, TRAIT_NOHUNGER)) || (appendix && ((appendix.organ_flags & ORGAN_FAILING) || (appendix.organ_flags & ORGAN_SYNTHETIC))))
		replace_appendix(appendix)
		return

	var/obj/item/organ/internal/liver/liver = owner.getorganslot(ORGAN_SLOT_LIVER)
	if((!liver && !HAS_TRAIT(owner, TRAIT_NOMETABOLISM)) || (liver && ((liver.damage > liver.high_threshold) || (liver.organ_flags & ORGAN_SYNTHETIC))))
		replace_liver(liver)
		return

	var/obj/item/organ/internal/lungs/lungs = owner.getorganslot(ORGAN_SLOT_LUNGS)
	if((!lungs && !HAS_TRAIT(owner, TRAIT_NOBREATH)) || (lungs && ((lungs.damage > lungs.high_threshold) || (lungs.organ_flags & ORGAN_SYNTHETIC))))
		replace_lungs(lungs)
		return

	var/obj/item/organ/internal/stomach/stomach = owner.getorganslot(ORGAN_SLOT_STOMACH)
	if((!stomach && !HAS_TRAIT(owner, TRAIT_NOHUNGER)) || (stomach && ((stomach.damage > stomach.high_threshold) || (stomach.organ_flags & ORGAN_SYNTHETIC))))
		replace_stomach(stomach)
		return

	var/obj/item/organ/internal/eyes/eyes = owner.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes || (eyes && ((eyes.damage > eyes.low_threshold) || (eyes.organ_flags & ORGAN_SYNTHETIC))))
		replace_eyes(eyes)
		return

	var/obj/item/bodypart/limb
	var/list/limb_list = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	for(var/zone in limb_list)
		limb = owner.get_bodypart(zone)
		if(!limb)
			replace_limb(zone)
			return
		if((limb.get_damage() >= (limb.max_damage / 2)) || (!IS_ORGANIC_LIMB(limb)))
			replace_limb(zone, limb)
			return

	if(owner.getToxLoss() > 40)
		replace_blood()
		return
	var/tox_amount = 0
	for(var/datum/reagent/toxin/T in owner.reagents.reagent_list)
		tox_amount += owner.reagents.get_reagent_amount(T.type)
	if(tox_amount > 10)
		replace_blood()
		return
	if(owner.blood_volume < BLOOD_VOLUME_OKAY)
		owner.blood_volume = BLOOD_VOLUME_NORMAL
		to_chat(owner, span_warning("You feel your blood pulsing within you."))
		return

	var/obj/item/bodypart/chest/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	if((chest.get_damage() >= (chest.max_damage / 4)) || (!IS_ORGANIC_LIMB(chest)))
		replace_chest(chest)
		return

/obj/item/organ/internal/heart/gland/heal/proc/reject_implant(obj/item/implant/implant)
	owner.visible_message(span_warning("[owner] vomits up a tiny mangled implant!"), span_userdanger("You suddenly vomit up a tiny mangled implant!"))
	owner.vomit(0, TRUE, TRUE, 1, FALSE, FALSE, FALSE, TRUE)
	implant.removed(owner)
	qdel(implant)

/obj/item/organ/internal/heart/gland/heal/proc/reject_cyberimp(obj/item/organ/internal/cyberimp/implant)
	owner.visible_message(span_warning("[owner] vomits up his [implant.name]!"), span_userdanger("You suddenly vomit up your [implant.name]!"))
	owner.vomit(0, TRUE, TRUE, 1, FALSE, FALSE, FALSE, TRUE)
	implant.Remove(owner)
	implant.forceMove(owner.drop_location())

/obj/item/organ/internal/heart/gland/heal/proc/replace_appendix(obj/item/organ/internal/appendix/appendix)
	if(appendix)
		owner.vomit(0, TRUE, TRUE, 1, FALSE, FALSE, FALSE, TRUE)
		appendix.Remove(owner)
		appendix.forceMove(owner.drop_location())
		owner.visible_message(span_warning("[owner] vomits up his [appendix.name]!"), span_userdanger("You suddenly vomit up your [appendix.name]!"))
	else
		to_chat(owner, span_warning("You feel a weird rumble in your bowels..."))

	var/appendix_type = /obj/item/organ/internal/appendix
	if(owner?.dna?.species?.mutantappendix)
		appendix_type = owner.dna.species.mutantappendix
	var/obj/item/organ/internal/appendix/new_appendix = new appendix_type()
	new_appendix.Insert(owner)

/obj/item/organ/internal/heart/gland/heal/proc/replace_liver(obj/item/organ/internal/liver/liver)
	if(liver)
		owner.visible_message(span_warning("[owner] vomits up his [liver.name]!"), span_userdanger("You suddenly vomit up your [liver.name]!"))
		owner.vomit(0, TRUE, TRUE, 1, FALSE, FALSE, FALSE, TRUE)
		liver.Remove(owner)
		liver.forceMove(owner.drop_location())
	else
		to_chat(owner, span_warning("You feel a weird rumble in your bowels..."))

	var/liver_type = /obj/item/organ/internal/liver
	if(owner?.dna?.species?.mutantliver)
		liver_type = owner.dna.species.mutantliver
	var/obj/item/organ/internal/liver/new_liver = new liver_type()
	new_liver.Insert(owner)

/obj/item/organ/internal/heart/gland/heal/proc/replace_lungs(obj/item/organ/internal/lungs/lungs)
	if(lungs)
		owner.visible_message(span_warning("[owner] vomits up his [lungs.name]!"), span_userdanger("You suddenly vomit up your [lungs.name]!"))
		owner.vomit(0, TRUE, TRUE, 1, FALSE, FALSE, FALSE, TRUE)
		lungs.Remove(owner)
		lungs.forceMove(owner.drop_location())
	else
		to_chat(owner, span_warning("You feel a weird rumble inside your chest..."))

	var/lung_type = /obj/item/organ/internal/lungs
	if(owner.dna.species && owner.dna.species.mutantlungs)
		lung_type = owner.dna.species.mutantlungs
	var/obj/item/organ/internal/lungs/new_lungs = new lung_type()
	new_lungs.Insert(owner)

/obj/item/organ/internal/heart/gland/heal/proc/replace_stomach(obj/item/organ/internal/stomach/stomach)
	if(stomach)
		owner.visible_message(span_warning("[owner] vomits up his [stomach.name]!"), span_userdanger("You suddenly vomit up your [stomach.name]!"))
		owner.vomit(0, TRUE, TRUE, 1, FALSE, FALSE, FALSE, TRUE)
		stomach.Remove(owner)
		stomach.forceMove(owner.drop_location())
	else
		to_chat(owner, span_warning("You feel a weird rumble in your bowels..."))

	var/stomach_type = /obj/item/organ/internal/stomach
	if(owner?.dna?.species?.mutantstomach)
		stomach_type = owner.dna.species.mutantstomach
	var/obj/item/organ/internal/stomach/new_stomach = new stomach_type()
	new_stomach.Insert(owner)

/obj/item/organ/internal/heart/gland/heal/proc/replace_eyes(obj/item/organ/internal/eyes/eyes)
	if(eyes)
		owner.visible_message(span_warning("[owner]'s [eyes.name] fall out of their sockets!"), span_userdanger("Your [eyes.name] fall out of their sockets!"))
		playsound(owner, 'sound/effects/splat.ogg', 50, TRUE)
		eyes.Remove(owner)
		eyes.forceMove(owner.drop_location())
	else
		to_chat(owner, span_warning("You feel a weird rumble behind your eye sockets..."))

	addtimer(CALLBACK(src, PROC_REF(finish_replace_eyes)), rand(100, 200))

/obj/item/organ/internal/heart/gland/heal/proc/finish_replace_eyes()
	var/eye_type = /obj/item/organ/internal/eyes
	if(owner.dna.species && owner.dna.species.mutanteyes)
		eye_type = owner.dna.species.mutanteyes
	var/obj/item/organ/internal/eyes/new_eyes = new eye_type()
	new_eyes.Insert(owner)
	owner.visible_message(span_warning("A pair of new eyes suddenly inflates into [owner]'s eye sockets!"), span_userdanger("A pair of new eyes suddenly inflates into your eye sockets!"))

/obj/item/organ/internal/heart/gland/heal/proc/replace_limb(body_zone, obj/item/bodypart/limb)
	if(limb)
		owner.visible_message(span_warning("[owner]'s [limb.plaintext_zone] suddenly detaches from [owner.p_their()] body!"), span_userdanger("Your [limb.plaintext_zone] suddenly detaches from your body!"))
		playsound(owner, SFX_DESECRATION, 50, TRUE, -1)
		limb.drop_limb()
	else
		to_chat(owner, span_warning("You feel a weird tingle in your [parse_zone(body_zone)]... even if you don't have one."))

	addtimer(CALLBACK(src, PROC_REF(finish_replace_limb), body_zone), rand(150, 300))

/obj/item/organ/internal/heart/gland/heal/proc/finish_replace_limb(body_zone)
	owner.visible_message(span_warning("With a loud snap, [owner]'s [parse_zone(body_zone)] rapidly grows back from [owner.p_their()] body!"),
	span_userdanger("With a loud snap, your [parse_zone(body_zone)] rapidly grows back from your body!"),
	span_warning("Your hear a loud snap."))
	playsound(owner, 'sound/magic/demon_consume.ogg', 50, TRUE)
	owner.regenerate_limb(body_zone)

/obj/item/organ/internal/heart/gland/heal/proc/replace_blood()
	owner.visible_message(span_warning("[owner] starts vomiting huge amounts of blood!"), span_userdanger("You suddenly start vomiting huge amounts of blood!"))
	keep_replacing_blood()

/obj/item/organ/internal/heart/gland/heal/proc/keep_replacing_blood()
	var/keep_going = FALSE
	owner.vomit(0, TRUE, FALSE, 3, FALSE, FALSE, FALSE, TRUE)
	owner.Stun(15)
	owner.adjustToxLoss(-15, TRUE, TRUE)

	owner.blood_volume = min(BLOOD_VOLUME_NORMAL, owner.blood_volume + 20)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		keep_going = TRUE

	if(owner.getToxLoss())
		keep_going = TRUE
	for(var/datum/reagent/toxin/R in owner.reagents.reagent_list)
		owner.reagents.remove_reagent(R.type, 4)
		if(owner.reagents.has_reagent(R.type))
			keep_going = TRUE
	if(keep_going)
		addtimer(CALLBACK(src, PROC_REF(keep_replacing_blood)), 30)

/obj/item/organ/internal/heart/gland/heal/proc/replace_chest(obj/item/bodypart/chest/chest)
	if(!IS_ORGANIC_LIMB(chest))
		owner.visible_message(span_warning("[owner]'s [chest.name] rapidly expels its mechanical components, replacing them with flesh!"), span_userdanger("Your [chest.name] rapidly expels its mechanical components, replacing them with flesh!"))
		playsound(owner, 'sound/magic/clockwork/anima_fragment_attack.ogg', 50, TRUE)
		var/list/dirs = GLOB.alldirs.Copy()
		for(var/i in 1 to 3)
			var/obj/effect/decal/cleanable/robot_debris/debris = new(get_turf(owner))
			debris.streak(dirs)
	else
		owner.visible_message(span_warning("[owner]'s [chest.name] sheds off its damaged flesh, rapidly replacing it!"), span_warning("Your [chest.name] sheds off its damaged flesh, rapidly replacing it!"))
		playsound(owner, 'sound/effects/splat.ogg', 50, TRUE)
		var/list/dirs = GLOB.alldirs.Copy()
		for(var/i in 1 to 3)
			var/obj/effect/decal/cleanable/blood/gibs/gibs = new(get_turf(owner))
			gibs.streak(dirs)

	var/obj/item/bodypart/chest/new_chest = new(null)
	new_chest.replace_limb(owner, TRUE)
	qdel(chest)
