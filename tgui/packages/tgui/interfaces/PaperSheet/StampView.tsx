import { useBackend } from '../../backend';
import { Stamp } from './Stamp';
import { PaperContext } from './types';

// Renders all the stamp components for every valid stamp.
export function StampView(props) {
  const { data } = useBackend<PaperContext>();

  const { raw_stamp_input = [] } = data;

  const { stampYOffset } = props;

  return (
    <>
      {raw_stamp_input.map((stamp, index) => {
        return (
          <Stamp
            key={index}
            x={stamp.x}
            y={stamp.y}
            rotation={stamp.rotation}
            sprite={stamp.class}
            yOffset={stampYOffset}
          />
        );
      })}
    </>
  );
}
