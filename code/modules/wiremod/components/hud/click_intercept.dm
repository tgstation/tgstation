/**
 * # Click Intercept Component
 *
 * When activated intercepts next click and outputs clicked atom.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/click_intercept
	display_name = "Target Intercept"
	desc = "Requires a BCI shell. A component that when activated will intercept next user's click and output the object that was clicked."

	required_shells = list(/obj/item/organ/cyberimp/bci)

	var/datum/port/output/clicked_atom

	var/obj/item/organ/cyberimp/bci/bci
	var/intercept_cooldown = 1 SECONDS

/obj/item/circuit_component/click_intercept/Initialize()
	. = ..()
	trigger_input = add_input_port("Activate", PORT_TYPE_SIGNAL)
	trigger_output = add_output_port("Target", PORT_TYPE_SIGNAL)
	clicked_atom = add_output_port("Targeted Object", PORT_TYPE_ATOM)

/obj/item/circuit_component/click_intercept/register_shell(atom/movable/shell)
	bci = shell
	RegisterSignal(shell, COMSIG_ORGAN_REMOVED, .proc/on_organ_removed)

/obj/item/circuit_component/click_intercept/unregister_shell(atom/movable/shell)
	bci = null
	UnregisterSignal(shell, COMSIG_ORGAN_REMOVED)

/obj/item/circuit_component/click_intercept/input_received(datum/port/input/port)
	. = ..()

	if(. || !bci)
		return

	var/mob/living/owner = bci.owner
	if(!owner || !istype(owner) || !owner.client)
		return

	if(TIMER_COOLDOWN_CHECK(parent, COOLDOWN_CIRCUIT_CLICK_INTERCEPT))
		return

	to_chat(owner, "<B>Left-click to activate click interceptor!</B>")
	owner.client.click_intercept = src

/obj/item/circuit_component/click_intercept/proc/on_organ_removed(datum/source, mob/living/carbon/owner)
	SIGNAL_HANDLER

	if(owner.client && owner.client.click_intercept == src)
		owner.client.click_intercept = null

/obj/item/circuit_component/click_intercept/proc/InterceptClickOn(mob/user, params, atom/object)
	user.client.click_intercept = null
	clicked_atom.set_output(object)
	trigger_output.set_output(COMPONENT_SIGNAL)
	TIMER_COOLDOWN_START(parent, COOLDOWN_CIRCUIT_CLICK_INTERCEPT, intercept_cooldown)

/obj/item/circuit_component/click_intercept/get_ui_notices()
	. = ..()
	. += create_ui_notice("Target Interception Cooldown: [DisplayTimeText(intercept_cooldown)]", "orange", "stopwatch")
	. += create_ui_notice("Only usable in BCI circuits", "orange", "info")
