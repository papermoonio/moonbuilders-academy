const main = async () => {
    await window.ethereum.enable();
    const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
    });


    const from = accounts[0];
    const to = "0x0000000000000000000000000000000000000808";
    const value = "0";
    const data = "0x96e292b8000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000003800000000000000000000000000000000000000000000000000000000000000002000000000000000000000000ffffffff1fcacbd218edc0eba20fc2308c7780800000000000000000000000005b55f89d4fde76de4d4b96a1618a67c24d9872ad0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000044095ea7b30000000000000000000000005b55f89d4fde76de4d4b96a1618a67c24d9872ad000000000000000000000000000000000000000000000000000000174876e80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012441a68f8d0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000174876e80000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000022019c6af76cd6513e44e421ab8dc8f9d86e102200eb2e55cbc41a2d5ce214ee254f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    const gaslimit = "INSERT-GAS-LIMIT";
    const nonce = "INSERT-SIGNERS-NONCE-HERE";
    const deadline = "INSERT-DEADLINE-HERE";

    const createPermitMessageData = function () {
        const message = {
            from: from,
            to: to,
            value: value,
            data: data,
            gaslimit: gaslimit,
            nonce: nonce,
            deadline: deadline,
        };

        const typedData = JSON.stringify({
            types: {
                EIP712Domain: [{
                    name: "name",
                    type: "string"
                },
                {
                    name: "version",
                    type: "string"
                },
                {
                    name: "chainId",
                    type: "uint256"
                },
                {
                    name: "verifyingContract",
                    type: "address"
                },
                ],
                CallPermit: [{
                    name: "from",
                    type: "address"
                },
                {
                    name: "to",
                    type: "address"
                },
                {
                    name: "value",
                    type: "uint256"
                },
                {
                    name: "data",
                    type: "bytes"
                },
                {
                    name: "gaslimit",
                    type: "uint64"
                },
                {
                    name: "nonce",
                    type: "uint256"
                },
                {
                    name: "deadline",
                    type: "uint256"
                },
                ],
            },
            primaryType: "CallPermit",
            domain: {
                name: "Call Permit Precompile",
                version: "1",
                chainId: 1287,
                verifyingContract: "0x000000000000000000000000000000000000080a",
            },
            message: message,
        });

        return {
            typedData,
            message,
        };
    };

    const method = "eth_signTypedData_v4";
    const messageData = createPermitMessageData();
    const params = [from, messageData.typedData];

    web3.currentProvider.sendAsync({
        method,
        params,
        from,
    },
        function (err, result) {
            if (err) return console.dir(err);
            if (result.error) {
                alert(result.error.message);
                return console.error("ERROR", result);
            }
            console.log("Signature:" + JSON.stringify(result.result));
            console.log(ethers.utils.splitSignature(result.result))

        }
    );
}

main()