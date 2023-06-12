/datum/greyscale_config/material_airlock
	name = "Material Airlock"
	icon_file = 'icons/obj/doors/airlocks/material/material.dmi'
	json_config = 'code/datums/greyscale/json_configs/material_airlock.json'

//
// BENCHES
//

/datum/greyscale_config/bench
	name = "Bench Middle"
	icon_file = 'icons/obj/sofa.dmi'
	json_config = 'code/datums/greyscale/json_configs/bench_middle.json'

/datum/greyscale_config/bench/solo
	name = "Bench Solo"
	json_config = 'code/datums/greyscale/json_configs/bench_solo.json'

/datum/greyscale_config/bench/left
	name = "Bench Left"
	json_config = 'code/datums/greyscale/json_configs/bench_left.json'

/datum/greyscale_config/bench/right
	name = "Bench Right"
	json_config = 'code/datums/greyscale/json_configs/bench_right.json'

/datum/greyscale_config/bench/corner
	name = "Bench Corner"
	json_config = 'code/datums/greyscale/json_configs/bench_corner.json'

//
// GIFTWRAP
// (Yes, some of these are items and not large objects, but it's better they stay grouped together)
//

/datum/greyscale_config/giftbox
	name = "Giftwrapped Package"
	icon_file = 'icons/obj/storage/wrapping.dmi'
	json_config = 'code/datums/greyscale/json_configs/giftboxes.json'

/datum/greyscale_config/wrap_paper
	name = "Wrapping Paper"
	icon_file = 'icons/obj/stack_objects.dmi'
	json_config = 'code/datums/greyscale/json_configs/wrap_paper.json'

//
// ATMOSPHERICS
//

// CANISTERS
/datum/greyscale_config/canister
	name = "Default Canister"
	icon_file = 'icons/obj/atmospherics/canisters.dmi'
	json_config = 'code/datums/greyscale/json_configs/canister_default.json'

/datum/greyscale_config/canister/base
	name = "Base Canister Style"
	json_config = 'code/datums/greyscale/json_configs/canister_base.json'

/datum/greyscale_config/canister/post_effects
	name = "Canister Post-Effects"
	json_config = 'code/datums/greyscale/json_configs/canister_post_effects.json'

/datum/greyscale_config/canister/stripe
	name = "Single Striped Canister"
	json_config = 'code/datums/greyscale/json_configs/canister_stripe.json'

/datum/greyscale_config/canister/double_stripe
	name = "Double Striped Canister"
	json_config = 'code/datums/greyscale/json_configs/canister_double_stripe.json'

/datum/greyscale_config/canister/hazard
	name = "Hazard Striped Canister"
	json_config = 'code/datums/greyscale/json_configs/canister_hazard.json'

/datum/greyscale_config/prototype_canister
	name = "Prototype Canister"
	icon_file = 'icons/obj/atmospherics/prototype_canister.dmi'
	json_config = 'code/datums/greyscale/json_configs/canister_proto.json'

/datum/greyscale_config/stationary_canister
	name = "Stationary Canister"
	icon_file = 'icons/obj/atmospherics/stationary_canisters.dmi'
	json_config = 'code/datums/greyscale/json_configs/smooth_canister_stationary.json'

// MISC ATMOSPHERICS
/datum/greyscale_config/meter
	name = "Meter"
	icon_file = 'icons/obj/atmospherics/pipes/meter.dmi'
	json_config = 'code/datums/greyscale/json_configs/meter.json'

/datum/greyscale_config/thermomachine
	name = "Thermomachine"
	icon_file = 'icons/obj/atmospherics/components/thermomachine.dmi'
	json_config = 'code/datums/greyscale/json_configs/thermomachine.json'
