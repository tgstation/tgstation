/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @author Original Aleksej Komarov
 * @author Changes ThePotato97
 * @license MIT
 */

import { classes } from 'common/react';
import { ReactNode } from 'react';
import { BoxProps, computeBoxClassName, computeBoxProps } from './Box';

const FA_OUTLINE_REGEX = /-o$/;

type IconPropsUnique = { name: string } & Partial<{
  size: number;
  spin: boolean;
  className: string;
  rotation: number;
  style: Partial<HTMLDivElement['style']>;
}>;

export type IconProps = IconPropsUnique & BoxProps;

export const Icon = (props: IconProps) => {
  let { style, ...restlet } = props;
  const { name, size, spin, className, rotation, ...rest } = restlet;

  if (size) {
    if (!style) {
      style = {};
    }
    style['fontSize'] = size * 100 + '%';
  }
  if (rotation) {
    if (!style) {
      style = {};
    }
    style['transform'] = `rotate(${rotation}deg)`;
  }
  rest.style = style;

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
      {...computeBoxProps(rest)}>
      {children}
    </span>
  );
};

Icon.Stack = IconStack;
