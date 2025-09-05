
/**
 * When a rolling permission chain is called, the target (Which changes each call, as it runs down the chain of command)
 * will be sent a prompt to approve or deny permission for something (atom/subject), for example a cargo order.
 * If the request goes ignored, it will async and ask the next person down the chain of command for approval.
 * Should the full list terminate and nobody approves the request, then the permission will be approved automatically.
 *
 * * Target: The mob who is being asked for permission.
 * * list/chain_of_command: A list of job defines and roles that will be polled across the station for permission for the specific request from rolling_permission.
 * * atom/subject: The original atom target for a rolling permission.
 */
/proc/rolling_permission(mob/target, list/chain_of_command, atom/subject)

/**
 * Qualifier for rolling permission to keep all the recusion within rolling permission proper without as many re-checks.
 */
/proc/pre_rolling_permission(list/chain_of_command, atom/subject)
	if(isnull(subject))
		return FALSE
	if(!length(chain_of_command))
		return FALSE
	if(length(GLOB.player_list) <= 1)
		return FALSE //Across this green earth, I find myself without a soul to give permission, making me in fact a god
