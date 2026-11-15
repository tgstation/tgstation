# /// script
# requires-python = ">=3.10"
# dependencies = ["numpy", "scipy", "soundfile"]
# ///
"""Convert raw Crystal recordings to the finished announcer sound.

Usage:
  makeannouncervoice.py raw.wav finished.ogg
  makeannouncervoice.py raw_folder finished_folder --format ogg
  makeannouncervoice.py --drop raw.wav [another.wav ...]

Dependencies are declared above for uv. The BAT launcher handles drag and drop.
"""
import argparse
from pathlib import Path
import sys
import soundfile as sf

# The announcer chain: clear high-passed voice + stereo chord layer that follows the voice + sibilant air + echoes + reverb.
import numpy as np
from scipy.signal import butter, sosfilt, lfilter, resample_poly, fftconvolve
FS=44100
DEF=dict(
    notes=[(185.5,0.0),(277.9,0.0),(371.1,0.0),(555.6,0.0),(742.4,0.0),(834.0,0.0),(927.0,0.0),(1112.5,0.0),(1668.0,0.0),(2225.0,0.0)],   # Hz, gain dB
    bw_oct=0.67, bw_by_note={277.9:1.0,371.1:0.4,555.6:0.5}, band_by_note={}, env_hz=25.0, detune_hz=0.3, tone_gain=0.0, tone_center=0.3,
    hp_hz=430.0, hp_order=2, voice_eq=[(330.0,2.0,-2.2),(660.0,1.2,1.5),(2800.0,0.8,1.0)], voice_gain=0.0, voice_shelf=(2000.0,0.0), split_hz=3000.0, uv_lo=-18.0, uv_hi=-8.0, uv_ref=5.13, uv_floor=0.0,
    sib_gain=3.0, sib_det=(5500.0,7800.0), sib_top=7000.0, sib_ceil=-3.5,
    air_gain=-1.0, air_lo=7600.0, air_slope=3.4, sibn_db=10.0, sibn_lo=4900.0, sibn_thr=-12.0, sibn_ceil=-2.5, sibn_att=0.003, sibn_rel=0.02,
    echo_t1=0.0660, echo_g1=0.65, echo_t2=0.2099, echo_g2=-0.37, echo_rep=0.5, echo_lp1=350.0, echo_lp2=2900.0, echo_gain=1.0,
    rev_gain=0.0, rev_bands=[(0,450,1.35,-30.0,0.07),(450,1000,1.0,-22.7,0.07),(1000,2000,0.98,-19.5,0.07),(2000,4000,0.6,-18.5,0.08),(4000,9000,0.9,-27.8,0.08)], rev_width=0.9, rev_width_hi=0.0, treble_side=-11.0, rev_predelay=0.012,
    out_rms_db=-23.0, tail=1.2, lead=0.04, seed=7)
def peq(x,f,q,gdb):
    A=10**(gdb/40); w=2*np.pi*f/FS; al=np.sin(w)/(2*q); b=[1+al*A,-2*np.cos(w),1-al*A]; a=[1+al/A,-2*np.cos(w),1-al/A]
    return lfilter(np.array(b)/a[0],np.array(a)/a[0],x)
def hishelf(x,f,gdb):
    A=10**(gdb/40); w=2*np.pi*f/FS; al=np.sin(w)/2*np.sqrt(2); c=np.cos(w); sq=2*np.sqrt(A)*al
    b=[A*((A+1)+(A-1)*c+sq),-2*A*((A-1)+(A+1)*c),A*((A+1)+(A-1)*c-sq)]; a=[(A+1)-(A-1)*c+sq,2*((A-1)-(A+1)*c),(A+1)-(A-1)*c-sq]
    return lfilter(np.array(b)/a[0],np.array(a)/a[0],x)
def env_follow(b,hz):
    return np.maximum(sosfilt(butter(2,hz,'low',fs=FS,output='sos'),np.abs(b))*(np.pi/2),0)
def reverb_ir(P):
    """Decaying noise per band; each band has unit energy before its gain, so a band's gain is its reverb level relative to the direct sound in that band."""
    rng=np.random.default_rng(P['seed']); n=int(1.6*max(b[2] for b in P['rev_bands'])*FS); t=np.arange(n)/FS; m=np.zeros(n); sd=np.zeros(n)
    for band in P['rev_bands']:
        lo,hi,rt,gdb=band[:4]; att=band[4] if len(band)>4 else 0.0     # att: soft onset (s); the treble part of the room builds up instead of starting at full level
        sos=butter(2,[lo,hi],'band',fs=FS,output='sos') if lo>0 else butter(2,hi,'low',fs=FS,output='sos')
        shape=10**(-3*t/rt)*((1-np.exp(-t/att)) if att>0 else 1)
        wdt=P['rev_width_hi'] if lo>=2000 else P['rev_width']          # the treble part of the room sits in the centre
        for acc,wd in ((m,1.0),(sd,wdt)):
            v=sosfilt(sos,rng.standard_normal(n)*shape); acc+=v/np.sqrt((v**2).sum())*10**(gdb/20)*wd/np.sqrt(1+wdt**2)
    ir=np.stack([m+sd,m-sd],1)
    return np.concatenate([np.zeros((int(P['rev_predelay']*FS),2)),ir])
def shaped_noise(n,P,rng):
    N=1<<int(np.ceil(np.log2(n))); W=np.fft.rfft(rng.standard_normal(N)); f=np.fft.rfftfreq(N,1/FS)
    g=np.where(f<P['air_lo'],10**(P['sibn_db']/20),10**(-(f-P['air_lo'])/1000*P['air_slope']/20)); lo=f<P['sibn_lo']; g[lo]=10**(P['sibn_db']/20)*10**(-(P['sibn_lo']-f[lo])/1000*14/20); g[f>15500]=0
    if P['sibn_db']<-60: g=np.where(f<P['air_lo'],10**(-(P['air_lo']-f)/1000*12/20),g)
    return np.fft.irfft(W*g,N)[:n]
def echo_ir(P):
    """Measured from the originals' autocorrelation: a dark slap at 66 ms, a weaker inverted one at 210 ms, almost no repeats."""
    n=int(0.5*FS); F=lambda v: sosfilt(butter(4,P['echo_lp2'],'low',fs=FS,output='sos'),lfilter(*butter(1,P['echo_lp1'],'low',fs=FS),v))
    d1=np.zeros(n); d1[int(round(P['echo_t1']*FS))]=1; d2=np.zeros(n); d2[int(round(P['echo_t2']*FS))]=1; d3=np.zeros(n); d3[int(round(2*P['echo_t1']*FS))]=1
    h=P['echo_g1']*F(d1)+P['echo_g2']*lfilter(*butter(1,2500.0,'low',fs=FS),F(d2))+P['echo_rep']*P['echo_g1']**2*F(F(d3))
    return h*P['echo_gain']
def announcer(c,sr,P=DEF,parts=False):
    P={**DEF,**P}; rng=np.random.default_rng(P['seed'])
    from math import gcd
    g=gcd(FS,sr); x=resample_poly(c,FS//g,sr//g) if sr!=FS else c.copy()
    e=np.sqrt(np.convolve(x**2,np.ones(2205)/2205,'same')); x=x/np.sqrt(np.mean(x[e>0.1*e.max()]**2))*0.1
    on=int(np.argmax(e>0.03*e.max())); a0=max(0,on-int(P['lead']*FS)); x=x[a0:]; e_sp=np.concatenate([(e>0.1*e.max())[a0:],np.zeros(int(P['tail']*FS),bool)])       # start just before the voice, as the originals do
    x=np.concatenate([x,np.zeros(int(P['tail']*FS))]); n=len(x); t=np.arange(n)/FS
    # chord layer
    T=np.zeros((n,2)); tg=10**(P['tone_gain']/20)
    for f,gdb in P['notes']:
        bw=P['bw_by_note'].get(f,P['bw_oct']); lo=f*2**(-bw/2); hi=f*2**(bw/2)
        if str(f) in P['band_by_note']: lo,hi=P['band_by_note'][str(f)]
        en=env_follow(sosfilt(butter(2,[lo,hi],'band',fs=FS,output='sos'),x),P['env_hz'])*10**(gdb/20)*tg
        d=P['detune_hz']*(0.6+0.8*rng.random())*rng.choice([-1,1]); ph=rng.random(2)*2*np.pi
        cc=P['tone_center']*np.sin(2*np.pi*f*t+rng.random()*2*np.pi); nrm=1/np.sqrt(1+P['tone_center']**2)
        T[:,0]+=en*nrm*(np.sin(2*np.pi*(f-d)*t+ph[0])+cc); T[:,1]+=en*nrm*(np.sin(2*np.pi*(f+d)*t+ph[1])+cc)
    # voice: body below split, sibilants above it through an expander (quiet on vowels, boosted on s/sh/t), plus air above 8 kHz
    xc=sosfilt(butter(8,7800.0,'low',fs=FS,output='sos'),x)
    lr=lambda v,kind: sosfilt(butter(2,P['split_hz'],kind,fs=FS,output='sos'),sosfilt(butter(2,P['split_hz'],kind,fs=FS,output='sos'),v))
    body=lr(xc,'low'); hf=lr(xc,'high')
    hf=sosfilt(butter(2,P['sib_top'],'low',fs=FS,output='sos'),hf) if P['sib_top'] else hf
    # dry treble passes when the sound is unvoiced (weak lows), even if quiet, and is removed when it is voiced
    lowlev=20*np.log10(env_follow(sosfilt(butter(2,[120.0,1000.0],'band',fs=FS,output='sos'),xc),60.0)/0.1+1e-9)
    lowlev=lowlev-(np.percentile(lowlev[e_sp],90)-P['uv_ref'])       # judge 'weak lows' against this voice's own typical lows, so any voice or microphone works
    u=np.clip((P['uv_hi']-lowlev)/(P['uv_hi']-P['uv_lo']),0,1); u=sosfilt(butter(1,80.0,'low',fs=FS,output='sos'),u)
    en=env_follow(hf,150.0); lev=20*np.log10(en/0.1+1e-9); gdb=P['sib_gain']-np.maximum(0,lev+P['sib_gain']-P['sib_ceil'])*0.75
    gl=(u+(1-u)*10**(P['uv_floor']/20))*10**(gdb/20)
    # sibilant noise: opens only on real sibilants (5.5-7.8 kHz), fast attack, slow release, like a vocoder's noise channel
    det=env_follow(sosfilt(butter(4,list(P['sib_det']),'band',fs=FS,output='sos'),xc),150.0)[::44]
    gate=np.clip((20*np.log10(det/0.1+1e-9)-P['sibn_thr'])/4.0+1,0,1); drive=det*gate; cap=0.1*10**(P['sibn_ceil']/20); drive=np.where(drive>cap,cap*(drive/cap)**0.25,drive); r=np.zeros(len(drive)); v=0.0
    ka=np.exp(-1/(P['sibn_att']*FS/44)); kr=np.exp(-1/(P['sibn_rel']*FS/44))
    for i,dv in enumerate(drive):
        k_=ka if dv>v else kr; v=k_*v+(1-k_)*dv; r[i]=v
    ens=np.interp(np.arange(n),np.arange(len(r))*44,r)
    air=shaped_noise(n,P,rng)*ens*10**(P['air_gain']/20)
    bodyf=sosfilt(butter(P['hp_order'],P['hp_hz'],'high',fs=FS,output='sos'),body)
    for fq,q,gq in P['voice_eq']: bodyf=peq(bodyf,fq,q,gq)
    sib=hf*gl+air; vg=10**(P['voice_gain']/20)
    if P['voice_shelf'][1]: bodyf=hishelf(bodyf,*P['voice_shelf'])
    bodyf=bodyf*vg; sib=sib*vg; voice=bodyf+sib
    pre=T+voice[:,None]; sdv=np.zeros(n)
    if P['treble_side']>-60:                                   # in the originals each consonant is itself slightly wide
        kt=np.arange(int(0.004*FS)); kern=rng.standard_normal(len(kt))*np.exp(-kt/(0.0012*FS)); kern/=np.sqrt((kern**2).sum())
        sdv=lfilter(*butter(1,3500.0,'low',fs=FS),fftconvolve(sib,kern)[:n])*10**(P['treble_side']/20); pre[:,0]+=sdv; pre[:,1]-=sdv
    eh=echo_ir(P); ech=np.stack([fftconvolve(pre[:,c],eh)[:n] for c in (0,1)],1)
    bus=pre+ech; ir=reverb_ir(P); rev=np.stack([fftconvolve(bus.mean(1),ir[:,c])[:n] for c in (0,1)],1)*10**(P['rev_gain']/20)
    y=bus+rev
    ym=y.mean(1); e=np.sqrt(np.convolve(ym**2,np.ones(2205)/2205,'same')); k=10**(P['out_rms_db']/20)/np.sqrt(np.mean(ym[e>0.1*e.max()]**2))
    if parts: return y*k, dict(voice=voice*k,body=bodyf*k,sib=sib*k,tside=sdv*k,tones=T*k,air=air*k,echo=ech*k,rev=rev*k,k=k,n=n)
    return y*k

# Chord levels fitted so each note is as loud as in the 2010 clips (measured over all 17 lines).
DEF['notes']=[(185.5, -15.0), (277.9, -5.9), (371.1, 1.9), (555.6, 5.0), (742.4, -2.6), (834.0, -4.5), (927.0, -11.2), (1112.5, -6.9), (1668.0, -8.5), (2225.0, -15.3)]
DEF['out_rms_db']=-22.1


def convert(source, destination, adjustments, gain_db):
    audio, rate = sf.read(source, always_2d=True)
    mono = audio.mean(axis=1)
    if len(mono) / rate < .05:
        raise ValueError(f'{source}: input must be at least 50 ms long')
    if not np.isfinite(mono).all() or not np.any(np.abs(mono) > 1e-10):
        raise ValueError(f'{source}: input must contain finite, non-silent audio')
    output = announcer(mono, rate, adjustments)
    if not np.isfinite(output).all():
        raise ValueError(f'{source}: processing produced invalid samples')
    output *= 10 ** (gain_db / 20)
    peak = float(np.max(np.abs(output)))
    attenuation = min(1., .98 / peak)
    output *= attenuation
    destination.parent.mkdir(parents=True, exist_ok=True)
    subtype = 'VORBIS' if destination.suffix.lower() == '.ogg' else 'PCM_16'
    sf.write(destination, output, FS, subtype=subtype)
    print(f'{source.name} -> {destination} '
          f'({len(output)/FS:.2f} s, stereo, {FS} Hz)')
    if attenuation < 1:
        print(f'  Reduced gain by {-20*np.log10(attenuation):.2f} dB for peak headroom.')


def drop_files(arguments):
    failed = False
    for argument in arguments:
        source = Path(argument).resolve()
        if not source.is_file() or source.suffix.lower() != '.wav':
            print(f'Skipped: {source} (drop a WAV file)')
            failed = True
            continue
        folder = source.parent / 'announcer-output'
        destination = folder / (source.stem + '.ogg')
        number = 2
        while destination.exists():
            destination = folder / f'{source.stem} ({number}).ogg'
            number += 1
        try:
            # Same zero-adjustment settings as the accepted supplied script.
            convert(source, destination, {}, 0.)
        except Exception as error:
            print(f'Failed: {source.name}: {error}')
            failed = True
    return int(failed)


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--drop":
        if len(sys.argv) < 3:
            raise ValueError("Drop one or more WAV files onto the BAT launcher")
        return drop_files(sys.argv[2:])
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('input', type=Path, help='Raw Crystal WAV or folder of WAVs')
    parser.add_argument('output', type=Path, help='Output WAV/OGG file, or output folder for a batch')
    parser.add_argument('--format', choices=['wav', 'ogg'], default='ogg',
                        help='Batch output format; default ogg. Single files use their output extension.')
    parser.add_argument('--recursive', action='store_true', help='Include subfolders in batch mode')
    parser.add_argument('--gain-db', type=float, default=0., help='Final gain adjustment; default 0')
    parser.add_argument('--reverb-db', type=float, default=0., help='Reverb adjustment; default 0')
    parser.add_argument('--chord-db', type=float, default=0., help='Robotic chord adjustment; default 0')
    parser.add_argument('--echo-db', type=float, default=0., help='Delayed layer adjustment; default 0')
    parser.add_argument('--voice-db', type=float, default=0., help='Direct voice adjustment; default 0')
    args = parser.parse_args()
    for key in ['gain_db', 'reverb_db', 'chord_db', 'echo_db', 'voice_db']:
        if not np.isfinite(getattr(args, key)) or not -60 <= getattr(args, key) <= 24:
            parser.error(f'--{key.replace("_", "-")} must be between -60 and +24 dB')
    if args.input.is_file():
        if args.output.suffix.lower() not in ['.wav', '.ogg']:
            parser.error('For a single file, specify an output ending in .wav or .ogg')
        jobs = [(args.input, args.output)]
    elif args.input.is_dir():
        if args.output.exists() and not args.output.is_dir():
            parser.error('Batch output must be a directory')
        candidates = args.input.rglob('*') if args.recursive else args.input.iterdir()
        sources = sorted(p for p in candidates if p.is_file() and p.suffix.lower() == '.wav')
        if not sources:
            parser.error('No raw WAV files found')
        jobs = [(p, args.output / p.relative_to(args.input).with_suffix('.'+args.format))
                for p in sources]
    else:
        parser.error(f'Input does not exist: {args.input}')
    # Check all destination paths before writing any batch output.
    destinations = set()
    for source, destination in jobs:
        target = destination.resolve()
        if target == source.resolve():
            parser.error(f'Output would overwrite the raw input: {source}')
        if destination.exists():
            parser.error(f'Output already exists; choose another destination: {destination}')
        if target in destinations:
            parser.error(f'Multiple inputs map to the same output: {destination}')
        destinations.add(target)
    adjustments = dict(rev_gain=args.reverb_db, tone_gain=args.chord_db,
                       echo_gain=10 ** (args.echo_db / 20), voice_gain=args.voice_db)
    for source, destination in jobs:
        convert(source, destination, adjustments, args.gain_db)
    print(f'Finished {len(jobs)} file(s).')

if __name__ == '__main__':
    try:
        sys.exit(main() or 0)
    except (ValueError, OSError, sf.LibsndfileError) as error:
        print(f'Error: {error}', file=sys.stderr)
        sys.exit(1)
