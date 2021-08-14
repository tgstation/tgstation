import { Component, createRef, RefObject } from "inferno";
import { Box, Button, Flex, Icon, Section, Stack, Table, Tooltip, TrackOutsideClicks } from "../../components";
import { resolveAsset } from "../../assets";
import { PreferencesMenuData } from "./data";
import { useBackend, useLocalState } from "../../backend";
import { sortBy } from "common/collections";

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
      captureKeys={props.typingHotkey === null}
      onClick={props.onClick}
      selected={props.typingHotkey !== null}
    >
      {props.typingHotkey || props.currentHotkey || "Unbound"}
    </Button>
  );

  if (props.typingHotkey) {
    return (
      <TrackOutsideClicks onOutsideClick={() => {
        // Will toggle it off
        props.onClick();
      }}>
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
  categoryRefs: Record<string, RefObject<HTMLDivElement>> = {};
  keybindingsSectionRef: RefObject<HTMLDivElement> = createRef();
  keybindingOnClicks: Record<string, (() => void)[]> = {};
  lastKeybinds?: PreferencesMenuData["keybindings"];

  constructor() {
    super();

    this.state = {
      lastKeyboardEvent: null,
      keybindings: null,
      selectedKeybindings: null,
      rebindingHotkey: null,
    };

    this.onKeyDown = this.onKeyDown.bind(this);
  }

  componentDidMount() {
    this.populateSelectedKeybindings();
    this.populateKeybindings();

    document.addEventListener("keydown", this.onKeyDown);
  }

  componentDidUpdate() {
    const { data } = useBackend<PreferencesMenuData>(this.context);

    // keybindings is static data, so it'll pass `===` checks.
    // This'll change when resetting to defaults.
    if (data.keybindings !== this.lastKeybinds) {
      this.populateSelectedKeybindings();
    }
  }

  componentWillUnmount() {
    document.removeEventListener("keydown", this.onKeyDown);
  }

  setRebindingHotkey(value?: string) {
    const { act } = useBackend<PreferencesMenuData>(this.context);

    this.setState((state) => {
      let selectedKeybindings = state.selectedKeybindings;
      if (!selectedKeybindings) {
        return state;
      }

      selectedKeybindings = { ...selectedKeybindings };

      const [keybindName, slot] = state.rebindingHotkey;

      if (selectedKeybindings[keybindName]) {
        selectedKeybindings[keybindName][slot] = value;
        selectedKeybindings[keybindName] = selectedKeybindings[keybindName]
          .filter(value => !!value);
      } else if (!value) {
        return;
      } else {
        selectedKeybindings[keybindName] = [value];
      }

      act("set_keybindings", {
        "keybind_name": keybindName,
        "hotkeys": selectedKeybindings[keybindName],
      });

      return {
        lastKeyboardEvent: null,
        rebindingHotkey: null,
        selectedKeybindings,
      };
    });
  }

  onKeyDown(event: KeyboardEvent) {
    const rebindingHotkey = this.state.rebindingHotkey;

    if (!rebindingHotkey) {
      return;
    }

    event.preventDefault();

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

  getKeybindingOnClick(
    keybindingId: string,
    slot: number,
  ): () => void {
    if (!this.keybindingOnClicks[keybindingId]) {
      this.keybindingOnClicks[keybindingId] = [];
    }

    if (!this.keybindingOnClicks[keybindingId][slot]) {
      this.keybindingOnClicks[keybindingId][slot] = () => {
        if (this.state.rebindingHotkey === null) {
          this.setState({
            lastKeyboardEvent: null,
            rebindingHotkey: [keybindingId, slot],
          });
        } else {
          this.setState({
            lastKeyboardEvent: null,
            rebindingHotkey: null,
          });
        }
      };
    }

    return this.keybindingOnClicks[keybindingId][slot];
  }

  getTypingHotkey(keybindingId: string, slot: number): string | null {
    if (!this.state.rebindingHotkey) {
      return null;
    }

    if (this.state.rebindingHotkey[0] !== keybindingId
        || this.state.rebindingHotkey[1] !== slot
    ) {
      return null;
    }

    if (this.state.lastKeyboardEvent === null) {
      return "...";
    }

    return formatKeyboardEvent(this.state.lastKeyboardEvent);
  }

  async populateKeybindings() {
    const keybindingsResponse = await fetch(resolveAsset("keybindings.json"));
    const keybindingsData: Keybindings = await keybindingsResponse.json();

    for (const category of Object.keys(keybindingsData)) {
      this.categoryRefs[category] = createRef();
    }

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
      <Stack vertical fill>
        <Stack.Item>
          <Stack fill px={5}>
            {keybindingEntries.map(([category, _]) => {
              return (
                <Stack.Item key={category} grow>
                  <Button
                    align="center"
                    fontSize="1.2em"
                    fluid
                    onClick={() => {
                      const offsetTop = this.categoryRefs[category]
                        .current?.offsetTop;

                      if (!offsetTop) {
                        return;
                      }

                      if (!this.keybindingsSectionRef.current) {
                        return;
                      }

                      this.keybindingsSectionRef.current.scrollTop = offsetTop;
                    }}
                  >
                    {category}
                  </Button>
                </Stack.Item>
              );
            })}
          </Stack>
        </Stack.Item>

        <Stack.Item
          grow
          ref={this.keybindingsSectionRef}
          style={{
            "overflow-y": "scroll",
          }}
        >
          <Stack vertical fill px={2}>
            {keybindingEntries.map(
              ([category, keybindings]) => {
                return (
                  <Stack.Item
                    key={category}
                    ref={this.categoryRefs[category]}
                  >
                    <Section
                      fill
                      title={category}
                    >
                      <Stack vertical fill>
                        {sortKeybindings(Object.entries(keybindings)).map(
                          ([keybindingId, keybinding]) => {
                            const keys
                              = this.state.selectedKeybindings[keybindingId]
                                || [];

                            return (
                              <Stack.Item key={keybindingId}>
                                <Stack fill>
                                  {/* <Tooltip
                                    content={
                                      keybinding.description
                                      || "No description"
                                    }
                                  >
                                    <Stack.Item basis="25%">
                                      {keybinding.name}
                                    </Stack.Item>
                                  </Tooltip> */}

                                  {/* MOTHBLOCKS TODO: FIX TOOLTIP LAG */}
                                  <Stack.Item basis="25%">
                                    {keybinding.name}
                                  </Stack.Item>

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
                    </Section>
                  </Stack.Item>
                );
              }
            )}
          </Stack>
        </Stack.Item>
      </Stack>
    );
  }
}
