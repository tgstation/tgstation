/datum/design/component/bci
	abstract_type = /datum/design/component/bci
	category = list(
		RND_CATEGORY_CIRCUITRY_COMPS + RND_SUBCATEGORY_CIRCUITRY_BCI_COMPONENTS
	)

/datum/design/component/bci/bci_camera
	name = "BCI Camera"
	build_path = /obj/item/circuit_component/remotecam/bci

/datum/design/component/bci/object_overlay
	name = "Object Overlay Component"
	build_path = /obj/item/circuit_component/object_overlay

/datum/design/component/bci/bar_overlay
	name = "Bar Overlay Component"
	build_path = /obj/item/circuit_component/object_overlay/bar

/datum/design/component/bci/vox
	name = "VOX Announcement Component"
	build_path = /obj/item/circuit_component/vox

/datum/design/component/bci/thought_listener
	name = "Thought Listener Component"
	build_path = /obj/item/circuit_component/thought_listener

/datum/design/component/bci/target_intercept
	name = "BCI Target Interceptor"
	build_path = /obj/item/circuit_component/target_intercept

/datum/design/component/bci/counter_overlay
	name = "Counter Overlay Component"
	build_path = /obj/item/circuit_component/counter_overlay

/datum/design/component/bci/reagent_injector
	name = "Reagent Injector Component"
	build_path = /obj/item/circuit_component/reagent_injector

/datum/design/component/bci/install_detector
	name = "Install Detector Component"
	build_path = /obj/item/circuit_component/install_detector
