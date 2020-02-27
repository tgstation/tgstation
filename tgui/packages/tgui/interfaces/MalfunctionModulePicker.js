import { decodeHtmlEntities } from 'common/string';
import { Component, Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, Input, Section, Table, Tabs } from '../components';

// It's a class because we need to store state in the form of the current
// hovered item, and current search terms
export class MalfunctionModulePicker extends Component {
  constructor() {
    super();
    this.state = {
      hoveredItem: {},
      currentSearch: '',
    };
  }

  setHoveredItem(hoveredItem) {
    this.setState({
      hoveredItem,
    });
  }

  setSearchText(currentSearch) {
    this.setState({
      currentSearch,
    });
  }

  render() {
    const { state } = this.props;
    const { config, data } = state;
    const { ref } = config;
    const {
      compact_mode,
      processing_time,
      categories = [],
    } = data;
    const { hoveredItem, currentSearch } = this.state;
    return (
      <Section
        title={(
          <Box
            inline
            color={processing_time > 0 ? 'good' : 'bad'}>
            {processing_time} Processing Time
          </Box>
        )}
        buttons={(
          <Fragment>
            Search
            <Input
              value={currentSearch}
              onInput={(e, value) => this.setSearchText(value)}
              ml={1}
              mr={1} />
            <Button
              icon={compact_mode ? 'list' : 'info'}
              content={compact_mode ? 'Compact' : 'Detailed'}
              onClick={() => act(ref, 'compact_toggle')} />
          </Fragment>
        )}>
        {currentSearch.length > 0 ? (
          <table className="Table">
            <ItemList
              compact
              items={categories
                .flatMap(category => {
                  return category.items || [];
                })
                .filter(item => {
                  const searchTerm = currentSearch.toLowerCase();
                  const searchableString = String(item.name + item.desc)
                    .toLowerCase();
                  return searchableString.includes(searchTerm);
                })}
              hoveredItem={hoveredItem}
              onBuyMouseOver={item => this.setHoveredItem(item)}
              onBuyMouseOut={item => this.setHoveredItem({})}
              onBuy={item => act(ref, 'buy', {
                ref: item.ref,
              })} />
          </table>
        ) : (
          <Tabs vertical>
            {categories.map(category => {
              const { name, items } = category;
              if (items === null) {
                return;
              }
              return (
                <Tabs.Tab
                  key={name}
                  label={`${name} (${items.length})`}>
                  {() => (
                    <ItemList
                      compact={compact_mode}
                      items={items}
                      hoveredItem={hoveredItem}
                      processing_time={processing_time}
                      onBuyMouseOver={item => this.setHoveredItem(item)}
                      onBuyMouseOut={item => this.setHoveredItem({})}
                      onBuy={item => act(ref, 'buy', {
                        ref: item.ref,
                      })} />
                  )}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        )}
      </Section>
    );
  }
}

const ItemList = props => {
  const {
    items,
    hoveredItem,
    processing_time,
    compact,
    onBuy,
    onBuyMouseOver,
    onBuyMouseOut,
  } = props;
  const hoveredCost = hoveredItem && hoveredItem.cost || 0;
  if (compact) {
    return (
      <Table>
        {items.map(item => {
          const notSameItem = hoveredItem && hoveredItem.name !== item.name;
          const notEnoughHovered = processing_time - hoveredCost < item.cost;
          const disabledDueToHovered = notSameItem && notEnoughHovered;
          return (
            <Table.Row
              key={item.name}
              className="candystripe">
              <Table.Cell bold>
                {decodeHtmlEntities(item.name)}
              </Table.Cell>
              <Table.Cell collapsing textAlign="right">
                <Button
                  fluid
                  content={item.cost + " PT"}
                  disabled={processing_time < item.cost || disabledDueToHovered}
                  tooltip={item.desc}
                  tooltipPosition="left"
                  onmouseover={() => onBuyMouseOver(item)}
                  onmouseout={() => onBuyMouseOut(item)}
                  onClick={() => onBuy(item)} />
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    );
  }
  return items.map(item => {
    const notSameItem = hoveredItem && hoveredItem.name !== item.name;
    const notEnoughHovered = processing_time - hoveredCost < item.cost;
    const disabledDueToHovered = notSameItem && notEnoughHovered;
    return (
      <Section
        key={item.name}
        title={item.name}
        level={2}
        buttons={(
          <Button
            content={item.cost + ' PT'}
            disabled={processing_time < item.cost || disabledDueToHovered}
            onmouseover={() => onBuyMouseOver(item)}
            onmouseout={() => onBuyMouseOut(item)}
            onClick={() => onBuy(item)} />
        )}>
        {decodeHtmlEntities(item.desc)}
      </Section>
    );
  });
};
