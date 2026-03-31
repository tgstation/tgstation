////////////////////////////////////
//            Dances              //
////////////////////////////////////

// TODO: there's definitely a better way to init the global list
// Will deal with that if/when this becomes more than a silly april fool's joke

// Not really a dance, just for the wave emote
GLOBAL_DATUM_INIT(wave_moves, /datum/dance_moves/wave, new /datum/dance_moves/wave())

// Dances that can be picked by the random dance routine or by the *dance emote
GLOBAL_LIST_INIT(all_dances_by_name, list(
	LOWER_TEXT(/datum/dance_moves/shoulder_wave::dance_name) = new /datum/dance_moves/shoulder_wave,
	LOWER_TEXT(/datum/dance_moves/floss::dance_name) = new /datum/dance_moves/floss,
	LOWER_TEXT(/datum/dance_moves/disco::dance_name) = new /datum/dance_moves/disco,
))

/datum/dance_moves/wave
	dance_name = "Wave"
	emote_text = "waves!"

/datum/dance_moves/wave/New()
	keyframes = list()
	var/datum/dance_keyframe/newframe
	newframe = new
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 5
	newframe.arm_l.rotation = 10
	newframe.arm_l.scale_y = -1
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = 45
	newframe.arm_l.scale_y = -1
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = 10
	newframe.arm_l.scale_y = -1
	keyframes += newframe

	// Repeat x1
	keyframes += keyframes[3]
	keyframes += keyframes[4]

	newframe = new
	newframe.time_to_do = 5
	keyframes += newframe

/datum/dance_moves/shoulder_wave
	dance_name = "ShoulderWave"
	emote_text = "does the wave!"

/datum/dance_moves/shoulder_wave/New()
	keyframes = list()
	var/datum/dance_keyframe/newframe
	newframe = new
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -80
	newframe.arm_r.rotation = 80
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -80
	newframe.arm_r.rotation = 100
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -80
	newframe.arm_r.rotation = 60
	newframe.arm_r.offset_y = 3
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -60
	newframe.arm_l.offset_y = 3
	newframe.arm_r.rotation = 80
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -100
	newframe.arm_r.rotation = 80
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -80
	newframe.arm_r.rotation = 80
	keyframes += newframe

	// Previous 4 frames in reverse order
	keyframes += keyframes[6]
	keyframes += keyframes[5]
	keyframes += keyframes[4]
	keyframes += keyframes[3]

	newframe = new
	newframe.time_to_do = 3
	newframe.arm_l.rotation = -80
	newframe.arm_r.rotation = 80
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 3
	keyframes += newframe

/datum/dance_moves/floss
	dance_name = "Floss"
	emote_text = "does the floss!"

/datum/dance_moves/floss/New()
	keyframes = list()
	var/datum/dance_keyframe/newframe
	newframe = new
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 5
	newframe.body.offset_x = 4
	newframe.body.rotation = -15
	newframe.arm_l.rotation = 45
	newframe.arm_l.offset_x = -2
	newframe.arm_r.rotation = 45
	newframe.arm_r.offset_x = 2
	newframe.leg_l.rotation = 25
	newframe.leg_l.offset_y = 3
	newframe.leg_r.rotation = 25
	newframe.leg_r.offset_y = 0
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 5
	newframe.body.offset_x = -4
	newframe.body.rotation = 15
	newframe.arm_l.rotation = -45
	newframe.arm_l.offset_x = -2
	newframe.arm_r.rotation = -45
	newframe.arm_r.offset_x = 2
	newframe.leg_l.rotation = -25
	newframe.leg_l.offset_y = 0
	newframe.leg_r.rotation = -25
	newframe.leg_r.offset_y = 3
	keyframes += newframe

	// Repeat x3
	keyframes += keyframes[2]
	keyframes += keyframes[3]
	keyframes += keyframes[2]
	keyframes += keyframes[3]
	keyframes += keyframes[2]
	keyframes += keyframes[3]

	// Is this what flossing is? IDK, whatever

	newframe = new
	newframe.time_to_do = 5
	keyframes += newframe

/datum/dance_moves/disco
	dance_name = "Disco"
	emote_text = "dances a groovy disco number!"

/datum/dance_moves/disco/New()
	keyframes = list()
	var/datum/dance_keyframe/newframe
	newframe = new
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 8
	newframe.head_dir = WEST
	newframe.arm_l.rotation = -15
	newframe.arm_r.rotation = 120
	newframe.arm_r.scale_y = 1.2
	newframe.arm_r.scale_x = -0.9
	newframe.leg_r.rotation = 20
	newframe.leg_l.rotation = 0
	newframe.leg_l.offset_y = 2
	newframe.body.offset_x = 3
	keyframes += newframe

	newframe = new
	newframe.time_to_do = 8
	newframe.head_dir = WEST
	newframe.arm_l.rotation = 0
	newframe.arm_r.rotation = 120
	newframe.arm_r.scale_y = -0.8
	newframe.arm_r.scale_x = -0.9
	newframe.leg_r.rotation = 20
	newframe.leg_l.rotation = 0
	newframe.leg_l.offset_y = 1
	newframe.body.offset_x = -1
	keyframes += newframe

	// Repeat x3
	keyframes += keyframes[2]
	keyframes += keyframes[3]
	keyframes += keyframes[2]
	keyframes += keyframes[3]
	keyframes += keyframes[2]
	keyframes += keyframes[3]

	newframe = new
	newframe.time_to_do = 5
	keyframes += newframe
