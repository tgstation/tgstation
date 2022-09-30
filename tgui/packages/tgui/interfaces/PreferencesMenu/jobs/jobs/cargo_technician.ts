import { Job } from "../base";
import { Cargo } from "../departments";

const CargoTechnician: Job = {
  name: "Cargo Technician",
  description: "Distribute supplies to the departments that ordered them, \
    collect empty crates, load and unload the supply shuttle, \
    ship bounty cubes.",
  department: Cargo,
};

export default CargoTechnician;
