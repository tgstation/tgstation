/datum/experiment_type/poke
	name = "Poke"

/datum/experiment/destroy/lash
	weight = 20
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/destroy/lash/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	. = FALSE
	E.visible_message("<span class='danger'>[E] malfunctions and destroys [O], lashing its arms out at nearby people!</span>")
	for(var/mob/living/m in oview(1, E))
		m.apply_damage(15, BRUTE, pick("head","chest","groin"))
		E.investigate_log("Experimentor dealt minor brute to [m].", INVESTIGATE_EXPERIMENTOR)
		. = TRUE

/datum/experiment/instead_obliterate
	weight = 30
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/instead_obliterate/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	..()
	E.visible_message("<span class='warning'>[E] malfunctions!</span>")
	. = E.perform_experiment(/datum/experiment_type/destroy)

/datum/experiment/throw_item
	weight = 50
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/throw_item/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] malfunctions, throwing the [O]!</span>")
	var/mob/living/target = locate(/mob/living) in oview(7,E)
	if(target)
		E.investigate_log("Experimentor has thrown [O] at [target]", INVESTIGATE_EXPERIMENTOR)
		E.eject_item()
		O.throw_at(target, 10, 1)

/datum/experiment/open_bomb
	weight = 80
	is_bad = TRUE
	experiment_type = /datum/experiment_type/poke

/datum/experiment/open_bomb/init()
	valid_types = typecacheof(/obj/item/transfer_valve)

/datum/experiment/open_bomb/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && is_valid_bomb(O))
		. = TRUE

/datum/experiment/open_bomb/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='danger'>[E] begins [pick("curiously","mischievously","angrily")] [pick("screwing","twisting","twirling","turning")] open the [O]!</span>")
	E.investigate_log("Experimentor is activating a bomb.", INVESTIGATE_EXPERIMENTOR)
	addtimer(CALLBACK(src, .proc/open, E, O), 30)
	E.reset_time += 30

/datum/experiment/open_bomb/proc/open(obj/machinery/rnd/experimentor/E,obj/item/transfer_valve/O)
	if(E.loaded_item == O)
		O.toggle_valve()
		E.visible_message("<span class='danger'>[E] has opened the [O]!</span>")
	else
		playsound(E, 'sound/machines/buzz-sigh.ogg', 50, 1)
	E.RefreshParts()

/datum/experiment/knock_container
	weight = 80
	experiment_type = /datum/experiment_type/poke

/datum/experiment/knock_container/init()
	valid_types = typecacheof(/obj/item/reagent_containers) //Only works on containers

/datum/experiment/knock_container/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(!O.reagents || O.reagents.total_volume <= 0)
		. = FALSE

/datum/experiment/knock_container/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	E.visible_message("<span class='warning'>[E] knocks over [O].</span>")
	E.investigate_log("Experimentor has splashed [O].", INVESTIGATE_EXPERIMENTOR)
	chem_splash(get_turf(E),3,list(O.reagents))

/datum/experiment/enable_improve
	weight = 0 //disabled until further testing
	experiment_type = /datum/experiment_type/poke
	base_points = 2500
	critical = TRUE

/datum/experiment/enable_improve/can_perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(. && E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		. = web.all_experiment_types[/datum/experiment_type/improve].hidden || web.all_experiment_types[/datum/experiment_type/improve].uses <= 0

/datum/experiment/enable_improve/perform(obj/machinery/rnd/experimentor/E,obj/item/O)
	. = ..()
	if(E.linked_console)
		var/datum/techweb/web = E.linked_console.stored_research
		var/datum/experiment_type/improve/mode = web.all_experiment_types[/datum/experiment_type/improve]
		mode.hidden = FALSE
		mode.uses = E.bad_thing_coeff
		E.experiments[mode.type] = mode //Give it to this experimentor. Others need to relink to unlock.

		E.visible_message("[E] displays a message: New data discovered. Potential optimizations availible.")
		playsound(E, 'sound/machines/ping.ogg', 50, 1)
