import { ObjectValues } from 'common/types';
import { Component, createRef } from 'inferno';
import { resolveAsset } from '../assets';
import { Box } from './Box';

export const BODYZONES = {
  Head: 'head',
  Chest: 'chest',
  LeftArm: 'l_arm',
  RightArm: 'r_arm',
  LeftLeg: 'l_leg',
  RightLeg: 'r_leg',
  Eyes: 'eyes',
  Mouth: 'mouth',
  Groin: 'groin',
} as const;

export type BodyZone = ObjectValues<typeof BODYZONES>;

const bodyZonePixelToZone = (x: number, y: number): BodyZone | null => {
  // TypeScript translation of /atom/movable/screen/zone_sel/proc/get_zone_at
  if (y < 1) {
    return null;
  } else if (y < 10) {
    if (x > 10 && x < 15) {
      return BODYZONES.RightLeg;
    } else if (x > 17 && x < 22) {
      return BODYZONES.LeftLeg;
    }
  } else if (y < 13) {
    if (x > 8 && x < 11) {
      return BODYZONES.RightArm;
    } else if (x > 12 && x < 20) {
      return BODYZONES.Groin;
    } else if (x > 21 && x < 24) {
      return BODYZONES.LeftArm;
    }
  } else if (y < 22) {
    if (x > 8 && x < 11) {
      return BODYZONES.RightArm;
    } else if (x > 12 && x < 20) {
      return BODYZONES.Chest;
    } else if (x > 21 && x < 24) {
      return BODYZONES.LeftArm;
    }
  } else if (y < 30 && x > 12 && x < 20) {
    if (y > 23 && y < 24 && x > 15 && x < 17) {
      return BODYZONES.Mouth;
    } else if (y > 25 && y < 27 && x > 14 && x < 18) {
      return BODYZONES.Eyes;
    } else {
      return BODYZONES.Head;
    }
  }

  return null;
};

type BodyZoneSelectorProps = {
  onClick?: (zone: BodyZone) => void;
  scale?: number;
  selectedZone: BodyZone | null;
};

type BodyZoneSelectorState = {
  hoverZone: BodyZone | null;
};

export class BodyZoneSelector extends Component<
  BodyZoneSelectorProps,
  BodyZoneSelectorState
> {
  ref = createRef<HTMLDivElement>();
  state: BodyZoneSelectorState = {
    hoverZone: null,
  };

  render() {
    const { hoverZone } = this.state;
    const { scale = 3, selectedZone } = this.props;

    return (
      <div
        ref={this.ref}
        style={{
          width: `${32 * scale}px`,
          height: `${32 * scale}px`,
          position: 'relative',
        }}>
        <Box
          as="img"
          src={resolveAsset('body_zones.base.png')}
          onClick={() => {
            const onClick = this.props.onClick;
            if (onClick && this.state.hoverZone) {
              onClick(this.state.hoverZone);
            }
          }}
          onMouseMove={(event) => {
            if (!this.props.onClick) {
              return;
            }

            const rect = this.ref.current?.getBoundingClientRect();
            if (!rect) {
              return;
            }

            const x = event.clientX - rect.left;
            const y = 32 * scale - (event.clientY - rect.top);

            this.setState({
              hoverZone: bodyZonePixelToZone(x / scale, y / scale),
            });
          }}
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
            'position': 'absolute',
            'width': `${32 * scale}px`,
            'height': `${32 * scale}px`,
          }}
        />

        {selectedZone && (
          <Box
            as="img"
            src={resolveAsset(`body_zones.${selectedZone}.png`)}
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              'pointer-events': 'none',
              'position': 'absolute',
              'width': `${32 * scale}px`,
              'height': `${32 * scale}px`,
            }}
          />
        )}

        {hoverZone && hoverZone !== selectedZone && (
          <Box
            as="img"
            src={resolveAsset(`body_zones.${hoverZone}.png`)}
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
              'opacity': 0.5,
              'pointer-events': 'none',
              'position': 'absolute',
              'width': `${32 * scale}px`,
              'height': `${32 * scale}px`,
            }}
          />
        )}
      </div>
    );
  }
}
