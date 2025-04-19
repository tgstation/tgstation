/datum/animate_flag
	var/name
	var/description
	var/value

/datum/animate_flag/end_now
	name = "End Now"
	description = "Normally if you interrupt another animation, it transitions from its current state. This flag will start the new animation fresh by bringing the old one to its conclusion immediately. It is only meaningful on the first step of a new animation."
	value = ANIMATION_END_NOW

/datum/animate_flag/linear_transform
	name = "Linear Transform"
	description = "The transform var is interpolated in a way that preserves size during rotation, by pulling the rotation step out. This flag forces linear interpolation, which may be more desirable for things like beam effects, mechanical arms, etc."
	value = ANIMATION_LINEAR_TRANSFORM

/datum/animate_flag/parallel
	name = "Parallel"
	description = "Start a parallel animation sequence that runs alongside the current animation sequence. The difference between where the parallel sequence started, and its current appearance, is added to the result of any previous animations. For instance, you could use this to animate pixel_y separately from pixel_x with different timing and easing. You could also use this to apply a rotational transform after a previous animation sequence did a translate."
	value = ANIMATION_PARALLEL

/datum/animate_flag/relative
	name = "Relative"
	description = "The vars specified are relative to the current state. This works for maptext_x/y/width/height, pixel_x/y/w/z, luminosity, layer, alpha, transform, and color. For transform and color, the current value is multiplied by the new one."
	value = ANIMATION_RELATIVE

/datum/animate_flag/a_continue
	name = "Continue"
	description = "This flag is equivalent to leaving out the Object argument. It exists to make it easier to define an animation using a for loop."
	value = ANIMATION_CONTINUE

/datum/animate_flag/slice
	name = "Slice"
	description = "Following a series of animate() calls, you can view just a portion of the animation by using animate(object, delay=start, time=duration, flags=ANIMATION_SLICE). The loop parameter may optionally be included. The delay is the start time of the slice, relative to the beginning of all the active animations on the object. (That is, earlier animations that have concluded will not be included.) You can call the proc again with a different slice if you want to see a different portion of the animation. A negative value for time will remove the slice and finish any existing animations. "
	value = ANIMATION_SLICE

/datum/animate_flag/end_loop
	name = "End Loop"
	description = "Tells previous animation sequences to stop looping and end naturally. The delay for starting this new sequence is adjusted based on that."
#ifndef SPACEMAN_DMM
	value = ANIMATION_END_LOOP
#else
	value = 0
#endif
