## Basic documentation
Just a fair warning, if you train a model, you will need to include the config in the `vits/configs` folder. This folder should ideally exist in the persistent_data folder, but it doesn't as of now.

Before running, make sure you set up a `persistent_data` folder with a `tts_models` folder containing the checkpoint file that you plan to use (`.pth`).
The checkpoint file should be called `vits.pth`

To run, simply do `docker compose up -d`
This will build the container if it isn't build already, but if it is, then it'll re-use the built image.

To build the container after making any changes to the non-persistent files, you can do `docker compose build`
