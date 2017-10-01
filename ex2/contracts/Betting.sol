pragma solidity ^0.4.15;

contract Betting {
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
	event WithdrawlMade(address gambler, uint amt);
	event GameReset();


	/* Uh Oh, what are these? */
	modifier OwnerOnly() {require(address(owner) != 0); require(owner != gamblerA); require(owner != gamblerB); _;}
	modifier OracleOnly() {require(address(oracle) != 0); require(oracle != gamblerA); require(owner != gamblerB); _;}


	/* Constructor function, where owner and outcomes are set */
	function Betting(uint[] _outcomes) {
		owner = msg.sender; 
		outcomes = _outcomes; 
	}


	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		require(_oracle != owner);
		oracle = _oracle; 
		return oracle;
	}


	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		address better = msg.sender;
		require(better != oracle);
		bool outcome_found = false;
		for (uint i = 0; i < outcomes.length; i++) {
			if (outcomes[i] == _outcome) {
				outcome_found = true;
			}
		}
		require(outcome_found);
		require(address(gamblerA) != 0 || address(gamblerB) != 0);
		if (address(gamblerA) != 0) {
			gamblerA = better;
		} else {
			gamblerB = better;
		}
		require(!bets[better].initialized);
		bets[better].outcome = _outcome;
		bets[better].amount = msg.value;
		bets[better].initialized = true;
		BetMade(better);
		if (address(gamblerA) != 0 && address(gamblerB) != 0) {
			BetClosed();
		}
		return true;
	}


	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
		require(bets[gamblerA].initialized && bets[gamblerB].initialized);
		uint outcomeA = bets[gamblerA].outcome;
		uint amountA = bets[gamblerA].amount;
		uint outcomeB = bets[gamblerB].outcome;
		uint amountB = bets[gamblerB].amount;
		uint total = amountA + amountB;
		if (outcomeA == outcomeB) {
			winnings[gamblerA] = amountA;
			winnings[gamblerB] = amountB;
		}
		if (outcomeA != _outcome && outcomeB != _outcome) {
			winnings[oracle] = total;
		}
		
		if (outcomeA == _outcome) {
			winnings[gamblerA] = winnings[gamblerA] + total; 
		} else {
			winnings[gamblerB] = winnings[gamblerB] + total;
		}
	}


	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		address withdrawer = msg.sender;
		if (withdrawAmount > 0 && (withdrawer == gamblerA || withdrawer == gamblerB || withdrawer == oracle) && withdrawAmount <= checkWinnings()) {
			winnings[withdrawer] -= withdrawAmount;
			withdrawer.transfer(withdrawAmount);
			WithdrawlMade(withdrawer, withdrawAmount);
		}
		return winnings[withdrawer];
	}
	

	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
		return outcomes;
	}


	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
		return winnings[msg.sender];
	}


	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
		delete(gamblerA);
		delete(gamblerB);
		bets[gamblerA] = Bet({outcome: 0, amount: 0, initialized: false});
		bets[gamblerB] = Bet({outcome: 0, amount: 0, initialized: false});
		GameReset();
	}


	/* Fallback function */
	function() {
		revert();
	}
}
