import React, { useState,useEffect } from "react";
import Web3 from 'web3';
import Register from './contracts/Register.json';
import AssignRole from './contracts/AssignRole.json';

function RoleRegistration() {
  const [web3, setWeb3] = useState(null);
  const [accounts, setAccounts] = useState([]);
  const [registerContract, setRegisterContract] = useState(null);
  const [roleContract, setRoleContract] = useState(null);
  const [registrationStatus, setRegistrationStatus] = useState('');

  useEffect(()=>{
    const provider=new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545");
    async function template(){
      const web3=new Web3(provider);
      //we need abi and contract address
      const networkId= await web3.eth.net.getId();
      const deployedNetwork=Register.networks[networkId];
  
      const contractregister=new web3.eth.Contract(Register.abi,deployedNetwork.address);
      setWeb3(web3);
      setRegisterContract(contractregister);
      const deployedNetworkrole=AssignRole.networks[networkId];
      const contractrole=new web3.eth.Contract(AssignRole.abi, deployedNetworkrole.address);
      
      setRoleContract(contractrole);
    }
    provider && template();
  },[]);

  

  const registerUser = async () => {
    
    try {
      const data=document.querySelector("#value").value;
      const acc=0x633653571DC7964A600e554ae8AC6c7115871B32;
        
        //const gasPrice = web3.utils.toWei('0.001', 'ether'); // Convert 0.2 ETH to Wei
        await roleContract.methods.setRole(data,acc).send({
            from: acc,
            gas: 200000, // Set a reasonable gas limit (adjust as needed)
            //gasPrice: gasPrice, // Set the fixed gas price
          });
  
        setRegistrationStatus(`Registration Successful. Designation: ${data}`);
      
    } catch (error) {
      console.error(error);
      setRegistrationStatus('Registration Failed');
    }
  };
  

  return (
    <div>
      <h1>Role Registration</h1>
      
      
      <input type="text" placeholder="Enter Designation" id="value"></input>
      <button onClick={registerUser}>Register User</button>
      <p>{registrationStatus}</p>
    </div>
  );
}

export default RoleRegistration;
