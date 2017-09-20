pragma solidity ^0.4.15;

contract BettingContract {
	/* Standard state variables */
	address owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes;

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {}
	modifier OracleOnly() {}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
		owner = msg.sender; /**/
		outcomes = _outcomes; /**/
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		oracle = _oracle; /**/
		return oracle; /** or do something with modifier? */
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		/**/
		if (checkOutcomes()) {
			bets[msg.sender] = Bet();
			bets[msg.sender].outcome = _outcome;
			bets[msg.sender].amount = msg.value;
			bets[msg.sender].initialized = msg.value; /*or maybe some bool?*/
			return True;
		} else {
			return False;
		}
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
		/**/
		outcomes[msg.sender] = _outcome;
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		/**/
		if (msg.sender.value >= withdrawAmount):
			msg.sender.send(withdrawAmount);
			msg.sender.value -= withdrawAmount;
			BetClosed();
		return msg.sender.value;
		
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
		return outcomes; /**/
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
		/**/
		return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		/*check winnings and withdraw them too?*/
		delete(outcomes);
		delete(bets);
	}

	/* Fallback function */
	function() {
		revert();
	}
}
