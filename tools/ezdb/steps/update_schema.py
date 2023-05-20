from contextlib import closing
from ..ezdb.changes import get_changes
from ..ezdb.config import read_config
from ..ezdb.mysql import execute_sql, insert_new_schema_query, open_connection
from .step import Step

class UpdateSchema(Step):
    @staticmethod
    def should_run() -> bool:
        # Last step is always run
        return True

    @staticmethod
    def run(args):
        config = read_config()
        assert config is not None, "No config file found"

        database = config["FEEDBACK_DATABASE"]
        assert database is not None, "No database found in config file"

        with open_connection() as connection:
            with closing(connection.cursor()) as cursor:
                cursor.execute(f"USE {database}")
                cursor.execute("SELECT major, minor FROM `schema_revision` ORDER BY `major` DESC, `minor` DESC LIMIT 1")
                (major_version, minor_version) = cursor.fetchone()

            changes = get_changes()
            for change in changes:
                if change.major_version != major_version:
                    print("NOT IMPLEMENTED: Major version change, these historically require extra tooling")
                    continue

                if change.minor_version > minor_version:
                    print(f"Running change {change.major_version}.{change.minor_version}")
                    execute_sql(change.sql + ";" + insert_new_schema_query(change.major_version, change.minor_version))
                else:
                    print("No updates necessary")
                    return
