/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useCallback, useEffect } from 'react';
import type { Box } from 'tgui-core/components';
import { addScrollableNode, removeScrollableNode } from 'tgui-core/events';
import { classes } from 'tgui-core/react';
import { computeBoxClassName, computeBoxProps } from 'tgui-core/ui';

type BoxProps = React.ComponentProps<typeof Box>;

type Props = Partial<{
  theme: string;
}> &
  BoxProps;

export function Layout(props: Props) {
  const { className, theme = 'nanotrasen', children, ...rest } = props;

  const themeClass = `theme-${theme}`;

  useEffect(() => {
    document.documentElement.className = themeClass;
  }, [themeClass]);

  return (
    <div className={themeClass}>
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
  const node = useCallback(
    (self: HTMLDivElement) => {
      if (scrollable) {
        addScrollableNode(self);
      }
      return () => {
        if (scrollable) {
          removeScrollableNode(self);
        }
      };
    },
    [scrollable],
  );

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
