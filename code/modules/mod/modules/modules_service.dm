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
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_energy_cost)

///Advanced Balloon Blower - Blows a long balloon.
/obj/item/mod/module/balloon_advanced
	name = "MOD advanced balloon blower module"
	desc = "A relatively new piece of technology developed by finest clown engineers to make long balloons and balloon animals \
	at party-appropriate rate."
	icon_state = "bloon"
	module_type = MODULE_USABLE
	complexity = 1
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/balloon_advanced)
	cooldown_time = 15 SECONDS

/obj/item/mod/module/balloon_advanced/on_use()
	. = ..()
	if(!.)
		return
	if(!do_after(mod.wearer, 15 SECONDS, target = mod))
		return FALSE
	mod.wearer.adjustOxyLoss(20)
	playsound(src, 'sound/items/modsuit/inflate_bloon.ogg', 50, TRUE)
	var/obj/item/toy/balloon/long/l_balloon = new(get_turf(src))
	mod.wearer.put_in_hands(l_balloon)
	drain_power(use_energy_cost)


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
	incompatible_modules = list(/obj/item/mod/module/microwave_beam, /obj/item/mod/module/organ_thrower)
	cooldown_time = 10 SECONDS

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
		utilizing its' sensitivity to the pilot's often-limited brainwaves to directly read their next step, \
		affecting the boots they're installed in. Employing a twin-linked gravitonic drive to create \
		miniaturized etheric blasts of space-time beneath the user's feet, this enables them to... \
		to waddle around, bouncing to and fro with a pep in their step."
	icon_state = "waddle"
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/waddle)

/obj/item/mod/module/waddle/on_suit_activation()
	mod.boots.AddComponent(/datum/component/squeak, list('sound/effects/footstep/clownstep1.ogg'=1,'sound/effects/footstep/clownstep2.ogg'=1), 50, falloff_exponent = 20) //die off quick please
	mod.wearer.AddElementTrait(TRAIT_WADDLING, MOD_TRAIT, /datum/element/waddling)
	if(is_clown_job(mod.wearer.mind?.assigned_role))
		mod.wearer.add_mood_event("clownshoes", /datum/mood_event/clownshoes)

/obj/item/mod/module/waddle/on_suit_deactivation(deleting = FALSE)
	if(!deleting)
		qdel(mod.boots.GetComponent(/datum/component/squeak))
	REMOVE_TRAIT(mod.wearer, TRAIT_WADDLING, MOD_TRAIT)
	if(is_clown_job(mod.wearer.mind?.assigned_role))
		mod.wearer.clear_mood_event("clownshoes")
