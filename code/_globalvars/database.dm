	// MySQL configuration

GLOBAL_VAR_INIT(sqladdress, "localhost")
GLOBAL_PROTECT(sqladdress)
GLOBAL_VAR_INIT(sqlport, "3306")
GLOBAL_PROTECT(sqlport)
GLOBAL_VAR_INIT(sqlfdbkdb, "test")
GLOBAL_PROTECT(sqlfdbkdb)
GLOBAL_VAR_INIT(sqlfdbklogin, "root")
GLOBAL_PROTECT(sqlfdbklogin)
GLOBAL_VAR_INIT(sqlfdbkpass, "")
GLOBAL_PROTECT(sqlfdbkpass)
GLOBAL_VAR_INIT(sqlfdbktableprefix, "erro_") //backwords compatibility with downstream server hosts
GLOBAL_PROTECT(sqlfdbktableprefix)
