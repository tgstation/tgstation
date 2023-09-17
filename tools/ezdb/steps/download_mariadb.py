import os
import pathlib
import tempfile
import urllib.request
import zipfile
from ..ezdb.paths import get_config_path, get_data_path, get_db_path, get_mariadb_bin_path, get_mariadb_daemon_path, get_mariadb_install_db_path
from .step import Step

# Theoretically, this could use the REST API that MariaDB has to find the URL given a version:
# https://downloads.mariadb.org/rest-api/mariadb/10.11
DOWNLOAD_URL = "http://downloads.mariadb.org/rest-api/mariadb/10.11.2/mariadb-10.11.2-winx64.zip"
FOLDER_NAME = "mariadb-10.11.2-winx64"

temp_extract_path = get_db_path() / "_temp/"

class DownloadMariaDB(Step):
    @staticmethod
    def should_run() -> bool:
        return not get_mariadb_bin_path().exists()

    @staticmethod
    def run(args):
        if temp_extract_path.exists():
            print("Deleting old temporary extract folder")
            temp_extract_path.rmdir()

        print("Downloading portable MariaDB...")

        # delete = False so we can write to it
        temporary_file = tempfile.NamedTemporaryFile(delete = False)

        try:
            urllib.request.urlretrieve(DOWNLOAD_URL, temporary_file.name)

            print("Extracting...")
            os.makedirs(temp_extract_path, exist_ok = True)
            with zipfile.ZipFile(temporary_file) as zip_file:
                for file in zip_file.namelist():
                    if file.startswith(f"{FOLDER_NAME}/bin/"):
                        with zip_file.open(file) as source, open(temp_extract_path / pathlib.Path(file).name, "wb") as target:
                            target.write(source.read())

            print("Moving...")

            temp_extract_path.rename(get_mariadb_bin_path())
        finally:
            temporary_file.close()

            if temp_extract_path.exists():
                temp_extract_path.rmdir()
