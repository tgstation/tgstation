/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useEffect, useRef } from 'react';
import {
  Box,
  computeBoxClassName,
  computeBoxProps, // TODO: Tgui core
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { addScrollableNode, removeScrollableNode } from '../events';

type BoxProps = React.ComponentProps<typeof Box>;

type Props = Partial<{
  theme: string;
}> &
  BoxProps;

export function Layout(props: Props) {
  const { className, theme = 'nanotrasen', children, ...rest } = props;

  return (
    <div className={'theme-' + theme}>
      <div
        className={classes(['Layout', className, computeBoxClassName(rest)])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    </div>
  );
}

type ContentProps = Partial<{
  scrollable: boolean;
}> &
  BoxProps;

function LayoutContent(props: ContentProps) {
  const { className, scrollable, children, ...rest } = props;
  const node = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const self = node.current;

    if (self && scrollable) {
      addScrollableNode(self);
    }
    return () => {
      if (self && scrollable) {
        removeScrollableNode(self);
      }
    };
  }, []);

  return (
    <div
      className={classes([
        'Layout__content',
        scrollable && 'Layout__content--scrollable',
        className,
        computeBoxClassName(rest),
      ])}
      ref={node}
      {...computeBoxProps(rest)}
    >
      {children}
    </div>
  );
}

Layout.Content = LayoutContent;
