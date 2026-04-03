
// Info about an animation
/datum/humanoid_animation
	var/name = "Unnamed Dance"
	var/emote_text = ""
	var/list/keyframes

// Emote animations
GLOBAL_LIST_EMPTY(emote_animations)

// All dances
GLOBAL_LIST_EMPTY(all_dances_by_name)

// Dances that can be picked by the random dance routine or by the *dance emote
GLOBAL_LIST_EMPTY(random_dances_by_name)

/proc/json_pose_to_pose(list/json_pose)
	var/datum/animation_pose/pose = new
	if(json_pose["rotation"])
		pose.rotation = json_pose["rotation"]
	if(json_pose["offset_x"])
		pose.offset_x = json_pose["offset_x"]
	if(json_pose["offset_y"])
		pose.offset_y = json_pose["offset_y"]
	if(json_pose["scale_x"])
		pose.scale_x = json_pose["scale_x"]
	if(json_pose["scale_y"])
		pose.scale_y = json_pose["scale_y"]
	return pose

/proc/json_list_to_keyframes(list/json_list)
	var/list/keyframes = list()
	for(var/frame in json_list)
		if(frame["repeat_frames"])
			for(var/frameIdx in frame["repeat_frames"])
				keyframes += keyframes[frameIdx]
		else
			var/datum/animation_keyframe/keyframe = new
			if(frame["time"])
				keyframe.time = frame["time"]
			if(frame["animate"])
				keyframe.animate = frame["animate"]
			if(frame["head_dir"])
				keyframe.head_dir = text2dir(frame["head_dir"])
			if(frame["body_dir"])
				keyframe.body_dir = text2dir(frame["body_dir"])
			if(frame["legs_dir"])
				keyframe.legs_dir = text2dir(frame["legs_dir"])
			if(frame["head"])
				keyframe.head = json_pose_to_pose(frame["head"])
			if(frame["body"])
				keyframe.body = json_pose_to_pose(frame["body"])
			if(frame["arm_l"])
				keyframe.arm_l = json_pose_to_pose(frame["arm_l"])
			if(frame["arm_r"])
				keyframe.arm_r = json_pose_to_pose(frame["arm_r"])
			if(frame["leg_l"])
				keyframe.leg_l = json_pose_to_pose(frame["leg_l"])
			if(frame["leg_r"])
				keyframe.leg_r = json_pose_to_pose(frame["leg_r"])
			keyframes += keyframe
	return keyframes

/proc/loadDancesFromFile(filename, directory = "strings/tcg")
	var/filepath = "strings/dances.json"
	var/list/json = json_decode(file2text(filepath))
	if(!json)
		message_admins(span_warning("error decoding json when loading dances from file"))
		return
	GLOB.emote_animations.Cut()
	for(var/dance in json["emotes"])
		var/datum/humanoid_animation/anim = new
		anim.name = dance["name"]
		anim.keyframes = json_list_to_keyframes(dance["keyframes"])
		GLOB.emote_animations[LOWER_TEXT(anim.name)] = anim
	GLOB.all_dances_by_name.Cut()
	GLOB.random_dances_by_name.Cut()
	for(var/dance in json["random_dances"])
		var/datum/humanoid_animation/anim = new
		anim.name = dance["name"]
		anim.emote_text = dance["emote_text"]
		anim.keyframes = json_list_to_keyframes(dance["keyframes"])
		GLOB.all_dances_by_name[LOWER_TEXT(anim.name)] = anim
		GLOB.random_dances_by_name[LOWER_TEXT(anim.name)] = anim
	for(var/dance in json["secret_dances"])
		var/datum/humanoid_animation/anim = new
		anim.name = dance["name"]
		anim.emote_text = dance["emote_text"]
		anim.keyframes = json_list_to_keyframes(dance["keyframes"])
		GLOB.all_dances_by_name[LOWER_TEXT(anim.name)] = anim
