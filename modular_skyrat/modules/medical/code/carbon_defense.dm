/mob/living/carbon/proc/self_grasp_bleeding_limb(obj/item/bodypart/grasped_part, supress_message = FALSE)
	if(!grasped_part?.get_bleed_rate())
		return
	var/starting_hand_index = active_hand_index
	if(starting_hand_index == grasped_part.held_index)
		to_chat(src, "<span class='danger'>You can't grasp your [grasped_part.name] with itself!</span>")
		return

	to_chat(src, "<span class='warning'>You try grasping at your [grasped_part.name], trying to stop the bleeding...</span>")
	if(!do_after(src, 1.5 SECONDS))
		to_chat(src, "<span class='danger'>You fail to grasp your [grasped_part.name].</span>")
		return

	var/obj/item/self_grasp/grasp = new
	if(starting_hand_index != active_hand_index || !put_in_active_hand(grasp))
		to_chat(src, "<span class='danger'>You fail to grasp your [grasped_part.name].</span>")
		QDEL_NULL(grasp)
		return
	grasp.grasp_limb(grasped_part)
