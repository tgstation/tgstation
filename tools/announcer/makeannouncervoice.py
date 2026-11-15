# /// script
# requires-python = ">=3.10"
# dependencies = ["numpy", "scipy", "soundfile"]
# ///
"""Apply the announcer voice filter to WAV files.

Usage:
  makeannouncervoice.py raw.wav finished.ogg
  makeannouncervoice.py raw_folder finished_folder --format ogg
  makeannouncervoice.py --drop raw.wav [another.wav ...]

The packages this needs are listed above. Drop WAVs onto the BAT to use it.
"""

import argparse
from pathlib import Path
import sys
import soundfile as sf
import numpy as np
from scipy.signal import butter, sosfilt, lfilter, resample_poly, fftconvolve

SAMPLE_RATE = 44100
# Settings for the sound. The command-line options let you turn each layer up or down.
PRESET = dict(
    # The pitches and volumes of the extra robotic tones.
    notes=[
        (185.5, -15.0),
        (277.9, -5.9),
        (371.1, 1.9),
        (555.6, 5.0),
        (742.4, -2.6),
        (834.0, -4.5),
        (927.0, -11.2),
        (1112.5, -6.9),
        (1668.0, -8.5),
        (2225.0, -15.3),
    ],
    # How much of the voice each tone listens to, and how quickly it follows it.
    bw_oct=0.67,
    bw_by_note={277.9: 1.0, 371.1: 0.4, 555.6: 0.5},
    band_by_note={},
    env_hz=25.0,
    # Slightly different pitches in each ear make the tones sound wider.
    detune_hz=0.3,
    tone_gain=0.0,
    tone_center=0.3,
    # Cut some bass from the real voice and adjust its sound a little.
    hp_hz=430.0,
    hp_order=2,
    voice_eq=[(330.0, 2.0, -2.2), (660.0, 1.2, 1.5), (2800.0, 0.8, 1.0)],
    voice_gain=0.0,
    split_hz=3000.0,
    uv_lo=-18.0,
    uv_hi=-8.0,
    uv_ref=5.13,
    uv_floor=0.0,
    # Keep the s, sh and t sounds clear without making them too loud.
    sib_gain=3.0,
    sib_det=(5500.0, 7800.0),
    sib_top=7000.0,
    sib_ceil=-3.5,
    # Add a little hiss when those sounds happen, rather than all the time.
    air_gain=-1.0,
    air_lo=7600.0,
    air_slope=3.4,
    sibn_db=10.0,
    sibn_lo=4900.0,
    sibn_thr=-12.0,
    sibn_ceil=-2.5,
    sibn_att=0.003,
    sibn_rel=0.02,
    # When the quieter copies play, how loud they are, and how muffled they sound.
    echo_t1=0.066,
    echo_g1=0.65,
    echo_t2=0.2099,
    echo_g2=-0.37,
    echo_rep=0.5,
    echo_lp1=350.0,
    echo_lp2=2900.0,
    echo_gain=1.0,
    # Reverb settings: low/high pitch, fade time, volume, and time to fade in.
    rev_gain=0.0,
    rev_bands=[
        (0, 450, 1.35, -30.0, 0.07),
        (450, 1000, 1.0, -22.7, 0.07),
        (1000, 2000, 0.98, -19.5, 0.07),
        (2000, 4000, 0.6, -18.5, 0.08),
        (4000, 9000, 0.9, -27.8, 0.08),
    ],
    rev_width=0.9,
    rev_width_hi=0.0,
    treble_side=-11.0,
    rev_predelay=0.012,
    # Finished volume, extra space at the end, and a little space before the voice.
    out_rms_db=-22.1,
    tail=1.2,
    lead=0.04,
    seed=7,  # Use the same random sounds each time so the result is repeatable.
)


def peq(audio, frequency, quality, gain_db):
    """Turn one part of the voice's sound up or down."""
    amplitude = 10 ** (gain_db / 40)
    angle = 2 * np.pi * frequency / SAMPLE_RATE
    alpha = np.sin(angle) / (2 * quality)
    numerator = [1 + alpha * amplitude, -2 * np.cos(angle), 1 - alpha * amplitude]
    denominator = [1 + alpha / amplitude, -2 * np.cos(angle), 1 - alpha / amplitude]
    return lfilter(
        np.array(numerator) / denominator[0],
        np.array(denominator) / denominator[0],
        audio,
    )


def env_follow(audio, cutoff):
    """Follow how loud the sound gets, but smooth out the tiny jumps."""
    return np.maximum(
        sosfilt(butter(2, cutoff, "low", fs=SAMPLE_RATE, output="sos"), np.abs(audio))
        * (np.pi / 2),
        0,
    )


def reverb_ir(settings):
    """Make a short room sound that we can mix with the voice as reverb."""
    rng = np.random.default_rng(settings["seed"])
    length = int(1.6 * max((b[2] for b in settings["rev_bands"])) * SAMPLE_RATE)
    time = np.arange(length) / SAMPLE_RATE
    mid = np.zeros(length)
    side = np.zeros(length)
    # Give the low and high parts of the room their own fade times.
    for band in settings["rev_bands"]:
        low, high, decay, gain_db = band[:4]
        attack = band[4] if len(band) > 4 else 0.0
        band_filter = (
            butter(2, [low, high], "band", fs=SAMPLE_RATE, output="sos")
            if low > 0
            else butter(2, high, "low", fs=SAMPLE_RATE, output="sos")
        )
        # Let the room sound build up, then fade away.
        shape = 10 ** (-3 * time / decay) * (
            1 - np.exp(-time / attack) if attack > 0 else 1
        )
        # Keep the high part in the middle and spread the lower part across both ears.
        width = settings["rev_width_hi"] if low >= 2000 else settings["rev_width"]
        for accumulator, weight in ((mid, 1.0), (side, width)):
            noise = sosfilt(band_filter, rng.standard_normal(length) * shape)
            accumulator += (
                noise
                / np.sqrt((noise**2).sum())
                * 10 ** (gain_db / 20)
                * weight
                / np.sqrt(1 + width**2)
            )
    # Make the left and right room sounds and leave a short gap before they start.
    impulse = np.stack([mid + side, mid - side], 1)
    return np.concatenate(
        [np.zeros((int(settings["rev_predelay"] * SAMPLE_RATE), 2)), impulse]
    )


def shaped_noise(length, settings, rng):
    """Make the little hiss used to give s and sh sounds more bite."""
    fft_size = 1 << int(np.ceil(np.log2(length)))
    spectrum = np.fft.rfft(rng.standard_normal(fft_size))
    frequencies = np.fft.rfftfreq(fft_size, 1 / SAMPLE_RATE)
    gain = np.where(
        frequencies < settings["air_lo"],
        10 ** (settings["sibn_db"] / 20),
        10 ** (-(frequencies - settings["air_lo"]) / 1000 * settings["air_slope"] / 20),
    )
    # Take out the low rumble and the very highest hiss.
    below_band = frequencies < settings["sibn_lo"]
    gain[below_band] = 10 ** (settings["sibn_db"] / 20) * 10 ** (
        -(settings["sibn_lo"] - frequencies[below_band]) / 1000 * 14 / 20
    )
    gain[frequencies > 15500] = 0
    if settings["sibn_db"] < -60:
        gain = np.where(
            frequencies < settings["air_lo"],
            10 ** (-(settings["air_lo"] - frequencies) / 1000 * 12 / 20),
            gain,
        )
    return np.fft.irfft(spectrum * gain, fft_size)[:length]


def echo_ir(settings):
    """Make a few quieter, muffled copies that play after the voice."""
    length = int(0.5 * SAMPLE_RATE)

    def darken(audio):
        # Cut the high sounds so the copies are more muffled than the main voice.
        return sosfilt(
            butter(4, settings["echo_lp2"], "low", fs=SAMPLE_RATE, output="sos"),
            lfilter(*butter(1, settings["echo_lp1"], "low", fs=SAMPLE_RATE), audio),
        )

    # Put each copy at its delay time. The negative volume flips the second copy.
    first = np.zeros(length)
    first[int(round(settings["echo_t1"] * SAMPLE_RATE))] = 1
    second = np.zeros(length)
    second[int(round(settings["echo_t2"] * SAMPLE_RATE))] = 1
    repeat = np.zeros(length)
    repeat[int(round(2 * settings["echo_t1"] * SAMPLE_RATE))] = 1
    impulse = (
        settings["echo_g1"] * darken(first)
        + settings["echo_g2"]
        * lfilter(*butter(1, 2500.0, "low", fs=SAMPLE_RATE), darken(second))
        + settings["echo_rep"] * settings["echo_g1"] ** 2 * darken(darken(repeat))
    )
    return impulse * settings["echo_gain"]


def prepare_voice(audio, sample_rate, settings):
    """Get the voice ready before adding the effect."""
    from math import gcd

    # Make every file use the same sample rate.
    divisor = gcd(SAMPLE_RATE, sample_rate)
    samples = (
        resample_poly(audio, SAMPLE_RATE // divisor, sample_rate // divisor)
        if sample_rate != SAMPLE_RATE
        else audio.copy()
    )
    # Find the talking parts and bring them to a steady starting volume.
    speech_envelope = np.sqrt(np.convolve(samples**2, np.ones(2205) / 2205, "same"))
    samples = (
        samples
        / np.sqrt(np.mean(samples[speech_envelope > 0.1 * speech_envelope.max()] ** 2))
        * 0.1
    )
    # Cut off extra silence at the start, but leave a small gap before the words.
    onset = int(np.argmax(speech_envelope > 0.03 * speech_envelope.max()))
    start = max(0, onset - int(settings["lead"] * SAMPLE_RATE))
    samples = samples[start:]
    # Remember where the talking is, so silence does not throw off later checks.
    speech_mask = np.concatenate(
        [
            (speech_envelope > 0.1 * speech_envelope.max())[start:],
            np.zeros(int(settings["tail"] * SAMPLE_RATE), bool),
        ]
    )
    # Leave room at the end so the echoes and reverb are not cut off.
    samples = np.concatenate([samples, np.zeros(int(settings["tail"] * SAMPLE_RATE))])
    return (samples, speech_mask)


def make_chord(samples, settings, rng):
    """Add tones that follow the words to make the voice more robotic."""
    length = len(samples)
    time = np.arange(length) / SAMPLE_RATE
    tones = np.zeros((length, 2))
    tone_gain = 10 ** (settings["tone_gain"] / 20)
    # Each tone listens to a small part of the voice.
    for frequency, gain_db in settings["notes"]:
        bandwidth = settings["bw_by_note"].get(frequency, settings["bw_oct"])
        low = frequency * 2 ** (-bandwidth / 2)
        high = frequency * 2 ** (bandwidth / 2)
        if str(frequency) in settings["band_by_note"]:
            low, high = settings["band_by_note"][str(frequency)]
        # Follow that part's volume so the tone speaks along with the words.
        envelope = (
            env_follow(
                sosfilt(
                    butter(2, [low, high], "band", fs=SAMPLE_RATE, output="sos"),
                    samples,
                ),
                settings["env_hz"],
            )
            * 10 ** (gain_db / 20)
            * tone_gain
        )
        # Shift the left and right pitches a tiny bit so they are not identical.
        detune = (
            settings["detune_hz"] * (0.6 + 0.8 * rng.random()) * rng.choice([-1, 1])
        )
        phase = rng.random(2) * 2 * np.pi
        # Keep a little of the tone in the middle too.
        center_tone = settings["tone_center"] * np.sin(
            2 * np.pi * frequency * time + rng.random() * 2 * np.pi
        )
        normalizer = 1 / np.sqrt(1 + settings["tone_center"] ** 2)
        tones[:, 0] += (
            envelope
            * normalizer
            * (np.sin(2 * np.pi * (frequency - detune) * time + phase[0]) + center_tone)
        )
        tones[:, 1] += (
            envelope
            * normalizer
            * (np.sin(2 * np.pi * (frequency + detune) * time + phase[1]) + center_tone)
        )
    return tones


def make_voice(samples, speech_mask, settings, rng):
    """Keep the real words clear and give s and sh sounds more bite."""
    length = len(samples)
    filtered = sosfilt(butter(8, 7800.0, "low", fs=SAMPLE_RATE, output="sos"), samples)

    def crossover(audio, kind):
        return sosfilt(
            butter(2, settings["split_hz"], kind, fs=SAMPLE_RATE, output="sos"),
            sosfilt(
                butter(2, settings["split_hz"], kind, fs=SAMPLE_RATE, output="sos"),
                audio,
            ),
        )

    # Work on the low voice and the high sounds separately.
    body = crossover(filtered, "low")
    treble = crossover(filtered, "high")
    treble = (
        sosfilt(
            butter(2, settings["sib_top"], "low", fs=SAMPLE_RATE, output="sos"), treble
        )
        if settings["sib_top"]
        else treble
    )
    # Weak low sounds help us spot things like s and sh instead of vowel sounds.
    low_level = 20 * np.log10(
        env_follow(
            sosfilt(
                butter(2, [120.0, 1000.0], "band", fs=SAMPLE_RATE, output="sos"),
                filtered,
            ),
            60.0,
        )
        / 0.1
        + 1e-09
    )
    # Compare against this voice's own volume, rather than one fixed volume.
    low_level = low_level - (
        np.percentile(low_level[speech_mask], 90) - settings["uv_ref"]
    )
    unvoiced = np.clip(
        (settings["uv_hi"] - low_level) / (settings["uv_hi"] - settings["uv_lo"]), 0, 1
    )
    unvoiced = sosfilt(butter(1, 80.0, "low", fs=SAMPLE_RATE, output="sos"), unvoiced)
    # Bring up the high sounds, but hold them back when they get too loud.
    envelope = env_follow(treble, 150.0)
    level_db = 20 * np.log10(envelope / 0.1 + 1e-09)
    gain_db = (
        settings["sib_gain"]
        - np.maximum(0, level_db + settings["sib_gain"] - settings["sib_ceil"]) * 0.75
    )
    treble_gain = (
        unvoiced + (1 - unvoiced) * 10 ** (settings["uv_floor"] / 20)
    ) * 10 ** (gain_db / 20)
    # Only add extra hiss when there is a real s, sh or similar sound.
    detector = env_follow(
        sosfilt(
            butter(4, list(settings["sib_det"]), "band", fs=SAMPLE_RATE, output="sos"),
            filtered,
        ),
        150.0,
    )[::44]
    gate = np.clip(
        (20 * np.log10(detector / 0.1 + 1e-09) - settings["sibn_thr"]) / 4.0 + 1, 0, 1
    )
    drive = detector * gate
    ceiling = 0.1 * 10 ** (settings["sibn_ceil"] / 20)
    drive = np.where(drive > ceiling, ceiling * (drive / ceiling) ** 0.25, drive)
    # Let the hiss start quickly and fade a little more slowly so it does not click.
    smoothed = np.zeros(len(drive))
    previous = 0.0
    attack = np.exp(-1 / (settings["sibn_att"] * SAMPLE_RATE / 44))
    release = np.exp(-1 / (settings["sibn_rel"] * SAMPLE_RATE / 44))
    for index, value in enumerate(drive):
        coefficient = attack if value > previous else release
        previous = coefficient * previous + (1 - coefficient) * value
        smoothed[index] = previous
    noise_envelope = np.interp(
        np.arange(length), np.arange(len(smoothed)) * 44, smoothed
    )
    # Make the hiss follow those sounds instead of running in the background.
    air = (
        shaped_noise(length, settings, rng)
        * noise_envelope
        * 10 ** (settings["air_gain"] / 20)
    )
    # Remove some bass so the real voice has more of a speaker/PA sound.
    filtered_body = sosfilt(
        butter(
            settings["hp_order"],
            settings["hp_hz"],
            "high",
            fs=SAMPLE_RATE,
            output="sos",
        ),
        body,
    )
    # Make a few small changes to the voice's tone, then put it back together.
    for frequency, quality, gain_db in settings["voice_eq"]:
        filtered_body = peq(filtered_body, frequency, quality, gain_db)
    sibilants = treble * treble_gain + air
    voice_gain = 10 ** (settings["voice_gain"] / 20)
    filtered_body = filtered_body * voice_gain
    sibilants = sibilants * voice_gain
    voice = filtered_body + sibilants
    return (voice, sibilants)


def add_echo_and_reverb(combined, sibilants, settings, rng):
    """Add the quieter delayed copies and the reverb around them."""
    length = len(combined)
    side = np.zeros(length)
    # Make the s and sh sounds a little different in each ear.
    if settings["treble_side"] > -60:
        indices = np.arange(int(0.004 * SAMPLE_RATE))
        kernel = rng.standard_normal(len(indices)) * np.exp(
            -indices / (0.0012 * SAMPLE_RATE)
        )
        kernel /= np.sqrt((kernel**2).sum())
        side = lfilter(
            *butter(1, 3500.0, "low", fs=SAMPLE_RATE),
            fftconvolve(sibilants, kernel)[:length],
        ) * 10 ** (settings["treble_side"] / 20)
        combined[:, 0] += side
        combined[:, 1] -= side
    # Add the delayed copies first, so they also get reverb.
    echo_kernel = echo_ir(settings)
    echoes = np.stack(
        [fftconvolve(combined[:, audio], echo_kernel)[:length] for audio in (0, 1)], 1
    )
    room_input = combined + echoes
    # Add the room sound around the voice and its copies.
    room_kernel = reverb_ir(settings)
    reverb = np.stack(
        [
            fftconvolve(room_input.mean(1), room_kernel[:, audio])[:length]
            for audio in (0, 1)
        ],
        1,
    ) * 10 ** (settings["rev_gain"] / 20)
    output = room_input + reverb
    return output


def announcer(audio, sample_rate, settings=PRESET):
    """Put the whole effect together, then set the finished volume."""
    settings = {**PRESET, **settings}
    rng = np.random.default_rng(settings["seed"])
    # Get the voice ready, then make the robotic and clear voice layers.
    samples, speech_mask = prepare_voice(audio, sample_rate, settings)
    tones = make_chord(samples, settings, rng)
    voice, sibilants = make_voice(samples, speech_mask, settings, rng)
    # Mix the layers and add the delayed copies and reverb.
    output = add_echo_and_reverb(tones + voice[:, None], sibilants, settings, rng)
    mono = output.mean(1)
    speech_envelope = np.sqrt(np.convolve(mono**2, np.ones(2205) / 2205, "same"))
    # Set the volume using the talking parts, not the silence at the end.
    normalization = 10 ** (settings["out_rms_db"] / 20) / np.sqrt(
        np.mean(mono[speech_envelope > 0.1 * speech_envelope.max()] ** 2)
    )
    return output * normalization


def convert(source, destination, adjustments, gain_db):
    """Read one file, add the effect, and save the finished file."""
    audio, rate = sf.read(source, always_2d=True)
    # Start with one voice track even if the input has left and right channels.
    mono = audio.mean(axis=1)
    if len(mono) / rate < 0.05:
        raise ValueError(f"{source}: input must be at least 50 ms long")
    if not np.isfinite(mono).all() or not np.any(np.abs(mono) > 1e-10):
        raise ValueError(f"{source}: input must contain finite, non-silent audio")
    output = announcer(mono, rate, adjustments)
    if not np.isfinite(output).all():
        raise ValueError(f"{source}: processing produced invalid samples")
    output *= 10 ** (gain_db / 20)
    peak = float(np.max(np.abs(output)))
    # Turn it down if needed so the loudest parts do not clip.
    attenuation = min(1.0, 0.98 / peak)
    output *= attenuation
    destination.parent.mkdir(parents=True, exist_ok=True)
    subtype = "VORBIS" if destination.suffix.lower() == ".ogg" else "PCM_16"
    # Write smaller blocks so Windows does not crash while saving long lines.
    with sf.SoundFile(
        destination,
        mode="w",
        samplerate=SAMPLE_RATE,
        channels=output.shape[1],
        subtype=subtype,
    ) as output_file:
        for start in range(0, len(output), 65536):
            output_file.write(output[start : start + 65536])
    print(
        f"{source.name} -> {destination} ({len(output) / SAMPLE_RATE:.2f} s, stereo, {SAMPLE_RATE} Hz)"
    )
    if attenuation < 1:
        print(
            f"  Reduced gain by {-20 * np.log10(attenuation):.2f} dB for peak headroom."
        )


def drop_files(arguments):
    """Handle the WAVs dropped onto the BAT file."""
    failed = False
    for argument in arguments:
        source = Path(argument).resolve()
        if not source.is_file() or source.suffix.lower() != ".wav":
            print(f"Skipped: {source} (drop a WAV file)")
            failed = True
            continue
        folder = source.parent / "announcer-output"
        destination = folder / (source.stem + ".ogg")
        number = 2
        # Use a numbered name if this file was already converted.
        while destination.exists():
            destination = folder / f"{source.stem} ({number}).ogg"
            number += 1
        try:
            convert(source, destination, {}, 0.0)
        except Exception as error:
            print(f"Failed: {source.name}: {error}")
            failed = True
    return int(failed)


def main():
    # The BAT uses this mode to choose an output folder automatically.
    if len(sys.argv) > 1 and sys.argv[1] == "--drop":
        if len(sys.argv) < 3:
            raise ValueError("Drop one or more WAV files onto the BAT launcher")
        return drop_files(sys.argv[2:])
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument("input", type=Path, help="WAV file or folder of WAVs")
    parser.add_argument(
        "output", type=Path, help="Output WAV/OGG file, or output folder for a batch"
    )
    parser.add_argument(
        "--format",
        choices=["wav", "ogg"],
        default="ogg",
        help="Batch output format; default ogg. Single files use their output extension.",
    )
    parser.add_argument(
        "--recursive", action="store_true", help="Include subfolders in batch mode"
    )
    parser.add_argument(
        "--gain-db", type=float, default=0.0, help="Final gain adjustment; default 0"
    )
    parser.add_argument(
        "--reverb-db", type=float, default=0.0, help="Reverb adjustment; default 0"
    )
    parser.add_argument(
        "--chord-db",
        type=float,
        default=0.0,
        help="Robotic chord adjustment; default 0",
    )
    parser.add_argument(
        "--echo-db", type=float, default=0.0, help="Delayed layer adjustment; default 0"
    )
    parser.add_argument(
        "--voice-db", type=float, default=0.0, help="Direct voice adjustment; default 0"
    )
    args = parser.parse_args()
    for key in ["gain_db", "reverb_db", "chord_db", "echo_db", "voice_db"]:
        if not np.isfinite(getattr(args, key)) or not -60 <= getattr(args, key) <= 24:
            parser.error(f"--{key.replace('_', '-')} must be between -60 and +24 dB")
    # Convert either one file or all the WAVs in a folder.
    if args.input.is_file():
        if args.output.suffix.lower() not in [".wav", ".ogg"]:
            parser.error("For a single file, specify an output ending in .wav or .ogg")
        jobs = [(args.input, args.output)]
    elif args.input.is_dir():
        if args.output.exists() and (not args.output.is_dir()):
            parser.error("Batch output must be a directory")
        candidates = args.input.rglob("*") if args.recursive else args.input.iterdir()
        sources = sorted(
            (p for p in candidates if p.is_file() and p.suffix.lower() == ".wav")
        )
        if not sources:
            parser.error("No raw WAV files found")
        jobs = [
            (p, args.output / p.relative_to(args.input).with_suffix("." + args.format))
            for p in sources
        ]
    else:
        parser.error(f"Input does not exist: {args.input}")
    # Check every output name before starting, so nothing gets overwritten.
    destinations = set()
    for source, destination in jobs:
        target = destination.resolve()
        if target == source.resolve():
            parser.error(f"Output would overwrite the raw input: {source}")
        if destination.exists():
            parser.error(
                f"Output already exists; choose another destination: {destination}"
            )
        if target in destinations:
            parser.error(f"Multiple inputs map to the same output: {destination}")
        destinations.add(target)
    adjustments = dict(
        rev_gain=args.reverb_db,
        tone_gain=args.chord_db,
        echo_gain=10 ** (args.echo_db / 20),
        voice_gain=args.voice_db,
    )
    for source, destination in jobs:
        convert(source, destination, adjustments, args.gain_db)
    print(f"Finished {len(jobs)} file(s).")


if __name__ == "__main__":
    try:
        sys.exit(main() or 0)
    except (ValueError, OSError, sf.LibsndfileError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
