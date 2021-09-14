import { Job } from "../base";
import { Captain as DepartmentCaptain } from "../departments";

const Captain: Job = {
  name: "Captain",
  description: "Be responsible for the station, manage your Heads of Staff, \
    keep the crew alive, be prepared to do anything and everything or die \
    horribly trying.",
  department: DepartmentCaptain,
};

export default Captain;
