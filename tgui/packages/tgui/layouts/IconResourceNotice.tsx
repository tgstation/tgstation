import { useAtomValue } from 'jotai';
import type { PropsWithChildren } from 'react';
import { Button, NoticeBox } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { iconMapStateAtom, retryIconMap } from '../iconMap';

/**
 * Everything below the title bar - the icon notice, then the window's content.
 * The notice takes its room from the content's box, never from inside it, and
 * the content scrolls while it shows, so every row stays reachable.
 */
export function IconResourceNotice(props: PropsWithChildren) {
  const { children } = props;
  const failed = useAtomValue(iconMapStateAtom).status === 'error';
  return (
    <div
      className={classes([
        'IconResourceNotice',
        failed && 'IconResourceNotice--shown',
      ])}
    >
      {/* The region stays mounted so screen readers announce the notice when it appears */}
      <div className="IconResourceNotice__status" role="status">
        {failed && (
          <NoticeBox className="IconResourceNotice__box">
            <span>Some icons could not load.</span>
            <Button icon="rotate" onClick={retryIconMap}>
              Retry icons
            </Button>
          </NoticeBox>
        )}
      </div>
      <div className="IconResourceNotice__content">{children}</div>
    </div>
  );
}
