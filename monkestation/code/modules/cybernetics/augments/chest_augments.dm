/obj/item/organ/internal/cyberimp/chest
	name = "chest-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_CHEST
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	w_class = WEIGHT_CLASS_SMALL
	encode_info = AUGMENT_NT_LOWLEVEL
	implant_overlay = "chest_implant_overlay"
	slot = ORGAN_SLOT_SPINAL
	var/double_legged = FALSE

/datum/action/item_action/organ_action/sandy
	name = "Sandevistan Activation"

/obj/item/organ/internal/cyberimp/chest/sandevistan
	name = "Militech Apogee Sandevistan"
	desc = "This model of Sandevistan doesn't exist, at least officially. Off the record, there's gossip of secret Militech Lunar labs producing covert cyberware. It was never meant to be mass produced, but an army would only really need a few pieces like this one to dominate their enemy."
	encode_info = AUGMENT_SYNDICATE_LEVEL
	icon_state = "sandy"
	actions_types = list(/datum/action/item_action/organ_action/sandy)
	icon = 'monkestation/code/modules/cybernetics/icons/implants.dmi'

	COOLDOWN_DECLARE(in_the_zone)
	/// The bodypart overlay datum we should apply to whatever mob we are put into
	visual_implant = TRUE
	bodypart_overlay = /datum/bodypart_overlay/simple/sandy
	var/cooldown_time = 45 SECONDS

/obj/item/organ/internal/cyberimp/chest/sandevistan/ui_action_click()
	if(!check_compatibility())
		return

	if((organ_flags & ORGAN_FAILING))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	if(!COOLDOWN_FINISHED(src, in_the_zone))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be recharging..."))
		return
	COOLDOWN_START(src, in_the_zone, cooldown_time)

	owner.AddComponent(/datum/component/after_image, 16, 0.5, TRUE)
	owner.AddComponent(/datum/component/slowing_field, 0.1, 5, 3)
	addtimer(CALLBACK(src, PROC_REF(exit_the_zone), owner), 15 SECONDS)


/obj/item/organ/internal/cyberimp/chest/sandevistan/proc/exit_the_zone(mob/living/exiter)
	var/datum/component/after_image = exiter.GetComponent(/datum/component/after_image)
	qdel(after_image)
	var/datum/component/slowing_field = exiter.GetComponent(/datum/component/slowing_field)
	qdel(slowing_field)

/datum/bodypart_overlay/simple/sandy
	icon = 'monkestation/code/modules/cybernetics/icons/implants.dmi'
	icon_state = "sandy_overlay"
	layers = EXTERNAL_ADJACENT


/obj/item/organ/internal/cyberimp/chest/sandevistan/refurbished
	name = "refurbished sandevistan"
	desc = "The branding has been scratched off of these and it looks hastily put together."

	cooldown_time = 65 SECONDS

/obj/item/organ/internal/cyberimp/chest/sandevistan/refurbished/ui_action_click(mob/user, actiontype)
	if(prob(45))
		if(iscarbon(user))
			var/mob/living/carbon/carbon = user
			carbon.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
			to_chat(user, span_warning("You are overloaded with information and suffer some backlash."))
	. = ..()

/obj/item/organ/internal/cyberimp/chest/sandevistan/refurbished/exit_the_zone(mob/living/exiter)
	. = ..()
	exiter.adjustBruteLoss(10)
	to_chat(exiter, span_warning("Your body was not able to handle the strain of [src] causing you to experience some minor bruising."))


/datum/reagent/medicine/brain_healer
	name = "Brain Healer"
	description = "Efficiently restores brain damage."
	taste_description = "pleasant sweetness"
	color = "#A0A0A0" //mannitol is light grey, neurine is lighter grey
	ph = 10.4
	purity = REAGENT_STANDARD_PURITY


/datum/reagent/medicine/brain_healer/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	affected_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -5 * REM * seconds_per_tick * normalise_creation_purity(), required_organtype = affected_organtype)
	..()


/obj/item/organ/internal/cyberimp/chest/chemvat
	name = "R.A.G.E. chemical system"
	desc = "Extremely dangerous system that fills the user with a mix of potent drugs."
	encode_info = AUGMENT_SYNDICATE_LEVEL
	icon_state = "chemvat_back_held"
	icon = 'monkestation/code/modules/cybernetics/icons/implants_onmob.dmi'

	var/obj/item/clothing/mask/chemvat/forced
	var/obj/item/chemvat_tank/forced_tank

	var/max_ticks_cooldown = 20 SECONDS
	var/current_ticks_cooldown = 0

	var/list/reagent_list = list(
		/datum/reagent/determination = 2,
		/datum/reagent/medicine/c2/penthrite = 3 ,
		/datum/reagent/drug/bath_salts = 3 ,
		/datum/reagent/medicine/omnizine = 3,
		/datum/reagent/medicine/brain_healer = 5,
	)

	var/mutable_appearance/overlay

/obj/item/organ/internal/cyberimp/chest/chemvat/on_life()
	if(!check_compatibility())
		return
		//Cost of refilling is a little bit of nutrition, some blood and getting jittery
	if(owner.nutrition > NUTRITION_LEVEL_STARVING && owner.blood_volume > BLOOD_VOLUME_SURVIVE && current_ticks_cooldown > 0)

		owner.nutrition -= 5
		owner.blood_volume--
		owner.adjust_jitter(1)
		owner.adjust_dizzy(1)

		current_ticks_cooldown -= SSmobs.wait

		return

	if(current_ticks_cooldown <= 0)
		current_ticks_cooldown = max_ticks_cooldown
		on_effect()

/obj/item/organ/internal/cyberimp/chest/chemvat/proc/on_effect()
	var/obj/effect/temp_visual/chempunk/punk = new /obj/effect/temp_visual/chempunk(get_turf(owner))
	punk.color = "#77BD5D"
	owner.reagents.add_reagent_list(reagent_list)

	overlay = mutable_appearance('icons/effects/effects.dmi', "biogas", ABOVE_MOB_LAYER)
	overlay.color = "#77BD5D"

	RegisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))

	addtimer(CALLBACK(src, PROC_REF(remove_overlay)),max_ticks_cooldown/2)

	to_chat(owner,"<span class = 'notice'> You feel a sharp pain as the cocktail of chemicals is injected into your bloodstream!</span>")
	return


/obj/item/organ/internal/cyberimp/chest/chemvat/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(overlay)
		overlays += overlay

/obj/item/organ/internal/cyberimp/chest/chemvat/proc/remove_overlay()
	QDEL_NULL(overlay)

	UnregisterSignal(owner,COMSIG_ATOM_UPDATE_OVERLAYS)

/obj/item/organ/internal/cyberimp/chest/chemvat/Insert(mob/living/carbon/receiver, special, drop_if_replaced)
	. = ..()
	forced = new
	forced_tank = new

	if(receiver.wear_mask && !istype(receiver.wear_mask,/obj/item/clothing/mask/chemvat))
		receiver.dropItemToGround(receiver.wear_mask, TRUE)
		receiver.equip_to_slot(forced, ITEM_SLOT_MASK)
	if(!receiver.wear_mask)
		receiver.equip_to_slot(forced, ITEM_SLOT_MASK)

	if(receiver.back && !istype(receiver.back,/obj/item/chemvat_tank))
		receiver.dropItemToGround(receiver.back, TRUE)
		receiver.equip_to_slot(forced_tank, ITEM_SLOT_BACK)
	if(!receiver.back)
		receiver.equip_to_slot(forced_tank, ITEM_SLOT_BACK)

/obj/item/organ/internal/cyberimp/chest/chemvat/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	organ_owner.dropItemToGround(organ_owner.wear_mask, TRUE)
	organ_owner.dropItemToGround(organ_owner.back, TRUE)
	QDEL_NULL(forced)
	QDEL_NULL(forced_tank)

/obj/item/chemvat_tank
	name = "chemvat tank"

	icon_state = "chemvat_back_held"
	icon = 'monkestation/code/modules/cybernetics/icons/implants_onmob.dmi'
	worn_icon = 'monkestation/code/modules/cybernetics/icons/implants_onmob.dmi'
	worn_icon_state = "chemvat_back"

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/chemvat_tank/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)


/obj/item/clothing/mask/chemvat
	icon_state = "chemvat_mask_held"
	icon = 'monkestation/code/modules/cybernetics/icons/implants_onmob.dmi'
	worn_icon = 'monkestation/code/modules/cybernetics/icons/implants_onmob.dmi'
	worn_icon_state = "chemvat_mask"
	lefthand_file = null
	righthand_file = null

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/mask/chemvat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = ORGAN_SLOT_STOMACH_AID
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/chest/nutriment/on_life(seconds_per_tick, times_fired)
	if(!check_compatibility())
		return

	if(synthesizing)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = TRUE
		to_chat(owner, span_notice("You feel less hungry..."))
		owner.adjust_nutrition(25 * seconds_per_tick)
		addtimer(CALLBACK(src, PROC_REF(synth_cool)), 50)

/obj/item/organ/internal/cyberimp/chest/nutriment/proc/synth_cool()
	synthesizing = FALSE

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.reagents.add_reagent(/datum/reagent/toxin/bad_food, poison_amount / severity)
	to_chat(owner, span_warning("You feel like your insides are burning."))


/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10

/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	slot = ORGAN_SLOT_HEART_AID
	encode_info = AUGMENT_NT_HIGHLEVEL
	var/revive_cost = 0
	var/reviving = FALSE
	COOLDOWN_DECLARE(reviver_cooldown)
	COOLDOWN_DECLARE(defib_cooldown)

/obj/item/organ/internal/cyberimp/chest/reviver/on_death(seconds_per_tick, times_fired)
	if(isnull(owner)) // owner can be null, on_death() gets called by /obj/item/organ/internal/process() for decay
		return
	try_heal() // Allows implant to work even on dead people

/obj/item/organ/internal/cyberimp/chest/reviver/on_life(seconds_per_tick, times_fired)
	try_heal()

/obj/item/organ/internal/cyberimp/chest/reviver/proc/try_heal()
	if(reviving)
		if(owner.stat == CONSCIOUS)
			COOLDOWN_START(src, reviver_cooldown, revive_cost)
			reviving = FALSE
			to_chat(owner, span_notice("Your reviver implant shuts down and starts recharging. It will be ready again in [DisplayTimeText(revive_cost)]."))
		else
			addtimer(CALLBACK(src, PROC_REF(heal)), 3 SECONDS)
		return

	if(!COOLDOWN_FINISHED(src, reviver_cooldown) || HAS_TRAIT(owner, TRAIT_SUICIDED))
		return

	if(owner.stat != CONSCIOUS)
		revive_cost = 0
		reviving = TRUE
		to_chat(owner, span_notice("You feel a faint buzzing as your reviver implant starts patching your wounds..."))
		COOLDOWN_START(src, defib_cooldown, 8 SECONDS) // 5 seconds after heal proc delay


/obj/item/organ/internal/cyberimp/chest/reviver/proc/heal()
	if(COOLDOWN_FINISHED(src, defib_cooldown))
		revive_dead()

	/// boolean that stands for if PHYSICAL damage being patched
	var/body_damage_patched = FALSE
	var/need_mob_update = FALSE
	if(owner.getOxyLoss())
		need_mob_update += owner.adjustOxyLoss(-5, updating_health = FALSE)
		revive_cost += 5
	if(owner.getBruteLoss())
		need_mob_update += owner.adjustBruteLoss(-2, updating_health = FALSE)
		revive_cost += 40
		body_damage_patched = TRUE
	if(owner.getFireLoss())
		need_mob_update += owner.adjustFireLoss(-2, updating_health = FALSE)
		revive_cost += 40
		body_damage_patched = TRUE
	if(owner.getToxLoss())
		need_mob_update += owner.adjustToxLoss(-1, updating_health = FALSE)
		revive_cost += 40
	if(need_mob_update)
		owner.updatehealth()

	if(body_damage_patched && prob(35)) // healing is called every few seconds, not every tick
		owner.visible_message(span_warning("[owner]'s body twitches a bit."), span_notice("You feel like something is patching your injured body."))


/obj/item/organ/internal/cyberimp/chest/reviver/proc/revive_dead()
	if(!check_compatibility())
		return
	if(!COOLDOWN_FINISHED(src, defib_cooldown) || owner.stat != DEAD || owner.can_defib() != DEFIB_POSSIBLE)
		return
	owner.notify_ghost_cloning("You are being revived by [src]!")
	revive_cost += 10 MINUTES // Additional 10 minutes cooldown after revival.
	owner.grab_ghost()

	defib_cooldown += 16 SECONDS // delay so it doesn't spam

	owner.visible_message(span_warning("[owner]'s body convulses a bit."))
	playsound(owner, SFX_BODYFALL, 50, TRUE)
	playsound(owner, 'sound/machines/defib_zap.ogg', 75, TRUE, -1)
	owner.revive()
	owner.emote("gasp")
	owner.set_jitter_if_lower(200 SECONDS)
	SEND_SIGNAL(owner, COMSIG_LIVING_MINOR_SHOCK)
	log_game("[owner] been revived by [src]")


/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return

	if(reviving)
		revive_cost += 200
	else
		reviver_cooldown += 20 SECONDS

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		if(human_owner.stat != DEAD && prob(50 / severity) && human_owner.can_heartattack())
			human_owner.set_heartattack(TRUE)
			to_chat(human_owner, span_userdanger("You feel a horrible agony in your chest!"))
			addtimer(CALLBACK(src, PROC_REF(undo_heart_attack)), 600 / severity)

/obj/item/organ/internal/cyberimp/chest/reviver/proc/undo_heart_attack()
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return
	human_owner.set_heartattack(FALSE)
	if(human_owner.stat == CONSCIOUS)
		to_chat(human_owner, span_notice("You feel your heart beating again!"))


/obj/item/organ/internal/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpacks, this device has no stabilization system."
	slot = ORGAN_SLOT_THRUSTERS
	icon_state = "imp_jetpack"
	base_icon_state = "imp_jetpack"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = WEIGHT_CLASS_NORMAL

	encode_info = AUGMENT_NT_HIGHLEVEL
	var/on = FALSE
	var/datum/callback/get_mover
	var/datum/callback/check_on_move

/obj/item/organ/internal/cyberimp/chest/thrusters/Initialize(mapload)
	. = ..()
	get_mover = CALLBACK(src, PROC_REF(get_user))
	check_on_move = CALLBACK(src, PROC_REF(allow_thrust), 0.01)
	refresh_jetpack()

/obj/item/organ/internal/cyberimp/chest/thrusters/Destroy()
	get_mover = null
	check_on_move = null
	return ..()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/refresh_jetpack()
	AddComponent(/datum/component/jetpack, FALSE, COMSIG_THRUSTER_ACTIVATED, COMSIG_THRUSTER_DEACTIVATED, THRUSTER_ACTIVATION_FAILED, get_mover, check_on_move, /datum/effect_system/trail_follow/ion)

/obj/item/organ/internal/cyberimp/chest/thrusters/Remove(mob/living/carbon/thruster_owner, special = 0)
	if(on)
		deactivate(silent = TRUE)
	..()

/obj/item/organ/internal/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/toggle(silent = FALSE)
	if(!check_compatibility())
		return
	if(on)
		deactivate()
	else
		activate()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/activate(silent = FALSE)
	if(on)
		return
	if(organ_flags & ORGAN_FAILING)
		if(!silent)
			to_chat(owner, span_warning("Your thrusters set seems to be broken!"))
		return
	if(SEND_SIGNAL(src, COMSIG_THRUSTER_ACTIVATED) & THRUSTER_ACTIVATION_FAILED)
		return

	on = TRUE
	owner.add_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
	if(!silent)
		to_chat(owner, span_notice("You turn your thrusters set on."))
	update_appearance()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/deactivate(silent = FALSE)
	if(!on)
		return
	SEND_SIGNAL(src, COMSIG_THRUSTER_DEACTIVATED)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/jetpack/cybernetic)
	if(!silent)
		to_chat(owner, span_notice("You turn your thrusters set off."))
	on = FALSE
	update_appearance()

/obj/item/organ/internal/cyberimp/chest/thrusters/update_icon_state()
	icon_state = "[base_icon_state][on ? "-on" : null]"
	return ..()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/allow_thrust(num, use_fuel = TRUE)
	if(!owner)
		return FALSE

	var/turf/owner_turf = get_turf(owner)
	if(!owner_turf) // No more runtimes from being stuck in nullspace.
		return FALSE

	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = owner_turf.return_air()
	if(environment && environment.return_pressure() > 30)
		return TRUE

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num * 100)
		if(use_fuel)
			owner.adjustPlasma(-num * 100)
		return TRUE

	// Priority 3: use internals tank.
	var/datum/gas_mixture/internal_mix = owner.internal?.return_air()
	if(internal_mix && internal_mix.total_moles() > num)
		if(!use_fuel)
			return TRUE
		var/datum/gas_mixture/removed = internal_mix.remove(num)
		if(removed.total_moles() > 0.005)
			owner_turf.assume_air(removed)
			return TRUE
		else
			owner_turf.assume_air(removed)

	deactivate(silent = TRUE)
	return FALSE

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/get_user()
	return owner


/datum/action/item_action/organ_action/knockout
	name = "Knockout Punch"

/obj/item/organ/internal/cyberimp/chest/knockout
	name = "knockout chest implant"
	desc = "Knocks the socks of the person in front of you!"

	actions_types = list(/datum/action/item_action/organ_action/knockout)
	encode_info = AUGMENT_NT_LOWLEVEL

	COOLDOWN_DECLARE(shoot)

	var/cooldown_time = 60 SECONDS
	///the object we beam
	var/projectile = /obj/item/punching_glove
	///our fire sound
	var/fire_sound = 'sound/items/bikehorn.ogg'
	///do we do damage
	var/harmful = FALSE


/obj/item/organ/internal/cyberimp/chest/knockout/ui_action_click()
	if(!check_compatibility())
		return

	if((organ_flags & ORGAN_FAILING))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	if(!COOLDOWN_FINISHED(src, shoot))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be recharging..."))
		return
	COOLDOWN_START(src, shoot, cooldown_time)

	shoot_fist()


/obj/item/organ/internal/cyberimp/chest/knockout/proc/shoot_fist()
	var/turf/target = get_edge_target_turf(owner, owner.dir)
	var/obj/O = new projectile(owner.loc)
	playsound(owner, fire_sound, 50, TRUE)
	log_message("Launched a [O.name] from [owner], targeting [target].", LOG_ATTACK)

	if(harmful)
		O.throwforce = 35
	else
		O.throwforce = 0

	owner.visible_message(span_warning("[owner] shoots a [O] out of their chest."))
	owner.Beam(O, icon_state = "chain", time = 100, maxdistance = 7)
	O.throw_at(target, 5, 1.5, owner, FALSE, diagonals_first = TRUE)

	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		var/obj/item/item = human.wear_suit
		if(item)
			owner.dropItemToGround(human.wear_suit, TRUE)
			item.throw_at(target, 5, 1.5, owner, FALSE, diagonals_first = TRUE)

	owner.visible_message(span_notice("[owner] flies backwards falling on their ass."))
	var/newtonian_target = turn(owner.dir,180)
	owner.newtonian_move(newtonian_target)
	owner.SetKnockdown(1.5 SECONDS)

	return TRUE
