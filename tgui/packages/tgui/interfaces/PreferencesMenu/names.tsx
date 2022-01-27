import { binaryInsertWith, sortBy } from "common/collections";
import { useLocalState } from "../../backend";
import { Box, Button, FitText, Icon, Input, LabeledList, Modal, Section, Stack, TrackOutsideClicks } from "../../components";
import { Name } from "./data";
import { ServerPreferencesFetcher } from "./ServerPreferencesFetcher";

type NameWithKey = {
  key: string,
  name: Name,
};

const binaryInsertName = binaryInsertWith<NameWithKey>(({ key }) => key);

const sortNameWithKeyEntries = sortBy<[string, NameWithKey[]]>(
  ([key]) => key,
);

export const MultiNameInput = (props: {
  handleClose: () => void,
  handleRandomizeName: (nameType: string) => void,
  handleUpdateName: (nameType: string, value: string) => void,
  names: Record<string, string>,
}, context) => {
  const [currentlyEditingName, setCurrentlyEditingName]
    = useLocalState<string | null>(context, "currentlyEditingName", null);

  return (
    <ServerPreferencesFetcher render={data => {
      if (!data) {
        return null;
      }

      const namesIntoGroups: Record<string, NameWithKey[]> = {};

      for (const [key, name] of Object.entries(data.names.types)) {
        namesIntoGroups[name.group] = binaryInsertName(
          namesIntoGroups[name.group] || [],
          {
            key,
            name,
          }
        );
      }

      return (
        <Modal style={{
          "margin": "0 auto",
          "width": "40%",
        }}>
          <TrackOutsideClicks onOutsideClick={props.handleClose}>
            <Section
              buttons={(
                <Button
                  color="red"
                  onClick={props.handleClose}
                >
                  Close
                </Button>
              )}
              title="Alternate names"
            >
              <LabeledList>
                {sortNameWithKeyEntries(Object.entries(namesIntoGroups))
                  .map(([_, names], index, collection) => (
                    <>
                      {names.map(({ key, name }) => {
                        let content;

                        if (currentlyEditingName === key) {
                          const updateName = (event, value) => {
                            props.handleUpdateName(
                              key,
                              value,
                            );

                            setCurrentlyEditingName(null);
                          };

                          content = (
                            <Input
                              autoSelect
                              onEnter={updateName}
                              onChange={updateName}
                              onEscape={() => {
                                setCurrentlyEditingName(null);
                              }}
                              value={props.names[key]}
                            />
                          );
                        } else {
                          content = (
                            <Button
                              width="100%"
                              onClick={(event) => {
                                setCurrentlyEditingName(key);
                                event.cancelBubble = true;
                                event.stopPropagation();
                              }}
                            >
                              <FitText maxFontSize={12} maxWidth={130}>
                                {props.names[key]}
                              </FitText>
                            </Button>
                          );
                        }

                        return (
                          <LabeledList.Item
                            key={key}
                            label={name.explanation}
                          >
                            <Stack fill>
                              <Stack.Item grow>
                                {content}
                              </Stack.Item>

                              {!!name.can_randomize && (
                                <Stack.Item>
                                  <Button
                                    icon="dice"
                                    tooltip="Randomize"
                                    tooltipPosition="right"
                                    onClick={() => {
                                      props.handleRandomizeName(key);
                                    }}
                                  />
                                </Stack.Item>
                              )}
                            </Stack>
                          </LabeledList.Item>
                        );
                      })}

                      {(index !== collection.length - 1)
                        && <LabeledList.Divider />}
                    </>
                  ))}
              </LabeledList>
            </Section>
          </TrackOutsideClicks>
        </Modal>
      );
    }} />
  );
};

export const NameInput = (props: {
  handleUpdateName: (name: string) => void,
  name: string,
  openMultiNameInput: () => void,
}, context) => {
  const [lastNameBeforeEdit, setLastNameBeforeEdit]
    = useLocalState<string | null>(context, "lastNameBeforeEdit", null);
  const editing = lastNameBeforeEdit === props.name;

  const updateName = (e, value) => {
    setLastNameBeforeEdit(null);
    props.handleUpdateName(value);
  };

  return (
    <Button captureKeys={!editing} onClick={() => {
      setLastNameBeforeEdit(props.name);
    }} textAlign="center" width="100%" height="28px">
      <Stack align="center" fill>
        <Stack.Item>
          <Icon style={{
            "color": "rgba(255, 255, 255, 0.5)",
            "font-size": "17px",
          }} name="edit" />
        </Stack.Item>

        <Stack.Item grow position="relative">
          {editing && (
            <Input
              autoSelect
              onEnter={updateName}
              onChange={updateName}
              onEscape={() => {
                setLastNameBeforeEdit(null);
              }}
              value={props.name}
            />
          ) || (
            <FitText maxFontSize={16} maxWidth={130}>
              {props.name}
            </FitText>
          )}

          <Box style={{
            "border-bottom": "2px dotted rgba(255, 255, 255, 0.8)",
            right: "50%",
            transform: "translateX(50%)",
            position: "absolute",
            width: "90%",
            bottom: "-1px",
          }} />
        </Stack.Item>

        {/* We only know other names when the server tells us */}
        <ServerPreferencesFetcher render={data => data ? (
          <Stack.Item>
            <Button
              as="span"
              tooltip="Alternate Names"
              tooltipPosition="bottom"
              style={{
                background: "rgba(0, 0, 0, 0.7)",
                position: "absolute",
                right: "2px",
                top: "50%",
                transform: "translateY(-50%)",
                width: "2%",
              }}
              onClick={(event) => {
                props.openMultiNameInput();

                // We're a button inside a button.
                // Did you know that's against the W3C standard? :)
                event.cancelBubble = true;
                event.stopPropagation();
              }}
            >
              <Icon name="ellipsis-v" style={{
                "position": "relative",
                "left": "1px",
                "min-width": "0px",
              }} />
            </Button>
          </Stack.Item>
        ) : null} />
      </Stack>
    </Button>
  );
};


