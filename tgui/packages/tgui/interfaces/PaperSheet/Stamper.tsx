import { Component, type RefObject } from 'react';
import { clamp } from 'tgui-core/math';

import { useBackend } from '../../backend';
import { Stamp } from './Stamp';
import type { PaperContext } from './types';

type PaperSheetStamperState = {
  x: number;
  y: number;
  rotation: number;
  yOffset: number;
};

type PaperSheetStamperProps = {
  scrollableRef: RefObject<HTMLDivElement | null>;
};

type StampPosition = {
  x: number;
  y: number;
  rotation: number;
  yOffset: number;
};

// Handles the ghost stamp when attempting to stamp paper sheets.
export class PaperSheetStamper extends Component<PaperSheetStamperProps> {
  style: null;
  state: PaperSheetStamperState = { x: 0, y: 0, rotation: 0, yOffset: 0 };
  scrollableRef: RefObject<HTMLDivElement>;

  constructor(props) {
    super(props);

    this.style = null;
    this.scrollableRef = props.scrollableRef;
  }

  // Stops propagation of a given event.
  pauseEvent = (e: Event): boolean => {
    if (e.stopPropagation) {
      e.stopPropagation();
    }
    if (e.preventDefault) {
      e.preventDefault();
    }
    e.cancelBubble = true;
    e.returnValue = false;
    return false;
  };

  handleMouseMove = (e: MouseEvent): void => {
    const pos = this.findStampPosition(e);
    if (!pos) {
      return;
    }

    this.pauseEvent(e);
    this.setState({
      x: pos.x,
      y: pos.y,
      rotation: pos.rotation,
      yOffset: pos.yOffset,
    });
  };

  handleMouseClick = (e: MouseEvent): void => {
    if (e.pageY <= 30) {
      return;
    }
    const { act } = useBackend<PaperContext>();

    act('add_stamp', {
      x: this.state.x,
      y: this.state.y + this.state.yOffset,
      rotation: this.state.rotation,
    });
  };

  findStampPosition(e: MouseEvent): StampPosition | undefined {
    let rotating;
    const scrollable = this.scrollableRef.current;

    if (!scrollable) {
      return;
    }

    const stampYOffset = scrollable.scrollTop || 0;

    const stamp = document.getElementById('stamp');
    if (!stamp) {
      return;
    }

    if (e.shiftKey) {
      rotating = true;
    }

    const stampHeight = stamp.clientHeight;
    const stampWidth = stamp.clientWidth;

    const currentHeight = rotating ? this.state.y : e.pageY - stampHeight;
    const currentWidth = rotating ? this.state.x : e.pageX - stampWidth / 2;

    const widthMin = 0;
    const heightMin = 0;

    const widthMax = scrollable.clientWidth - stampWidth;
    const heightMax = scrollable.clientHeight - stampHeight;

    const radians = Math.atan2(
      currentWidth + stampWidth / 2 - e.pageX,
      currentHeight + stampHeight - e.pageY,
    );

    const rotate = rotating
      ? radians * (180 / Math.PI) * -1
      : this.state.rotation;

    return {
      x: clamp(currentWidth, widthMin, widthMax),
      y: clamp(currentHeight, heightMin, heightMax),
      rotation: rotate,
      yOffset: stampYOffset,
    };
  }

  componentDidMount() {
    document.addEventListener('mousemove', this.handleMouseMove);
    document.addEventListener('click', this.handleMouseClick);
  }

  componentWillUnmount() {
    document.removeEventListener('mousemove', this.handleMouseMove);
    document.removeEventListener('click', this.handleMouseClick);
  }

  render() {
    const { data } = useBackend<PaperContext>();
    const { held_item_details } = data;

    if (!held_item_details?.stamp_class) {
      return;
    }

    return (
      <Stamp
        activeStamp
        opacity={0.5}
        sprite={held_item_details.stamp_class}
        x={this.state.x}
        y={this.state.y}
        rotation={this.state.rotation}
      />
    );
  }
}
