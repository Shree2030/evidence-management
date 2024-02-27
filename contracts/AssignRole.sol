// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// how do i deal with these infinite gas statements 

contract AssignRole{
    mapping(string => uint) private Levels;
    mapping(address => uint) public Roles; // each address will have a IG level storing is like address : Integrity Level 1/2
    address[] private RegisteredUsers;  // dynamic array of all registered users, to check whether they exists or not
    
    event RegistrationDone(string, address, uint);
    
    constructor(){
        Levels["Head Investigator"] = 1;
        Levels["Lead Investigator"] =4;
        Levels["Team Investigator"] = 7;
    }

    function getLevel(string memory designation) public payable returns(uint){
       return (Levels[designation]);
    }

    function DoesExists (address user) public view returns(bool){
        for(uint i =0; i < RegisteredUsers.length; i++){
            if(RegisteredUsers[i] == user){
                return true;
            }
        }
        return false;
    }

    function setRole(string memory designation, address user) public payable {
        
        require(DoesExists(user) == false, "User Already Registered" );
        require(getLevel(designation)> 0, "Invalid designation");
        Roles[user] = getLevel(designation);
        RegisteredUsers.push(user);
        emit RegistrationDone(" User Registration Completed",user, Roles[user]);
        
    }
    function returnRole(address user) public view returns(uint){
        require(DoesExists(user) == true , "User is not registered");
        return Roles[user];
    }
}