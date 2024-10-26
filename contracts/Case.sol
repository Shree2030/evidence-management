// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AssignRole.sol";

contract Case{
    AssignRole public assignrole;
    constructor (address _assignrole) {
      assignrole = AssignRole(_assignrole); 
    }
    
    struct SCase{
        string ID;
        bytes32 IDhash;
        mapping (bytes32 => uint) AssignedEvidences;
        mapping (bytes32 => uint) UnassignedEvidences;
        mapping (address => uint) investigators; // list is expensive , use mapping instead
        address HI;
        uint evid;
    }
    uint[] Cases; 
    mapping(uint => SCase) cases; // keep track of mulitple cases running
    mapping (uint => address) Head_Investigators;
    // create a case , check for head investigator 
    event RegistrationDone(string, string, uint, address);
    event InvestigatorRemoved(string, address, uint);
    event EvidenceAssignedLevel(string, bytes32, uint);
    event EvidenceRegistered(string, bytes32, address);
    
    function does_case_exists(uint num) public view returns(bool){
        for(uint i =0; i<Cases.length; i++){
            if(Cases[i] == num){
                return true;
            }
        }
        return false;
    }


    function createcase(string memory name, uint case_number, address HI) public payable {       // create case
        require(does_case_exists(case_number) == false, "Case is already created");
        require(assignrole.returnRole(HI) == 1, "Only Head Investigator can create cases");
        SCase storage newCase = cases[case_number];
        newCase.ID = name;
        newCase.IDhash = keccak256(abi.encodePacked(name));
        newCase.HI = HI;
        newCase.investigators[HI] = 1;
        Cases.push(case_number);
        Head_Investigators[case_number] = HI;
        emit RegistrationDone ("Case Registered", name, case_number,Head_Investigators[case_number]);
    }

    function returnHI(uint case_number) public payable returns(address){ // return HI
        return (Head_Investigators[case_number]); 
        
    }

    function is_authorized(address user, uint number) public view returns(bool) { // DAC
        SCase storage nC = cases[number];
        if (nC.investigators[user] == 1){
            return true;
        }
        return false;
    }

    function add_investigator(address inv, uint num) public payable{    // DAC

        SCase storage newC= cases[num];
        newC.investigators[inv] = 1;

    }
    
    function does_evidence_exists(uint case_number, bytes32 key) public view returns(bool){  // evi exists
        require(does_case_exists(case_number) == true, "Case does not exists");
        SCase storage c = cases[case_number];
        if (c.AssignedEvidences[key]>0){
            return true;
        }
        if (c.UnassignedEvidences[key]>0){
            return true;
        }
        return false; 
    }

    function is_level_assigned(uint case_number, bytes32 key) public view returns(bool){ // level 
        SCase storage c = cases[case_number];
        if(c.UnassignedEvidences[key] == 1){
            return false;
        }
        return true;
    }

    function remove_investigator(uint case_number, address inv) public payable{   // access revokation
        // remove an investigator from DAC policy
        SCase storage nC = cases[case_number];
        nC.investigators[inv] = 0;
        emit InvestigatorRemoved("Investigator has been removed from case", inv, case_number);
    }

    function setlevel(bytes32 key, uint case_num) public payable{ // set level never show this 
        SCase storage nc = cases[case_num];
        uint lvl = nc.evid;
        if(lvl == 0){
            lvl =lvl+1;
        }
        if(lvl > 7){
            lvl = 7;
        }
        nc.AssignedEvidences[key] = lvl; // addition to Assigned evidences
        nc.UnassignedEvidences[key] = 0; // removal from Unassigned evidences 
        emit EvidenceAssignedLevel("Evidence as been assigned a level", key, lvl);
    }

    function assign_inl(uint case_num, bytes32 ev) public payable {  // assign level
        
        require(does_case_exists(case_num) == true , "Case does not exists");
        require(does_evidence_exists(case_num,ev) == true , "Evidence exists");
        require(is_level_assigned(case_num,ev) == false, "Level assigned" );
        setlevel(ev, case_num);
    }

    ///@notice simple registeration of new evidence 
    function register_evi(uint case_num, bytes32 ev, address user)public payable{ 

        require(does_case_exists(case_num) == true , "Case does not exists");
        require(does_evidence_exists(case_num,ev) == false , "Evidence exists");
        SCase storage nC = cases[case_num];
        nC.UnassignedEvidences[ev] = 1;
        nC.evid += 1;
        emit EvidenceRegistered("Evidence has been registered by", ev, user);

    }

    function return_level(uint case_num, bytes32 key) public payable returns(uint){   // return level if a evidence 
        require(does_case_exists(case_num) == true, "Case does not exists");
        require(does_evidence_exists(case_num, key) == true , "Evidence does not exists");
        require(is_level_assigned(case_num, key) == true , "Evidence not valid");
        SCase storage nc = cases[case_num];
        uint lvl = nc.AssignedEvidences[key];
        return lvl;
    }

}