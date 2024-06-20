/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original Aleksej Komarov
 * @author Changes ThePotato97
 * @license MIT
 */

import { BooleanLike, classes } from 'common/react';
import { ReactNode } from 'react';

import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

type IconPropsUnique = { name: string } & Partial<{
  size: number;
  spin: BooleanLike;
  className: string;
  rotation: number;
  style: Partial<HTMLDivElement['style']>;
}>;

export type IconProps = IconPropsUnique & BoxProps;

export const Icon = (props: IconProps) => {
  const { name, size, spin, className, rotation, ...rest } = props;

  const customStyle = rest.style || {};
  if (size) {
    customStyle.fontSize = size * 100 + '%';
  }
  if (rotation) {
    customStyle.transform = `rotate(${rotation}deg)`;
  }
  rest.style = customStyle;

  const boxProps = computeBoxProps(rest);

  let iconClass = '';
  if (name.startsWith('tg-')) {
    // tgfont icon
    iconClass = name;
  } else {
    // font awesome icon
    const faRegular = FA_OUTLINE_REGEX.test(name);
    const faName = name.replace(FA_OUTLINE_REGEX, '');
    const preprendFa = !faName.startsWith('fa-');

    iconClass = faRegular ? 'far ' : 'fas ';
    if (preprendFa) {
      iconClass += 'fa-';
    }
    iconClass += faName;
    if (spin) {
      iconClass += ' fa-spin';
    }
  }
  return (
    <i
      className={classes([
        'Icon',
        iconClass,
        className,
        computeBoxClassName(rest),
      ])}
      {...boxProps}
    />
  );
};

type IconStackUnique = {
  children: ReactNode;
  className?: string;
};

export type IconStackProps = IconStackUnique & BoxProps;

export const IconStack = (props: IconStackProps) => {
  const { className, children, ...rest } = props;
  return (
    <span
      className={classes(['IconStack', className, computeBoxClassName(rest)])}
      {...computeBoxProps(rest)}
    >
      {children}
    </span>
  );
};

Icon.Stack = IconStack;
