import {
  Box,
  Button,
  LabeledList,
  Section,
  Slider,
  Tooltip,
} from 'tgui-core/components';

import { Plane } from './types';
import { usePlaneDebugContext } from './usePlaneDebug';

export function PlaneEditor() {
  const { activePlane, planesProcessed, setPlaneOpen, act } =
    usePlaneDebugContext();

  const currentPlane: Plane = planesProcessed[activePlane as number];
  const doc_html = {
    __html: currentPlane.documentation,
  };

  return (
    <Section
      fill
      scrollable
      width="450px"
      position="absolute"
      top="0px"
      right="0px"
      backgroundColor="#121212"
      title={`Plane Master: ${currentPlane.name}`}
      buttons={
        <Button
          icon="times"
          tooltip="Close"
          onClick={() => setPlaneOpen(false)}
        />
      }
    >
      <Section title="Information">
        <Box dangerouslySetInnerHTML={doc_html} />
        <br />
        <LabeledList>
          <LabeledList.Divider />
          <Tooltip
            content="Any atoms in the world with the same plane will be drawn to this plane master"
            position="right"
          >
            <LabeledList.Item label="Plane">
              {currentPlane.plane}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="You can think of this as the 'layer' this plane is on. We make duplicates of each plane for each layer, so we can make multiz work"
            position="right"
          >
            <LabeledList.Item label="Offset">
              {currentPlane.offset}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="Render targets can be used to either reference or draw existing drawn items on the map. For plane masters, we use these for either relays (the blue lines), or filters (the pink ones)"
            position="right"
          >
            <LabeledList.Item label="Render Target">
              {currentPlane.render_target
                ? `"${currentPlane.render_target}"`
                : 'None'}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="Defines how this plane draws to the things it is relay'd onto. Check the byond ref for more details"
            position="right"
          >
            <LabeledList.Item label="Blend Mode">
              {currentPlane.blend_mode}
            </LabeledList.Item>
          </Tooltip>
          <Tooltip
            content="If this is 1, the plane master is being forced to hide from its mob. This is most often done as an optimization tactic, since some planes only rarely need to be used"
            position="right"
          >
            <LabeledList.Item label="Forced Hidden">
              {currentPlane.force_hidden ? 'True' : 'False'}
            </LabeledList.Item>
          </Tooltip>
        </LabeledList>
        <br />
        <Section title="Visuals">
          <Button
            tooltip="Open this plane's VV menu"
            mr="5px"
            mb="5px"
            onClick={() =>
              act('vv_plane', {
                edit: currentPlane.plane,
              })
            }
          >
            View Variables
          </Button>
          <Button
            tooltip="Apply and edit effects over the whole plane"
            mr="5px"
            mb="5px"
            onClick={() =>
              act('edit_filters', {
                edit: currentPlane.plane,
              })
            }
          >
            Edit Filters
          </Button>
          <Button
            tooltip="Modify how different color components map to the final plane"
            mr="5px"
            mb="5px"
            onClick={() =>
              act('edit_color_matrix', {
                edit: currentPlane.plane,
              })
            }
          >
            Edit Color Matrix
          </Button>
          <Slider
            value={currentPlane.alpha}
            minValue={0}
            maxValue={255}
            step={1}
            stepPixelSize={1.9}
            onChange={(_event, value) =>
              act('set_alpha', { edit: currentPlane.plane, alpha: value })
            }
          >
            Alpha ({currentPlane.alpha})
          </Slider>
        </Section>
      </Section>
    </Section>
  );
}
