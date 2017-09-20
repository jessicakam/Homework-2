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
	event BetClosed(); /* same as MadeDecision for oracle?*/
	event WithdrawlMade(address gambler, uint amt) /**/
	event GameReset(); /**/

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {require(owner); require(owner != gamblerA); require(owner != gamblerB); _;} /**/
	modifier OracleOnly() {require(oracle); require(oracle != gamblerA); require(owner != gamblerB; _;} /**/

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
		owner = msg.sender; /**/
		outcomes = _outcomes; /**/
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
		oracle = _oracle; /**/
		return oracle; /**/
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome) payable returns (bool) {
		/*better way instead of all these requires*/
		address better = msg.sender;
		require(better != oracle);
		bool outcome_found = false;
		for (int i = 0; i < outcomes.length; i++) {
			if (outcomes[i] == _outcome) {
				outcome_found = true;
			}
		}
		require(outcome_found);
		require(!gamblerA || !gamblerB);
		if (!gamblerA) {
			gamblerA = better;
		} else {
			gamblerB = better;
		}
		require(!bets[better].initialized);
		bets[better].outcome = _outcome;
		bets[better].amount = msg.value;
		bets[better].initialized = 1;
		BetMade(better);
		return true; /** where return false? what require return? */
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
		/*where use BetClosed()*/
		require(bets[gamblerA].initialized == 1 && bets[gamblerB].initialized == 1);
		uint outcomeA = bets[gamblerA].outcome;
		uint amountA = bets[gamblerA].amount;
		uint outcomeB = bets[gamblerB].outcome;
		uint amountB = bets[gamblerB].amount;
		if (outcomeA == outcomeB) {
			/*reinburst both*/
			winnings[gamblerA] = amountA;
			winnings[gamblerB] = amountB;
		}
		if (outcomeA != _outcome && outcomeB != _outcome) {
			winnings[oracle] = amountA + amountB;
		}
		/* how define total winnings*/
		if (outcomeA == _outcome) {
			winnings[A] += (amountA + amountB); /**.
		} else {
			winnings[B] += (amountA + amountB); /**.
		}
		
		outcomes[msg.sender] = _outcome;
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
		/**/
		address withdrawer = msg.sender
		if (withdrawAmount > 0 && (withdrawer == gamblerA || withdrawer == gamblerB || withdrawer == oracle) && withdrawAmount <= checkWinnings()) {
			winnings[withdrawer] -= withdrawAmount;
			if (!withdrawer.send(withdrawAmount)) {
				revert();
			}
			WithdrawlMade(withdrawer, withdrawAmount);
		}
		return winnings[withdrawer];		
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
		/* keep winnings? delete outcomes? bets??*/
		delete(gamblerA);
		delete(gamblerB);
		delete(bets);
		GameReset();
	}

	/* Fallback function */
	function() {
		revert();
	}
}
