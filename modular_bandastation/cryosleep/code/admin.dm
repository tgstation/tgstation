/// Send player in not-quiet cryopod. If with_paper = TRUE, place a paper with notification under player.
/mob/living/proc/send_to_cryo(with_paper = FALSE)
	var/obj/machinery/cryopod/valid_pod
	for(var/obj/machinery/cryopod/cryo as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/cryopod))
		if(!cryo.can_be_put_inside(src))
			continue

		valid_pod = cryo
		break

	if(!valid_pod)
		message_admins("no valid pod found for [key_name_admin(name)]")
		return

	if(buckled)
		buckled.unbuckle_mob(src, TRUE)

	if(buckled_mobs)
		for(var/mob/buckled_mob as anything in buckled_mobs)
			unbuckle_mob(buckled_mob)

	playsound(loc, 'sound/effects/magic/Repulse.ogg', 50, TRUE)
	do_sparks(10, TRUE, loc, null, /datum/effect_system/basic/spark_spread/quantum)

	if(with_paper)
		var/obj/item/paper/cryo_paper = new /obj/item/paper(loc)
		cryo_paper.name = "Уведомление - [name]"
		cryo_paper.add_raw_text("Приносим искренние извинения, персону \"[name][job ? ", [job]," : ""]\" пришлось отправить в криогенное хранилище по причинам, которые на данный момент не могут быть уточнены.<br><br>С уважением,<br><i>Агентство Нанотрейзен по борьбе с SSD.</i>")
		cryo_paper.update_appearance()

	valid_pod.close_machine(src)
