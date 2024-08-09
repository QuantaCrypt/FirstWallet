// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract consumer{ 
    

function deposit() public payable {
}


function getBalance() public view returns (uint) {
    return address(this).balance;
} 
}


contract firstWallet {
    address  payable public WalletOwner;

    constructor()  {
        WalletOwner=payable(msg.sender);
    }
    
    receive  () external payable  {
    }
    
    fallback() external payable  {
        // custom code
    }


    mapping(address=>uint) public allowance;
    mapping(address=>bool) public isallowedToSend;
    mapping(address=>bool) public guardians;
    
    address payable nextOwner;
    mapping(address=>mapping(address=>bool)) nextOwnerGuardianVotedBool;

    uint guardiansResetCount;
    
    uint public constant confirmationsFromGuardiansforReset=3;

    function addGuardian(address _guardian, bool _isGuardian) public {
        require (msg.sender==WalletOwner, "you are not owner");
        guardians[_guardian]=_isGuardian;

    }

    function proposeNewOwner(address payable _newOwner) public{
        require(guardians[msg.sender],"you are not guardian");
        require(nextOwnerGuardianVotedBool[_newOwner][msg.sender]==false,"you already voted");
        if(_newOwner!=nextOwner){
            nextOwner=_newOwner;
            guardiansResetCount=0;
        }
        guardiansResetCount++;

        if(guardiansResetCount>=confirmationsFromGuardiansforReset){
            WalletOwner=nextOwner;
            nextOwner=payable(address(0));

        }
    }

    


    function Balance() public view returns (uint256) {
        return address(this).balance;
    }
    
    
    function setAllowance(address qualified, uint qualifiedAmount) public{
        require(msg.sender==WalletOwner, "you are not constructor");
        allowance[qualified]=qualifiedAmount;
        if(qualifiedAmount>0){
            isallowedToSend[qualified]=true;
        } else {
            isallowedToSend[qualified]=false;
        }
    }
    function send(address payable to, uint amount, bytes memory payload) public returns (bytes memory) {
        //require(msg.sender==WalletOwner,"You are stranger");
        if (msg.sender !=WalletOwner){
            require(isallowedToSend[msg.sender],"you are not allowed");
            require(allowance[msg.sender]>=amount,"you are trying to send more than you are allowed to, aborting");
        
            allowance[msg.sender]-=amount;
        }
        //require(amount<=address(this).balance,"Insufficient Balance");
        (bool success, bytes memory returnData )=to.call{value: amount}(payload);
        require(success, "Aborting");
        return returnData;
    }  

    
 }
