import { classes, normalizeChildren } from 'common/react';
import { Component } from 'inferno';
import { Box } from './Box';
import { Button } from './Button';

// A magic value for enforcing type safety
const TAB_MAGIC_TYPE = 'Tab';

const validateTabs = tabs => {
  for (let tab of tabs) {
    if (!tab.props || tab.props.__type__ !== TAB_MAGIC_TYPE) {
      const json = JSON.stringify(tab, null, 2);
      throw new Error('<Tabs> only accepts children of type <Tabs.Tab>.'
        + 'This is what we received: ' + json);
    }
  }
};

export class Tabs extends Component {
  constructor(props) {
    super(props);
    this.state = {
      activeTabKey: null,
    };
  }

  getActiveTab() {
    const { state, props } = this;
    const tabs = normalizeChildren(props.children);
    validateTabs(tabs);
    // Get active tab
    let activeTabKey = props.activeTab || state.activeTabKey;
    // Verify that active tab exists
    let activeTab = tabs
      .find(tab => {
        const key = tab.key || tab.props.label;
        return key === activeTabKey;
      });
    // Set first tab as the active tab
    if (!activeTab) {
      activeTab = tabs[0];
      activeTabKey = activeTab && (activeTab.key || activeTab.props.label);
    }
    return {
      tabs,
      activeTab,
      activeTabKey,
    };
  }

  render() {
    const { props } = this;
    const {
      className,
      vertical,
      altSelection,
      children,
      ...rest
    } = props;
    const {
      tabs,
      activeTab,
      activeTabKey,
    } = this.getActiveTab();
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
            const altSelectionStyle = 'Button--altSelected'
            + (vertical ? '--right' : '--bottom');
            return (
              <Button
                key={key}
                className={classes([
                  'Tabs__tab',
                  active && 'Tabs__tab--active',
                  highlight && !active && 'color-yellow',
                  altSelection && active && altSelectionStyle,
                  className,
                ])}
                selected={!altSelection && active}
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

Tab.defaultProps = {
  __type__: TAB_MAGIC_TYPE,
};

Tabs.Tab = Tab;
