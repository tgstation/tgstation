GLOBAL_VAR_INIT(master_mode, "traitor") //"extended"
GLOBAL_VAR_INIT(secret_force_mode, "secret") // if this is anything but "secret", the secret rotation will forceably choose this mode

GLOBAL_VAR_INIT(wavesecret, 0) // meteor mode, delays wave progression, terrible name
GLOBAL_DATUM(start_state, /datum/station_state) // Used in round-end report

// Cult, needs to be global so admin cultists are functional
GLOBAL_VAR_INIT(blood_target, null) // Cult Master's target or Construct's Master
GLOBAL_DATUM(blood_target_image, /image)
GLOBAL_DATUM(sac_mind, /datum/mind)
GLOBAL_VAR_INIT(sac_image, null)
GLOBAL_VAR_INIT(cult_mastered, FALSE)
GLOBAL_VAR_INIT(reckoning_complete, FALSE)
GLOBAL_VAR_INIT(sac_complete, FALSE)