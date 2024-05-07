import { useRef } from 'react';

import { BoxProps, computeBoxProps } from './Box';

type Props = Partial<{
  /** True is default, this fixes an ie thing */
  fixBlur: boolean;
  /** False by default. Good if you're fetching images on UIs that do not auto update. This will attempt to fix the 'x' icon 5 times. */
  fixErrors: boolean;
  /** Fill is default. */
  objectFit: 'contain' | 'cover';
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
    ...rest
  } = props;
  const attempts = useRef(0);

  const computedProps = computeBoxProps(rest);
  computedProps['style'] = {
    ...computedProps.style,
    '-ms-interpolation-mode': fixBlur ? 'nearest-neighbor' : 'auto',
    objectFit,
  };

  return (
    <img
      onError={(event) => {
        if (fixErrors && attempts.current < maxAttempts) {
          const imgElement = event.currentTarget;

          setTimeout(() => {
            imgElement.src = `${src}?attempt=${attempts.current}`;
            attempts.current++;
          }, 1000);
        }
      }}
      src={src}
      {...computedProps}
    />
  );
}
