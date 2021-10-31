/obj/item/mod/module/wzhzhzh
	name = "MOD microwave beam module"
	desc = "A hand-mounted microwave beam to cook your food to perfection."
	module_type = MODULE_ACTIVE
	complexity = 2
	use_power_cost = 50
	incompatible_modules = list(/obj/item/mod/module/wzhzhzh)

/obj/item/mod/module/wzhzhzh/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/wearer_human = mod.wearer
	if(get_dist(wearer_human, target) > 7)
		return
	if(!istype(target, /obj/item))
		return
	var/obj/item/microwave_target = target
	var/datum/effect_system/spark_spread/spark_effect = new
	spark_effect.set_up(2, 1, wearer_human)
	spark_effect.start()
	wearer_human.Beam(target,icon_state="lightning[rand(1,12)]", time = 5)
	//TODO: microwave
	if(microwave_target.microwave_act())
		playsound(src, 'sound/machines/microwave/microwave-end.ogg', 50, FALSE)
		balloon_alert(mod.wearer, "[microwave_target] microwaved")
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 50, FALSE)
		balloon_alert(mod.wearer, "[microwave_target] can't be microwaved")
	var/datum/effect_system/spark_spread/spark_effect_two = new
	spark_effect_two.set_up(2, 1, microwave_target)
	spark_effect_two.start()
