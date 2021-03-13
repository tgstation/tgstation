import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';
import { Button, Dropdown, Section, Stack } from '../components';

export const PaintingMachine = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    pdaTypes,
    cardTrims,
    hasPDA,
    pdaName,
    hasID,
    idName,
  } = data;

  const [
    selectedPDA,
  ] = useSharedState(context, "pdaSelection", pdaTypes[Object.keys(pdaTypes)[0]]);

  const [
    selectedTrim,
  ] = useSharedState(context, "trimSelection", cardTrims[Object.keys(cardTrims)[0]]);



  return (
    <Window
      width={500}
      height={620}>
      <Window.Content scrollable>
        <Section
          title="PDA Painter"
          buttons={
            <Button.Confirm
              disabled={!hasPDA}
              content="Paint PDA"
              confirmContent="Confirm?"
              onClick={() => act("trim_pda", {
                selection: selectedPDA,
              })} />
          }>
          <Stack vertical>
            <Stack.Item height="100%">
              <EjectButton
                name={pdaName || "-----"}
                onClickEject={() => act("eject_pda")} />
            </Stack.Item>
            <Stack.Item height="100%">
              <PainterDropdown
                stateKey="pdaSelection"
                options={pdaTypes} />
            </Stack.Item>
          </Stack>
        </Section>
        <Section
          title="ID Trim Imprinter"
          buttons={
            <>
              <Button.Confirm
                disabled={!hasID}
                content="Imprint ID Trim"
                confirmContent="Confirm?"
                onClick={sel => act("trim_card", {
                  selection: selectedTrim,
                })} />
              <Button
                icon="question-circle"
                tooltip={"WARNING: This is destructive"
                + " and will wipe ALL access on the card."}
                tooltipPosition="left" />
            </>
          }>
          <Stack vertical>
            <Stack.Item height="100%">
              <EjectButton
                name={idName || "-----"}
                onClickEject={() => act("eject_card")} />
            </Stack.Item>
            <Stack.Item height="100%">
              <PainterDropdown
                stateKey="trimSelection"
                options={cardTrims} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

export const EjectButton = (props, context) => {
  const {
    name,
    onClickEject,
  } = props;

  return (
    <Button
      fluid
      ellipsis
      icon="eject"
      content={name}
      onClick={() => onClickEject()} />
  );
};

export const PainterDropdown = (props, context) => {
  const {
    stateKey,
    options,
  } = props;

  const [
    selectedOption,
    setSelectedOption,
  ] = useSharedState(context, stateKey, options[Object.keys(options)[0]]);

  return (
    <Dropdown
      width="100%"
      selected={selectedOption}
      options={
        Object.keys(options).map(path => {
          return options[path];
        })
      }
      onSelected={sel => setSelectedOption(sel)} />
  );
};
