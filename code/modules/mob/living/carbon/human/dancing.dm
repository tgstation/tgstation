// We can dance if we want to
// we can leave your friends behind
// cause your friends don't dance
// and if they don't dance
// well they're, no friends of mine

// Dance data for a single limb
// The limb will rotate and scale around its anchoring joint, and then have offsets applied
/datum/limb_dance_move
	var/rotation = 0
	var/offset_x = 0
	var/offset_y = 0
	var/scale_x = 1
	var/scale_y = 1

// Get the translation matrix for this dance move
/datum/limb_dance_move/proc/get_matrix(list/joint_pos)
	var/matrix/my_matrix = matrix()
	// Move the joint (shoulter, hip, etc.) to the center so we scale/rotate around it
	my_matrix.Translate(16.5 - joint_pos[1], 16.5 - joint_pos[2])

	// Do scale/rotation transformations
	my_matrix.Scale(scale_x, scale_y)
	my_matrix.Turn(rotation)

	// Move the joint back to where it was
	my_matrix.Translate(joint_pos[1] - 16.5, joint_pos[2] - 16.5)

	// Do translate transformations
	my_matrix.Translate(offset_x, offset_y)
	return my_matrix

// Keyframe for a dance
/datum/dance_keyframe
	var/time_to_do = 0 // in deciseconds
	var/head_dir = SOUTH
	var/body_dir = SOUTH
	var/datum/limb_dance_move/head
	var/datum/limb_dance_move/body
	var/datum/limb_dance_move/arm_l
	var/datum/limb_dance_move/arm_r
	var/datum/limb_dance_move/leg_l
	var/datum/limb_dance_move/leg_r

/datum/dance_keyframe/New()
	head = new /datum/limb_dance_move()
	body = new /datum/limb_dance_move()
	arm_l = new /datum/limb_dance_move()
	arm_r = new /datum/limb_dance_move()
	leg_l = new /datum/limb_dance_move()
	leg_r = new /datum/limb_dance_move()

// A dance in the abstract
/datum/dance_moves
	var/dance_name = "Unnamed Dance"
	var/emote_text = "dances"
	var/list/keyframes

// A dance that is currently being performed
/datum/active_dance
	var/datum/dance_moves/my_dance
	var/mob/living/carbon/human/dancer
	var/current_dance_keyframe = 0
	var/timer_id

/datum/active_dance/proc/apply_keyframe_to_limb(datum/dance_keyframe/keyframe, obj/effect/dancing_limb/limb, datum/limb_dance_move/move, limb_dir, list/joint_pos)
	if(limb && move)
		limb.dir = limb_dir
		animate(limb, transform = move.get_matrix(joint_pos), time = keyframe.time_to_do)

/datum/active_dance/proc/apply_first_keyframe_to_limb(datum/dance_keyframe/keyframe, obj/effect/dancing_limb/limb, datum/limb_dance_move/move, limb_dir, list/joint_pos)
	if(limb && move)
		limb.dir = limb_dir
		limb.transform = move.get_matrix(joint_pos)

/datum/active_dance/proc/apply_keyframe(keyframe_idx)
	if(!dancer)
		// where'd our dancer go?
		qdel(src)
		return
	if(LAZYLEN(my_dance.keyframes) < keyframe_idx)
		// Dance over
		qdel(src)
		return
	if(!dancer.current_dance_sprites)
		dancer.current_dance_sprites = create_dance_sprites(dancer)
		dancer.current_dance_sprites.apply_to(dancer)
	current_dance_keyframe = keyframe_idx
	var/datum/dance_keyframe/keyframe = my_dance.keyframes[current_dance_keyframe]
	// Setup next keyframe call
	timer_id = addtimer(CALLBACK(src, PROC_REF(apply_keyframe), current_dance_keyframe + 1), keyframe.time_to_do, TIMER_DELETE_ME | TIMER_STOPPABLE)
	// Animate dance sprites
	var/h_dir = keyframe.head_dir
	var/b_dir = keyframe.body_dir
	if(keyframe_idx == 1)
		apply_first_keyframe_to_limb(keyframe, dancer.current_dance_sprites.head, keyframe.head, h_dir, get_limb_joint_pos(BODY_ZONE_HEAD, h_dir))
		apply_first_keyframe_to_limb(keyframe, dancer.current_dance_sprites.body, keyframe.body, b_dir, get_limb_joint_pos(BODY_ZONE_CHEST, b_dir))
		apply_first_keyframe_to_limb(keyframe, dancer.current_dance_sprites.arm_l, keyframe.arm_l, b_dir, get_limb_joint_pos(BODY_ZONE_L_ARM, b_dir))
		apply_first_keyframe_to_limb(keyframe, dancer.current_dance_sprites.arm_r, keyframe.arm_r, b_dir, get_limb_joint_pos(BODY_ZONE_R_ARM, b_dir))
		apply_first_keyframe_to_limb(keyframe, dancer.current_dance_sprites.leg_l, keyframe.leg_l, b_dir, get_limb_joint_pos(BODY_ZONE_L_LEG, b_dir))
		apply_first_keyframe_to_limb(keyframe, dancer.current_dance_sprites.leg_r, keyframe.leg_r, b_dir, get_limb_joint_pos(BODY_ZONE_R_LEG, b_dir))
	else
		apply_keyframe_to_limb(keyframe, dancer.current_dance_sprites.head, keyframe.head, h_dir, get_limb_joint_pos(BODY_ZONE_HEAD, h_dir))
		apply_keyframe_to_limb(keyframe, dancer.current_dance_sprites.body, keyframe.body, b_dir, get_limb_joint_pos(BODY_ZONE_CHEST, b_dir))
		apply_keyframe_to_limb(keyframe, dancer.current_dance_sprites.arm_l, keyframe.arm_l, b_dir, get_limb_joint_pos(BODY_ZONE_L_ARM, b_dir))
		apply_keyframe_to_limb(keyframe, dancer.current_dance_sprites.arm_r, keyframe.arm_r, b_dir, get_limb_joint_pos(BODY_ZONE_R_ARM, b_dir))
		apply_keyframe_to_limb(keyframe, dancer.current_dance_sprites.leg_l, keyframe.leg_l, b_dir, get_limb_joint_pos(BODY_ZONE_L_LEG, b_dir))
		apply_keyframe_to_limb(keyframe, dancer.current_dance_sprites.leg_r, keyframe.leg_r, b_dir, get_limb_joint_pos(BODY_ZONE_R_LEG, b_dir))

/datum/active_dance/Destroy()
	if(dancer)
		dancer.current_dance = null
		dancer.stop_dancing()
		dancer = null
	deltimer(timer_id)
	timer_id = null
	return ..()

// An object we can use to animate a dance
// Will copy the overlays of a limb or torso
// Limbs are nested in the torso vias vis_contents so they inherit the torso's transform
/obj/effect/dancing_limb
	var/datum/dance_sprites/my_holder

// Good faith effort to relay clicks to the actual human mob
/obj/effect/dancing_limb/Click(location, control, params)
	my_holder?.my_human?.Click(location, control, params)

/obj/effect/dancing_limb/Destroy()
	my_holder = null
	return ..()

// Handles for all the objects that form a dancer's body
/datum/dance_sprites
	var/obj/effect/dancing_limb/head
	var/obj/effect/dancing_limb/body
	var/obj/effect/dancing_limb/arm_l
	var/obj/effect/dancing_limb/arm_r
	var/obj/effect/dancing_limb/leg_l
	var/obj/effect/dancing_limb/leg_r
	var/mob/living/carbon/human/my_human

/datum/dance_sprites/proc/apply_to(mob/living/carbon/human/dancer)
	my_human = dancer
	var/list/limbs = list(head, arm_l, arm_r, leg_l, leg_r)
	list_clear_nulls(limbs)
	for(var/obj/effect/dancing_limb/limb as anything in limbs)
		limb.name = dancer.name
	body.name = dancer.name
	body.vis_contents |= limbs
	dancer.vis_contents |= body

/datum/dance_sprites/proc/unapply_from(mob/living/carbon/human/dancer)
	my_human = null
	var/list/objs = list(head, body, arm_l, arm_r, leg_l, leg_r)
	list_clear_nulls(objs)
	dancer.vis_contents -= body

/datum/dance_sprites/proc/stop_animations()
	if(head)
		animate(head)
	if(body)
		animate(body)
	if(arm_l)
		animate(arm_l)
	if(arm_r)
		animate(arm_r)
	if(leg_l)
		animate(leg_l)
	if(leg_r)
		animate(leg_r)

/datum/dance_sprites/Destroy()
	if(my_human)
		unapply_from(my_human)
	QDEL_NULL(head)
	QDEL_NULL(body)
	QDEL_NULL(arm_l)
	QDEL_NULL(arm_r)
	QDEL_NULL(leg_l)
	QDEL_NULL(leg_r)
	return ..()

// Create a single limb for the holder made up of the given overlays
/proc/create_dance_limb(datum/dance_sprites/holder, list/overlays)
	if(overlays)
		var/obj/effect/dancing_limb/d_limb = new /obj/effect/dancing_limb()
		d_limb.my_holder = holder
		d_limb.add_overlay(overlays)
		return d_limb
	return null

// The big scary function that does icon blend operations
// Has a 10 second cooldown per mob to avoid spamming the server with blend procs
// If the cooldown is still in effect, use the last cached version of dance sprites for this human
// The cooldown leads to some weird situations if you are changing clothes a lot while dancing, but we need some throttling
/proc/create_dance_sprites(mob/living/carbon/human/dancer)
	// For most limbs, we can apply the limb sprite along with the proper overlays
	// However, we also want the legs and arms of UNIFORM_LAYER and SUIT_LAYER to move with the limbs
	// To support this, we will create an image of those and chop them up
	// Looks weird on skirts but pretty good on everything else
	// Also it only works for south-facing sprites right now, so only the head can turn in any other direction

	var/datum/dance_sprites/my_sprites = new
	var/list/imgList
	if(!dancer.last_dance_sprites || COOLDOWN_FINISHED(dancer, last_dance_sprite_gen))
		var/list/d_overlays = dancer.overlays_standing

		// Construct sprite for uniform, suit, shoes, and gloves
		var/icon/body_clothes
		var/mutable_appearance/crop_appearance = new
		crop_appearance.overlays += d_overlays[UNIFORM_LAYER]
		crop_appearance.overlays += d_overlays[SUIT_LAYER]
		crop_appearance.overlays += d_overlays[GLOVES_LAYER]
		crop_appearance.overlays += d_overlays[SHOES_LAYER]
		if(crop_appearance.overlays.len)
			body_clothes = getFlatIcon(crop_appearance, defdir = SOUTH)

		// Head
		var/list/head = list()
		if(dancer.get_bodypart(BODY_ZONE_HEAD))
			head += dancer.get_bodypart(BODY_ZONE_HEAD).get_limb_icon()
			head += d_overlays[HEAD_LAYER]
			head += d_overlays[EYES_LAYER]
			head += d_overlays[EARS_LAYER]
			head += d_overlays[FACEMASK_LAYER]
			head += d_overlays[BENEATH_HAIR_LAYER]
			head += d_overlays[ABOVE_BODY_FRONT_GLASSES_LAYER]
			head += d_overlays[ABOVE_BODY_FRONT_HEAD_LAYER]
			head += d_overlays[HALO_LAYER]
			head += d_overlays[LOW_FACEMASK_LAYER]
			head += d_overlays[GLASSES_LAYER]

		// Torso
		var/list/torso = list()
		// Going to assume that the human has a torso
		// Sue me for discrimination when you find a torsoless human
		torso += dancer.get_bodypart(BODY_ZONE_CHEST).get_limb_icon()
		torso += d_overlays[BODY_BEHIND_LAYER]
		torso += d_overlays[ID_LAYER]
		torso += d_overlays[ID_CARD_LAYER]
		torso += d_overlays[LOW_NECK_LAYER]
		torso += d_overlays[BELT_LAYER]
		torso += d_overlays[SUIT_STORE_LAYER]
		torso += d_overlays[NECK_LAYER]
		torso += d_overlays[BACK_LAYER]
		if(body_clothes)
			var/icon/crop_img = new /icon(body_clothes)
			crop_img.Crop(12, 10, 20, 22)
			var/icon/torso_img = icon('icons/mob/human/human.dmi', "blank", SOUTH)
			torso_img.Blend(crop_img, ICON_OVERLAY, 12, 10)
			torso += torso_img

		// Left Arm
		var/list/l_arm = list()
		if(dancer.get_bodypart(BODY_ZONE_L_ARM))
			l_arm += dancer.get_bodypart(BODY_ZONE_L_ARM).get_limb_icon()
			if(body_clothes)
				var/icon/crop_img = new /icon(body_clothes)
				crop_img.Crop(21, 10, 25, 22)
				var/icon/l_arm_img = icon('icons/mob/human/human.dmi', "blank", SOUTH)
				l_arm_img.Blend(crop_img, ICON_OVERLAY, 21, 10)
				l_arm += l_arm_img

		// Right Arm
		var/list/r_arm = list()
		if(dancer.get_bodypart(BODY_ZONE_R_ARM))
			r_arm += dancer.get_bodypart(BODY_ZONE_R_ARM).get_limb_icon()
			if(body_clothes)
				var/icon/crop_img = new /icon(body_clothes)
				crop_img.Crop(7, 10, 11, 22)
				var/icon/r_arm_img = icon('icons/mob/human/human.dmi', "blank", SOUTH)
				r_arm_img.Blend(crop_img, ICON_OVERLAY, 7, 10)
				r_arm += r_arm_img

		// Left Leg
		var/list/l_leg = list()
		if(dancer.get_bodypart(BODY_ZONE_L_LEG))
			l_leg += dancer.get_bodypart(BODY_ZONE_L_LEG).get_limb_icon()
			if(body_clothes)
				var/icon/crop_img = new /icon(body_clothes)
				crop_img.Crop(17, 1, 24, 10)
				var/icon/l_leg_img = icon('icons/mob/human/human.dmi', "blank", SOUTH)
				l_leg_img.Blend(crop_img, ICON_OVERLAY, 17, 1)
				l_leg += l_leg_img

		// Right Leg
		var/list/r_leg = list()
		if(dancer.get_bodypart(BODY_ZONE_R_LEG))
			r_leg += dancer.get_bodypart(BODY_ZONE_R_LEG).get_limb_icon()
			if(body_clothes)
				var/icon/crop_img = new /icon(body_clothes)
				crop_img.Crop(8, 1, 15, 10)
				var/icon/r_leg_img = icon('icons/mob/human/human.dmi', "blank", SOUTH)
				r_leg_img.Blend(crop_img, ICON_OVERLAY, 8, 1)
				r_leg += r_leg_img

		imgList = list(head, torso, l_arm, r_arm, l_leg, r_leg)

		COOLDOWN_START(dancer, last_dance_sprite_gen, 10 SECONDS)
		dancer.last_dance_sprites = imgList
	else
		imgList = dancer.last_dance_sprites

	my_sprites.head = create_dance_limb(my_sprites, imgList[1])
	my_sprites.body = create_dance_limb(my_sprites, imgList[2])
	my_sprites.arm_l = create_dance_limb(my_sprites, imgList[3])
	my_sprites.arm_r = create_dance_limb(my_sprites, imgList[4])
	my_sprites.leg_l = create_dance_limb(my_sprites, imgList[5])
	my_sprites.leg_r = create_dance_limb(my_sprites, imgList[6])

	return my_sprites

/mob/living/carbon/human/proc/start_dancing(datum/dance_moves/dance_to_do)
	if(current_dance)
		// TODO: could try to do a seamless transition to the new dance here
		// Maybe later
		deltimer(current_dance.timer_id)
		current_dance.timer_id = null
		if(current_dance_sprites)
			current_dance_sprites.stop_animations()
	else
		current_dance = new /datum/active_dance()
	current_dance.my_dance = dance_to_do
	current_dance.dancer = src
	current_dance.apply_keyframe(1)
	regenerate_icons()

/mob/living/carbon/human/proc/stop_dancing(datum/dance_moves/dance)
	current_dance_sprites?.unapply_from(src)
	QDEL_NULL(current_dance)
	QDEL_NULL(current_dance_sprites)
	regenerate_icons()

// Return the location of the anchoring joint for a limb
// i.e., the shoulder for an arm, the hip for a leg, the neck for a head
// torsos are considered anchored to the center of the sprite
/proc/get_limb_joint_pos(limb, dir)
	// TODO: currently only supports SOUTH dir
	// Things will get weird if you make a dance for a different direction without populating the values in this function
	switch(limb)
		if(BODY_ZONE_HEAD)
			switch(dir)
				if(NORTH)
					return list(0, 0)
				if(SOUTH)
					return list(16, 23)
				if(EAST)
					return list(0, 0)
				if(WEST)
					return list(0, 0)
		if(BODY_ZONE_CHEST)
			switch(dir)
				if(NORTH)
					return list(0, 0)
				if(SOUTH)
					return list(16, 16)
				if(EAST)
					return list(0, 0)
				if(WEST)
					return list(0, 0)
		if(BODY_ZONE_L_ARM)
			switch(dir)
				if(NORTH)
					return list(0, 0)
				if(SOUTH)
					return list(21, 21)
				if(EAST)
					return list(0, 0)
				if(WEST)
					return list(0, 0)
		if(BODY_ZONE_R_ARM)
			switch(dir)
				if(NORTH)
					return list(0, 0)
				if(SOUTH)
					return list(11, 21)
				if(EAST)
					return list(0, 0)
				if(WEST)
					return list(0, 0)
		if(BODY_ZONE_L_LEG)
			switch(dir)
				if(NORTH)
					return list(0, 0)
				if(SOUTH)
					return list(18, 10)
				if(EAST)
					return list(0, 0)
				if(WEST)
					return list(0, 0)
		if(BODY_ZONE_R_LEG)
			switch(dir)
				if(NORTH)
					return list(0, 0)
				if(SOUTH)
					return list(14, 10)
				if(EAST)
					return list(0, 0)
				if(WEST)
					return list(0, 0)
	return list(0, 0)
