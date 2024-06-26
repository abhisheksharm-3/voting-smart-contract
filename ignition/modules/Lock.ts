import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const DEFAULT_CANDIDATES = ["Alice", "Bob", "Charlie"];

const BallotModule = buildModule("BallotModule", (m) => {
  const candidateNames = m.getParameter("candidateNames", DEFAULT_CANDIDATES);

  const ballot = m.contract("Ballot", [candidateNames]);

  return { ballot };
});

export default BallotModule;
