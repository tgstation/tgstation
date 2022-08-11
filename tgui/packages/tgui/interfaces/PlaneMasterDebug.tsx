import { useBackend, useLocalState } from '../backend';
import { InfinitePlane, Stack, Box, Button, Modal, Dropdown, Section, LabeledList, Tooltip, Slider } from '../components';
import { sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { classes, shallowDiffers } from 'common/react';
import { Component, createRef, RefObject } from 'inferno';
import { Window } from '../layouts';
import { resolveAsset } from '../assets';
import { MOUSE_BUTTON_LEFT, noop } from './IntegratedCircuit/constants';
import { Connections } from './IntegratedCircuit/Connections';

enum ConnectionType {
  Relay,
  Filter,
}

enum ConnectionDirection {
  Incoming,
  Outgoing,
}

type ConnectionRef = {
  ref: string;
  sort_by: number;
};

type Plane = {
  name: string;
  documentation: string;
  plane: number;
  our_ref: string;
  offset: number;
  real_plane: number;
  renders_onto: number[];
  blend_mode: number;
  color: string | number[];
  alpha: number;
  render_target: string;
  incoming_relays: string[];
  outgoing_relays: string[];
  incoming_filters: string[];
  outgoing_filters: string[];
  intended_hidden: boolean;

  incoming_connections: ConnectionRef[];
  outgoing_connections: ConnectionRef[];

  x: number;
  y: number;
  step_size: number;
  size_x: number;
  size_y: number;
};

type Relay = {
  name: string;
  layer: number;
};

type Filter = {
  type: string;
  name: string;
  render_source: string;
};

// Type of something that spawn a connection
type Connected = {
  connect_color: string;
  source: number;
  source_ref: string;
  target: number;
  target_ref: string;
  our_ref: string;

  source_index: number;
  target_index: number;

  connect_type: ConnectionType;
};

interface AssocPlane {
  [index: string]: Plane;
}

interface AssocRelays {
  [index: string]: Relay & Connected;
}

interface AssocFilters {
  [index: string]: Filter & Connected;
}

interface AssocConnected {
  [index: string]: Connected;
}

interface AssocString {
  [index: string]: string;
}

type Position = {
  x: number;
  y: number;
};

type Connection = {
  color: string;
  from: Position;
  to: Position;
  ref: string;
};

type PlaneDebugData = {
  our_group: string;
  present_groups: string[];
  enable_group_view: boolean;
  relay_info: AssocRelays;
  plane_info: AssocPlane;
  filter_connect: AssocFilters;
  depth_stack: AssocString[];
  mob_name: string;
  mob_ref: string;
  our_ref: string;
  tracking_active: boolean;
};

// Stolen wholesale from fontcode
const textWidth = (text, font, fontsize) => {
  // default font height is 12 in tgui
  font = fontsize + 'x ' + font;
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d') as any;
  ctx.font = font;
  const width = ctx.measureText(text).width;
  return width;
};

const planeToPosition = function (plane: Plane, index, is_incoming): Position {
  return {
    x: is_incoming ? plane.x : plane.x + plane.size_x,
    y:
      29 +
      plane.y +
      plane.step_size * index +
      (plane.step_size - plane.step_size / 3),
  };
};

// Takes a plane, returns the amount of node space it will need
const getPlaneNodeHeight = function (plane: Plane): number {
  return Math.max(
    plane.incoming_relays.length + plane.incoming_filters.length,
    plane.outgoing_relays.length + plane.outgoing_filters.length
  );
};

const sortConnectionRefs = function (
  refs: ConnectionRef[],
  direction: ConnectionDirection,
  connectSources: AssocConnected
) {
  refs = sortBy((connection: ConnectionRef) => connection.sort_by)(refs);
  refs.map((connection, index) => {
    let connectSource = connectSources[connection.ref];
    if (direction === ConnectionDirection.Outgoing) {
      connectSource.source_index = index;
    } else if (direction === ConnectionDirection.Incoming) {
      connectSource.target_index = index;
    }
  });
  return refs;
};

const addConnectionRefs = function (
  read_from: string[],
  add_type: ConnectionDirection,
  add_to: ConnectionRef[],
  reference: AssocConnected,
  plane_info: AssocPlane
) {
  for (const ref of read_from) {
    const connected = reference[ref];
    let our_plane;
    // If we're incoming, use the target ref, and vis versa
    if (add_type === ConnectionDirection.Incoming) {
      our_plane = plane_info[connected.source_ref];
    } else if (add_type === ConnectionDirection.Outgoing) {
      our_plane = plane_info[connected.target_ref];
    }
    add_to.push({
      ref: ref,
      sort_by: our_plane.plane,
    });
  }
};

// Takes a list of planes, uses the depth stack to position them
const positionPlanes = function (context, connectSources: AssocConnected) {
  const { data } = useBackend<PlaneDebugData>(context);
  const { plane_info, relay_info, filter_connect, depth_stack } = data;

  // First, we concatinate our connection sources
  // We need them in one list partly for later purposes
  // But also so we can set their source/target index nicely
  for (const ref of Object.keys(relay_info)) {
    let connection_source: Connected = relay_info[ref];
    connection_source.connect_type = ConnectionType.Relay;
    connection_source.connect_color = 'blue';
    connectSources[ref] = connection_source;
  }
  for (const ref of Object.keys(filter_connect)) {
    let connection_source: Connected = filter_connect[ref];
    connection_source.connect_type = ConnectionType.Filter;
    connection_source.connect_color = 'purple';
    connectSources[ref] = connection_source;
  }

  for (const plane_ref of Object.keys(plane_info)) {
    let our_plane = plane_info[plane_ref];
    const incoming_conct: ConnectionRef[] = [] as any;
    const outgoing_conct: ConnectionRef[] = [] as any;
    addConnectionRefs(
      our_plane.incoming_relays,
      ConnectionDirection.Incoming,
      incoming_conct,
      relay_info,
      plane_info
    );
    addConnectionRefs(
      our_plane.incoming_filters,
      ConnectionDirection.Incoming,
      incoming_conct,
      filter_connect,
      plane_info
    );
    addConnectionRefs(
      our_plane.outgoing_relays,
      ConnectionDirection.Outgoing,
      outgoing_conct,
      relay_info,
      plane_info
    );
    addConnectionRefs(
      our_plane.outgoing_filters,
      ConnectionDirection.Outgoing,
      outgoing_conct,
      filter_connect,
      plane_info
    );
    our_plane.incoming_connections = sortConnectionRefs(
      incoming_conct,
      ConnectionDirection.Incoming,
      connectSources
    );
    our_plane.outgoing_connections = sortConnectionRefs(
      outgoing_conct,
      ConnectionDirection.Outgoing,
      connectSources
    );
  }

  // First we sort by the plane of each member,
  // then we sort by the plane of each member's head
  // This way we get a nicely sorted list
  // and get rid of the now unneeded parent refs
  const stack = depth_stack.map((layer) =>
    flow([
      sortBy((plane: string) => plane_info[plane].plane),
      sortBy((plane: string) => {
        const read_from = plane_info[layer[plane]];
        if (!read_from) {
          return 0;
        }
        return read_from.plane;
      }),
    ])(Object.keys(layer))
  );

  let base_x = 0;
  let longest_name = 0;
  let tallest_stack = 0;
  for (const layer of stack) {
    base_x += longest_name;
    base_x += 150;
    let new_longest = 0;
    let last_node_len = 0;
    let base_y = 0;
    for (const plane_ref of layer) {
      const old_y = base_y;
      const plane = plane_info[plane_ref];
      // - because we want to work backwards rather then forwards
      plane.x = -base_x;
      // I am assuming the height of a plane master with two connections looks
      // like 50% name 50% (two) nodes
      base_y += 45;
      // One extra for the relay add button
      base_y += 19 * (last_node_len + 1);
      // We need to know how large node steps are for later
      plane.step_size = 19;
      plane.y = base_y;
      const width = textWidth(plane.name, '', 16) + 30;
      plane.size_x = width;
      plane.size_y = old_y - base_y;
      new_longest = Math.max(new_longest, width);
      last_node_len = getPlaneNodeHeight(plane);
    }
    longest_name = new_longest;
    tallest_stack = Math.max(tallest_stack, base_y);
  }

  // Now that we've got everything stacked, we need to center it
  for (const layer of stack) {
    const last_ref = layer[layer.length - 1];
    const last_plane = plane_info[last_ref];
    const delta_tall = tallest_stack - last_plane.y;
    // Now that we know how "off" our height is, we can correct it
    // We halve because otherwise this looks dumb
    const offset = delta_tall / 2;
    for (const plane_ref of layer) {
      const plane = plane_info[plane_ref];
      plane.y += offset;
    }
  }
};

const arrayRemove = function (arr: any, value) {
  return arr.filter((element) => element !== value);
};

export class PlaneMasterDebug extends Component {
  constructor() {
    super();
    this.handlePortClick = this.handlePortClick.bind(this);
  }

  handlePortClick(connection: Connected, isOutput, event) {
    if (event.button !== MOUSE_BUTTON_LEFT) {
      return;
    }
    const { act, data } = useBackend<PlaneDebugData>(this.context);
    const { plane_info } = data;

    event.preventDefault();
    if (connection.connect_type === ConnectionType.Relay) {
      // Close the connection
      act('disconnect_relay', {
        source: connection.source_ref,
        target: connection.target_ref,
      });
      let source_plane = plane_info[connection.source_ref];
      let target_plane = plane_info[connection.source_ref];
      source_plane.outgoing_relays = arrayRemove(
        source_plane.outgoing_relays,
        connection.our_ref
      );
      target_plane.incoming_relays = arrayRemove(
        target_plane.incoming_relays,
        connection.our_ref
      );
    } else if (connection.connect_type === ConnectionType.Filter) {
      // Close the connection
      const filter = connection as Filter & Connected;
      act('disconnect_filter', {
        target: filter.target_ref,
        name: filter.name,
      });
      let source_plane = plane_info[connection.source_ref];
      let target_plane = plane_info[connection.source_ref];
      source_plane.outgoing_filters = arrayRemove(
        source_plane.outgoing_filters,
        connection.our_ref
      );
      target_plane.incoming_filters = arrayRemove(
        target_plane.incoming_filters,
        connection.our_ref
      );
    }
  }

  render() {
    const { act, data } = useBackend<PlaneDebugData>(this.context);
    const { plane_info, mob_name } = data;
    const [showAdd, setShowAdd] = useLocalState(this.context, 'showAdd', false);

    const [connectSources, setConnectSouces] = useLocalState<AssocConnected>(
      this.context,
      'connectionSources',
      {}
    );

    positionPlanes(this.context, connectSources);

    const connections: Connection[] = [];

    for (const ref of Object.keys(connectSources)) {
      const connect = connectSources[ref];
      const source_plane = plane_info[connect.source_ref];
      const target_plane = plane_info[connect.target_ref];
      connections.push({
        color: connect.connect_color,
        from: planeToPosition(source_plane, connect.source_index, false),
        to: planeToPosition(target_plane, connect.target_index, true),
        ref: ref,
      });
    }

    return (
      <Window width={1200} height={800} title={'Plane Debugging: ' + mob_name}>
        <Window.Content
          style={{
            'background-image': 'none',
          }}>
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage={resolveAsset('grid_background.png')}
            imageWidth={900}
            initialLeft={800}
            initialTop={-740}>
            {Object.keys(plane_info).map(
              (plane_key, index) =>
                plane_key && (
                  <PlaneMaster
                    key={index}
                    {...plane_info[plane_key]}
                    our_plane={plane_info[plane_key]}
                    connected_list={connectSources}
                    onPortMouseDown={this.handlePortClick}
                    act={act}
                  />
                )
            )}
            <Connections connections={connections} />
          </InfinitePlane>
          <DrawAbovePlane />
        </Window.Content>
      </Window>
    );
  }
}

type PlaneMasterProps = {
  name: string;
  incoming_connections: ConnectionRef[];
  outgoing_connections: ConnectionRef[];
  connected_list: AssocConnected;
  our_plane: Plane;
  x: number;
  y: number;
  onPortMouseDown: Function;
  act: Function;
};

class PlaneMaster extends Component<PlaneMasterProps> {
  shouldComponentUpdate(nextProps, nextState) {
    const { incoming_connections, outgoing_connections } = this
      .props as PlaneMasterProps;

    return (
      shallowDiffers(this.props, nextProps) ||
      shallowDiffers(this.state as object, nextState) ||
      shallowDiffers(incoming_connections, nextProps.incoming_connections) ||
      shallowDiffers(outgoing_connections, nextProps.outgoing_connections)
    );
  }

  render() {
    const {
      name,
      incoming_connections,
      outgoing_connections,
      connected_list,
      our_plane,
      x,
      y,
      onPortMouseDown = noop,
      act = noop,
      ...rest
    } = this.props as PlaneMasterProps;
    const [showAdd, setShowAdd] = useLocalState(this.context, 'showAdd', false);
    const [currentPlane, setCurrentPlane] = useLocalState(
      this.context,
      'currentPlane',
      {}
    );
    const [readPlane, setReadPlane] = useLocalState(
      this.context,
      'readPlane',
      ''
    );

    // Assigned onto the ports
    const PortOptions = {
      onPortMouseDown: onPortMouseDown,
    };
    return (
      <Box position="absolute" left={`${x}px`} top={`${y}px`} {...rest}>
        <Box
          backgroundColor={our_plane.intended_hidden ? '#191919' : '#000000'}
          py={1}
          px={1}
          className="ObjectComponent__Titlebar">
          {name}
          <Button
            ml={2}
            icon="pager"
            tooltip="Inspect and edit this plane"
            onClick={() => setReadPlane(our_plane.our_ref)}
          />
        </Box>
        <Box
          className={
            our_plane.intended_hidden
              ? 'ObjectComponent__Greyed_Content'
              : 'ObjectComponent__Content'
          }
          unselectable="on"
          py={1}
          px={1}>
          <Stack>
            <Stack.Item>
              <Stack vertical fill>
                {incoming_connections.map((con_ref, portIndex) => (
                  <Stack.Item key={portIndex}>
                    <Port
                      act={act}
                      connection={connected_list[con_ref.ref]}
                      {...PortOptions}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Stack.Item>
            <Stack.Item ml={5} width="100%">
              <Stack vertical>
                {outgoing_connections.map((con_ref, portIndex) => (
                  <Stack.Item key={portIndex}>
                    <Port
                      act={act}
                      connection={connected_list[con_ref.ref]}
                      {...PortOptions}
                      isOutput
                    />
                  </Stack.Item>
                ))}
                <Stack.Item align="flex-end">
                  <Button
                    icon="plus"
                    onClick={() => {
                      setShowAdd(true);
                      setCurrentPlane(our_plane);
                    }}
                    right="-4px"
                    tooltip="Connect to another plane"
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
      </Box>
    );
  }
}

type PortProps = {
  connection: Connected;
  isOutput?: boolean;
  onPortMouseDown?: Function;
  act: Function;
};
class Port extends Component<PortProps> {
  // Ok so like, we're basically treating iconRef as a string here
  // Mostly so svg can work later. You're really not supposed to do this.
  // Should really be a RefObject<Element>
  // But it's how it was being done in circuit code, so eh
  iconRef: RefObject<SVGCircleElement> | RefObject<HTMLSpanElement> | any;

  constructor() {
    super();
    this.iconRef = createRef();
    this.handlePortMouseDown = this.handlePortMouseDown.bind(this);
  }

  handlePortMouseDown(e) {
    const {
      connection,
      isOutput,
      onPortMouseDown = noop,
    } = this.props as PortProps;
    onPortMouseDown(connection, isOutput, e);
  }

  render() {
    const { connection, isOutput, ...rest } = this.props as PortProps;

    return (
      <Stack {...rest} justify={isOutput ? 'flex-end' : 'flex-start'}>
        <Stack.Item>
          <Box
            className={classes(['ObjectComponent__Port'])}
            onMouseDown={this.handlePortMouseDown}
            textAlign="center">
            <svg
              style={{
                width: '100%',
                height: '100%',
                position: 'absolute',
              }}
              viewBox="0, 0, 100, 100">
              <circle
                stroke={connection.connect_color}
                strokeDasharray={`${100 * Math.PI}`}
                strokeDashoffset={-100 * Math.PI}
                className={`color-stroke-${connection.connect_color}`}
                strokeWidth="50px"
                cx="50"
                cy="50"
                r="50"
                fillOpacity="0"
                transform="rotate(90, 50, 50)"
              />
              <circle
                ref={this.iconRef}
                cx="50"
                cy="50"
                r="50"
                className={`color-fill-${connection.connect_color}`}
              />
            </svg>
            <span ref={this.iconRef} className="ObjectComponent__PortPos" />
          </Box>
        </Stack.Item>
      </Stack>
    );
  }
}

const DrawAbovePlane = (props, context) => {
  const [showAdd, setShowAdd] = useLocalState(context, 'showAdd', false);
  const [showInfo, setShowInfo] = useLocalState(context, 'showInfo', false);
  const [readPlane, setReadPlane] = useLocalState(context, 'readPlane', '');

  const { act, data } = useBackend<PlaneDebugData>(context);
  // Plane groups don't use relays right now, because of a byond bug
  // This exists mostly so enabling viewing them is easy and simple
  const { enable_group_view } = data;

  return (
    <>
      {!!readPlane && <PlaneWindow />}
      {!readPlane && (
        <>
          <InfoButton />
          <MobResetButton />
          <ToggleMirror />
          <VVButton />
          <RefreshButton />
        </>
      )}
      {!!enable_group_view && <GroupDropdown />}
      {!!showAdd && <AddModal />}
      {!!showInfo && <InfoModal />}
    </>
  );
};

const PlaneWindow = (props, context) => {
  const { data, act } = useBackend<PlaneDebugData>(context);
  const { plane_info } = data;
  const [readPlane, setReadPlane] = useLocalState(context, 'readPlane', '');

  const workingPlane: Plane = plane_info[readPlane];

  // NOT sanitized, since this would only be editable by admins or coders
  const doc_html = {
    __html: workingPlane.documentation,
  };
  return (
    <Section
      top="27px"
      right="0px"
      width="40%"
      height="100%"
      position="absolute"
      backgroundColor="#000000"
      title={'Plane Master: ' + workingPlane.name}
      buttons={
        <>
          <ClosePlaneWindow />
          <InfoButton no_position />
          <MobResetButton no_position />
          <ToggleMirror no_position />
          <VVButton no_position />
          <RefreshButton no_position />
        </>
      }>
      <Section title="Information">
        <Box dangerouslySetInnerHTML={doc_html} />
        <LabeledList>
          <LabeledList.Divider />
          <Tooltip
            content="Any atoms in the world with the same plane will be drawn to this plane master"
            position="right">
            <LabeledList.Item label="Plane">
              {workingPlane.plane}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="You can think of this as the 'layer' this plane is on. We make duplicates of each plane for each layer, so we can make multiz work"
            position="right">
            <LabeledList.Item label="Offset">
              {workingPlane.offset}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="Render targets can be used to either reference or draw existing drawn items on the map. For plane masters, we use these for either relays (the blue lines), or filters (the pink ones)"
            position="right">
            <LabeledList.Item label="Render Target">
              {workingPlane.render_target || '""'}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="Defines how this plane draws to the things it is relay'd onto. Check the byond ref for more details"
            position="right">
            <LabeledList.Item label="Blend Mode">
              {workingPlane.blend_mode}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="If this is 1, the plane master is being forced to hide from its mob. This is most often done as an optimization tactic, since some planes only rarely need to be used"
            position="right">
            <LabeledList.Item label="Forced Hidden">
              {workingPlane.intended_hidden}
            </LabeledList.Item>
          </Tooltip>
        </LabeledList>
      </Section>
      <Section title="Visuals">
        <Button
          tooltip="Open this plane's VV menu"
          onClick={() =>
            act('vv_plane', {
              edit: workingPlane.our_ref,
            })
          }>
          View Variables
        </Button>
        <Button
          tooltip="Apply and edit effects over the whole plane"
          onClick={() =>
            act('edit_filters', {
              edit: workingPlane.our_ref,
            })
          }>
          Edit Filters
        </Button>
        <Button
          tooltip="Modify how different color components map to the final plane"
          onClick={() =>
            act('edit_color_matrix', {
              edit: workingPlane.our_ref,
            })
          }>
          Edit Color Matrix
        </Button>
        <Slider
          value={workingPlane.alpha}
          minValue={0}
          maxValue={255}
          step={1}
          stepPixelSize={1.9}
          onDrag={(e, value) =>
            act('set_alpha', {
              edit: workingPlane.our_ref,
              alpha: value,
            })
          }
          onChange={(e, value) =>
            act('set_alpha', {
              edit: workingPlane.our_ref,
              alpha: value,
            })
          }>
          Alpha ({workingPlane.alpha})
        </Slider>
      </Section>
    </Section>
  );
};

const InfoButton = (props, context) => {
  const [showInfo, setShowInfo] = useLocalState(context, 'showInfo', false);
  const { no_position } = props;
  const foreign = has_foreign_mob(context);

  return (
    <Button
      top={no_position ? '' : '30px'}
      right={no_position ? '' : foreign ? '100px' : '76px'}
      position={no_position ? '' : 'absolute'}
      icon="exclamation"
      onClick={() => setShowInfo(true)}
      tooltip="Info about what this window is/why it exists"
    />
  );
};

const MobResetButton = (props, context): any => {
  const { act } = useBackend(context);
  const { no_position } = props;
  if (!has_foreign_mob(context)) {
    return;
  }

  return (
    <Button
      top={no_position ? '' : '30px'}
      right={no_position ? '' : '76px'}
      position={no_position ? '' : 'absolute'}
      color="bad"
      icon="power-off"
      onClick={() => act('reset_mob')}
      tooltip="Reset our focused mob to your active mob"
    />
  );
};

const ToggleMirror = (props, context) => {
  const { act, data } = useBackend<PlaneDebugData>(context);
  const { no_position } = props;
  const { tracking_active } = data;

  return (
    <Button
      top={no_position ? '' : '30px'}
      right={no_position ? '' : '52px'}
      position={no_position ? '' : 'absolute'}
      color={tracking_active ? 'bad' : 'good'}
      icon="eye"
      onClick={() => act('toggle_mirroring')}
      tooltip={
        (tracking_active ? 'Disables' : 'Enables') +
        " seeing 'through' the edited mob's eyes, for debugging and such"
      }
    />
  );
};

const has_foreign_mob = function (context) {
  const { data } = useBackend<PlaneDebugData>(context);
  const { mob_ref, our_ref } = data;
  return mob_ref !== our_ref;
};

const VVButton = (props, context) => {
  const { act } = useBackend(context);
  const { no_position } = props;

  return (
    <Button
      top={no_position ? '' : '30px'}
      right={no_position ? '' : '28px'}
      position={no_position ? '' : 'absolute'}
      icon="pen"
      onClick={() => act('vv_mob')}
      tooltip="View the variables of our currently focused mob"
    />
  );
};

const GroupDropdown = (props, context) => {
  const { act, data } = useBackend<PlaneDebugData>(context);
  const { our_group, present_groups } = data;

  return (
    <Box top={'30px'} left={'28px'} position={'absolute'}>
      <Tooltip
        content="Plane masters are stored in groups, based off where they came from. MAIN is the main group, but if you open something that displays atoms in a new window, it'll show up here"
        position="right">
        <Dropdown
          options={present_groups}
          selected={our_group}
          displayText={our_group}
          onSelected={(value) =>
            act('set_group', {
              target_group: value,
            })
          }
        />
      </Tooltip>
    </Box>
  );
};

const RefreshButton = (props, context) => {
  const { act } = useBackend(context);
  const { no_position } = props;

  return (
    <Button
      top={no_position ? '' : '30px'}
      right={no_position ? '' : '6px'}
      position={no_position ? '' : 'absolute'}
      icon="recycle"
      onClick={() => act('refresh')}
      tooltip="Refreshes ALL plane masters. Kinda laggy, but useful"
    />
  );
};

const ClosePlaneWindow = (props, context) => {
  const [readPlane, setReadPlane] = useLocalState(context, 'readPlane', '');
  return <Button icon="times" onClick={() => setReadPlane('')} />;
};

const AddModal = (props, context) => {
  const { act, data } = useBackend<PlaneDebugData>(context);
  const { plane_info } = data;

  const [showAdd, setShowAdd] = useLocalState(context, 'showAdd', false);
  const [currentPlane, setCurrentPlane] = useLocalState<Plane>(
    context,
    'currentPlane',
    {} as Plane
  );
  const [currentTarget, setCurrentTarget] = useLocalState<Plane>(
    context,
    'currentTarget',
    {} as Plane
  );

  const plane_list = Object.keys(plane_info).map((plane) => plane_info[plane]);
  const planes = sortBy((plane: Plane) => -plane.plane)(plane_list);

  const plane_options = planes.map((plane) => plane.name);

  return (
    <Modal>
      <Section fill title={'Add relay from ' + currentPlane.name} pr="13px">
        <Dropdown
          options={plane_options}
          selected={currentTarget?.name || 'planes'}
          width="300px"
          onSelected={(value) => {
            setCurrentTarget(planes[plane_options.indexOf(value)]);
          }}
        />
        <Stack justify="center" fill pt="10px">
          <Stack.Item>
            <Button
              color="good"
              onClick={() => {
                act('connect_relay', {
                  source: currentPlane.plane,
                  target: currentTarget.plane,
                });
                setShowAdd(false);
              }}>
              Confirm
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button color="bad" onClick={() => setShowAdd(false)}>
              Cancel
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};

const InfoModal = (props, context) => {
  const [showInfo, setShowInfo] = useLocalState(context, 'showInfo', false);
  const pain = '';
  const display = {
    __html: pain,
  };
  return (
    <Modal
      position="absolute"
      top="100px"
      right="180px"
      left="180px"
      bottom="100px">
      <Section
        fill
        scrollable
        title="Information Panel"
        buttons={
          <Button
            icon="times"
            tooltip="Close"
            onClick={() => setShowInfo(false)}
          />
        }>
        <Box dangerouslySetInnerHTML={display} />
        <h3>What is all this?</h3>
        This UI exists to help visualize plane masters, the backbone of our
        rendering system. <br />
        It also provices some tools for editing and messing with them. <br />
        <br />
        <h3>How to use this UI</h3> <br />
        This UI exists primarially as a visualizer, mostly because this info is
        quite obscure, and I want it to be easier to understand.
        <br />
        <br />
        That said, it also supports editing plane masters, adding and removing
        relays, and provides easy access to color matrix/filter/alpha/vv
        editing. <br />
        <br />
        To start off with, each little circle represents a{' '}
        <code>render_target</code> based connection.
        <br />
        Blue nodes are relays, so drawing one plane onto another. Purple ones
        are filter based connections. <br />
        You can tell where a node starts and ends based on the side of the plane
        it&apos;s on. <br />
        <br />
        Adding a new relay is simple, you just need to hit the + button, and
        select a plane by name to relay onto. <br />
        <br />
        Each plane can be viewed more closely by clicking the little button in
        it&apos;s top right corner. This opens a sidebar, and displays a lot of
        more general info about the plane and its purpose, alongside exposing
        some useful buttons and interesting values. <br />
        <br />
        Planes are aligned based off their initial setup. If you end up breaking
        things byond repair, or just want to reset things, you can hit the
        recycle button in the top left to totally refresh your plane masters.{' '}
        <br />
        <br />
        <h3>What is a plane master?</h3>
        You can think of a plane master as a way to group a set of objects onto
        one rendering slate. <br />
        It is per client too, which makes it quite powerful. This is done using
        the <code>plane</code> variable of <code>/atom</code>. <br />
        <br />
        We first create an atom with an appearance flag that contains{' '}
        <code>PLANE_MASTER</code> and give it a <code>plane</code> value. <br />
        Then we mirror the same <code>plane</code> value on all the atoms we
        want to render in this group.
        <br />
        <br />
        Finally, we place the <code>PLANE_MASTER</code>&apos;d atom in the
        relevent client&apos;s screen contents. <br />
        That sets up the bare minimum.
        <br />
        <br />
        It is worth noting that the <code>plane</code> var does not only effect
        this rendering grouping behavior. <br />
        It also effects the layering of objects on the map. <br />
        <br />
        For this reason, there are some effects that are pretty much impossible
        with planes. <br />
        Masking one thing while also drawing that thing in the correct order
        with other objects on the map is a good example of this.
        <br />
        It <b>is</b> possible to do, but it&apos;s quite disruptive.
        <br />
        <br />
        Normally, planes will just group, apply an effect, and then draw
        directly to the game.
        <br />
        What if we wanted to draw <b>planes</b> onto other planes then? <br />
        <br />
        <h3>Render Targets and Relays</h3>
        <br />
        Rendering one thing onto another is actually not that complex. <br />
        We can set the <code>render_target</code> variable of an atom to relay
        it to some <code>render_source</code>.<br />
        <br />
        If that <code>render_target</code> is preceeded by *, it will
        <b>not</b> be drawn to the actual client view, and instead just relayed.{' '}
        <br />
        <br />
        Ok so we can relay a plane master onto some other atom, but how do we
        get it on another plane master? We can&apos;t just draw it with{' '}
        <code>render_source</code>, since we might want to relay more then one
        plane master.
        <br />
        <br />
        Why not relay it to another atom then? and then well, set that
        atom&apos;s <code>plane</code> var to the plane master we want? <br />
        <br />
        That ends up being about what we do. <br />
        It&apos;s worth noting that render sources are often used by filters,
        normally to apply some displacement or mask.
        <br />
        <br />
        <h3>Applying effects</h3> <br />
        Ok so we can group and relay planes, but what can we actually do with
        that? <br />
        <br />
        Lots of stuff it turns out. Filters are quite powerful, and we use them
        quite a bit. <br />
        You can use filters to mask one plane with another, or use one plane as
        a distortion source for another. <br />
        <br />
        Can do more basic stuff too, setting a plane&apos;s color matrix can be
        quite powerful. <br />
        Even just setting alpha to show and hide things can be quite useful.{' '}
        <br />
        <br />
        I won&apos;t get into every effect we do here, you can learn more about
        each plane by clicking on the little button in their top right. <br />
        <br />
      </Section>
    </Modal>
  );
};
