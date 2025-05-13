import { useState } from 'react';
import { Button, Dropdown, Modal, Section, Stack } from 'tgui-core/components';

import { BlendModes, Plane } from './types';
import { usePlaneDebugContext } from './usePlaneDebug';

export function PlaneMenus() {
  const { connectionOpen, infoOpen } = usePlaneDebugContext();

  return (
    <>
      {!!connectionOpen && <AddConnectionModal />}
      {!!infoOpen && <InfoModal />}
    </>
  );
}

function AddConnectionModal() {
  const {
    activePlane,
    setActivePlane,
    setConnectionOpen,
    planesProcessed,
    act,
  } = usePlaneDebugContext();
  const currentPlane = planesProcessed[activePlane as number];
  const optionMap: Record<string, number> = {};
  const [selectedTarget, setSelectedTarget] = useState<number>();
  const [selectedBlend, setSelectedBlend] = useState<string>('BLEND_DEFAULT');

  const selectablePlanes: Plane[] = [];
  for (const key in planesProcessed) {
    const plane: Plane = planesProcessed[key];
    if (plane !== currentPlane) {
      selectablePlanes.push(plane);
      optionMap[plane.name] = plane.plane;
    }
  }

  const planeOptions: Array<string> = selectablePlanes
    .sort((a, b) => {
      if (a.depth !== b.depth) {
        return a.depth - b.depth;
      }

      return a.plane - b.plane;
    })
    .map((a) => a.name);

  return (
    <Modal p={1}>
      <Section
        fill
        title={`Add relay from ${currentPlane.name}`}
        buttons={
          <Button
            icon="close"
            color="bad"
            onClick={() => {
              setConnectionOpen(false);
              setActivePlane(undefined);
            }}
          />
        }
      >
        <Stack fill vertical>
          <Stack.Item>
            <Dropdown
              options={planeOptions}
              selected={
                selectedTarget !== undefined
                  ? planesProcessed[selectedTarget].name
                  : 'Select target'
              }
              width="300px"
              onSelected={(value) => setSelectedTarget(optionMap[value])}
            />
          </Stack.Item>
          <Stack.Item>
            <Dropdown
              options={Object.keys(BlendModes).filter((x) =>
                Number.isNaN(Number(x)),
              )}
              selected={selectedBlend}
              width="300px"
              onSelected={(value) => setSelectedBlend(value)}
            />
          </Stack.Item>
          <Stack.Item textAlign="center">
            <Button
              color="good"
              onClick={() => {
                act('connect_relay', {
                  source: activePlane,
                  target: selectedTarget,
                  mode: BlendModes[selectedBlend],
                });
                setConnectionOpen(false);
                setActivePlane(undefined);
              }}
            >
              Confirm
            </Button>
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
}

function InfoModal() {
  const { setInfoOpen } = usePlaneDebugContext();
  return (
    <Modal
      position="absolute"
      top="100px"
      right="180px"
      left="180px"
      bottom="100px"
    >
      <Section
        fill
        scrollable
        title="Information Panel"
        buttons={
          <Button
            icon="times"
            tooltip="Close"
            onClick={() => setInfoOpen(false)}
          />
        }
      >
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
}
