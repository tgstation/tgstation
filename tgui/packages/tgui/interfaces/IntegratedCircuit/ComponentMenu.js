import {
  Section,
  Button,
  Dropdown,
  Stack,
  Box,
  Input,
} from '../../components';
import { Component } from 'inferno';
import { shallowDiffers } from 'common/react';
import { fetchRetry } from "../../http";
import { resolveAsset } from '../../assets';
import { Port } from './Port';
import { DEFAULT_COMPONENT_MENU_LIMIT, noop } from './constants';

// Cache response so it's only sent once
let fetchServerData;

export class ComponentMenu extends Component {
  constructor() {
    super();
    this.state = {
      selectedTab: "All",
      currentLimit: DEFAULT_COMPONENT_MENU_LIMIT,
      currentSearch: "",
    };
  }

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset("circuit_components.json"))
        .then(response => response.json());
    }

    const circuitData = await fetchServerData;

    this.setState({
      componentData: circuitData.sort((a, b) =>
        a.name.toLowerCase() < b.name.toLowerCase()),
    });
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (shallowDiffers(this.state, nextState)) {
      return true;
    }
    if (shallowDiffers(this.props.components, nextProps.components)) {
      return true;
    }
    return false;
  }

  render() {
    const {
      components = [],
      showAll = false,
      onMouseDownComponent,
      onClose,
      ...rest
    } = this.props;
    const {
      selectedTab,
      componentData = [],
      currentLimit,
      currentSearch,
    } = this.state;

    const tabs = ["All"];
    let shownComponents = componentData.filter(val => {
      let shouldShow = showAll || components.includes(val.type);
      if (shouldShow) {
        if (!tabs.includes(val.category)) {
          tabs.push(val.category);
        }
        if (currentSearch !== "") {
          const result
            = val.name.toLowerCase().search(currentSearch.toLowerCase());
          return result !== -1;
        }
        return selectedTab === "All" || selectedTab === val.category;
      }
      return false;
    });

    const trueLength = shownComponents.length;

    // Limit the maximum amount of shown components to prevent a lagspike
    // when you open the menu
    shownComponents.length = currentLimit;

    return (
      <Section
        title="Component Menu"
        {...rest}
        fill
        buttons={
          <Button
            icon="times"
            color="transparent"
            mr={2}
            onClick={onClose}
          />
        }
        onMouseUp={(event) => {
          event.preventDefault();
        }}
        scrollable
      >
        <Stack vertical>
          <Stack.Item>
            <Dropdown
              width="100%"
              options={tabs}
              onSelected={(value) => this.setState({
                selectedTab: value,
                currentSearch: "",
                currentLimit: DEFAULT_COMPONENT_MENU_LIMIT,
              })}
              displayText={`Category: ${selectedTab}`}
              color="transparent"
              className="IntegratedCircuit__BlueBorder"
            />
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder="Search.."
              value={currentSearch}
              fluid
              onInput={(e, val) => this.setState({
                currentSearch: val,
                selectedTab: "All",
                currentLimit: DEFAULT_COMPONENT_MENU_LIMIT,
              })}
            />
          </Stack.Item>
          <Stack.Item>
            <Stack vertical fill>
              {shownComponents.map(val => (
                <Stack.Item
                  key={val.type}
                  mt={1}
                  onMouseDown={(e) => onMouseDownComponent(e, val)}
                >
                  <Box
                    backgroundColor={val.color || "blue"}
                    py={1}
                    px={1}
                    className="ObjectComponent__Titlebar"
                  >
                    <Stack>
                      <Stack.Item grow={1} unselectable="on">
                        {val.name}
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          color="transparent"
                          icon="info"
                          compact
                          tooltip={val.description}
                          tooltipPosition="top"
                        />
                      </Stack.Item>
                    </Stack>
                  </Box>
                  <Box
                    className="ObjectComponent__Content"
                    unselectable="on"
                    py={1}
                    px={1}>
                    <Stack>
                      <Stack.Item grow>
                        <Stack vertical fill>
                          {val.input_ports.map((port, portIndex) => (
                            <Stack.Item key={portIndex}>
                              <Port
                                port={port}
                                act={noop}
                              />
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Stack.Item>
                      <Stack.Item>
                        <Stack vertical>
                          {val.output_ports.map((port, portIndex) => (
                            <Stack.Item key={portIndex}>
                              <Port
                                port={port}
                                act={noop}
                                isOutput
                              />
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Stack.Item>
                    </Stack>
                  </Box>
                </Stack.Item>
              ))}
              {trueLength > currentLimit && (
                <Stack.Item mt={1}>
                  <Button
                    height="32px"
                    textAlign="center"
                    py={1}
                    mb={1}
                    content="Show More"
                    onClick={() => this.setState({
                      currentLimit: currentLimit + 5,
                    })}
                    fluid
                  />
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Section>
    );
  }
}
