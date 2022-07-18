// SPDX-License-Identifier: GPL-3.0

pragma solidity>=0.5.0 < 0.9.0;

contract PurchaseAgreement{
   uint public value;
   uint deploydate;
   address payable public buyer;
   address payable public seller;

   enum State{Created,Locked,Relaesed,Inactive}
   State public state;

   constructor() payable{
       seller=payable(msg.sender);
       value=msg.value;
       deploydate=block.timestamp;
   }

   /// The function annot be called at the current state.
   error Invalidstate();

   ///Only the buyer can call this function
   error onlybuyer();

    ///Only the seller can call this function
   error onlyseller();

   modifier Instate(State _state)
   {
       if(state!=_state)
       {
           revert Invalidstate();
       }
       _;
   }

   modifier OnlyBuyer()
   {
       if(msg.sender!=buyer)
       {
           revert onlybuyer();
       }
       _;
   }

   modifier OnlySeller()
   {
       if(msg.sender!=seller)
       {
           revert onlyseller();
       }
       _;
   }

   function ConfirmPurchase() external Instate(State.Created) payable
   {
       require(msg.value==(2*value),"Please send 2x of Purchase Amount");
       buyer=payable(msg.sender);
       state=State.Locked;
   }

   function ConfirmReceived() external OnlyBuyer Instate(State.Locked)
   {
       state=State.Relaesed;
       buyer.transfer(value);
   }

   function payseller() external OnlySeller Instate(State.Relaesed)
   {
       state=State.Inactive;
       seller.transfer(2*value);
   }

   function abort() external OnlySeller Instate(State.Created)
   {
       state=State.Inactive;
       seller.transfer(address(this).balance);
   }
   function abortfornotreceived() external OnlyBuyer Instate(State.Locked)
   {
       require(block.timestamp>=deploydate + 2 days,"Still tranfer time not Completed");
       buyer.transfer(2*value);
       seller.transfer(value);
       state=State.Inactive;
   }
}