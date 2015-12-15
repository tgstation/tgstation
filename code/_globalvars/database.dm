	// MySQL configuration

var/sqladdress = "localhost"
var/sqlport = "3306"
var/sqlfdbkdb = "test"
var/sqlfdbklogin = "root"
var/sqlfdbkpass = ""
var/sqlfdbktableprefix = "erro_" //backwords compatibility with downstream server hosts

//Database connections
//A connection is established on world creation. Ideally, the connection dies when the server restarts (After feedback logging.).
var/DBConnection/dbcon = new()	//Feedback database (New database)
