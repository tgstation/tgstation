///Called from /proc/end_cooldown, for timer-stoppable cooldowns: (index)
#define COMSIG_CD_STOP(cd_index) "cooldown_[cd_index]"
///Called from /proc/reset_cooldown, for timer-stoppable cooldowns: (timeleft, index)
#define COMSIG_CD_RESET(cd_index) "cd_reset_[cd_index]"
