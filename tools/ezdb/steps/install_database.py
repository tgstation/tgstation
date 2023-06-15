import argparse
import secrets
import subprocess
from ..ezdb.paths import get_config_path, get_data_path, get_mariadb_bin_path, get_mariadb_daemon_path, get_mariadb_install_db_path
from .step import Step

def create_password() -> str:
    return secrets.token_urlsafe(40)

class InstallDatabase(Step):
    @staticmethod
    def should_run() -> bool:
        # If the db folder exists, but the config doesn't, we cancelled
        # halfway through and ought to start over by deleting the data folder.
        return get_mariadb_bin_path().exists() and (not get_data_path().exists() or not get_config_path().exists())

    @staticmethod
    def run(args: argparse.Namespace):
        data_folder = get_data_path()
        if data_folder.exists():
            print("Deleting old data folder")
            data_folder.rmdir()

        password = create_password()

        print("Installing database...")

        subprocess.run(
            [
                str(get_mariadb_install_db_path()),
                f"--port={args.port}",
                f"--password={password}",
            ],
            check = True,
            stderr = subprocess.STDOUT,
        )

        print("Creating config...")
        with open(get_config_path(), "w") as file:
            file.write("SQL_ENABLED\n")
            file.write(f"PORT {args.port}\n")
            file.write(f"FEEDBACK_LOGIN root\n")
            file.write(f"FEEDBACK_PASSWORD {password}\n")
            file.write("FEEDBACK_DATABASE tgstation\n")
            file.write("FEEDBACK_TABLEPREFIX\n")
            file.write(f"DB_DAEMON {str(get_mariadb_daemon_path())}")
