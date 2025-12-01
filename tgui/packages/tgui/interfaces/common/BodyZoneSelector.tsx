import { Component, createRef } from 'react';
import { Image } from 'tgui-core/components';

import { resolveAsset } from '../../assets';

export enum BodyZone {
  Head = 'head',
  Chest = 'chest',
  LeftArm = 'l_arm',
  RightArm = 'r_arm',
  LeftLeg = 'l_leg',
  RightLeg = 'r_leg',
  Eyes = 'eyes',
  Mouth = 'mouth',
  Groin = 'groin',
}

function bodyZonePixelToZone(x: number, y: number): BodyZone | null {
  // TypeScript translation of /atom/movable/screen/zone_sel/proc/get_zone_at
  if (y < 1) {
    return null;
  } else if (y < 10) {
    if (x > 10 && x < 15) {
      return BodyZone.RightLeg;
    } else if (x > 17 && x < 22) {
      return BodyZone.LeftLeg;
    }
  } else if (y < 13) {
    if (x > 8 && x < 11) {
      return BodyZone.RightArm;
    } else if (x > 12 && x < 20) {
      return BodyZone.Groin;
    } else if (x > 21 && x < 24) {
      return BodyZone.LeftArm;
    }
  } else if (y < 22) {
    if (x > 8 && x < 11) {
      return BodyZone.RightArm;
    } else if (x > 12 && x < 20) {
      return BodyZone.Chest;
    } else if (x > 21 && x < 24) {
      return BodyZone.LeftArm;
    }
  } else if (y < 30 && x > 12 && x < 20) {
    if (y > 23 && y < 24 && x > 15 && x < 17) {
      return BodyZone.Mouth;
    } else if (y > 25 && y < 27 && x > 14 && x < 18) {
      return BodyZone.Eyes;
    } else {
      return BodyZone.Head;
    }
  }

  return null;
}

type BodyZoneSelectorProps = {
  onClick?: (zone: BodyZone) => void;
  scale?: number;
  selectedZone: BodyZone | null;
  theme?: string;
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
    const { scale = 3, selectedZone, theme = 'midnight' } = this.props;

    return (
      <div
        ref={this.ref}
        style={{
          width: `${32 * scale}px`,
          height: `${32 * scale}px`,
          position: 'relative',
        }}
      >
        <Image
          src={resolveAsset(`body_zones.base_${theme}.png`)}
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
            position: 'absolute',
            width: `${32 * scale}px`,
            height: `${32 * scale}px`,
          }}
        />

        {selectedZone && (
          <Image
            src={resolveAsset(`body_zones.${selectedZone}.png`)}
            style={{
              pointerEvents: 'none',
              position: 'absolute',
              width: `${32 * scale}px`,
              height: `${32 * scale}px`,
            }}
          />
        )}

        {hoverZone && hoverZone !== selectedZone && (
          <Image
            src={resolveAsset(`body_zones.${hoverZone}.png`)}
            style={{
              opacity: '0.5',
              pointerEvents: 'none',
              position: 'absolute',
              width: `${32 * scale}px`,
              height: `${32 * scale}px`,
            }}
          />
        )}
      </div>
    );
  }
}
