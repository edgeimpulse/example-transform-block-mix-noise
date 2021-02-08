# Transformation block: Mix background noise into audio files

This is an Edge Impulse [transformation block](https://docs.edgeimpulse.com/docs/creating-a-transformation-block) that mixes background noise into audio files. It randomly picks a background sample, randomly changes the volume on the noise, and then combines these with the original file. It also downsamples the final audio file. You can use this to augment your data with realistic background noise in Edge Impulse.

## Usage in Edge Impulse

1. Install the Edge Impulse CLI.
1. Initialize the block:

    ```
    $ edge-impulse-blocks init
    ```

    (To log in with a different account, run `edge-impulse-blocks init --clean`)

1. Push the block:

    ```
    $ edge-impulse-blocks push
    ```

1. In your Edge Impulse organization now go to **Data transformation > Transformation blocks**, select your new transformation block and click **Edit transformation block**. Then for 'CLI Arguments' set `--frequency 16000 --out-count 10`.

## How to test locally

1. Install Docker for desktop.
1. Build the container

    ```
    $ docker build -t transform-mix-noise .
    ```

1. Run the script (this creates 10 files, and downsamples to 16KHz):

    ```
    $ docker run --rm -it -v $PWD/:/data transform-mix-noise --in-file /data/data/jan.wav --out-directory /data/out --frequency 16000 --out-count 10
    ```

1. The `out/` directory now contains 10 files.

## Updating the background audio file

To change the background audio go to `Dockerfile` and change the URL of the YouTube video. Alternatively you can copy a file into the container yourself.
