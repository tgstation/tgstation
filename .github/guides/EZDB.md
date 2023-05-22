# Quickly setting up a development database with ezdb
While you do not need a database to code for tgstation, it is a prerequisite to many important features, especially on the admin side. Thus, if you are working in any code that benefits from it, it can be helpful to have one handy.

**ezdb** is a tool for quickly setting up an isolated development database. It will manage downloading MariaDB, creating the database, setting it up, and updating it when the code evolves. It is not recommended for use in production servers, but is perfect for quick development.

To run ezdb, go to `tools/ezdb`, and double-click on ezdb.bat. This will set up the database on port 1338, but you can configure this with `--port`. When it is done, you should be able to launch tgstation as normal and have database access. This runs on the same Python bootstrapper as things like the map merge tool, which can sometimes be flaky.

If you wish to delete the ezdb database, delete the `db` folder as well as `config/ezdb.txt`.

To update ezdb, run the script again. This will both look for any updates in the database changelog, as well as update your schema revision.

Contact Mothblocks if you face any issues in this process.
