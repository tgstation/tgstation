var/master_mode = "traitor"//"extended"
var/secret_force_mode = "secret" // if this is anything but "secret", the secret rotation will forceably choose this mode

var/wavesecret = 0 // meteor mode, delays wave progression, terrible name
var/datum/station_state/start_state = null // Used in round-end report
