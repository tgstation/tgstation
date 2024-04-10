import { ReactNode, useState } from 'react';

import { BoxProps, computeBoxProps } from './Box';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  /** True is default, this fixes an ie thing */
  fixBlur: boolean;
  /** False by default. Good if you're fetching images on UIs that do not auto update. This will attempt to fix the 'x' icon 5 times. */
  fixErrors: boolean;
  /** Fill is default. */
  objectFit: 'contain' | 'cover'; // fill is default
  /** Creates a tooltip window using tooltip component. */
  tooltip: ReactNode;
}> &
  IconUnion &
  BoxProps;

// at least one of these is required
type IconUnion =
  | {
      className?: string;
      src: string;
    }
  | {
      className: string;
      src?: string;
    };

const maxAttempts = 5;

/** Image component. Use this instead of Box as="img". */
export function Image(props: Props) {
  const {
    fixBlur = true,
    fixErrors = false,
    objectFit = 'fill',
    src,
    tooltip,
    ...rest
  } = props;
  const [attempts, setAttempts] = useState(0);

  const computedProps = computeBoxProps(rest);
  computedProps['style'] = {
    ...computedProps.style,
    '-ms-interpolation-mode': fixBlur ? 'nearest-neighbor' : 'auto',
    objectFit,
  };

  let content = (
    <img
      onError={() => {
        if (fixErrors && attempts < maxAttempts) {
          setTimeout(() => {
            setAttempts((attempts) => attempts + 1);
          }, 1500);
        }
      }}
      src={src}
      {...computedProps}
    />
  );

  if (tooltip) {
    content = <Tooltip content={tooltip}>{content}</Tooltip>;
  }

  return content;
}
