import { useBackend } from '../backend';
import { classes } from 'common/react';
import { Fragment, Component } from 'inferno';
import { Section, Box, LabeledList, ProgressBar, Grid, Button,
  Tabs, Flex, Table, Dropdown, Collapsible, NumberInput } from '../components';
import { act } from '../byond';

import { createLogger } from '../logging';

const logger = createLogger('dna_scannertgui');

// STATE IDENTIFIERS
const STATE_BASE = 1;
const STATE_ST = 2;
const STATE_STC = 3;
const STATE_STCM = 4;
const STATE_STCC = 5;
const STATE_STD = 6;
const STATE_STDM = 7;
const STATE_GS = 8;

// STORAGE
const TGUI_MODE_ST = 1;
// SEQUENCER
const TGUI_MODE_SEQ = 2;
// ENZYMES
const TGUI_MODE_ENZ = 3;
// ADVANCED INJECTORS
const TGUI_MODE_ADV = 4;

// STORAGE STATES
// STORAGE > CONSOLE
const TGUI_ST_CO = 1;
// STORAGE > DISK
const TGUI_ST_DI = 2;

// STORAGE (CONSOLE/DISK) STATES
// STORAGE > MUTATIONS
const TGUI_ST_MUT = 1;
// STORAGE > CHROMOSOMES
const TGUI_ST_CHR = 2;
// STORAGE > GENETICS
const TGUI_ST_GEN = 3;

// STORAGE (MUTATIONS) STATES
// STORAGE > MUTATIONS > INFO
const TGUI_ST_M_INFO = 1;
// STORAGE > MUTATIONS > COMBINATION
const TGUI_ST_M_COMB = 2;
// STORAGE > MUTATIONS > COMMANDS
const TGUI_ST_M_COMM = 3;

// GENE SEQUENCER STATES
const TGUI_GS_INFO = 1;
const TGUI_GS_COMM = 2;

const clamp = function (num, min, max) {
  return Math.min(Math.max(num, min), max);
};

const createBrefFilteredList = function (srcObject, bref) {
  let filteredList = [];
  Object.keys(srcObject).map((value, key) => {
    if (!(srcObject[value].ByondRef === bref)) {
      filteredList.push(srcObject[value]);
    }
  });
  return filteredList;
};

// DropdownEx can take a list of objects for the options prop
//  If you give it a list of objects, property exKey can be used to specify
//   which object key is used to generate the entries in the DropdownEx
//
//  The exKey will represent the underlying object. In the onSelected event
//   handler, the value arg will be resolved back to the object itself.
//
//  For example, if you had a list of object {foo:"bar", bar:"foo"} then you
//   would specify exKey={"foo"} in order for the value of the foo key to be
//   used in the dropdown list to textually represent that object.

// DropdownEx can take an array of key:value pairs in the form of {key:"color"}
//  The DropdownEx will then apply the specific colour if any matching key is
//  the currently selected item
export class DropdownEx extends Component {
  constructor(props) {
    super(props);
    this.state = {
      defaultcolor: props.color || 'default',
      highlights: props.highlights || [],
      onSelected: props.onSelected,
      options: props.options || [],
      exKey: props.exKey,
    };

    this.state.color = this.getColor(props.selected);

    if (this.state.exKey) {
      this.state.optionsEx = this.createDropdownListFromObjectArray(
        this.state.options, this.state.exKey);
    }
    else {
      this.state.optionsEx = false;
    }
  }

  onSelected(selected) {
    let trueSelected = selected;
    this.state.options.map((value, key) => {
      if (value[this.state.exKey] === selected)
      { trueSelected = value; }
    });
    this.state.onSelected(trueSelected);
    this.setState({ color: this.getColor(selected) });
  }

  getColor(selected)
  {
    for (let pair in this.state.highlights) {
      if (
        Object.prototype.hasOwnProperty.call(
          this.state.highlights[pair],
          selected))
      { return this.state.highlights[pair][selected]; } }

    return this.state.defaultcolor;
  }

  createDropdownListFromObjectArray(srcList, keyEx) {
    let list = [];
    Object.keys(srcList).map((value, key) => {

      list.push(srcList[value][keyEx]);
    });

    return list;
  }

  render() {
    const { props } = this;

    return (
      <Dropdown
        {...props}
        color={this.state.color}
        options={this.state.optionsEx
          ? this.state.optionsEx
          : props.options}
        onSelected={e => { this.onSelected(e); }}
      />
    );
  }
}

export class MutationInfo extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  render() {
    const { props } = this;

    const {
      mutation,
      advInjectors,
      canAddChromo,
      data,
      actRef,
    } = props;

    let buffer = [];

    buffer.push(
      <Fragment>
        <LabeledList.Item label="Name">
          {mutation.Name}
        </LabeledList.Item>
        <LabeledList.Item label="Description">
          {mutation.Description}
        </LabeledList.Item>
        <LabeledList.Item label="Instability">
          {mutation.Instability}
        </LabeledList.Item>
      </Fragment>,
    );

    if (advInjectors) {
      buffer.push(
        <LabeledList.Item label="Add to Adv. Injector">
          <Dropdown
            textAlign="center"
            options={Object.keys(advInjectors)}
            disabled={(Object.keys(advInjectors).length === 0)}
            selected={
              (Object.keys(advInjectors).length === 0)
                ? "No Advanced Injectors"
                : "Select an injector"
            }
            width={"280px"}
            onSelected={value =>
              act(actRef, "add_adv_mut", {
                mutref: mutation.ByondRef, advinj: value })} />
        </LabeledList.Item>,
      );
    }

    buffer.push(
      <Chromosome
        mutation={mutation}
        data={data}
        actRef={actRef}
        disabled={!canAddChromo} />,
    );

    return (
      buffer
    );
  }
}

export class MutationCombine extends Component {
  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    const { props } = this;

    const {
      mutation,
      list,
      width,
      exKey,
      source,
      actRef,
    } = props;

    let buffer = [];

    let disabled = false;

    let selected = "";

    if (props.disabled) {
      selected = "Mutation Storage Full";
      disabled=true;
    }
    else if (!(list.length > 0)) {
      selected = "No Mutations Available";
      disabled=true;
    }
    else {
      selected = "Select Combination";
    }

    buffer.push(
      <Section
        title={props.title || "Combine Mutations"}>
        <DropdownEx
          {...props}
          key={mutation.ByondRef+"_dd"}
          options={list}
          width={width || "200px"}
          disabled={disabled}
          selected={selected}
          onSelected={e =>
            act(actRef, "combine_" + source, {
              srctype: mutation.Type,
              desttype: e.Type })} />
      </Section>,
    );

    return (
      buffer
    );
  }
}

export class MutationCommands extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  render() {
    let { props } = this;

    let {
      canInjector,
      canExport,
      mutation,
      source,
      disabled,
      actRef,
    } = props;

    let buffer = [];

    buffer.push(
      <Fragment>
        <Button
          disabled={!canInjector}
          content={"Print Activator"}
          onClick={() =>
            act(actRef, "print_injector",
              { mutref: mutation.ByondRef,
                is_activator: 1,
                source: source })} />
        <Button
          disabled={!canInjector}
          content={"Print Mutator"}
          onClick={() =>
            act(actRef, "print_injector",
              { mutref: mutation.ByondRef,
                is_activator: 0,
                source: source })} />
      </Fragment>,
    );

    let content = "";
    let action = "";

    switch (source) {
      case "console":
        content = "Export to Disk";
        action = "save_disk";
        break;
      case "disk":
        content = "Export to Console";
        action = "save_console";
        break;
    }

    buffer.push(
      <Fragment>
        <Button
          disabled={!canExport}
          content={content}
          onClick={() =>
            act(actRef, action, {
              mutref: mutation.ByondRef,
              source: source })} />
        <Button
          content={"Delete"}
          onClick={() =>
            act(
              actRef,
              "delete_" + source + "_mut",
              { mutref: mutation.ByondRef })} />
      </Fragment>,
    );

    return (
      buffer
    );
  }
}

export class MutationList extends Component {
  constructor(props) {
    super(props);

    this.state = {
      onSelected: props.onSelected,
      actRef: props.actRef,
      stateID: props.stateID,
      index: props.stateInfo.Index,
    };
  }

  onSelected(e, index) {
    act(this.state.actRef, "set_state", {
      id: this.state.stateID,
      index: index,
    });

    this.setState({ index: index });

    if (this.state.onSelected) {
      this.state.onSelected(e, index);
    }
  }

  render() {
    const { props } = this;

    const {
      mutations,
      width,
      height,
      source,
      canSave,
      canExport,
      buttons,
      canInjector,
      actRef,
      data,
      stateInfo,
    } = props;

    const {
      index,
    } = this.state;

    let buffer = [];
    let mutButtonBuffer = [];
    let mutBoxBuffer = [];

    let clampedIndex = clamp(
      index, 1, Object.keys(mutations).length);

    if (clampedIndex !== index) {
      act(actRef, "set_state", {
        id: this.state.stateID,
        index: clampedIndex,
      });
      this.setState({ index: clampedIndex });
    }

    Object.keys(mutations).map((value, key) => {
      return (
        mutButtonBuffer.push(
          <Table.Row>
            <Button
              content={mutations[value].Name}
              selected={clampedIndex === parseInt(value, 10)}
              fluid
              ellipsis
              textAlign={"center"}
              width={width || "8em"}
              onClick={e => (
                this.onSelected(e, parseInt(value, 10))
              )} />
          </Table.Row>,
        )
      );
    });

    if (Object.keys(mutations).length > 0) {
      switch (stateInfo.Mode) {
        case TGUI_ST_M_INFO:
          mutBoxBuffer.push(
            <Table.Cell>
              <Section title="Information">
                <LabeledList>
                  <MutationInfo
                    actRef={actRef}
                    mutation={mutations[clampedIndex]}
                    data={data} />
                </LabeledList>
              </Section>
            </Table.Cell>,
          );
          break;
        case TGUI_ST_M_COMB:
          mutBoxBuffer.push(
            <Table.Cell>
              <MutationCombine
                disabled={!canSave}
                source={source}
                mutation={mutations[clampedIndex]}
                exKey={"Name"}
                actRef={actRef}
                list={createBrefFilteredList(
                  mutations, mutations[clampedIndex].ByondRef)} />
            </Table.Cell>,
          );
          break;
        case TGUI_ST_M_COMM:
          mutBoxBuffer.push(
            <Table.Cell>
              <Section
                title="Commands">
                <MutationCommands
                  mutation={mutations[clampedIndex]}
                  source={source}
                  canInjector={canInjector}
                  canSave={canSave}
                  canExport={canExport}
                  actRef={actRef} />
              </Section>
            </Table.Cell>,
          );
      }
      buffer.push(
        <Table>
          <Table.Cell
            collapsing
            height={height || "132px"}
            overflowY="scroll">
            {mutButtonBuffer}
          </Table.Cell>
          <Table.Cell>
            {mutBoxBuffer}
          </Table.Cell>
        </Table>,
      );
    }

    return (
      <Section
        title="Mutations"
        textAlign="left"
        buttons={buttons}>
        {buffer}
      </Section>
    );
  }
}

export class SubjectStatus extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  buildSubjectStatus(status, data) {
    let subjectStatus = { string: "", color: "" };

    switch (status) {
      case data.CONSCIOUS:
        subjectStatus.color = "good";
        subjectStatus.string = "Conscious";
        break;
      case data.UNCONSCIOUS:
        subjectStatus.color = "average";
        subjectStatus.string = "Unconscious";
        break;
      case data.SOFT_CRIT:
        subjectStatus.color = "average";
        subjectStatus.string = "Critical";
        break;
      case data.DEAD:
        subjectStatus.color = "bad";
        subjectStatus.string = "Dead";
        break;
      default:
        subjectStatus.color = "good";
        subjectStatus.string = "";
        break;
    }

    return subjectStatus;
  }

  render() {
    const { props } = this;
    const {
      data,
    } = props;

    let buffer = [];
    let subjectStatus = {};

    if (!data.IsScannerConnected) {
      buffer.push(
        <LabeledList.Item label="Status">
          No DNA Scanner connected.
        </LabeledList.Item>,
      );
    }
    else if (data.IsViableSubject) {
      subjectStatus = this.buildSubjectStatus(status, data);

      buffer.push(
        <Fragment>
          <LabeledList.Item label="Status">
            {data.SubjectName}
            {" => "}
            <Box
              inline
              color={subjectStatus.color} >
              <b>{subjectStatus.string}</b>
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Health">
            <ProgressBar
              value={data.SubjectHealth}
              minValue={0}
              maxValue={100}
              ranges={{
                olive: [101, Infinity],
                good: [70, 101],
                average: [30, 70],
                bad: [-Infinity, 30],
              }}>
              {data.SubjectHealth}%
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Radiation">
            <ProgressBar
              value={data.SubjectRads}
              minValue={0}
              maxValue={100}
              ranges={{
                bad: [71, Infinity],
                average: [30, 71],
                good: [0, 30],
                olive: [-Infinity, 0],
              }}>
              {data.SubjectRads}%
            </ProgressBar>
          </LabeledList.Item>
        </Fragment>,
      );

    }
    else {
      buffer.push(
        <LabeledList.Item label="Status">
          No viable subject in DNA Scanner.
        </LabeledList.Item>,
      );
    }

    return (
      buffer
    );
  }
}

export class GeneticSequencer extends Component {
  constructor(props) {
    super(props);

    this.state = {
      index: props.index,
      mode: props.mode,
    };
  }

  render() {
    const { props, state } = this;

    const {
      mutations,
      actRef,
      height,
    } = props;

    const {
      index,
      mode,
    } = state;

    let parent = this;

    let geneBtnRowBuffer = [];
    let geneBtnBuffer = [];
    let geneBoxBuffer = [];
    let buffer = [];

    let clampedIndex = clamp(
      index, 1, Object.keys(mutations).length);

    if (clampedIndex !== index) {
      act(actRef, "set_state", {
        id: STATE_GS,
        index: clampedIndex,
      });
      this.setState({ index: clampedIndex });
    }

    let bufferPushed = false;
    Object.keys(mutations).map((value, key) => {
      bufferPushed = false;
      geneBtnRowBuffer.push(
        <Table.Cell>
          <Button
            selected={clampedIndex === parseInt(value, 10)}
            width={"82px"}
            height={"55px"}
            color={(mutations[value].Active)
              ? ("good")
              : ("bad")}
            onClick={function (e) {
              act(actRef, "check_discovery", { alias: mutations[value].Alias });
              act(actRef, "set_state", { id: STATE_GS, index: value });
              parent.setState({ index: value });
            }} >
            <Table mt={0.5}>
              <Table.Cell
                width={"82px"}
                height={"55px"}
                className={classes([
                  "text-middle",
                  "text-center"] )}>
                <img src={mutations[value].Image} width={"65px"} />
              </Table.Cell>
            </Table>
          </Button>
        </Table.Cell>,
      );
      if ((key % 2) !== 0) {
        geneBtnBuffer.push(
          <Table.Row>
            {geneBtnRowBuffer}
          </Table.Row>,
        );
        bufferPushed = true;
        geneBtnRowBuffer = [];
      }
    });

    if (!bufferPushed) {
      geneBtnBuffer.push(
        <Table.Row>
          {geneBtnRowBuffer}
        </Table.Row>,
      );
    }

    buffer.push(
      <Table>
        <Table.Cell
          collapsing
          height={height || "132px"}
          overflowY="scroll">
          {geneBtnBuffer}
        </Table.Cell>
        <Table.Cell>
          {false}
        </Table.Cell>
      </Table>,
    );

    return (
      buffer
    );
  }
}

export class Cooldowns extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  render() {
    const { props } = this;
    const {
      data,
      readyText,
    } = props;

    let buffer = [];

    buffer.push(
      <Grid mb={1}>
        <Grid.Column>
          <Section title="Scramble DNA">
            { data.IsScrambleReady
              ? readyText
              : Math.floor(data.ScrambleSeconds/60)
                + ":"
                + ((data.ScrambleSeconds % 60) < 10
                  ? "0" + data.ScrambleSeconds % 60
                  : data.ScrambleSeconds % 60)}
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="JOKER Alogrithm">
            { data.IsJokerReady
              ? readyText
              : Math.floor(data.JokerSeconds/60)
                + ":"
                + ((data.JokerSeconds % 60) < 10
                  ? "0" + data.JokerSeconds % 60
                  : data.JokerSeconds % 60)}
          </Section>
        </Grid.Column>
        <Grid.Column>
          <Section title="Injector Cooldown">
            { data.IsInjectorReady
              ? readyText
              : Math.floor(data.InjectorSeconds/60)
                + ":"
                + ((data.InjectorSeconds % 60) < 10
                  ? "0" + data.InjectorSeconds % 60
                  : data.InjectorSeconds % 60)}
          </Section>
        </Grid.Column>
      </Grid>,
    );

    return (
      buffer
    );
  }
}

export class Chromosome extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  render() {
    const { props } = this;
    const {
      mutation,
      data,
      actRef,
      disabled,
    } = props;

    switch (mutation.CanChromo) {
      case data.CHROMOSOME_NEVER:
        return (
          <LabeledList.Item label="Compatible Chromosomes">
            No compatible chromosomes
          </LabeledList.Item>
        );
      case data.CHROMOSOME_NONE:
        if (disabled) {
          return (
            <LabeledList.Item label="Applied Chromosome">
              None
            </LabeledList.Item>
          );
        }
        return (
          <Fragment>
            <LabeledList.Item label="Compatible Chromosomes">
              {mutation.ValidChromos}
            </LabeledList.Item>
            <LabeledList.Item label="Select Chromosome">
              <Dropdown
                textAlign="center"
                options={mutation.ValidStoredChromos}
                disabled={(mutation.ValidStoredChromos.length === 0)}
                selected={
                  (mutation.ValidStoredChromos.length === 0)
                    ? "No Suitable Chromosomes"
                    : "Select a chromosome"
                }
                width={"280px"}
                onSelected={e =>
                  act(actRef, "apply_chromo", {
                    chromo: e, mutref: mutation.ByondRef })} />
            </LabeledList.Item>
          </Fragment>
        );
      case data.CHROMOSOME_USED:
        return (
          <LabeledList.Item label="Applied Chromosome">
            {mutation.AppliedChromo}
          </LabeledList.Item>
        );
      default:
        return false;
    }

    return false;
  }
}

LabeledList.Chromosome = Chromosome;

export class GeneSequence extends Component {
  constructor(props) {
    super(props);
    this.state = {

    };
  }

  onSelected(actRef, pos, gene, alias) {
    act(actRef, "pulse_gene", {
      pos: pos,
      gene: gene,
      alias: alias });
  }

  render() {
    const { props } = this;

    const {
      data,
      mutation,
      actRef,
      highlights,
    } = props;

    let buffer = [];
    let topRowBuffer = [];
    let bottomRowBuffer = [];

    mutation.SeqList.map((v, k) => {
      if (k % 2 === 0) {
        topRowBuffer.push(
          <Table.Cell>
            <DropdownEx
              disabled={(mutation.Class !== data.MUT_NORMAL)}
              key={k+v+mutation.Alias}
              textAlign="center"
              options={
                data.IsJokerReady
                  ? ["J"].concat(data.REVERSEGENES)
                  : data.REVERSEGENES
              }
              width="20px"
              selected={v}
              over
              nochevron
              noscroll
              highlights={highlights}
              onSelected={e => (
                this.onSelected(actRef, k+1, e, mutation.Alias)
              )} />
          </Table.Cell>,
        );
      }
      else {
        bottomRowBuffer.push(
          <Table.Cell>
            <DropdownEx
              disabled={(mutation.Class !== data.MUT_NORMAL)}
              key={k+v+mutation.Alias}
              textAlign="center"
              options={
                data.IsJokerReady
                  ? data.GENES.concat(["J"])
                  : data.GENES
              }
              width="20px"
              selected={v}
              nochevron
              noscroll
              highlights={highlights}
              onSelected={e => (
                this.onSelected(actRef, k+1, e, mutation.Alias)
              )} />
          </Table.Cell>,
        );
      }
    });

    if (data.SubjectStatus === data.DEAD) {
      buffer.push(
        "GENETIC SEQUENCE CORRUPTED: SUBJECT DIAGNOSTIC REPORT - DECEASED",
      );
    }
    else if (data.IsMonkey && (mutation.Name !== "Monkified")) {
      buffer.push(
        "GENETIC SEQUENCE CORRUPTED: SUBJECT DIAGNOSTIC REPORT - MONKEY",
      );
    }
    else {
      buffer.push(
        <Table>
          <Table.Row>
            {topRowBuffer}
          </Table.Row>
          <Table.Row>
            {bottomRowBuffer}
          </Table.Row>
        </Table>,
      );
    }

    return (
      <Box m={1}>
        {buffer}
      </Box>
    );
  }
}

export class RadiationEmitter extends Component {
  constructor(props) {
    super(props);

    this.state = {

    };
  }

  render() {
    const { props } = this;

    const {
      data,
      actRef,
    } = props;

    return (
      <Fragment>
        <LabeledList.Item label="Output Level">
          <NumberInput
            value={data.RadStrength}
            step={1}
            stepPixelSize={10}
            minValue={1}
            maxValue={data.RADIATION_STRENGTH_MAX}
            animated
            onDrag={(e, value) => (
              act(actRef, "set_pulse_strength", { val: value })
            )} />
        </LabeledList.Item>
        <LabeledList.Item label=" > Mutation">
          {`(-${data.StdDevStr} to +${data.StdDevStr} = 68 %)`
          + `(-${2*(data.StdDevStr)} to +${2*(data.StdDevStr)} = 95 %)`}
        </LabeledList.Item>
        <LabeledList.Item label="Pulse Duration">
          <NumberInput
            value={data.RadDuration}
            step={1}
            stepPixelSize={10}
            minValue={1}
            maxValue={data.RADIATION_DURATION_MAX}
            animated
            onDrag={(e, value) => (
              act(actRef, "set_pulse_duration", { val: value })
            )} />
        </LabeledList.Item>
        <LabeledList.Item label=" > Accuracy">
          {data.StdDevAcc}
        </LabeledList.Item>
      </Fragment>
    );
  }
}

export class AdvancedInjector extends Component {
  constructor(props) {
    super(props);

    this.state = {

    };
  }

  render() {
    const { props } = this;

    const {
      injector,
      name,
      actRef,
      data,
    } = props;

    let buffer = [];

    Object.keys(injector).map((value, key) => (
      buffer.push(
        <Tabs vertical>
          <Tabs.Tab
            key={`raim_${value}_${key}_${name}`}
            label={injector[value].Name}>
            {() => (
              <Fragment>
                <MutationInfo
                  mutation={injector[value]}
                  data={data} />
                <Button
                  content={"Delete"}
                  onClick={e => (
                    act(
                      actRef,
                      "del_adv_mut",
                      { advinj: name, mutref: injector[value].ByondRef },
                    )
                  )} />
              </Fragment>
            )}
          </Tabs.Tab>
        </Tabs>,
      )
    ));

    return (
      buffer
    );
  }
}

export class DnaConsole extends Component {
  constructor(props) {
    super(props);

    let masterState = props.state.data.State;

    this.state = {
      consStorage: {
        chromIndex: masterState.Storage.Console.Chromo.Index,
      },
      masterState: masterState,
    };
  }

  //
  renderScanner(data) {
    return (
      <LabeledList>
        { data.IsScannerConnected
          ? data.ScannerOpen ? (
            <LabeledList.Item label="Scanner Door">
              Open
            </LabeledList.Item>
          ) : (
            <Fragment>
              <LabeledList.Item label="Scanner Door">
                Closed
              </LabeledList.Item>
              <LabeledList.Item label="Scanner Lock">
                {data.ScannerLocked ? "Engaged" : "Released"}
              </LabeledList.Item>
            </Fragment>
          ) : (
            <LabeledList.Item label="Scanner Door">
              Error: No scanner connected.
            </LabeledList.Item>
          )}
      </LabeledList>
    );
  }

  //
  buildScannerButtons(ref, data) {
    let buffer = [];

    // If scanner is not connected, only display the connect button.
    if (!data.IsScannerConnected) {
      buffer.push(
        <Button
          content={"Connect Scanner"}
          onClick={() =>
            act(ref, "connect_scanner")} />,
      );
    }
    // Else display the rest of the buttons
    else {
      // Only display the Cancel Delayed Action button if there's one to cancel.
      if (data.HasDelayedAction) {
        buffer.push(
          <Button
            content={"Cancel Delayed Action"}
            onClick={() =>
              act(ref, "cancel_delay")} />,
        );
      }
      // Only display the Scramble DNA button if there's a viable occupant.
      if (data.IsViableSubject) {
        buffer.push(
          <Button
            disabled={
              !data.IsScrambleReady
              || data.IsPulsingRads
            }
            content={"Scramble DNA"}
            onClick={() =>
              act(ref, "scramble_dna")} />,
        );
      }
      // Display the open and lock scanner buttons
      buffer.push(
        <Fragment>
          <Button
            disabled={data.ScannerOpen}
            content={
              data.ScannerLocked
                ? ("Unlock Scanner")
                : ("Lock Scanner")
            }
            onClick={() =>
              act(ref, "toggle_lock")} />
          <Button
            disabled={data.ScannerLocked}
            content={
              data.ScannerOpen
                ? ("Close Scanner")
                : ("Open Scanner")
            }
            onClick={() =>
              act(ref, "toggle_door")} />
        </Fragment>,
      );
    }

    return (
      buffer
    );
  }

  //
  buildConsoleCommands(ref, data) {
    let buffer = [];
    let modeBuffer = [];
    let parent = this;

    modeBuffer.push(
      <Button
        content={"Storage"}
        selected={this.state.masterState.Mode === TGUI_MODE_ST}
        onClick={function () {
          let newState = { ...parent.state.masterState };
          newState.Mode = TGUI_MODE_ST;

          parent.setState({
            masterState: newState,
          });

          act(ref, "set_state", {
            id: STATE_BASE,
            mode: TGUI_MODE_ST,
          });
        }} />,
    );

    if (data.IsViableSubject) {
      modeBuffer.push(
        <Button
          content={"Sequencer"}
          selected={this.state.masterState.Mode === TGUI_MODE_SEQ}
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Mode = TGUI_MODE_SEQ;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", { id: STATE_STCM, mode: TGUI_MODE_SEQ });
            act(ref, "all_check_discovery");
          }} />,
      );
    }

    modeBuffer.push(
      <Fragment>
        <Button
          content={"Enzymes"}
          selected={this.state.masterState.Mode === TGUI_MODE_ENZ}
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Mode = TGUI_MODE_ENZ;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_BASE,
              mode: TGUI_MODE_ENZ,
            });
          }} />
        <Button
          content={"Advanced Injectors"}
          selected={this.state.masterState.Mode === TGUI_MODE_ADV}
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Mode = TGUI_MODE_ADV;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_BASE,
              mode: TGUI_MODE_ADV,
            });
          }} />
      </Fragment>,
    );

    buffer.push(
      <LabeledList.Item label="Mode">
        {modeBuffer}
      </LabeledList.Item>,
    );

    if (data.HasDisk) {
      buffer.push(
        <LabeledList.Item label="Disk">
          <Button
            disabled={!data.HasDisk}
            content={"Eject Disk"}
            onClick={function () {
              let newState = { ...parent.state.masterState };
              newState.Storage.Mode = TGUI_ST_CO;

              parent.setState({
                masterState: newState,
              });

              act(ref, "set_state", { id: STATE_ST, mode: TGUI_ST_CO });
              act(ref, "eject_disk");
            }} />
        </LabeledList.Item>,
      );
    }

    return (
      buffer
    );
  }

  //
  renderMode(ref, data, mutations) {
    let buffer = [];

    switch (this.state.masterState.Mode) {
      case TGUI_MODE_ST:
        return this.renderStorage(ref, data);
      case TGUI_MODE_SEQ:
        buffer.push(
          <Section
            title="Genetic Sequencer">
            <GeneticSequencer
              mutations={data.SubjectMutations}
              actRef={ref}
              index={this.state.masterState.Sequencer.Index}
              mode={this.state.masterState.Sequencer.Mode}
              height={null} />
          </Section>,
        );
        break;
      case TGUI_MODE_ENZ:
        buffer.push(
          <Section
            title="Enzymes">
            {this.renderUniqueIdentifiers(ref, data)}
          </Section>,
        );
        break;
      case TGUI_MODE_ADV:
        buffer.push(
          <Section
            title="Advanced Injectors">
            {this.renderAdvInjectors(ref, data)}
          </Section>,
        );
        break;
      default:
        return false;
    }

    return (
      buffer
    );
  }

  // COMPLETE
  renderGeneticSequencer(ref, data, mut, key) {
    const renderGeneticInfo = function () {
      const buildButtons = function () {
        let buffer = [];

        if (mut.Active) {
          buffer.push(
            <Fragment>
              <Button
                disabled={!data.IsInjectorReady}
                content={"Print Activator"}
                onClick={() =>
                  act(ref, "print_injector",
                    { mutref: mut.ByondRef,
                      is_activator: 1,
                      source: "sequencer" })} />
              <Button
                disabled={!data.IsInjectorReady}
                content={"Print Mutator"}
                onClick={() =>
                  act(ref, "print_injector",
                    { mutref: mut.ByondRef,
                      is_activator: 0,
                      source: "sequencer" })} />
              <Button
                disabled={!(data.MutationCapacity > 0)}
                content={"Save to Console"}
                onClick={() =>
                  act(ref, "save_console",
                    { mutref: mut.ByondRef,
                      source: "sequencer" })} />
              <Button
                disabled={!data.HasDisk
                || !(data.DiskCapacity > 0)
                || data.DiskReadOnly}
                content={"Save to Disk"}
                onClick={() =>
                  act(ref, "save_disk", {
                    mutref: mut.ByondRef,
                    source: "sequencer" })} />
            </Fragment>,
          );
        }
        if ((mut.Class === data.MUT_EXTRA) || mut.Scrambled) {
          buffer.push(
            <Button
              content={"Nullify"}
              onClick={() =>
                act(
                  ref,
                  "nullify",
                  {
                    mutref: mut.ByondRef })} />,
          );
        }

        return (
          <Box m={1} inline>
            {buffer}
          </Box>
        );
      };

      return (
        mut.Discovered
          ? (
            <Fragment>
              <LabeledList>
                <MutationInfo
                  actRef={ref}
                  mutation={mut}
                  data={data}
                  advInjectors={data.AdvInjectors}
                  canAddChromo />
              </LabeledList>
              {buildButtons()}
            </Fragment>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Name">
                {mut.Alias}
              </LabeledList.Item>
            </LabeledList>)
      );
    };

    return (
      <Tabs.Tab
        color={(mut.Active)
          ? ("good")
          : ("bad")}
        key={`rgs_${key}_${mut.Alias}`}
        label=<img src={mut.Image}
          width={"65"} />
        onClick={e =>
          act(ref,
            "check_discovery",
            { alias: mut.Alias })}>
        {() => (
          <Fragment>
            <Section
              title={mut.Discovered
                ? `Genetic Information (${mut.Name})`
                : `Genetic Information (${mut.Alias})`}
              textAlign="left">
              {renderGeneticInfo()}
            </Section>
            <Section title="Genetic Sequence">
              <GeneSequence
                data={data}
                mutation={mut}
                actRef={ref}
                highlights={[
                  { "X": "red" },
                  { "A": "green" },
                  { "T": "green" },
                  { "G": "blue" },
                  { "C": "blue" },
                ]} />
            </Section>
          </Fragment>
        )}
      </Tabs.Tab>
    );
  }

  renderChromInfo(ref, data, chrom) {
    return (
      <Section
        title="Information">
        <LabeledList>
          <LabeledList.Item label="Name">
            {chrom.Name}
          </LabeledList.Item>
          <LabeledList.Item label="Description">
            {chrom.Description}
          </LabeledList.Item>
          <LabeledList.Item label="Eject">
            <Button
              mt={1}
              content={"Eject Chromosome"}
              onClick={() =>
                act(ref, "eject_chromo",
                  { chromo: chrom.Name })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    );
  }

  renderDiskMutModeButtons(ref, data) {
    let buffer = [];
    let parent = this;

    buffer.push(
      <Fragment>
        <Button
          content={"Information"}
          selected={
            this.state.masterState.Storage.Disk.Mutation.Mode
            === TGUI_ST_M_INFO
          }
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Disk.Mutation.Mode = TGUI_ST_M_INFO;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_STDM,
              mode: TGUI_ST_M_INFO,
            });
          }} />
        <Button
          content={"Combination"}
          selected={
            this.state.masterState.Storage.Disk.Mutation.Mode
            === TGUI_ST_M_COMB
          }
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Disk.Mutation.Mode = TGUI_ST_M_COMB;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_STDM,
              mode: TGUI_ST_M_COMB,
            });
          }} />
        <Button
          content={"Commands"}
          selected={
            this.state.masterState.Storage.Disk.Mutation.Mode
            === TGUI_ST_M_COMM
          }
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Disk.Mutation.Mode = TGUI_ST_M_COMM;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_STDM,
              mode: TGUI_ST_M_COMM,
            });
          }} />
      </Fragment>,
    );

    return (
      buffer
    );
  }

  renderConsMutModeButtons(ref, data) {
    let buffer = [];
    let parent = this;

    buffer.push(
      <Fragment>
        <Button
          content={"Information"}
          selected={
            this.state.masterState.Storage.Console.Mutation.Mode
            === TGUI_ST_M_INFO
          }
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Console.Mutation.Mode = TGUI_ST_M_INFO;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_STCM,
              mode: TGUI_ST_M_INFO,
            });
          }} />
        <Button
          content={"Combination"}
          selected={
            this.state.masterState.Storage.Console.Mutation.Mode
            === TGUI_ST_M_COMB
          }
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Console.Mutation.Mode = TGUI_ST_M_COMB;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_STCM,
              mode: TGUI_ST_M_COMB,
            });
          }} />
        <Button
          content={"Commands"}
          selected={
            this.state.masterState.Storage.Console.Mutation.Mode
            === TGUI_ST_M_COMM
          }
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Console.Mutation.Mode = TGUI_ST_M_COMM;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_STCM,
              mode: TGUI_ST_M_COMM,
            });
          }} />
      </Fragment>,
    );

    return (
      buffer
    );
  }

  renderChromoStorage(ref, data) {
    let buffer = [];
    let chromButtonBuffer = [];
    let chromBoxBuffer = [];

    let clampedIndex = clamp(
      this.state.consStorage.chromIndex,
      1,
      Object.keys(data.ChromoStorage).length);

    if (clampedIndex !== this.state.consStorage.chromIndex) {
      this.setState(
        prevState => (
          { consStorage: {
            ...prevState.consStorage, chromIndex: clampedIndex,
          } }
        ),
      );
    }


    const btnOnClick = (ref, parent, index) => {
      parent.setState({
        consStorage: {
          ...parent.state.consStorage,
          chromIndex: index,
        },
      });
    };

    Object.keys(data.ChromoStorage).map((value, key) => {
      return (
        chromButtonBuffer.push(
          <Table.Row>
            <Button
              content={data.ChromoStorage[value].Name.split(" ")[0]}
              selected={clampedIndex === parseInt(value, 10)}
              fluid
              textAlign={"center"}
              onClick={() => (
                btnOnClick(ref, this, parseInt(value, 10))
              )} />
          </Table.Row>,
        )
      );
    });

    if (Object.keys(data.ChromoStorage).length > 0) {
      chromBoxBuffer.push(
        <Table>
          <Table.Cell
            collapsing
            height="132px"
            overflowY="scroll">
            {chromButtonBuffer}
          </Table.Cell>
          <Table.Cell>
            {this.renderChromInfo(
              ref,
              data,
              data.ChromoStorage[clampedIndex])}
          </Table.Cell>
        </Table>,
      );
    }

    return (
      <Section
        title="Chromosomes"
        textAlign="left">
        {chromBoxBuffer}
      </Section>
    );
  }

  renderDiskGenMakeup(ref, data) {
    return (
      <Section
        title="Genetic Makeup Storage"
        textAlign="left"
        buttons={
          <Button
            disabled={data.DiskReadOnly
              || !(data.DiskMakeupBuffer.name
                || data.DiskMakeupBuffer.blood_type
                || data.DiskMakeupBuffer.UE
                || data.DiskMakeupBuffer.UI)}
            content={"Delete"}
            onClick={(e, value) => (
              act(ref, "del_makeup_disk")
            )} />
        }>
        <LabeledList>
          <LabeledList.Item label="Subject">
            {data.DiskMakeupBuffer.name
              ? data.DiskMakeupBuffer.name
              : "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Blood Type">
            {data.DiskMakeupBuffer.blood_type
              ? data.DiskMakeupBuffer.blood_type
              : "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Unique Enzyme">
            {data.DiskMakeupBuffer.UE
              ? data.DiskMakeupBuffer.UE
              : "None"}
          </LabeledList.Item>
          <LabeledList.Item label="Unique Identifier">
            {data.DiskMakeupBuffer.UI
              ? data.DiskMakeupBuffer.UI
              : "None"}
          </LabeledList.Item>
          {(data.DiskMakeupBuffer.UI
            && data.DiskMakeupBuffer.UE)
            ? (
              <LabeledList.Item label="UE/UI Combination">
                {data.DiskMakeupBuffer.UI
                  + "/"
                  + data.DiskMakeupBuffer.UE}
              </LabeledList.Item>
            ) : false }
        </LabeledList>
      </Section>
    );
  }

  renderDiskStorage(ref, data) {
    let buffer = [];

    switch (this.state.masterState.Storage.Disk.Mode) {
      case TGUI_ST_MUT:
        buffer.push(
          <MutationList
            canSave={(data.HasDisk
              && (data.DiskCapacity > 0)
              && !data.DiskReadOnly)}
            canExport={(data.MutationCapacity > 0)}
            source={"disk"}
            mutations={data.DiskMutations}
            buttons={this.renderDiskMutModeButtons(ref, data)}
            canInjector={data.IsInjectorReady}
            actRef={ref}
            data={data}
            stateInfo={this.state.masterState.Storage.Disk.Mutation}
            stateID={STATE_STDM} />,
        );
        break;
      case TGUI_ST_GEN:
        buffer.push(
          this.renderDiskGenMakeup(ref, data),
        );
        break;
    }

    return (
      buffer
    );
  }

  renderConsoleStorage(ref, data) {
    let buffer = [];

    switch (this.state.masterState.Storage.Console.Mode) {
      case TGUI_ST_MUT:
        buffer.push(
          <MutationList
            canSave={(data.MutationCapacity > 0)}
            canExport={(data.HasDisk
              && (data.DiskCapacity > 0)
              && !data.DiskReadOnly)}
            source={"console"}
            mutations={data.MutationStorage}
            buttons={this.renderConsMutModeButtons(ref, data)}
            canInjector={data.IsInjectorReady}
            actRef={ref}
            data={data}
            stateInfo={this.state.masterState.Storage.Console.Mutation}
            stateID={STATE_STCM} />,
        );
        break;
      case TGUI_ST_CHR:
        buffer.push(
          this.renderChromoStorage(ref, data),
        );
        break;
    }

    return (
      buffer
    );
  }

  // COMPLETE
  renderStorage(ref, data) {
    let buffer = [];
    let parent = this;

    const buildConsoleStorageButtons = function () {
      return (
        <Fragment>
          <Button
            content={"Mutations"}
            selected={
              parent.state.masterState.Storage.Console.Mode
              === TGUI_ST_MUT
            }
            onClick={function () {
              let newState = { ...parent.state.masterState };
              newState.Storage.Console.Mode = TGUI_ST_MUT;

              parent.setState({
                masterState: newState,
              });

              act(ref, "set_state", {
                id: STATE_STC,
                mode: TGUI_ST_MUT,
              });
            }} />
          <Button
            content={"Chromosomes"}
            selected={
              parent.state.masterState.Storage.Console.Mode
              === TGUI_ST_CHR
            }
            onClick={function () {
              let newState = { ...parent.state.masterState };
              newState.Storage.Console.Mode = TGUI_ST_CHR;

              parent.setState({
                masterState: newState,
              });

              act(ref, "set_state", {
                id: STATE_STC,
                mode: TGUI_ST_CHR,
              });
            }} />
        </Fragment>
      );
    };

    const buildDiskStorageButtons = function () {
      return (
        <Fragment>
          <Button
            content={"Mutations"}
            selected={
              parent.state.masterState.Storage.Disk.Mode
              === TGUI_ST_MUT
            }
            onClick={function () {
              let newState = { ...parent.state.masterState };
              newState.Storage.Disk.Mode = TGUI_ST_MUT;

              parent.setState({
                masterState: newState,
              });

              act(ref, "set_state", {
                id: STATE_STD,
                mode: TGUI_ST_MUT,
              });
            }} />
          <Button
            content={"Genetic Data"}
            selected={
              parent.state.masterState.Storage.Disk.Mode
              === TGUI_ST_GEN
            }
            onClick={function () {
              let newState = { ...parent.state.masterState };
              newState.Storage.Disk.Mode = TGUI_ST_GEN;

              parent.setState({
                masterState: newState,
              });

              act(ref, "set_state", {
                id: STATE_STD,
                mode: TGUI_ST_GEN,
              });
            }} />
        </Fragment>
      );
    };

    const buildStorageButtons = function () {
      let btnBuffer = [];

      btnBuffer.push(
        <Button
          content={"Console"}
          selected={parent.state.masterState.Storage.Mode === TGUI_ST_CO}
          onClick={function () {
            let newState = { ...parent.state.masterState };
            newState.Storage.Mode = TGUI_ST_CO;

            parent.setState({
              masterState: newState,
            });

            act(ref, "set_state", {
              id: STATE_ST,
              mode: TGUI_ST_CO,
            });
          }} />,
      );

      if (data.HasDisk) {
        btnBuffer.push(
          <Button
            content={"Disk"}
            selected={parent.state.masterState.Storage.Mode === TGUI_ST_DI}
            onClick={function () {
              let newState = { ...parent.state.masterState };
              newState.Storage.Mode = TGUI_ST_DI;

              parent.setState({
                masterState: newState,
              });

              act(ref, "set_state", {
                id: STATE_ST,
                mode: TGUI_ST_DI,
              });
            }} />,
        );
      }

      return (
        btnBuffer
      );
    };

    const buildContent = function () {
      switch (parent.state.masterState.Storage.Mode) {
        case TGUI_ST_CO:
          return (
            <Section
              title="Console"
              buttons={buildConsoleStorageButtons()}>
              {parent.renderConsoleStorage(ref, data)}
            </Section>
          );
        case TGUI_ST_DI:
          return (
            <Section
              title="Disk"
              buttons={buildDiskStorageButtons()}>
              {parent.renderDiskStorage(ref, data)}
            </Section>
          );
        default:
          return false;
      }
    };

    return (
      <Section
        title="Storage"
        buttons={buildStorageButtons()}>
        {buildContent()}
      </Section>
    );
  }

  // COMPLETE
  renderUniqueIdentifiers(ref, data) {
    let buffer = [];

    const renderMakeupBuffers = function () {
      let buffer = [];
      let currentMakeup;

      const buildMakeupButtons = function (index) {
        return (
          <Collapsible
            title="Commands">
            <Box m={1}>
              {data.IsViableSubject
                ? (
                  <Fragment>
                    <Button
                      content={"Transfer Enzyme"}
                      onClick={e => (
                        act(
                          ref, "makeup_apply", { index: index, type: "ue" })
                      )} />
                    <Button
                      content={"Transfer Identity"}
                      onClick={e => (
                        act(
                          ref, "makeup_apply", { index: index, type: "ui" })
                      )} />
                    <Button
                      content={"Transfer Full Makeup"}
                      onClick={e => (
                        act(
                          ref, "makeup_apply", { index: index, type: "mixed" })
                      )} />
                  </Fragment>
                ) : (
                  <Fragment>
                    <Button
                      content={"Transfer Enzyme (Delayed)"}
                      onClick={e => (
                        act(
                          ref, "makeup_delay", { index: index, type: "ue" })
                      )} />
                    <Button
                      content={"Transfer Identity (Delayed)"}
                      onClick={e => (
                        act(
                          ref, "makeup_delay", { index: index, type: "ui" })
                      )} />
                    <Button
                      content={"Transfer Full Makeup (Delayed)"}
                      onClick={e => (
                        act(
                          ref, "makeup_delay", { index: index, type: "mixed" })
                      )} />
                  </Fragment>
                )}
            </Box>
            <Box m={1}>
              <Button
                content={"Print Enzyme Injector"}
                onClick={e => (
                  act(
                    ref, "makeup_injector", { index: index, type: "ue" })
                )} />
              <Button
                content={"Print Identity Injector"}
                onClick={e => (
                  act(
                    ref, "makeup_injector", { index: index, type: "ui" })
                )} />
              <Button
                content={"Print Full Makeup Injector"}
                onClick={e => (
                  act(
                    ref, "makeup_injector", { index: index, type: "mixed" })
                )} />
            </Box>
          </Collapsible>
        );
      };

      for (let i = 1; i <= data.MakeupCapcity; ++i) {
        currentMakeup = data.MakeupStorage[i.toString()];
        buffer.push(
          currentMakeup
            ? (
              <Collapsible
                title={
                  currentMakeup.label
                    ? currentMakeup.label
                    : currentMakeup.name
                }
                buttons={
                  <Fragment>
                    <Button
                      disabled={!(data.IsViableSubject)}
                      content={"Save To Slot"}
                      onClick={(e, value) => (
                        act(ref, "save_makeup_console", { index: i })
                      )} />
                    <Button
                      content={"Clear Slot"}
                      onClick={(e, value) => (
                        act(ref, "del_makeup_console", { index: i })
                      )} />
                    <Button
                      disabled={!(data.HasDisk) || !(data.DiskHasMakeup)}
                      content={"Import From Disk"}
                      onClick={(e, value) => (
                        act(ref, "load_makeup_disk", { index: i })
                      )} />
                    <Button
                      disabled={!(data.HasDisk)
                      || (data.DiskReadOnly)}
                      content={"Export To Disk"}
                      onClick={(e, value) => (
                        act(ref, "save_makeup_disk", { index: i })
                      )} />
                  </Fragment>
                } >
                <LabeledList>
                  <LabeledList.Item label="Subject">
                    {currentMakeup.name
                      ? currentMakeup.name
                      : "None"}
                  </LabeledList.Item>
                  <LabeledList.Item label="Blood Type">
                    {currentMakeup.blood_type
                      ? currentMakeup.blood_type
                      : "None"}
                  </LabeledList.Item>
                  <LabeledList.Item label="Unique Enzyme">
                    {currentMakeup.UE
                      ? currentMakeup.UE
                      : "None"}
                  </LabeledList.Item>
                  <LabeledList.Item label="Unique Identifier">
                    {currentMakeup.UI
                      ? currentMakeup.UI
                      : "None"}
                  </LabeledList.Item>
                </LabeledList>
                {buildMakeupButtons(i)}
              </Collapsible>)
            : (
              <Collapsible
                title={"Slot " + i}
                buttons={(
                  <Fragment>
                    <Button
                      content={"Save To Slot"}
                      onClick={(e, value) => (
                        act(ref, "save_makeup_console", { index: i })
                      )} />
                    <Button
                      disabled={!(data.HasDisk) || !(data.DiskHasMakeup)}
                      content={"Import From Disk"}
                      onClick={(e, value) => (
                        act(ref, "load_makeup_disk", { index: i })
                      )} />
                  </Fragment>
                )}>
                No stored subject data.
              </Collapsible>
            ),
        );
      }

      return (
        buffer
      );
    };

    const buildPulseButtons = function () {
      let btnBuffer = [];
      let current_block = 0;
      let uni_list = data.SubjectUNIList;

      for (let i = 0; i < uni_list.length; ++i) {
        if ((i % data.DNA_BLOCK_SIZE) === 0) {
          btnBuffer.push(
            <Button
              content={++current_block}
              disabled />,
          );
        }

        btnBuffer.push(
          <Button
            content={uni_list[i]}
            onClick={e => (
              act(ref, "makeup_pulse", { index: i+1 })
            )} />,
        );
      }
      return (
        btnBuffer
      );
    };

    if (!data.IsScannerConnected) {
      buffer.push(
        <Section
          title="Radiation Emitter Status"
          textAlign="left">
          No connected DNA Scanner available.
        </Section>,
      );
    }
    else {
      buffer.push(
        <Section
          title="Radiation Emitter Status"
          textAlign="left">
          <LabeledList>
            <RadiationEmitter
              data={data}
              actRef={ref} />
          </LabeledList>
        </Section>,
      );
      if (data.IsViableSubject) {
        buffer.push(
          <Section
            title="Unique Identifiers"
            textAlign="left">
            {buildPulseButtons()}
          </Section>,
        );
      }
    }

    return (
      <Fragment>
        {buffer}
        <Section
          title="Genetic Makeup Buffers"
          textAlign="left">
          {renderMakeupBuffers()}
        </Section>
      </Fragment>
    );
  }

  // COMPLETE
  renderAdvInjectors(ref, data) {
    let buffer = [];

    if (data.AdvInjectors) {
      if (Object.keys(data.AdvInjectors).length < data.MaxAdvInjectors) {
        buffer.push(
          <Button.Input
            m={1}
            content={"Create New Injector"}
            onCommit={(e, v) => (
              act(ref, "new_adv_inj", { name: v })
            )} />,
        );
      }

      Object.keys(data.AdvInjectors).map((value, key) => {
        return (
          buffer.push(
            <Collapsible
              title={value}
              buttons={(
                <Fragment>
                  <Button
                    content={"Delete"}
                    onClick={() => (
                      act(ref, "del_adv_inj", { name: value })
                    )} />
                  <Button
                    content={"Print"}
                    onClick={() => (
                      act(ref, "print_adv_inj", { name: value })
                    )} />
                </Fragment>
              )} >
              <Section
                title="Mutations"
                textAlign="left">
                <AdvancedInjector
                  data={data}
                  name={value}
                  actRef={ref}
                  injector={data.AdvInjectors[value]} />
              </Section>
            </Collapsible>,
          )
        );
      });
    }

    return (
      <Section
        title="Advanced Injectors"
        textAlign="left">
        {buffer}
      </Section>
    );
  }

  render() {
    const { state } = this.props;
    const { config, data } = state;
    const { ref } = config;

    const mutations = data.SubjectMutations || {};

    let canSaveMutToDisk = !data.HasDisk
      || !(data.DiskCapacity > 0)
      || data.DiskReadOnly;

    let canSaveMutToCons = !(data.MutationCapacity > 0);

    return (
      <Fragment>
        <Section
          title="DNA Scanner"
          textAlign="left"
          buttons={this.buildScannerButtons(ref, data)}>
          <SubjectStatus
            data={data} />
        </Section>
        <Cooldowns
          data={data}
          readyText={"Ready"} />
        <Section
          title="DNA Console"
          textAlign="left">
          <LabeledList>
            {this.buildConsoleCommands(ref, data)}
          </LabeledList>
        </Section>
        {data.IsPulsingRads
          ? (
            <Table>
              <Table.Row>
                {"Radiation pulse underway..."}
              </Table.Row>
              <Table.Row>
                {"Process complete in "
                + Math.floor(data.RadPulseSeconds/60)
                  + ":"
                  + ((data.RadPulseSeconds % 60) < 10
                    ? "0" + data.RadPulseSeconds % 60
                    : data.RadPulseSeconds % 60)}
              </Table.Row>
            </Table>
          ) : (
            data.HasDelayedAction
              ? (false)
              : (this.renderMode(ref, data, mutations))
          )}
      </Fragment>
    );
  }
}
