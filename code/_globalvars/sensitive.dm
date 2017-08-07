//Server API key
GLOBAL_REAL_VAR(comms_key) = "default_pwd"
GLOBAL_REAL_VAR(comms_allowed) = FALSE //By default, the server does not allow messages to be sent to it, unless the key is strong enough (this is to prevent misconfigured servers from becoming vulnerable)

//Medal API stuff

GLOBAL_REAL_VAR(medal_hub)
GLOBAL_REAL_VAR(medal_pass) = " "
GLOBAL_REAL_VAR(medals_enabled) = TRUE	//will be auto set to false if the game fails contacting the medal hub to prevent unneeded calls.

//Github API key
GLOBAL_REAL_VAR(github_api_key)

// MySQL configuration

GLOBAL_REAL_VAR(sqladdress) = "localhost"
GLOBAL_REAL_VAR(sqlport) = "3306"
GLOBAL_REAL_VAR(sqlfdbkdb) = "test"
GLOBAL_REAL_VAR(sqlfdbklogin) = "root"
GLOBAL_REAL_VAR(sqlfdbkpass) = ""
GLOBAL_REAL_VAR(sqlfdbktableprefix) = ""
