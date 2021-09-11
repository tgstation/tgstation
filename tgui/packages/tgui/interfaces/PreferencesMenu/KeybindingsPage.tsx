import { Component, createRef, RefObject } from "inferno";
import { Box, Button, Flex, Icon, KeyListener, Section, Stack, Table, Tooltip, TrackOutsideClicks } from "../../components";
import { resolveAsset } from "../../assets";
import { PreferencesMenuData } from "./data";
import { useBackend, useLocalState } from "../../backend";
import { sortBy } from "common/collections";
import { KeyEvent } from "../../events";
import { TabbedMenu } from "./TabbedMenu";
import { fetchRetry } from "../../http";

type Keybinding = {
  name: string;
  description?: string;
};

type Keybindings = Record<string, Record<string, Keybinding>>;

type KeybindingsPageState = {
  keybindings?: Keybindings;
  lastKeyboardEvent?: KeyboardEvent;
  selectedKeybindings?: PreferencesMenuData["keybindings"];

  /**
   * The current hotkey that the user is rebinding.
   *
   * First element is the hotkey name, the second is the slot.
   */
  rebindingHotkey?: [string, number];
};

const isStandardKey = (event: KeyboardEvent): boolean => {
  return event.key !== "Alt"
    && event.key !== "Control"
    && event.key !== "Shift"
    && event.key !== "Esc";
};

const KEY_CODE_TO_BYOND: Record<string, string> = {
  "DEL": "Delete",
  "DOWN": "South",
  "END": "Southwest",
  "HOME": "Northwest",
  "INSERT": "Insert",
  "LEFT": "West",
  "PAGEDOWN": "Southeast",
  "PAGEUP": "Northeast",
  "RIGHT": "East",
  "SPACEBAR": "Space",
  "UP": "North",
};

const sortKeybindings = sortBy(
  ([_, keybinding]: [string, Keybinding]) => {
    return keybinding.name;
  });

const sortKeybindingsByCategory = sortBy(
  ([category, _]: [string, Record<string, Keybinding>]) => {
    return category;
  });

const formatKeyboardEvent = (event: KeyboardEvent): string => {
  let text = "";

  if (event.altKey) {
    text += "Alt";
  }

  if (event.ctrlKey) {
    text += "Ctrl";
  }

  if (event.shiftKey) {
    text += "Shift";
  }

  if (event.location === KeyboardEvent.DOM_KEY_LOCATION_NUMPAD) {
    text += "Numpad";
  }

  if (isStandardKey(event)) {
    const key = event.key.toUpperCase();
    text += KEY_CODE_TO_BYOND[key] || key;
  }

  return text;
};

const moveToBottom = (entries: [string, unknown][], findCategory: string) => {
  entries.push(
    entries.splice(
      entries.findIndex(([category, _]) => {
        return category === findCategory;
      }), 1
    )[0]
  );
};

const KeybindingButton = (props: {
  currentHotkey?: string,
  onClick?: () => void,
  typingHotkey?: string,
}) => {
  const child = (
    <Button
      fluid
      textAlign="center"
      captureKeys={props.typingHotkey === undefined}
      onClick={props.onClick}
      selected={props.typingHotkey !== undefined}
    >
      {props.typingHotkey || props.currentHotkey || "Unbound"}
    </Button>
  );

  if (props.typingHotkey && props.onClick) {
    return (
      // props.onClick will cancel it
      <TrackOutsideClicks onOutsideClick={props.onClick}>
        {child}
      </TrackOutsideClicks>
    );
  } else {
    return child;
  }
};

const ResetToDefaultButton = (props: {
  keybindingId: string,
}, context) => {
  const { act } = useBackend<PreferencesMenuData>(context);

  return (
    <Button
      fluid
      textAlign="center"
      onClick={() => {
        act("reset_keybinds_to_defaults", {
          keybind_name: props.keybindingId,
        });
      }}
    >
      Reset to Defaults
    </Button>
  );
};

export class KeybindingsPage extends Component<{}, KeybindingsPageState> {
  cancelNextKeyUp?: number;
  keybindingOnClicks: Record<string, (() => void)[]> = {};
  lastKeybinds?: PreferencesMenuData["keybindings"];

  state: KeybindingsPageState = {
    lastKeyboardEvent: undefined,
    keybindings: undefined,
    selectedKeybindings: undefined,
    rebindingHotkey: undefined,
  };

  constructor() {
    super();

    this.handleKeyDown = this.handleKeyDown.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
  }

  componentDidMount() {
    this.populateSelectedKeybindings();
    this.populateKeybindings();
  }

  componentDidUpdate() {
    const { data } = useBackend<PreferencesMenuData>(this.context);

    // keybindings is static data, so it'll pass `===` checks.
    // This'll change when resetting to defaults.
    if (data.keybindings !== this.lastKeybinds) {
      this.populateSelectedKeybindings();
    }
  }

  setRebindingHotkey(value?: string) {
    const { act } = useBackend<PreferencesMenuData>(this.context);

    this.setState((state) => {
      let selectedKeybindings = state.selectedKeybindings;
      if (!selectedKeybindings) {
        return state;
      }

      if (!state.rebindingHotkey) {
        return state;
      }

      selectedKeybindings = { ...selectedKeybindings };

      const [keybindName, slot] = state.rebindingHotkey;

      if (selectedKeybindings[keybindName]) {
        if (value) {
          selectedKeybindings[keybindName][Math.min(
            selectedKeybindings[keybindName].length,
            slot
          )] = value;
        } else {
          selectedKeybindings[keybindName].splice(slot, 1);
        }
      } else if (!value) {
        return state;
      } else {
        selectedKeybindings[keybindName] = [value];
      }

      act("set_keybindings", {
        "keybind_name": keybindName,
        "hotkeys": selectedKeybindings[keybindName],
      });

      return {
        lastKeyboardEvent: undefined,
        rebindingHotkey: undefined,
        selectedKeybindings,
      };
    });
  }

  handleKeyDown(keyEvent: KeyEvent) {
    const event = keyEvent.event;
    const rebindingHotkey = this.state.rebindingHotkey;

    if (!rebindingHotkey) {
      return;
    }

    event.preventDefault();

    this.cancelNextKeyUp = keyEvent.code;

    if (isStandardKey(event)) {
      this.setRebindingHotkey(formatKeyboardEvent(event));
      return;
    } else if (event.key === "Esc") {
      this.setRebindingHotkey(undefined);
      return;
    }

    this.setState({
      lastKeyboardEvent: event,
    });
  }

  handleKeyUp(keyEvent: KeyEvent) {
    if (this.cancelNextKeyUp === keyEvent.code) {
      this.cancelNextKeyUp = undefined;
      keyEvent.event.preventDefault();
    }
  }

  getKeybindingOnClick(
    keybindingId: string,
    slot: number,
  ): () => void {
    if (!this.keybindingOnClicks[keybindingId]) {
      this.keybindingOnClicks[keybindingId] = [];
    }

    if (!this.keybindingOnClicks[keybindingId][slot]) {
      this.keybindingOnClicks[keybindingId][slot] = () => {
        if (this.state.rebindingHotkey === undefined) {
          this.setState({
            lastKeyboardEvent: undefined,
            rebindingHotkey: [keybindingId, slot],
          });
        } else {
          this.setState({
            lastKeyboardEvent: undefined,
            rebindingHotkey: undefined,
          });
        }
      };
    }

    return this.keybindingOnClicks[keybindingId][slot];
  }

  getTypingHotkey(keybindingId: string, slot: number): string | undefined {
    const { lastKeyboardEvent, rebindingHotkey } = this.state;

    if (!rebindingHotkey) {
      return undefined;
    }

    if (rebindingHotkey[0] !== keybindingId
        || rebindingHotkey[1] !== slot
    ) {
      return undefined;
    }

    if (lastKeyboardEvent === undefined) {
      return "...";
    }

    return formatKeyboardEvent(lastKeyboardEvent);
  }

  async populateKeybindings() {
    const keybindingsResponse = await fetchRetry(resolveAsset("keybindings.json"));
    const keybindingsData: Keybindings = await keybindingsResponse.json();

    this.setState({
      keybindings: keybindingsData,
    });
  }

  populateSelectedKeybindings() {
    const { data } = useBackend<PreferencesMenuData>(this.context);

    this.lastKeybinds = data.keybindings;

    this.setState({
      selectedKeybindings: Object.fromEntries(
        Object.entries(data.keybindings)
          .map(([keybind, hotkeys]) => {
            return [keybind, hotkeys.filter(value => value !== "Unbound")];
          })
      ),
    });
  }

  render() {
    const keybindings = this.state.keybindings;

    if (!keybindings) {
      return <Box>Loading keybindings...</Box>;
    }

    const keybindingEntries = sortKeybindingsByCategory(
      Object.entries(keybindings)
    );

    moveToBottom(keybindingEntries, "EMOTE");
    moveToBottom(keybindingEntries, "ADMIN");

    return (
      <>
        <KeyListener
          onKeyDown={this.handleKeyDown}
          onKeyUp={this.handleKeyUp}
        />

        <TabbedMenu
          categoryEntries={keybindingEntries.map(
            ([category, keybindings]) => {
              return [category, (
                <Stack key={category} vertical fill>
                  {sortKeybindings(Object.entries(keybindings)).map(
                    ([keybindingId, keybinding]) => {
                      const keys
                        = this.state.selectedKeybindings![keybindingId]
                          || [];

                      const name = (
                        <Stack.Item basis="25%">
                          {keybinding.description
                            ? (
                              <Tooltip
                                content={
                                  keybinding.description
                                }
                                position="bottom"
                              >
                                <Box as="span" style={{
                                  "border-bottom": "2px dotted rgba(255, 255, 255, 0.8)",
                                }}>
                                  {keybinding.name}
                                </Box>
                              </Tooltip>
                            )
                            : keybinding.name}
                        </Stack.Item>
                      );

                      return (
                        <Stack.Item key={keybindingId}>
                          <Stack fill>
                            {name}

                            <Stack.Item grow basis="10%">
                              <KeybindingButton
                                currentHotkey={keys[0]}
                                typingHotkey={this.getTypingHotkey(
                                  keybindingId,
                                  0,
                                )}
                                onClick={this.getKeybindingOnClick(
                                  keybindingId,
                                  0,
                                )}
                              />
                            </Stack.Item>

                            <Stack.Item grow basis="10%">
                              <KeybindingButton
                                currentHotkey={keys[1]}
                                typingHotkey={this.getTypingHotkey(
                                  keybindingId,
                                  1,
                                )}
                                onClick={this.getKeybindingOnClick(
                                  keybindingId,
                                  1,
                                )}
                              />
                            </Stack.Item>

                            <Stack.Item grow basis="10%">
                              <KeybindingButton
                                currentHotkey={keys[2]}
                                typingHotkey={this.getTypingHotkey(
                                  keybindingId,
                                  2,
                                )}
                                onClick={this.getKeybindingOnClick(
                                  keybindingId,
                                  2,
                                )}
                              />
                            </Stack.Item>

                            <Stack.Item shrink>
                              <ResetToDefaultButton
                                keybindingId={keybindingId} />
                            </Stack.Item>
                          </Stack>
                        </Stack.Item>
                      );
                    }
                  )}
                </Stack>
              )];
            }
          )}
        />
      </>
    );
  }
}
