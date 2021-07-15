import { classes } from "common/react";
import { sendAct, useBackend, useLocalState } from "../../backend";
import { Box, Button, ByondUi, Dropdown, FitText, Flex, Icon, Input, LabeledList, NumberInput, Popper, Stack } from "../../components";
import { createSetPreference, PreferencesMenuData } from "./data";
import { CharacterPreview } from "./CharacterPreview";
import { Gender, GENDERS } from "./preferences/gender";
import { Component, createRef } from "inferno";
import features from "./preferences/features";
import { Feature, ValueType } from "./preferences/features/base";

const CLOTHING_CELL_SIZE = 32;
const CLOTHING_SIDEBAR_ROWS = 9;

const CLOTHING_SELECTION_CELL_SIZE = 48;
const CLOTHING_SELECTION_WIDTH = 5.4;
const CLOTHING_SELECTION_MULTIPLIER = 5.2;

// MOTHBLOCKS TODO: Put this in the datum, or perhaps derive it?
// Actually, just put these all in the feature files.
const KEYS_TO_NAMES = {
  backpack: "backpack",
  feature_moth_wings: "moth wings",
  jumpsuit_style: "jumpsuit style",
  socks: "socks",
  undershirt: "undershirt",
  underwear: "underwear",
};

// MOTHBLOCKS TODO: Move outside this class
class Autofocus extends Component {
  ref = createRef<HTMLDivElement>();

  componentDidMount() {
    setTimeout(() => {
      this.ref.current?.focus();
    }, 1);
  }

  render() {
    return (
      <div ref={this.ref} tabIndex={-1}>
        {this.props.children}
      </div>
    );
  }
}

// MOTHBLOCKS TODO: Move outside this class
class TrackOutsideClicks extends Component<{
  onOutsideClick: () => void,
}> {
  ref = createRef<HTMLDivElement>();

  constructor() {
    super();

    this.handleOutsideClick = this.handleOutsideClick.bind(this);

    document.addEventListener("click", this.handleOutsideClick);
  }

  componentWillUnmount() {
    document.removeEventListener("click", this.handleOutsideClick);
  }

  handleOutsideClick(event: MouseEvent) {
    if (!(event.target instanceof Node)) {
      return;
    }

    if (this.ref.current && !this.ref.current.contains(event.target)) {
      this.props.onOutsideClick();
    }
  }

  render() {
    return (
      <div ref={this.ref}>
        {this.props.children}
      </div>
    );
  }
}

const CharacterControls = (props: {
  handleRotate: () => void,
  handleOpenSpecies: () => void,
  gender: Gender,
  setGender: (gender: Gender) => void,
}) => {
  return (
    <Stack>
      <Stack.Item>
        <Button
          onClick={props.handleRotate}
          fontSize="16px"
          icon="undo"
          tooltip="Rotate"
          tooltipPosition="top"
        />
      </Stack.Item>

      <Stack.Item>
        <Button
          onClick={props.handleOpenSpecies}
          fontSize="16px"
          icon="paw"
          tooltip="Species"
          tooltipPosition="top"
        />
      </Stack.Item>

      <Stack.Item>
        <GenderButton gender={props.gender} handleSetGender={props.setGender} />
      </Stack.Item>
    </Stack>
  );
};

const ChoicedSelection = (props: {
  name: string,
  catalog: Record<string, string>,
  selected: string,
  onSelect: (value: string) => void,
}) => {
  return (
    <Box style={{
      background: "white",
      padding: "5px",
      width: `${CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_WIDTH}px`,
      height:
        `${CLOTHING_SELECTION_CELL_SIZE * CLOTHING_SELECTION_MULTIPLIER}px`,
    }}>
      <Stack vertical fill>
        <Stack.Item>
          <Box style={{
            "border-bottom": "1px solid #888",
            "font-size": "14px",
            "text-align": "center",
          }}>Select {props.name}
          </Box>
        </Stack.Item>

        <Stack.Item overflowY="scroll">
          <Autofocus>
            <Flex wrap>
              {Object.entries(props.catalog).map(([name, image], index) => {
                return (
                  <Flex.Item
                    key={index}
                    basis={`${CLOTHING_SELECTION_CELL_SIZE}px`}
                    style={{
                      padding: "5px",
                    }}
                  >
                    <Button
                      onClick={() => {
                        props.onSelect(name);
                      }}
                      selected={name === props.selected}
                      tooltip={name}
                      tooltipPosition="right"
                      style={{
                        height: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                        width: `${CLOTHING_SELECTION_CELL_SIZE}px`,
                      }}
                    >
                      <Box className={classes(["preferences32x32", image, "centered-image"])} />
                    </Button>
                  </Flex.Item>
                );
              })}
            </Flex>
          </Autofocus>
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const GenderButton = (props: {
  handleSetGender: (gender: Gender) => void,
  gender: Gender,
}, context) => {
  const [genderMenuOpen, setGenderMenuOpen] = useLocalState(context, "genderMenuOpen", false);

  return (
    <Popper options={{
      placement: "right-end",
    }} popperContent={(
      genderMenuOpen
        && (
          <Stack backgroundColor="white" ml={0.5} p={0.3}>
            {[Gender.Male, Gender.Female, Gender.Other].map(gender => {
              return (
                <Stack.Item key={gender}>
                  <Button
                    selected={gender === props.gender}
                    onClick={() => {
                      props.handleSetGender(gender);
                      setGenderMenuOpen(false);
                    }}
                    fontSize="16px"
                    icon={GENDERS[gender].icon}
                    tooltip={GENDERS[gender].text}
                    tooltipPosition="top"
                  />
                </Stack.Item>
              );
            })}
          </Stack>
        )
    )}>
      <Button
        onClick={() => {
          setGenderMenuOpen(!genderMenuOpen);
        }}
        fontSize="16px"
        icon={GENDERS[props.gender].icon}
        tooltip="Gender"
        tooltipPosition="top"
      />
    </Popper>
  );
};

const NameInput = (props: {
  handleUpdateName: (name: string) => void,
  name: string,
}, context) => {
  const [lastNameBeforeEdit, setLastNameBeforeEdit] = useLocalState(context, "lastNameBeforeEdit", null);
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

        <Stack.Item>
          <Button as="span" tooltip="Alternate Names" tooltipPosition="bottom" style={{
            background: "rgba(0, 0, 0, 0.7)",
            position: "absolute",
            right: "2px",
            top: "50%",
            transform: "translateY(-50%)",
            width: "2%",
          }}>
            <Icon name="ellipsis-v" style={{
              "position": "relative",
              "left": "1px",
              "min-width": "0px",
            }} />
          </Button>
        </Stack.Item>
      </Stack>
    </Button>
  );
};

const FeatureValue = (props: {
  feature: Feature,
  featureId: string,
  value: unknown,

  act: typeof sendAct,
}, context) => {
  const feature = props.feature;

  const [predictedValue, setPredictedValue] = useLocalState(
    context,
    `${props.featureId}_predictedValue`,
    props.value,
  );

  const changeValue = (newValue: string) => {
    setPredictedValue(newValue);
    createSetPreference(props.act, props.featureId)(newValue);
  };

  switch (feature.valueType) {
    case ValueType.Choiced:
      // MOTHBLOCKS TODO: Sort
      return (<Dropdown
        selected={predictedValue}
        displayText={feature.choices[predictedValue as string]}
        onSelected={changeValue}
        width="120px"
        options={Object.entries(feature.choices).map(([dataValue, label]) => {
          return {
            displayText: label,
            value: dataValue,
          };
        })}
      />);
    case ValueType.Color:
      return (
        <Button onClick={() => {
          props.act("set_color_preference", {
            preference: props.featureId,
          });
        }}>
          <Stack align="center" fill>
            <Stack.Item>
              <Box style={{
                background: `#${props.value}`,
                border: "2px solid white",
                "box-sizing": "content-box",
                height: "11px",
                width: "11px",
              }} />
            </Stack.Item>

            <Stack.Item>
              Change
            </Stack.Item>
          </Stack>
        </Button>
      );
    case ValueType.Number:
      return (<NumberInput
        onChange={(e, value) => {
          changeValue(value);
        }}
        minValue={feature.minimum}
        maxValue={feature.maximum}
        value={predictedValue}
      />);
  }
};

const PreferenceList = (props: {
  act: typeof sendAct,
  preferences: Record<string, unknown>,
}) => {
  /* MOTHBLOCKS TODO: Overflow */
  /* MOTHBLOCKS TODO: Sort it */
  return (
    <Stack.Item basis="30%" grow style={{
      background: "rgba(0, 0, 0, 0.5)",
      padding: "4px",
    }}>
      {/* <Stack vertical fill>
        { Object.entries(props.preferences).map(([featureId, value]) => {
          const feature = features[featureId];

          if (feature === undefined) {
            return (
              <Stack.Item key={featureId}>
                <b>Feature {featureId} is not recognized.</b>
              </Stack.Item>
            );
          }

          return (
            <Stack.Item key={featureId}>
              <Stack fill>
                <Stack.Item grow>
                  <b>{feature.name}</b>
                </Stack.Item>

                <Stack.Item>
                  <FeatureValue
                    act={props.act}
                    feature={feature}
                    featureId={featureId}
                    value={value}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          );
        })}
      </Stack> */}

      <LabeledList>
        { Object.entries(props.preferences).map(([featureId, value]) => {
          const feature = features[featureId];

          if (feature === undefined) {
            return (
              <Stack.Item key={featureId}>
                <b>Feature {featureId} is not recognized.</b>
              </Stack.Item>
            );
          }

          return (
            <Stack.Item key={featureId}>
              <Stack fill>
                <Stack.Item grow>
                  <b>{feature.name}</b>
                </Stack.Item>

                <Stack.Item>
                  <FeatureValue
                    act={props.act}
                    feature={feature}
                    featureId={featureId}
                    value={value}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          );
        })}
      </LabeledList>
    </Stack.Item>
  );
};

export const MainPage = (props: {
  openSpecies: () => void,
}, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const [currentClothingMenu, setCurrentClothingMenu] = useLocalState(context, "currentClothingMenu", null);

  const currentSpeciesData = data.species[
    data
      .character_preferences
      .misc
      .species
  ];

  const requestPreferenceData = (key: string) => {
    act("request_values", {
      preference: key,
    });
  };

  return (
    <Stack fill>
      <Stack.Item>
        <Stack vertical>
          <Stack.Item>
            <CharacterControls
              gender={data.character_preferences.misc.gender}
              handleOpenSpecies={props.openSpecies}
              handleRotate={() => {
                act("rotate");
              }}
              setGender={createSetPreference(act, "gender")}
            />
          </Stack.Item>

          <Stack.Item>
            <CharacterPreview
              height={`${CLOTHING_SIDEBAR_ROWS * CLOTHING_CELL_SIZE}px`}
              id={data.character_preview_view} />
          </Stack.Item>

          <Stack.Item position="relative">
            <NameInput
              name={data.character_preferences.names[data.name_to_use].value}
              handleUpdateName={createSetPreference(act, data.name_to_use)}
            />
          </Stack.Item>

        </Stack>
      </Stack.Item>

      <Stack.Item>
        <Stack
          vertical
          fill
          width={`${CLOTHING_CELL_SIZE}px`}
        >
          {[
            ...Object.entries(data.character_preferences.clothing),
            ...Object.entries(data.character_preferences.features)
              .filter(([featureName]) => {
                return currentSpeciesData.features
                  .indexOf(featureName.split("feature_")[1]) !== -1;
              }),
          ]
            .map(([clothingKey, clothing]) => {
              // MOTHBLOCKS TODO: Better nude icons, rather than X
              return (
                <Stack.Item key={clothingKey}>
                  <Popper options={{
                    placement: "bottom-start",
                  }} popperContent={(currentClothingMenu === clothingKey
                    && data.generated_preference_values
                    && data.generated_preference_values[clothingKey]) && (
                    <TrackOutsideClicks onOutsideClick={() => {
                      setCurrentClothingMenu(null);
                    }}>
                      <ChoicedSelection
                        name={KEYS_TO_NAMES[clothingKey]
                          || `NO NAME FOR ${clothingKey}`}
                        catalog={
                          data.generated_preference_values[clothingKey]
                        }
                        selected={clothing.value}
                        onSelect={createSetPreference(act, clothingKey)}
                      />
                    </TrackOutsideClicks>
                  )}>
                    <Button onClick={() => {
                      setCurrentClothingMenu(
                        currentClothingMenu === clothingKey
                          ? null
                          : clothingKey
                      );

                      requestPreferenceData(clothingKey);
                    }} style={{
                      height: `${CLOTHING_CELL_SIZE}px`,
                      width: `${CLOTHING_CELL_SIZE}px`,
                    }} tooltip={clothing.value} tooltipPosition="right">
                      <Box
                        className={classes([
                          "preferences32x32",
                          clothing.icon,
                          "centered-image",
                        ])} />
                    </Button>
                  </Popper>
                </Stack.Item>
              );
            })}
        </Stack>
      </Stack.Item>

      <PreferenceList
        act={act}
        preferences={
          Object.fromEntries(
            Object.entries(data.character_preferences.secondary_features)
              .filter(([feature]) => {
                return currentSpeciesData.features.indexOf(feature) !== -1;
              }))
        }
      />

      <PreferenceList
        act={act}
        preferences={data.character_preferences.non_contextual}
      />
    </Stack>
  );
};
