//Service modules for MODsuits

///Bike Horn - Plays a bike horn sound.
/obj/item/mod/module/bikehorn
	name = "MOD bike horn module"
	desc = "A shoulder-mounted piece of heavy sonic artillery, this module uses the finest femto-manipulator technology to \
		precisely deliver an almost lethal squeeze to... a bike horn, producing a significantly memorable sound."
	icon_state = "bikehorn"
	module_type = MODULE_USABLE
	complexity = 1
	use_power_cost = DEFAULT_CELL_DRAIN
	incompatible_modules = list(/obj/item/mod/module/bikehorn)
	cooldown_time = 1 SECONDS

/obj/item/mod/module/bikehorn/on_use()
	. = ..()
	if(!.)
		return
	playsound(src, 'sound/items/bikehorn.ogg', 100, FALSE)
	drain_power(use_power_cost)

///Microwave Beam - Microwaves items instantly.
/obj/item/mod/module/microwave_beam
	name = "MOD microwave beam module"
	desc = "An oddly domestic device, this module is installed into the user's palm, \
		hooking up with culinary scanners located in the helmet to blast food with precise microwave radiation, \
		allowing them to cook food from a distance, with the greatest of ease. Not recommended for use against grapes."
	icon_state = "microwave_beam"
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	incompatible_modules = list(/obj/item/mod/module/microwave_beam, /obj/item/mod/module/organ_thrower)
	cooldown_time = 10 SECONDS

/obj/item/mod/module/microwave_beam/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	if(!istype(target, /obj/item))
		return
	if(!isturf(target.loc))
		balloon_alert(mod.wearer, "must be on the floor!")
		return
	var/obj/item/microwave_target = target
	var/datum/effect_system/spark_spread/spark_effect = new()
	spark_effect.set_up(2, 1, mod.wearer)
	spark_effect.start()
	mod.wearer.Beam(target,icon_state="lightning[rand(1,12)]", time = 5)
	if(microwave_target.microwave_act())
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, FALSE)
	else
		balloon_alert(mod.wearer, "can't be microwaved!")
	var/datum/effect_system/spark_spread/spark_effect_two = new()
	spark_effect_two.set_up(2, 1, microwave_target)
	spark_effect_two.start()
	drain_power(use_power_cost)

//Waddle - Makes you waddle and squeak.
/obj/item/mod/module/waddle
	name = "MOD waddle module"
	desc = "Some of the most primitive technology in use by HonkCo. This module works off an automatic intention system, \
		utilizing its' sensitivity to the pilot's often-limited brainwaves to directly read their next step, \
		affecting the boots they're installed in. Employing a twin-linked gravitonic drive to create \
		miniaturized etheric blasts of space-time beneath the user's feet, this enables them to... \
		to waddle around, bouncing to and fro with a pep in their step."
	icon_state = "waddle"
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.2
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/waddle)

/obj/item/mod/module/waddle/on_suit_activation()
	mod.boots.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50, falloff_exponent = 20) //die off quick please
	mod.wearer.AddElement(/datum/element/waddling)
	if(is_clown_job(mod.wearer.mind?.assigned_role))
		SEND_SIGNAL(mod.wearer, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/mod/module/waddle/on_suit_deactivation()
	qdel(mod.boots.GetComponent(/datum/component/squeak))
	mod.wearer.RemoveElement(/datum/element/waddling)
	if(is_clown_job(mod.wearer.mind?.assigned_role))
		SEND_SIGNAL(mod.wearer, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")
