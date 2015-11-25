////////////////////////////////////////////////////////////////////////////////
/// Droppers.
////////////////////////////////////////////////////////////////////////////////
/obj/item/weapon/reagent_containers/dropper
	name = "Dropper"
	desc = "A dropper. Transfers 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1,2,3,4,5)
	volume = 5
	// List of types that can be injected regardless of the CONTAINEROPEN flag
	// TODO Remove snowflake
	var/injectable_types = list(/obj/item/weapon/reagent_containers/food,
	                            /obj/item/slime_extract,
	                            /obj/item/clothing/mask/cigarette,
	                            /obj/item/weapon/storage/fancy/cigarettes,
	                            /obj/item/weapon/implantcase/chem,
	                            /obj/item/weapon/reagent_containers/pill/time_release)

/obj/item/weapon/reagent_containers/dropper/update_icon()
	icon_state = "dropper[(reagents.total_volume ? 1 : 0)]"

/obj/item/weapon/reagent_containers/dropper/afterattack(obj/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag) return

	if(!target.reagents)
		if(reagents.total_volume)
			if(istype(target, /obj/machinery/artifact))
				reagents.clear_reagents()
				to_chat(user, "<span class='notice'>You squirt the solution onto the [target]!</span>")
				update_icon()
		return

	if(reagents.total_volume)

		if(target.reagents.total_volume >= target.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[target] is full.</span>")
			return

		if(!target.is_open_container() && !ismob(target) && !is_type_in_list(target, injectable_types)) //You can inject humans and food but you cant remove the shit.
			to_chat(user, "<span class='warning'>You cannot directly fill this object.</span>")
			return

		var/trans = 0

		if(ismob(target))
			if(ishuman(target))
				var/mob/living/carbon/human/victim = target

				var/obj/item/safe_thing = victim.get_body_part_coverage(EYES)

				if(safe_thing)
					if(!safe_thing.reagents)
						safe_thing.create_reagents(100)
					trans = src.reagents.trans_to(safe_thing, amount_per_transfer_from_this)

					user.visible_message("<span class='danger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>")
					spawn(5)
						src.reagents.reaction(safe_thing, TOUCH)
					to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
					update_icon()
					return
			user.visible_message("<span class='danger'>[user] squirts something into [target]'s eyes!</span>")
			src.reagents.reaction(target, TOUCH)

			var/mob/living/M = target

			var/list/injected = list()
			for(var/datum/reagent/R in src.reagents.reagent_list)
				injected += R.name
			var/contained = english_list(injected)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been squirted with [src.name] by [user.name] ([user.ckey]). Reagents: [contained]</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to squirt [M.name] ([M.key]). Reagents: [contained]</font>")
			msg_admin_attack("[user.name] ([user.ckey]) squirted [M.name] ([M.key]) with [src.name]. Reagents: [contained] (INTENT: [uppertext(user.a_intent)]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user

		trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
		to_chat(user, "<span class='notice'>You transfer [trans] units of the solution.</span>")
		update_icon()

		// /vg/: Logging transfers of bad things
		if(istype(target))
			if(istype(reagents_to_log) && reagents_to_log.len && target.log_reagents)
				var/list/badshit=list()
				for(var/bad_reagent in reagents_to_log)
					if(reagents.has_reagent(bad_reagent))
						badshit += reagents_to_log[bad_reagent]
				if(badshit.len)
					var/hl="<span class='danger'>([english_list(badshit)])</span>"
					message_admins("[user.name] ([user.ckey]) added [trans]U to \a [target] with [src].[hl] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
					log_game("[user.name] ([user.ckey]) added [trans]U to \a [target] with [src].")

	else

		if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
			to_chat(user, "<span class='warning'>You cannot directly remove reagents from [target].</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] is empty.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

		to_chat(user, "<span class='notice'>You fill [src] with [trans] units of the solution.</span>")

		update_icon()

	return

/obj/item/weapon/reagent_containers/dropper/baster
	name = "baster"
	desc = "A specialized tool for precise addition of chemicals."
	icon_state = "baster"
	possible_transfer_amounts = list(1,2,3,4,5,10,15)
	volume = 15

/obj/item/weapon/reagent_containers/dropper/baster/update_icon()
	return

////////////////////////////////////////////////////////////////////////////////
/// Droppers. END
////////////////////////////////////////////////////////////////////////////////
