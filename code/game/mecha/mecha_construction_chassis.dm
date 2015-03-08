/datum/construction/mecha_chassis

/datum/construction/mecha_chassis/custom_action(step, atom/used_atom, mob/user)
	user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
	holder.overlays += used_atom.icon_state+"+o"
	del used_atom
	return 1

/datum/construction/mecha_chassis/action(atom/used_atom,mob/user as mob)
	return check_all_steps(used_atom,user)


//        RIPLEY          //
/datum/construction/mecha_chassis/ripley
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/ripley_torso),//1
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_right_leg)//5
					)

/datum/construction/mecha_chassis/ripley/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/ripley(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "ripley0"
	const_holder.density = 1
	const_holder.overlays.len = 0
	spawn()
		del src
	return

//        FIREFIGHTER      //
/datum/construction/mecha_chassis/firefighter
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/ripley_torso),//1
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list(Co_KEY=/obj/item/mecha_parts/part/ripley_right_leg),//5
					 list(Co_KEY=/obj/item/clothing/suit/fire)//6
					)

/datum/construction/mecha_chassis/firefighter/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/firefighter(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "firefighter0"
	const_holder.density = 1
	spawn()
		del src
	return

//          GYGAX          //
/datum/construction/mecha_chassis/gygax
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/gygax_torso),//1
					 list(Co_KEY=/obj/item/mecha_parts/part/gygax_left_arm),//2
					 list(Co_KEY=/obj/item/mecha_parts/part/gygax_right_arm),//3
					 list(Co_KEY=/obj/item/mecha_parts/part/gygax_left_leg),//4
					 list(Co_KEY=/obj/item/mecha_parts/part/gygax_right_leg),//5
					 list(Co_KEY=/obj/item/mecha_parts/part/gygax_head)
					)

/datum/construction/mecha_chassis/gygax/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/combat/gygax(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "gygax0"
	const_holder.density = 1
	spawn()
		del src
	return

//          DURAND         //

/datum/construction/mecha_chassis/durand
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/durand_torso),//1
				 list(Co_KEY=/obj/item/mecha_parts/part/durand_left_arm),//2
				 list(Co_KEY=/obj/item/mecha_parts/part/durand_right_arm),//3
				 list(Co_KEY=/obj/item/mecha_parts/part/durand_left_leg),//4
				 list(Co_KEY=/obj/item/mecha_parts/part/durand_right_leg),//5
				 list(Co_KEY=/obj/item/mecha_parts/part/durand_head)
				)

/datum/construction/mecha_chassis/durand/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/combat/durand(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "durand0"
	const_holder.density = 1
	spawn()
		del src
	return


//        ODYSSEUS         //
/datum/construction/mecha_chassis/odysseus
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/odysseus_torso),//1
					 list(Co_KEY=/obj/item/mecha_parts/part/odysseus_head),//2
					 list(Co_KEY=/obj/item/mecha_parts/part/odysseus_left_arm),//3
					 list(Co_KEY=/obj/item/mecha_parts/part/odysseus_right_arm),//4
					 list(Co_KEY=/obj/item/mecha_parts/part/odysseus_left_leg),//5
					 list(Co_KEY=/obj/item/mecha_parts/part/odysseus_right_leg)//6
					)

/datum/construction/mecha_chassis/odysseus/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/odysseus(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "odysseus0"
	const_holder.density = 1
	spawn()
		del src
	return


//         PHAZON           //
/datum/construction/mecha_chassis/phazon
	result = "/obj/mecha/combat/phazon"
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/phazon_torso),//1
					 list(Co_KEY=/obj/item/mecha_parts/part/phazon_left_arm),//2
					 list(Co_KEY=/obj/item/mecha_parts/part/phazon_right_arm),//3
					 list(Co_KEY=/obj/item/mecha_parts/part/phazon_left_leg),//4
					 list(Co_KEY=/obj/item/mecha_parts/part/phazon_right_leg),//5
					 list(Co_KEY=/obj/item/mecha_parts/part/phazon_head)
					)

/datum/construction/mecha_chassis/phazon/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/phazon(const_holder)
	const_holder.icon = 'icons/mecha/mech_construction.dmi'
	const_holder.icon_state = "phazon0"
	const_holder.density = 1
	spawn()
		del src
	return


////////////HONK////////////////
/datum/construction/mecha_chassis/honker
	steps = list(list(Co_KEY=/obj/item/mecha_parts/part/honker_torso),//1
					 list(Co_KEY=/obj/item/mecha_parts/part/honker_left_arm),//2
					 list(Co_KEY=/obj/item/mecha_parts/part/honker_right_arm),//3
					 list(Co_KEY=/obj/item/mecha_parts/part/honker_left_leg),//4
					 list(Co_KEY=/obj/item/mecha_parts/part/honker_right_leg),//5
					 list(Co_KEY=/obj/item/mecha_parts/part/honker_head)
					)

/datum/construction/mecha_chassis/honker/spawn_result(mob/user as mob)
	var/obj/item/mecha_parts/chassis/const_holder = holder
	const_holder.construct = new /datum/construction/reversible/mecha/honker(const_holder)
	const_holder.density = 1
	spawn()
		del src
	return