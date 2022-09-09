// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.8.0;

import "https://github.com/PureStake/moonbeam/blob/master/precompiles/randomness/Randomness.sol";
import "https://github.com/PureStake/moonbeam/blob/master/precompiles/randomness/RandomnessConsumer.sol";

/// @notice Smart contract to demonstrate how to use requestLocalVRFRandomWords
contract RandomnessDemo is RandomnessConsumer {
    /// @notice The Randomness Precompile Interface
    Randomness public randomness =
        Randomness(0x0000000000000000000000000000000000000809);

    uint256 public VRFOutputRandomWord;

    error WaitingFulfillment();

    error NotEnoughFee(uint256 value, uint256 required);

    error DepositTooLow(uint256 value, uint256 required);
 
    /// @notice The gas limit allowed to be used for the fulfillment
    /// @dev Depends on the code that is executed and the number of words requested
    /// @dev so XXX is a safe default for this example contract. Test and adjust
    /// @dev this limit based on the size of the request and the processing of the
    /// @dev callback request in the fulfillRandomWords() function.
    /// @dev The fee paid to start the lottery needs to be sufficient to pay for the gas limit
    uint64 public FULFILLMENT_GAS_LIMIT = 100000; // TODO: fill XXX

    /// @notice The minimum fee needed to pay for calling the callback function
    /// @dev This does not guarantee that there will be enough fee to pay for the
    /// @dev gas used by the fulfillment. Ideally it should be over-estimated
    /// @dev considering possible fluctuation of the gas price.
    /// @dev Additional fee will be refunded to the caller
    uint256 public MIN_FEE = FULFILLMENT_GAS_LIMIT * 1 gwei;

   /// @notice The number of block before the request can be fulfilled (for Local VRF randomness)
    /// @dev The MIN_VRF_BLOCKS_DELAY provides a minimum number that is safe enough for
    /// @dev games with low economical value at stake.
    /// @dev Increasing the delay reduces slightly the probability (already very low)
    /// @dev of a collator being able to predict the pseudo-random number
    uint32 public VRF_BLOCKS_DELAY = MIN_VRF_BLOCKS_DELAY;

    /// @notice A string used to allow having different salt that other contracts
    bytes32 public SALT_PREFIX = "my_demo_salt_change_me";

    /// @notice global number of request done
    /// @dev This number is used as a salt to make it unique for each request
    uint256 public globalRequestCount;

    /// @notice The current request id
    uint256 public requestId;

    /// @notice the owner of the contract
    address owner;

    /// @notice Which randomness source to use
    Randomness.RandomnessSource randomnessSource;

    constructor(Randomness.RandomnessSource source)
        RandomnessConsumer()
    {
        randomnessSource = source;
        owner = msg.sender;
        globalRequestCount = 0;
        /// Set the requestId to the maximum allowed value by the precompile (64 bits)
        requestId = 2**64 - 1;
    }

    function requestRandomWords() external payable onlyOwner {
        /// We check we haven't started the randomness request yet
        if (
            randomness.getRequestStatus(requestId) !=
            Randomness.RequestStatus.DoesNotExist
        ) {
            revert WaitingFulfillment();
        }

        uint256 fee = msg.value - randomness.requiredDeposit();

        if (msg.value < randomness.requiredDeposit() + MIN_FEE) {
            revert NotEnoughFee(msg.value, randomness.requiredDeposit() + MIN_FEE);
        }

        requestId = randomness.requestLocalVRFRandomWords(
                msg.sender,
                fee,
                FULFILLMENT_GAS_LIMIT,
                SALT_PREFIX ^ bytes32(globalRequestCount++),
                1,
                VRF_BLOCKS_DELAY
        );
    }

    /// @notice Allows to increase the fee associated with the request
    /// @dev This is needed if the gas price increase significantly before
    /// @dev the request is fulfilled
    function increaseRequestFee() external payable {
        randomness.increaseRequestFee(requestId, msg.value);
    }

    function fulfillRequest() public {
        randomness.fulfillRequest(requestId);
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        VRFOutputRandomWord = randomWords[0];
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}