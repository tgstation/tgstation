//Service modules for MODsuits

///Bike Horn - Plays a bike horn sound.
/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "A shoulder-mounted piece of heavy sonic artillery, this module uses the finest femto-manipulator technology to \
		precisely deliver an almost lethal squeeze to... a bike horn, producing a significantly memorable sound."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/on_use()
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_energy_cost)

///Advanced Balloon Blower - Blows a long balloon.
/obj/item/mod/module/balloon/advanced
	name = "MOD advanced balloon blower module"
	desc = "A relatively new piece of technology developed by finest clown engineers to make long balloons and balloon animals \
		at party-appropriate rate."
	cooldown_time = 20 SECONDS
	balloon_path = /obj/item/toy/balloon/long
	blowing_time = 15 SECONDS

///Microwave Beam - Microwaves items instantly.
/obj/item/mod/module/microwave_beam
	name = "MOD microwave beam module"
	desc = "An oddly domestic device, this module is installed into the user's palm, \
		hooking up with culinary scanners located in the helmet to blast food with precise microwave radiation, \
		allowing them to cook food from a distance, with the greatest of ease. Not recommended for use against grapes."
	icon_state = "microwave_beam"
	module_type = MODULE_ACTIVE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/microwave_beam, /obj/item/mod/module/organizer)
	cooldown_time = 10 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/obj/item/mod/module/microwave_beam/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!isitem(target))
		return
	if(!isturf(target.loc))
		balloon_alert(mod.wearer, "must be on the floor!")
		return
	var/obj/item/microwave_target = target
	var/datum/effect_system/spark_spread/spark_effect = new()
	spark_effect.set_up(2, 1, mod.wearer)
	spark_effect.start()
	mod.wearer.Beam(target,icon_state="lightning[rand(1,12)]", time = 5)
	if(microwave_target.microwave_act(microwaver = mod.wearer) & COMPONENT_MICROWAVE_SUCCESS)
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, FALSE)
	else
		balloon_alert(mod.wearer, "can't be microwaved!")
	var/datum/effect_system/spark_spread/spark_effect_two = new()
	spark_effect_two.set_up(2, 1, microwave_target)
	spark_effect_two.start()
	drain_power(use_energy_cost)

//Waddle - Makes you waddle and squeak.
/obj/item/mod/module/waddle
	name = "MOD waddle module"
	desc = "Some of the most primitive technology in use by Honk Co. This module works off an automatic intention system, \
		utilizing its sensitivity to the pilot's often-limited brainwaves to directly read their next step, \
		affecting the boots they're installed in. Employing a twin-linked gravitonic drive to create \
		miniaturized etheric blasts of space-time beneath the user's feet, this enables them to... \
		to waddle around, bouncing to and fro with a pep in their step."
	icon_state = "waddle"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/waddle)
	required_slots = list(ITEM_SLOT_FEET)

/obj/item/mod/module/waddle/on_suit_activation()
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes)
		shoes.AddComponent(/datum/component/squeak, list('sound/effects/footstep/clownstep1.ogg'=1,'sound/effects/footstep/clownstep2.ogg'=1), 50, falloff_exponent = 20) //die off quick please
	mod.wearer.AddElementTrait(TRAIT_WADDLING, MOD_TRAIT, /datum/element/waddling)
	if(is_clown_job(mod.wearer.mind?.assigned_role))
		mod.wearer.add_mood_event("clownshoes", /datum/mood_event/clownshoes)

/obj/item/mod/module/waddle/on_suit_deactivation(deleting = FALSE)
	var/obj/item/shoes = mod.get_part_from_slot(ITEM_SLOT_FEET)
	if(shoes && !deleting)
		qdel(shoes.GetComponent(/datum/component/squeak))
	REMOVE_TRAIT(mod.wearer, TRAIT_WADDLING, MOD_TRAIT)
	if(is_clown_job(mod.wearer.mind?.assigned_role))
		mod.wearer.clear_mood_event("clownshoes")

/obj/item/mod/module/fishing_gloves
	name = "MOD fishing gloves module"
	desc = "A MOD module that takes in an external fishing rod to enable the user to fish without having to hold one."
	icon_state = "fishing_gloves"
	complexity = 1
	incompatible_modules = (/obj/item/mod/module/fishing_gloves)
	required_slots = list(ITEM_SLOT_GLOVES)
	var/obj/item/fishing_rod/equipped

/obj/item/mod/module/fishing_gloves/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/mod/module/fishing_gloves/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(!held_item && equipped)
		context[SCREENTIP_CONTEXT_RMB] = "Remove rod"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/fishing_rod))
		context[SCREENTIP_CONTEXT_LMB] = "Insert rod"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/mod/module/fishing_gloves/examine(mob/user)
	. = ..()
	if(equipped)
		. += span_info("it has a [icon2html(equipped, user)] installed. [EXAMINE_HINT("Right-Click")] to remove it.")

/obj/item/mod/module/fishing_gloves/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/fishing_rod))
		return ..()
	if(equipped)
		balloon_alert(user, "remove current rod first!")
	if(!user.transferItemToLoc(tool, src))
		user.balloon_alert(user, "it's stuck!")
	equipped = tool
	balloon_alert(user, "rod inserted")
	playsound(src, 'sound/items/click.ogg', 50, TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/mod/module/fishing_gloves/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!equipped)
		return
	user.put_in_hands(equipped)
	balloon_alert(user, "rod removed")
	playsound(src, 'sound/items/click.ogg', 50, TRUE)

/obj/item/mod/module/fishing_gloves/Exited(atom/movable/gone)
	if(gone == equipped)
		equipped = null
		var/obj/item/gloves = mod?.get_part_from_slot(ITEM_SLOT_GLOVES)
		if(gloves && !QDELETED(mod))
			qdel(gloves.GetComponent(/datum/component/profound_fisher))

/obj/item/mod/module/fishing_gloves/on_suit_activation()
	if(equipped)
	var/obj/item/gloves = mod.get_part_from_slot(ITEM_SLOT_GLOVES)
	if(gloves)
		gloves.AddComponent(/datum/component/profound_fisher, equipped)

/obj/item/mod/module/fishing_gloves/on_suit_deactivation(deleting = FALSE)
	var/obj/item/gloves = mod.get_part_from_slot(ITEM_SLOT_GLOVES)
	if(gloves && !deleting)
		qdel(gloves.GetComponent(/datum/component/profound_fisher))
