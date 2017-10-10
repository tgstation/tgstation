/mob/living/silicon/ai/proc/handle_remotedoor(href_list)
  	var/obj/machinery/door/airlock/A = locate(href_list["remotedoor"]) in GLOB.machines
		if(stat == CONSCIOUS)
			if(A && near_camera(A))
				A.AIShiftClick(src)
				to_chat(src, "<span class='notice'>[A] opened.</span>")
			else
				to_chat(src, "<span class='notice'>Unable to locate airlock. It may be out of camera range.</span>")
