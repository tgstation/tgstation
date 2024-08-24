/datum/artifact_effect
	//string added to artifact desc, if not discovered.
	var/examine_hint
	//string added to artifact desc, if the effect has been discovered
	var/examine_discovered
	//When you discover this, how many credits does it add to the sell price?
	var/discovered_credits = CARGO_CRATE_VALUE*0.75
	//how likely is it that this effect is added to an artifact?
	var/weight = 1
	//if defined, artifact must be this size to roll
	var/artifact_size
	//how strong is this effect,1-100
	var/potency
	//If the artifact doesnt have the right activator, cant be put on. If null, assume any
	var/list/valid_activators
	//If the artifact doesnt have this origin, cant be put on. If null, assume any
	var/list/valid_origins
	//sent/played on [de]activation
	var/activation_message
	var/activation_sound
	var/deactivation_message
	var/deactivation_sound

	//The artifact we're on.
	var/datum/component/artifact/our_artifact
	//Type of effect, shows up in Xray Machine
	var/type_name = "Generic Artifact Effect"

/datum/artifact_effect/New()
	. = ..()
	potency = rand(1,100)


//Called when the artifact has been created
/datum/artifact_effect/proc/setup()
	return
//Called when the artifact has been activated
/datum/artifact_effect/proc/effect_activate(silent)
	return
//Called when the artifact has been de-activated
/datum/artifact_effect/proc/effect_deactivate(silent)
	return
//Called when the artifact has been touched by a living mob.
/datum/artifact_effect/proc/effect_touched(mob/living/user)
	return
//Called on every artifact subsystem tick.
/datum/artifact_effect/proc/effect_process()
	return
//Called when the artifact is destroyed
/datum/artifact_effect/proc/on_destroy(atom/source)
	return
