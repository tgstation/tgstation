/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Component } from 'inferno';
import { useBackend } from '../backend';
import { useDebug } from '../debug';
import { createLogger } from '../logging';
import { Layout, refocusLayout } from './Layout';
import { Box } from '../components';

const logger = createLogger('Pane');

export class Pane extends Component {
  componentDidMount() {
    logger.log('mounting');
    refocusLayout();
  }

  render() {
    const {
      theme,
      children,
      className,
      ...rest
    } = this.props;
    const { suspended } = useBackend(this.context);
    const { debugLayout } = useDebug(this.context);
    return (
      <Layout
        className={classes([
          'Window',
          className,
        ])}
        theme={theme}
        {...rest}>
        <Box
          fillPositionedParent
          className={debugLayout && 'debug-layout'}>
          {!suspended && children}
        </Box>
      </Layout>
    );
  }
}

const PaneContent = props => {
  const {
    className,
    fitted,
    children,
    ...rest
  } = props;
  return (
    <Layout.Content
      className={classes([
        'Window__content',
        className,
      ])}
      {...rest}>
      {fitted && children || (
        <div className="Window__contentPadding">
          {children}
        </div>
      )}
    </Layout.Content>
  );
};

Pane.Content = PaneContent;
