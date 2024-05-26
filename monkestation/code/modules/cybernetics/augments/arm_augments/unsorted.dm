/obj/item/organ/internal/cyberimp/arm/muscle
	name = "\proper Strong-Arm empowered musculature implant"
	desc = "When implanted, this cybernetic implant will enhance the muscles of the arm to deliver more power-per-action."
	icon_state = "muscle_implant"

	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_ARM_AUG

	actions_types = list()

	///The amount of damage dealt by the empowered attack.
	var/punch_damage = 13
	///IF true, the throw attack will not smash people into walls
	var/non_harmful_throw = TRUE
	///How far away your attack will throw your oponent
	var/attack_throw_range = 1
	///Minimum throw power of the attack
	var/throw_power_min = 1
	///Maximum throw power of the attack
	var/throw_power_max = 4
	///How long will the implant malfunction if it is EMP'd
	var/emp_base_duration = 9 SECONDS

/obj/item/organ/internal/cyberimp/arm/muscle/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(ishuman(reciever)) //Sorry, only humans
		RegisterSignal(reciever, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/obj/item/organ/internal/cyberimp/arm/muscle/Remove(mob/living/carbon/implant_owner, special = 0)
	. = ..()
	UnregisterSignal(implant_owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/organ/internal/cyberimp/arm/muscle/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	owner.balloon_alert(owner, "your arm spasms wildly!")
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/arm/muscle/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	owner.balloon_alert(owner, "your arm stops spasming!")

/obj/item/organ/internal/cyberimp/arm/muscle/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(source.get_active_hand() != source.get_bodypart(check_zone(zone)) || !proximity)
		return
	if(!(source.istate & ISTATE_HARM) || (source.istate & ISTATE_SECONDARY))
		return
	if(!isliving(target))
		return
	var/datum/dna/dna = source.has_dna()
	if(dna?.check_mutation(/datum/mutation/human/hulk)) //NO HULK
		return

	var/mob/living/living_target = target

	source.changeNext_move(CLICK_CD_MELEE)
	var/picked_hit_type = pick("punch", "smash", "kick")

	if(organ_flags & ORGAN_FAILING)
		if(source.body_position != LYING_DOWN && living_target != source && prob(50))
			to_chat(source, span_danger("You try to [picked_hit_type] [living_target], but lose your balance and fall!"))
			source.Knockdown(3 SECONDS)
			source.forceMove(get_turf(living_target))
		else
			to_chat(source, span_danger("Your muscles spasm!"))
			source.Paralyze(1 SECONDS)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.check_shields(source, punch_damage, "[source]'s' [picked_hit_type]"))
			source.do_attack_animation(target)
			playsound(living_target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			log_combat(source, target, "attempted to [picked_hit_type]", "muscle implant")
			return COMPONENT_CANCEL_ATTACK_CHAIN

	source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(living_target.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

	living_target.apply_damage(punch_damage, BRUTE)

	if(source.body_position != LYING_DOWN) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(living_target, source.dir)
		living_target.throw_at(throw_target, attack_throw_range, rand(throw_power_min,throw_power_max), source, gentle = non_harmful_throw)

	living_target.visible_message(
		span_danger("[source] [picked_hit_type]ed [living_target]!"),
		span_userdanger("You're [picked_hit_type]ed by [source]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		source,
	)

	to_chat(source, span_danger("You [picked_hit_type] [target]!"))

	log_combat(source, target, "[picked_hit_type]ed", "muscle implant")

	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/organ/internal/cyberimp/arm/ammo_counter
	name = "S.M.A.R.T. ammo logistics system"
	desc = "Special inhand implant that allows transmits the current ammo and energy data straight to the user's visual cortex."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#750137"
	encode_info = AUGMENT_NT_HIGHLEVEL

	var/atom/movable/screen/cybernetics/ammo_counter/counter_ref
	var/obj/item/gun/our_gun

/obj/item/organ/internal/cyberimp/arm/ammo_counter/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	RegisterSignal(M,COMSIG_CARBON_ITEM_PICKED_UP, PROC_REF(add_to_hand))
	RegisterSignal(M,COMSIG_CARBON_ITEM_DROPPED, PROC_REF(remove_from_hand))

/obj/item/organ/internal/cyberimp/arm/ammo_counter/Remove(mob/living/carbon/M, special)
	. = ..()
	UnregisterSignal(M,COMSIG_CARBON_ITEM_PICKED_UP)
	UnregisterSignal(M,COMSIG_CARBON_ITEM_DROPPED)
	our_gun = null
	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/update_implants()
	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/proc/update_hud_elements()
	SIGNAL_HANDLER
	if(!owner || !owner?.hud_used)
		return

	if(!check_compatibility())
		return

	var/datum/hud/H = owner.hud_used

	if(!our_gun)
		if(!H.cybernetics_ammo[zone])
			return
		H.cybernetics_ammo[zone] = null

		counter_ref.hud = null
		H.infodisplay -= counter_ref
		H.mymob.client.screen -= counter_ref
		QDEL_NULL(counter_ref)
		return

	if(!H.cybernetics_ammo[zone])
		counter_ref = new()
		counter_ref.screen_loc =  zone == BODY_ZONE_L_ARM ? ui_hand_position(1,1,9) : ui_hand_position(2,1,9)
		H.cybernetics_ammo[zone] = counter_ref
		counter_ref.hud = H
		H.infodisplay += counter_ref
		H.mymob.client.screen += counter_ref

	var/display
	if(istype(our_gun,/obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/balgun = our_gun
		display = balgun.magazine.ammo_count(FALSE)
	else
		var/obj/item/gun/energy/egun = our_gun
		var/obj/item/ammo_casing/energy/shot = egun.ammo_type[egun.select]
		display = FLOOR(egun.cell.charge / shot.e_cost,1)
	counter_ref.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='white'>[display]</font></div>")

/obj/item/organ/internal/cyberimp/arm/ammo_counter/proc/add_to_hand(datum/source,obj/item/maybegun)
	SIGNAL_HANDLER

	var/obj/item/bodypart/bp = owner.get_active_hand()

	if(bp.body_zone != zone)
		return

	if(istype(maybegun,/obj/item/gun/ballistic))
		our_gun = maybegun
		RegisterSignal(owner,COMSIG_MOB_FIRED_GUN, PROC_REF(update_hud_elements))

	if(istype(maybegun,/obj/item/gun/energy))
		var/obj/item/gun/energy/egun = maybegun
		our_gun = egun
		RegisterSignal(egun.cell,COMSIG_CELL_CHANGE_POWER, PROC_REF(update_hud_elements))

	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/proc/remove_from_hand(datum/source,obj/item/maybegun)
	SIGNAL_HANDLER

	if(our_gun != maybegun)
		return

	if(istype(maybegun,/obj/item/gun/ballistic))
		UnregisterSignal(owner,COMSIG_MOB_FIRED_GUN)

	if(istype(maybegun,/obj/item/gun/energy))
		var/obj/item/gun/energy/egun = maybegun
		UnregisterSignal(egun.cell,COMSIG_CELL_CHANGE_POWER)


	our_gun = null
	update_hud_elements()

/obj/item/organ/internal/cyberimp/arm/ammo_counter/syndicate
	encode_info = AUGMENT_SYNDICATE_LEVEL

/obj/item/organ/internal/cyberimp/arm/cooler
	name = "sub-dermal cooling implant"
	desc = "Special inhand implant that cools you down if overheated."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#00e1ff"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/cooler/on_life()
	. = ..()
	if(!check_compatibility())
		return
	var/amt = BODYTEMP_NORMAL - owner.get_body_temp_normal()
	if(amt == 0)
		return
	owner.add_body_temperature_change("dermal_cooler_[zone]",clamp(amt,-1,0))

/obj/item/organ/internal/cyberimp/arm/cooler/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.remove_body_temperature_change("dermal_cooler_[zone]")

/obj/item/organ/internal/cyberimp/arm/heater
	name = "sub-dermal heater implant"
	desc = "Special inhand implant that heats you up if overcooled."
	icon = 'monkestation/code/modules/cybernetics/icons/surgery.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#ff9100"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/heater/on_life()
	. = ..()
	if(!check_compatibility())
		return
	var/amt = BODYTEMP_NORMAL - owner.get_body_temp_normal()
	if(amt == 0)
		return
	owner.add_body_temperature_change("dermal_heater_[zone]",clamp(amt,0,1))

/obj/item/organ/internal/cyberimp/arm/heater/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.remove_body_temperature_change("dermal_heater_[zone]")
