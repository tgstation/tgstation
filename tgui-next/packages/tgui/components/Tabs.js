import { classes, normalizeChildren } from 'common/react';
import { Component } from 'inferno';
import { Button } from './Button';
import { Box } from './Box';

export class Tabs extends Component {
  constructor(props) {
    super(props);
    const tabs = normalizeChildren(props.children);
    const firstTab = tabs[0];
    const firstTabKey = firstTab && (firstTab.key || firstTab.props.label);
    this.state = {
      activeTabKey: props.activeTab || firstTabKey || null,
    };
  }

  render() {
    const { state, props } = this;
    const {
      className,
      vertical,
      children,
      ...rest
    } = props;
    const tabs = normalizeChildren(children);
    // Find the active tab
    const activeTabKey = props.activeTab || state.activeTabKey;
    const activeTab = tabs
      .find(tab => {
        const key = tab.key || tab.props.label;
        return key === activeTabKey;
      });
    // Retrieve tab content
    let content = null;
    if (activeTab) {
      content = activeTab.props.content || activeTab.props.children;
    }
    // Get children by calling a wrapper function
    if (typeof content === 'function') {
      content = content(activeTabKey);
    }
    return (
      <Box
        className={classes([
          'Tabs',
          vertical && 'Tabs--vertical',
          className,
        ])}
        {...rest}>
        <div className="Tabs__tabBox">
          {tabs.map(tab => {
            const {
              className,
              label,
              content, // ignored
              children, // ignored
              onClick,
              highlight,
              ...rest
            } = tab.props;
            const key = tab.key || tab.props.label;
            const active = tab.active || key === activeTabKey;
            return (
              <Button
                key={key}
                className={classes([
                  'Tabs__tab',
                  active && 'Tabs__tab--active',
                  highlight && !active && 'color-bright-yellow',
                  className,
                ])}
                selected={active}
                color="transparent"
                onClick={e => {
                  this.setState({ activeTabKey: key });
                  if (onClick) {
                    onClick(e, tab);
                  }
                }}
                {...rest}>
                {label}
              </Button>
            );
          })}
        </div>
        <div className="Tabs__content">
          {content || null}
        </div>
      </Box>
    );
  }
}

/**
 * A dummy component, which is used for carrying props for the
 * tab container.
 */
export const Tab = props => null;

Tabs.Tab = Tab;
