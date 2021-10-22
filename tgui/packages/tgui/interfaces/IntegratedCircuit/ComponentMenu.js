import {
  Section,
  Button,
} from '../../components';
import { Component } from 'inferno';
import { shallowDiffers } from 'common/react';

export class VariableMenu extends Component {
  constructor() {
    super();
    this.state = {
      variable_name: "",
      variable_type: "any",
    };
  }

  shouldComponentUpdate(nextProps, nextState) {
    if (shallowDiffers(this.state, nextState)) {
      return true;
    }

    const { variables } = this.props;
    if (variables.length !== nextProps.variables.length) {
      return true;
    }
    for (let i = 0; i < variables.length; i++) {
      if (shallowDiffers(variables[i], nextProps.variables[i])) {
        return true;
      }
    }
    return false;
  }

  render() {
    const {
      variables,
      onAddVariable,
      onRemoveVariable,
      onClose,
      handleMouseDownSetter,
      handleMouseDownGetter,
      types,
      ...rest
    } = this.props;
    const {
      variable_name,
      variable_type,
    } = this.state;

    return (
      <Section
        title="Component Menu"
        {...rest}
        fill
        buttons={
          <Button
            icon="times"
            color="transparent"
            mr={2}
            onClick={onClose}
          />
        }
      />
    );
  }
}
