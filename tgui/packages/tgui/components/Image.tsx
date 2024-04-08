import { ReactNode, useEffect, useState } from 'react';

import { BoxProps, computeBoxProps } from './Box';
import { Icon } from './Icon';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  /** True is default, this fixes an ie thing */
  fixBlur: boolean;
  /** A common case if the cdn does not have the image. This will try to refetch every 2s */
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

const maxAttempts = 3;

/** Image component. Use this instead of Box as="img". */
export function Image(props: Props) {
  const {
    fixBlur = true,
    fixErrors = true,
    objectFit = 'fill',
    src,
    tooltip,
    ...rest
  } = props;

  const [error, setError] = useState(false);
  const [attempts, setAttempts] = useState(0);

  const computedProps = computeBoxProps(rest);
  computedProps['style'] = {
    ...computedProps.style,
    '-ms-interpolation-mode': fixBlur ? 'nearest-neighbor' : 'auto',
    objectFit,
  };

  let content;
  if (!error && attempts < maxAttempts) {
    content = (
      <img
        onError={() => fixErrors && setError(true)}
        src={src}
        {...computedProps}
      />
    );
  } else {
    content = <Icon name="spinner" spin color="light-gray" />;
  }

  if (tooltip) {
    content = <Tooltip content={tooltip}>{content}</Tooltip>;
  }

  useEffect(() => {
    if (!error) return;

    // Extra careful with memory leaks, possibly unnecessary
    let isMounted = true;

    const timer = setTimeout(() => {
      if (isMounted) {
        setAttempts((prev) => prev + 1);
        setError(false);
      }
    }, 2000);

    return () => {
      isMounted = false;
      clearTimeout(timer);
    };
  }, [error]);

  return content;
}
