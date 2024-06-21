/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box } from '../components';
import { Layout } from './Layout';

export const Pane = (props) => {
  const { theme, children, className, ...rest } = props;
  const { suspended, debug } = useBackend();
  let debugLayout = false;
  if (debug) {
    debugLayout = debug.debugLayout;
  }

  return (
    <Layout className={classes(['Window', className])} theme={theme} {...rest}>
      <Box fillPositionedParent className={debugLayout && 'debug-layout'}>
        {!suspended && children}
      </Box>
    </Layout>
  );
};

const PaneContent = (props) => {
  const { className, fitted, children, ...rest } = props;
  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}>
      {(fitted && children) || (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Pane.Content = PaneContent;
