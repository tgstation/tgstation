/*
 * Runescape-inspired Chat Effects System
 *
 * Provides visual effects for runechat maptext messages, similar to
 * Runescape's chat effects. Effects are applied to chat message overlays.
 *
 * How to use:
 *   Type a prefix command before your message:
 *   .rs-red Hello!        -> Red text
 *   .rs-rainbow Hello!   -> Rainbow cycling text
 *   .rs-flash1 Hello!    -> Flashing red/yellow text
 *   .rs-wave Hello!      -> Wavy text
 *   .rs-shake Hello!     -> Shaking text
 */

/datum/runechat_effect
	var/effect_type = RSEFFECT_NONE
	var/effect_name = ""

/datum/runechat_effect/proc/apply_effect(image/message_image, lifespan, client/owner)
	return

GLOBAL_LIST_INIT(runechat_effect_map, list(
	"yellow" = /datum/runechat_effect/color/yellow,
	"red" = /datum/runechat_effect/color/red,
	"green" = /datum/runechat_effect/color/green,
	"cyan" = /datum/runechat_effect/color/cyan,
	"purple" = /datum/runechat_effect/color/purple,
	"white" = /datum/runechat_effect/color/white,
	"flash1" = /datum/runechat_effect/flash/flash1,
	"flash2" = /datum/runechat_effect/flash/flash2,
	"flash3" = /datum/runechat_effect/flash/flash3,
	"glow1" = /datum/runechat_effect/glow/glow1,
	"glow2" = /datum/runechat_effect/glow/glow2,
	"glow3" = /datum/runechat_effect/glow/glow3,
	"rainbow" = /datum/runechat_effect/rainbow,
	"wave" = /datum/runechat_effect/wave,
	"wave2" = /datum/runechat_effect/wave2,
	"shake" = /datum/runechat_effect/shake,
	"slide" = /datum/runechat_effect/slide,
	"scroll" = /datum/runechat_effect/scroll,
))

/proc/parse_runechat_effect(message)
	var/static/regex/effect_regex = new(@"^\.rs-([a-z0-9]+)\s+")
	if(effect_regex.Find(message))
		var/effect_name = effect_regex.group[1]
		var/effect_path = GLOB.runechat_effect_map[effect_name]
		if(effect_path)
			var/cleaned_text = copytext_char(message, effect_regex.index + length(effect_regex.match) + 1)
			return list("text" = cleaned_text, "effect" = new effect_path)
	return list("text" = message, "effect" = null)

/datum/runechat_effect/color
	effect_type = RSEFFECT_YELLOW
	var/effect_color = RSCOLOR_YELLOW

/datum/runechat_effect/color/apply_effect(image/message_image, lifespan, client/owner)
	return

/datum/runechat_effect/color/yellow
	effect_name = "yellow"
	effect_color = RSCOLOR_YELLOW
	effect_type = RSEFFECT_YELLOW

/datum/runechat_effect/color/red
	effect_name = "red"
	effect_color = RSCOLOR_RED
	effect_type = RSEFFECT_RED

/datum/runechat_effect/color/green
	effect_name = "green"
	effect_color = RSCOLOR_GREEN
	effect_type = RSEFFECT_GREEN

/datum/runechat_effect/color/cyan
	effect_name = "cyan"
	effect_color = RSCOLOR_CYAN
	effect_type = RSEFFECT_CYAN

/datum/runechat_effect/color/purple
	effect_name = "purple"
	effect_color = RSCOLOR_PURPLE
	effect_type = RSEFFECT_PURPLE

/datum/runechat_effect/color/white
	effect_name = "white"
	effect_color = RSCOLOR_WHITE
	effect_type = RSEFFECT_WHITE

/datum/runechat_effect/flash
	var/flash_color1 = "#FFFFFF"
	var/flash_color2 = "#000000"

/datum/runechat_effect/flash/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	var/flash_count = min(lifespan / RSEFFECT_FLASH_SPEED, RSEFFECT_MAX_LOOPS)
	var/loop_time = lifespan / flash_count
	animate(message_image, color = flash_color1, time = loop_time / 2, flags = ANIMATION_REPEAT)
	animate(color = flash_color2, time = loop_time / 2)

/datum/runechat_effect/flash/flash1
	effect_name = "flash1"
	effect_type = RSEFFECT_FLASH1
	flash_color1 = RSFLASH1_COLOR1
	flash_color2 = RSFLASH1_COLOR2

/datum/runechat_effect/flash/flash2
	effect_name = "flash2"
	effect_type = RSEFFECT_FLASH2
	flash_color1 = RSFLASH2_COLOR1
	flash_color2 = RSFLASH2_COLOR2

/datum/runechat_effect/flash/flash3
	effect_name = "flash3"
	effect_type = RSEFFECT_FLASH3
	flash_color1 = RSFLASH3_COLOR1
	flash_color2 = RSFLASH3_COLOR2

/datum/runechat_effect/glow
	var/list/glow_colors = list()

/datum/runechat_effect/glow/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image || !length(glow_colors))
		return
	var/glow_count = min(lifespan / RSEFFECT_GLOW_SPEED, RSEFFECT_MAX_LOOPS)
	var/step_time = lifespan / (glow_count * length(glow_colors))
	for(var/i in 1 to glow_count)
		for(var/color in glow_colors)
			animate(message_image, color = color, time = step_time)

/datum/runechat_effect/glow/glow1
	effect_name = "glow1"
	effect_type = RSEFFECT_GLOW1
	glow_colors = RSGLOW1_COLORS

/datum/runechat_effect/glow/glow2
	effect_name = "glow2"
	effect_type = RSEFFECT_GLOW2
	glow_colors = RSGLOW2_COLORS

/datum/runechat_effect/glow/glow3
	effect_name = "glow3"
	effect_type = RSEFFECT_GLOW3
	glow_colors = RSGLOW3_COLORS

/datum/runechat_effect/rainbow
	effect_name = "rainbow"
	effect_type = RSEFFECT_RAINBOW
	var/list/rainbow_colors = list(
		"#FF0000", "#FF8800", "#FFFF00", "#00FF00",
		"#0088FF", "#0000FF", "#8800FF", "#FF00FF"
	)

/datum/runechat_effect/rainbow/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	var/rainbow_count = min(lifespan / RSEFFECT_RAINBOW_SPEED, RSEFFECT_MAX_LOOPS)
	var/step_time = lifespan / (rainbow_count * length(rainbow_colors))
	for(var/i in 1 to rainbow_count)
		for(var/color in rainbow_colors)
			animate(message_image, color = color, time = step_time)

/datum/runechat_effect/wave
	effect_name = "wave"
	effect_type = RSEFFECT_WAVE

/datum/runechat_effect/wave/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	var/wave_count = min(lifespan / RSEFFECT_WAVE_SPEED, RSEFFECT_MAX_LOOPS)
	var/step_time = lifespan / (wave_count * 2)
	for(var/i in 1 to wave_count)
		animate(message_image, pixel_w = message_image.pixel_w + RS_WAVE_AMPLITUDE, time = step_time)
		animate(pixel_w = message_image.pixel_w - RS_WAVE_AMPLITUDE, time = step_time)

/datum/runechat_effect/wave2
	effect_name = "wave2"
	effect_type = RSEFFECT_WAVE2

/datum/runechat_effect/wave2/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	var/wave_count = min(lifespan / RSEFFECT_WAVE_SPEED, RSEFFECT_MAX_LOOPS)
	var/step_time = lifespan / (wave_count * 4)
	for(var/i in 1 to wave_count)
		animate(message_image, pixel_w = message_image.pixel_w + RS_WAVE_AMPLITUDE, pixel_z = message_image.pixel_z + RS_WAVE_AMPLITUDE, time = step_time)
		animate(pixel_w = message_image.pixel_w - RS_WAVE_AMPLITUDE, pixel_z = message_image.pixel_z + RS_WAVE_AMPLITUDE, time = step_time)
		animate(pixel_w = message_image.pixel_w - RS_WAVE_AMPLITUDE, pixel_z = message_image.pixel_z - RS_WAVE_AMPLITUDE, time = step_time)
		animate(pixel_w = message_image.pixel_w + RS_WAVE_AMPLITUDE, pixel_z = message_image.pixel_z - RS_WAVE_AMPLITUDE, time = step_time)

/datum/runechat_effect/shake
	effect_name = "shake"
	effect_type = RSEFFECT_SHAKE

/datum/runechat_effect/shake/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	var/shake_count = min(lifespan / RSEFFECT_SHAKE_SPEED, RSEFFECT_MAX_LOOPS)
	var/step_time = lifespan / (shake_count * 4)
	for(var/i in 1 to shake_count)
		animate(message_image, pixel_w = message_image.pixel_w + RS_SHAKE_AMPLITUDE, time = step_time)
		animate(pixel_w = message_image.pixel_w - RS_SHAKE_AMPLITUDE * 2, time = step_time)
		animate(pixel_w = message_image.pixel_w + RS_SHAKE_AMPLITUDE * 2, time = step_time)
		animate(pixel_w = message_image.pixel_w - RS_SHAKE_AMPLITUDE, time = step_time)

/datum/runechat_effect/slide
	effect_name = "slide"
	effect_type = RSEFFECT_SLIDE

/datum/runechat_effect/slide/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	var/slide_in_time = RSEFFECT_SLIDE_SPEED * 0.3
	var/stay_time = RSEFFECT_SLIDE_SPEED * 0.4
	var/slide_out_time = RSEFFECT_SLIDE_SPEED * 0.3
	var/slide_distance = 20
	message_image.pixel_z = message_image.pixel_z + slide_distance
	animate(message_image, pixel_z = message_image.pixel_z - slide_distance, time = slide_in_time, easing = CUBIC_EASING)
	animate(time = stay_time)
	animate(pixel_z = message_image.pixel_z - slide_distance, time = slide_out_time, easing = CUBIC_EASING)

/datum/runechat_effect/scroll
	effect_name = "scroll"
	effect_type = RSEFFECT_SCROLL

/datum/runechat_effect/scroll/apply_effect(image/message_image, lifespan, client/owner)
	if(!message_image)
		return
	message_image.pixel_w = message_image.pixel_w + RS_SCROLL_DISTANCE
	animate(message_image, pixel_w = message_image.pixel_w - RS_SCROLL_DISTANCE * 2, time = lifespan, easing = LINEAR_EASING)

/datum/runechat_effect/proc/get_color_string()
	return null

/datum/runechat_effect/color/get_color_string()
	return effect_color
