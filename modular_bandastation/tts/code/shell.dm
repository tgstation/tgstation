#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

#define SHELLEO_NAME "data/shelleo."
#define SHELLEO_ERR ".err"
#define SHELLEO_OUT ".out"

/proc/apply_sound_effect(datum/singleton/sound_effect/effect, filename_input, filename_output)
	if(!effect)
		CRASH("Invalid sound effect chosen.")

	var/taskset
	CONFIG_GET(string/ffmpeg_cpuaffinity)
	if(CONFIG_GET(string/ffmpeg_cpuaffinity))
		taskset = "taskset -ac [CONFIG_GET(string/ffmpeg_cpuaffinity)]"

	var/command = {"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "[effect.ffmpeg_arguments]" [filename_output]"}
	var/list/output = world.shelleo(command)

	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]
	if(errorlevel)
		log_runtime("Error: apply_sound_effect([effect.suffix], [filename_input], [filename_output]) - See debug logs.")
		logger.Log(LOG_CATEGORY_DEBUG, "apply_sound_effect([effect.suffix], [filename_input], [filename_output]) STDOUT: [stdout]")
		logger.Log(LOG_CATEGORY_DEBUG, "apply_sound_effect([effect.suffix], [filename_input], [filename_output]) STDERR: [stderr]")
		return FALSE
	return TRUE

/datum/singleton/sound_effect
	var/suffix
	var/ffmpeg_arguments

/datum/singleton/sound_effect/radio
	suffix = "_radio"
	ffmpeg_arguments = "highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log"

/datum/singleton/sound_effect/robot
	suffix = "_robot"
	ffmpeg_arguments = "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5"

/datum/singleton/sound_effect/radio_robot
	suffix = "_radio_robot"
	ffmpeg_arguments = "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5, highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log"

/datum/singleton/sound_effect/megaphone
	suffix = "_megaphone"
	ffmpeg_arguments = "highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log"

/datum/singleton/sound_effect/megaphone_robot
	suffix = "_megaphone_robot"
	ffmpeg_arguments = "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log"

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR

#undef SHELLEO_NAME
#undef SHELLEO_ERR
#undef SHELLEO_OUT
