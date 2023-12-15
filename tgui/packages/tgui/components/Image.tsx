import { classes } from 'common/react';
import { ReactNode } from 'react';
import { BoxProps, computeBoxProps } from './Box';
import { Tooltip } from './Tooltip';

type Props = Partial<{
  fixBlur: boolean; // true is default, this is an ie thing
  height: string;
  objectFit: 'contain' | 'cover'; // fill is default
  tooltip: ReactNode;
  width: string;
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

/** Image component. Use this instead of Box as="img". */
export const Image = (props: Props) => {
  const {
    className,
    height,
    objectFit,
    fixBlur = true,
    src,
    tooltip,
    width,
    ...rest
  } = props;

  const computedStyle = {
    ...computeBoxProps(rest).style,
    '-ms-interpolation-mode': fixBlur ? 'nearest-neighbor' : 'auto',
    height,
    objectFit,
    width,
  };

  let content = (
    <img
      className={classes(['Image__Inner', className])}
      src={src}
      style={computedStyle}
    />
  );

  if (tooltip) {
    content = <Tooltip content={tooltip}>{content}</Tooltip>;
  }

  return content;
};
