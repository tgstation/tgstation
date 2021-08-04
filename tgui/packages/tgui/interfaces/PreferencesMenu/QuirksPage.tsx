import { Component, StatelessComponent } from "inferno";
import { Box, Icon, Stack, Table, Tooltip } from "../../components";
import { resolveAsset } from "../../assets";
import { classes } from "common/react";
import { PreferencesMenuData } from "./data";
import { useBackend } from "../../backend";
import { logger } from "../../logging";

type Quirk = {
  description: string;
  name: string;
  value: number;
};

type QuirksPageState = {
  selectedQuirks: string[];
  quirkInfo?: Record<string, Quirk>;
  maxPositiveQuirks: number;
  quirkBlacklist: string[][];
};

type QuirkInfoResponse = {
  max_positive_quirks: number;
  quirk_info: Record<string, Quirk>;
  quirk_blacklist: string[][];
};

const getValueClass = (value: number): string => {
  if (value > 0) {
    return "positive";
  } else if (value < 0) {
    return "negative";
  } else {
    return "neutral";
  }
};

const QuirkList = (props: {
  quirks: [string, Quirk & {
    failTooltip?: string;
  }][],
  onClick: (quirkName: string, quirk: Quirk) => void,
}) => {
  return (
    <Stack
      className="PreferencesMenu__Quirks__QuirkList"
      vertical
      fill
    >
      {props.quirks.map(([quirkKey, quirk]) => {
        const className = "PreferencesMenu__Quirks__QuirkList__quirk";

        const child2 = (
          <Stack.Item
            className={className}
            key={quirkKey}
            onClick={() => props.onClick(quirkKey, quirk)}
            style={{
              "margin-top": 0,
            }}
          >
            <Stack fill>
              <Stack.Item style={{
                "border-right": "1px solid black",
                "height": "100%",
              }}>
                <Box
                  className={classes(["quirks64x64", quirkKey])}
                  style={{
                    // "position": "relative",
                    // "top": "50%",
                    // "transform": "translateY(-50%)",
                  }}
                />
              </Stack.Item>

              <Stack.Item grow style={{
                "margin-left": 0,
              }}>
                <Stack vertical fill>
                  <Stack.Item
                    className={
                      `${className}--${getValueClass(quirk.value)}`
                    }
                    style={{
                      "border-bottom": "1px solid black",
                      "padding": "2px",
                    }}
                  >
                    <Stack fill style={{
                      "font-size": "1.2em",
                    }}>
                      <Stack.Item grow>
                        <b>{quirk.name}</b>
                      </Stack.Item>

                      <Stack.Item>
                        <b>{quirk.value}</b>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>

                  <Stack.Item grow style={{
                    "margin-top": 0,
                    "padding": "3px",
                  }}>
                    {quirk.description}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        );

        const child = (
          <Stack.Item
          >
            <Box>
              lorem ipsum blab
              ba
              lablabbakjaoijboijaoijrgjoi9er98u t4u98u98m5498u geu98fuoidgf uiod
              gfoiuf dgoiugfd uoioiu dgfuoifd guoig  ouifdguoi
            </Box>
          </Stack.Item>
        );

        if (quirk.failTooltip) {
          return (
            <Tooltip
              content={quirk.failTooltip}
              key={quirkKey}
              position="top"
            >
              {child}
            </Tooltip>
          );
        } else {
          return child;
        }
      })}
    </Stack>
  );
};

const StatDisplay: StatelessComponent<{}> = (props) => {
  return (
    <Box
      backgroundColor="#eee"
      bold
      color="black"
      fontSize="1.2em"
      px={3}
      py={0.5}
    >
      {props.children}
    </Box>
  );
};

export class QuirksPage extends Component<{}, QuirksPageState> {
  constructor() {
    super();

    this.state = {
      maxPositiveQuirks: 0,
      quirkBlacklist: [],
      quirkInfo: null,
      selectedQuirks: [],
    };
  }

  componentDidMount() {
    this.populateSelectedQuirks();
    this.populateQuirkInfo();
  }

  async populateQuirkInfo() {
    const quirkDataResponse = await fetch(resolveAsset("quirk_info.json"));
    const quirkData: QuirkInfoResponse = await quirkDataResponse.json();

    this.setState({
      maxPositiveQuirks: quirkData.max_positive_quirks,
      quirkBlacklist: quirkData.quirk_blacklist,
      quirkInfo: quirkData.quirk_info,
    });
  }

  populateSelectedQuirks() {
    const { data } = useBackend<PreferencesMenuData>(this.context);

    this.setState({
      selectedQuirks: data.selected_quirks,
    });
  }

  render() {
    const { act, data } = useBackend<PreferencesMenuData>(this.context);

    if (!this.state.quirkInfo) {
      return <Box>Loading quirks...</Box>;
    }

    const quirks = Object.entries(this.state.quirkInfo);
    quirks.sort(([_, quirkA], [__, quirkB]) => {
      if (quirkA.value === quirkB.value) {
        return (quirkA.name > quirkB.name) ? 1 : -1;
      } else {
        return quirkA.value - quirkB.value;
      }
    });

    let balance = 0;
    let positiveQuirks = 0;

    for (const selectedQuirkName of this.state.selectedQuirks) {
      const selectedQuirk = this.state.quirkInfo[selectedQuirkName];
      if (!selectedQuirk) {
        continue;
      }

      if (selectedQuirk.value > 0) {
        positiveQuirks += 1;
      }

      balance += selectedQuirk.value;
    }

    const getReasonToNotAdd = (quirkName: string) => {
      const quirk = this.state.quirkInfo[quirkName];

      if (
        quirk.value > 0
      ) {
        if (positiveQuirks >= this.state.maxPositiveQuirks) {
          return "You can't have any more positive quirks!";
        } else if (balance + quirk.value > 0) {
          return "You need a negative quirk to balance this out!";
        }
      }

      const selectedQuirks = this.state.selectedQuirks.map(quirkKey => {
        return this.state.quirkInfo[quirkKey].name;
      });

      for (const blacklist of this.state.quirkBlacklist) {
        if (blacklist.indexOf(quirk.name) === -1) {
          continue;
        }

        for (const incompatibleQuirk of blacklist) {
          if (
            incompatibleQuirk !== quirk.name
            && selectedQuirks.indexOf(incompatibleQuirk) !== -1
          ) {
            return `This is incompatible with ${incompatibleQuirk}!`;
          }
        }
      }

      return null;
    };

    const getReasonToNotRemove = (quirkName: string) => {
      const quirk = this.state.quirkInfo[quirkName];

      if (balance - quirk.value > 0) {
        return "You need to remove a negative quirk first!";
      }

      return null;
    };

    return (
      <Stack align="center" fill>
        <Stack.Item basis="50%">
          <Stack vertical fill align="center">
            <Stack.Item>
              <Box fontSize="1.3em">
                Positive Quirks
              </Box>
            </Stack.Item>

            <Stack.Item>
              <StatDisplay>
                {positiveQuirks} / {this.state.maxPositiveQuirks}
              </StatDisplay>
            </Stack.Item>

            <Stack.Item>
              <Box as="b" fontSize="1.6em">
                Available Quirks
              </Box>
            </Stack.Item>

            <Stack.Item grow width="100%">
              <QuirkList
                onClick={(quirkName, quirk) => {
                  if (getReasonToNotAdd(quirkName) !== null) {
                    return;
                  }

                  this.setState(oldState => {
                    return {
                      selectedQuirks: oldState.selectedQuirks.concat(quirkName),
                    };
                  });

                  act("give_quirk", { quirk: quirk.name });
                }}
                quirks={quirks.filter(([quirkName, _]) => {
                  return this.state.selectedQuirks.indexOf(quirkName) === -1;
                }).map(([quirkName, quirk]) => {
                  return [quirkName, {
                    ...quirk,
                    failTooltip: getReasonToNotAdd(quirkName),
                  }];
                })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>

        <Stack.Item>
          <Icon
            name="exchange-alt"
            size={1.5}
            ml={2}
            mr={2}
          />
        </Stack.Item>

        <Stack.Item basis="50%">
          <Stack vertical fill align="center">
            <Stack.Item>
              <Box fontSize="1.3em">
                Quirk Balance
              </Box>
            </Stack.Item>

            <Stack.Item>
              <StatDisplay>
                {balance}
              </StatDisplay>
            </Stack.Item>

            <Stack.Item>
              <Box as="b" fontSize="1.6em">
                Current Quirks
              </Box>
            </Stack.Item>

            <Stack.Item grow width="100%">
              <QuirkList
                onClick={(quirkName, quirk) => {
                  if (getReasonToNotRemove(quirkName) !== null) {
                    return;
                  }

                  this.setState(oldState => {
                    return {
                      selectedQuirks: oldState.selectedQuirks
                        .filter(otherQuirk => quirkName !== otherQuirk),
                    };
                  });

                  act("remove_quirk", { quirk: quirk.name });
                }}
                quirks={quirks.filter(([quirkName, _]) => {
                  return this.state.selectedQuirks.indexOf(quirkName) !== -1;
                }).map(([quirkName, quirk]) => {
                  return [quirkName, {
                    ...quirk,
                    failTooltip: getReasonToNotRemove(quirkName),
                  }];
                })}
              />
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    );
  }
}
