/* eslint-disable react/prefer-stateless-function */
import { decodeHtmlEntities } from 'common/string';
import { Fragment, Component } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, NumberInput, Section, Tabs, Table, Input } from '../components';
import { createLogger } from '../logging';

const logger = createLogger("uplink");

// It's a class because we need to store state in the form of the current hovered item, and current search terms
export class Uplink extends Component {

  constructor() {
    super();
    this.state = {
      hoveredItem: {},
      currentSearch: "",
    };
  }

  setHoveredItem(hoveredItem) {
    this.setState({
      hoveredItem: hoveredItem,
    });
  }

  setSearchText(currentSearch) {
    this.setState({
      currentSearch: currentSearch,
    });
  }

  render() {
    const { state } = this.props;
    const { config, data } = state;
    const { ref } = config;
    const {
      compact_mode,
      lockable,
      telecrystals,
      categories = [],
    } = data;
    const { hoveredItem, currentSearch } = this.state;
    const hoveredCost = hoveredItem.cost || 0;
    return (
      <Section
        title={(
          <Box
            inline
            color={telecrystals > 0 ? "good" : "bad"}
          >
            {telecrystals} TC
          </Box>
        )}
        buttons={(
          <Fragment>
            Search
            <Input
              value={currentSearch}
              onInput={(e, value) => this.setSearchText(value)}
              ml={1}
              mr={1}
            />
            <Button
              icon={compact_mode ? "list" : "info"}
              content={compact_mode ? "Compact" : "Detailed"}
              onClick={() => act(ref, "compact_toggle")}
            />
            {!!lockable && (
              <Button
                icon="lock"
                content="Lock"
                onClick={() => act(ref, "lock") /* lock */}
              />
            )}
          </Fragment>
        )}
      >
        {currentSearch.length > 0 ? (
          <table className="Table">
            {categories.map(category => {
              const {
                items,
                name,
              } = category;
              if (items === null) {
                return;
              }
              return (
                <Fragment key={name}>
                  {items.map(item => {
                    const notSameItem = (hoveredItem.name !== item.name);
                    const notEnoughHovered = (telecrystals - hoveredCost < item.cost);
                    const disabledDueToHovered = (notSameItem && notEnoughHovered);
                    if (!item.name.toLowerCase().includes(currentSearch.toLowerCase())) { return; }
                    return (
                      <tr
                        key={item.name}
                        className="Table__row candystripe"
                      >
                        <td className="Table__cell" >
                          {item.name}
                        </td>
                        <td
                          className="Table__cell"
                          style={{
                            "width": "6px",
                          }}
                        >
                          <Button
                            fluid
                            content={item.cost + " TC"}
                            disabled={telecrystals < item.cost || disabledDueToHovered}
                            tooltip={item.desc}
                            tooltipPosition="left"
                            onmouseover={() => this.setHoveredItem(item)}
                            onmouseout={() => this.setHoveredItem({})}
                            onClick={() => act(ref, "buy", {
                              category: category,
                              item: item.name,
                              cost: item.cost,
                            })}
                          />
                        </td>
                      </tr>);
                  })}
                </Fragment>
              );
            })}
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
                  label={name}
                >
                  {compact_mode ? (
                    <Table>
                      {items.map(item => {
                        const notSameItem = (hoveredItem.name !== item.name);
                        const notEnoughHovered = (telecrystals - hoveredCost < item.cost);
                        const disabledDueToHovered = (notSameItem && notEnoughHovered);
                        return (
                          <Table.Row
                            key={item.name}
                            className="candystripe"
                          >
                            <Table.Cell bold>
                              {decodeHtmlEntities(item.name)}:
                            </Table.Cell>
                            <Table.Cell
                              textAlign="right"
                              width={1}
                            >
                              <Button
                                fluid
                                content={item.cost + " TC"}
                                disabled={telecrystals < item.cost || disabledDueToHovered}
                                tooltip={item.desc}
                                tooltipPosition="left"
                                onmouseover={() => this.setHoveredItem(item)}
                                onmouseout={() => this.setHoveredItem({})}
                                onClick={() => act(ref, "buy", {
                                  category: category,
                                  item: item.name,
                                  cost: item.cost,
                                })}
                              />
                            </Table.Cell>
                          </Table.Row>
                        );
                      })}
                    </Table>
                  ) : (
                    items.map(item => {
                      const notSameItem = (hoveredItem.name !== item.name);
                      const notEnoughHovered = (telecrystals - hoveredCost < item.cost);
                      const disabledDueToHovered = (notSameItem && notEnoughHovered);
                      return (
                        <Section
                          key={item.name}
                          title={item.name}
                          level={2}
                          buttons={(
                            <Button
                              content={item.cost + " TC"}
                              disabled={telecrystals < item.cost || disabledDueToHovered}
                              onmouseover={() => this.setHoveredItem(item)}
                              onmouseout={() => this.setHoveredItem({})}
                              onClick={() => act(ref, "buy", {
                                category: category,
                                item: item.name,
                                cost: item.cost,
                              })}
                            />
                          )}
                        >
                          {decodeHtmlEntities(item.desc)}
                        </Section>
                      );
                    })
                  )}
                  <LabeledList />
                </Tabs.Tab>
              );
            })}
          </Tabs>
        )}
      </Section>
    );
  }
}
