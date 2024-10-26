// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./AssignRole.sol";
import "./Case.sol";


contract BibaAppend{
   //AssignLevel public evidence; // contract instance
   AssignRole public  user;
   Case public scase;
   
   // keep track of which evidence was appended to, but an evidence can be appended to multiple times
   mapping (bytes32 => mapping(uint => bytes32)) public AppendedEvidence;  
    
   //use another mapping to keep track of how many times a evidence was appended to 
   mapping (bytes32 =>uint) public TrackerMapping; 
   
   //Evidence public evidence;
   event AppendAllowed(string, address, bytes32, bytes32); 
   
   constructor( address _assignRole, address _case){
    //evidence = AssignLevel(_assignLevel);
    user = AssignRole(_assignRole);
    scase = Case(_case);
    //create = Evidence()
   }
   ///@notice returns number of times an evidence had additional information added 
   ///@param key required to uniquely identify a case
   function returnTimes(bytes32 key) public view returns(uint){  
      return TrackerMapping[key];
   }

   function append_allowed(bytes32 key, address ad_user, bytes32 key_of_new, uint case_num) public payable returns (bool){
    require(scase.is_authorized(ad_user, case_num) == true, "Cannot interact with this evidence");
    uint L = scase.return_level(case_num, key);
    uint R = user.returnRole(ad_user);
    bool val = (R>=L);
    
    require(val == true, "User is not authorized to append to evidence");
    
    uint times = returnTimes(key); // find how many times the og evidence was appended to
    uint ntime = times+1;
    TrackerMapping[key] = ntime; // update how many times the orginal evidenece was appended to
    
    bytes32 newhash  = keccak256(abi.encodePacked(key,key_of_new)); // calculate new hash
    string memory str = "Hell";
    bytes32 evi = keccak256(abi.encode(str));
    scase.register_evi(case_num, evi, msg.sender); // create a new evidence with new founf evidence related to og evidence
    
    AppendedEvidence[key][ntime] = newhash; // finally add the appended evidence in the nested mapping 
    emit AppendAllowed("User has appended to evidence", ad_user, key, newhash);
    
    return true;
   }

}