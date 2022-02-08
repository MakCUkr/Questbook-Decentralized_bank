// require statements
const { ethers } = require('ethers');
let uniswapFactoryAbi = require('./abis/IUniswapV2Factory.json').abi;
let uniswapPairAbi = require('./abis/IUniswapV2Pair.json').abi;
// import environment variables
require('dotenv').config();
const privateKey = process.env.PRIVATE_KEY;
const flashLoanerAddress = process.env.FLASH_LOANER;
const infuraKey = process.env.INFURA_KEY;
// external contract addresses
const DAI_ADRESS = '0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735';
const WETH_ADDRESS = '0xc778417e063141139fce010982780140aa0cd5ab';
const UNISWAP_FACTORYv2_ADDRESS = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
const SUSHI_FACTORYv2_ADDRESS = "0xc35DADB65012eC5796536bD9864eD8773aBc74C4";
// initializing provider, wallet for ethers.js
const infuraProvider = new ethers.providers.JsonRpcProvider(infuraKey,'rinkeby');
const wallet = new ethers.Wallet(privateKey, infuraProvider);
// creating uniswap/sushiswap contract instances
const uniswapFactory = new  ethers.Contract( UNISWAP_FACTORYv2_ADDRESS , uniswapFactoryAbi, wallet);
const sushiFactory = new ethers.Contract( SUSHI_FACTORYv2_ADDRESS , uniswapFactoryAbi, wallet);
var uniswapPair, sushiswapPair;

const ETH_TRADE = 10;
// const DAI_TRADE = 3500;


const start = async() => {
	const fun = async() => {
		_uniswapPair = await uniswapFactory.getPair(WETH_ADDRESS,DAI_ADRESS);
		uniswapPair = new ethers.Contract(_uniswapPair, uniswapPairAbi,wallet);

		_sushiswapPair = await sushiFactory.getPair(WETH_ADDRESS,DAI_ADRESS);
		sushiswapPair = new ethers.Contract(_sushiswapPair, uniswapPairAbi,wallet);
	}

	await fun();


	infuraProvider.on('block', async (blockNumber) => {
		let priceFavorable = false;
		var spread;
	    try 
	    {
			console.log("\n-----------------------\nBlock Number",blockNumber);
			// (Uniswap)getting reserves and caculating price of eth
			let uniswapReserves = await uniswapPair.getReserves();
			let uniswapEthReserves = uniswapReserves[0];
			let uniswapDaiReserves = uniswapReserves[1];
			let uniswapEthPrice = uniswapDaiReserves/uniswapEthReserves;
			console.log("Uniswap WETH price", uniswapEthPrice, " DAI");
			// (Sushiswap)getting reserves and caculating price of eth
			let sushiswapReserves = await sushiswapPair.getReserves();
			let sushiswapEthReserves = sushiswapReserves[0];
			let sushiswapDaiReserves = sushiswapReserves[1];
			let sushiswapEthPrice = sushiswapDaiReserves/sushiswapEthReserves;			
			console.log("Sushiswap ETH price", sushiswapEthPrice, " DAI");

			if(sushiswapEthPrice > uniswapEthPrice){
				priceFavorable = true;
				spread = Math.abs((sushiswapEthPrice / uniswapEthPrice - 1) * 100) - 0.6;
			}
			console.log("Price difference is favorable: ", priceFavorable);
			console.log("Spread: ", spread);
			console.log(await uniswapPair.token0());

			if(! priceFavorable) return;
			// const recommendedGasPrice = Number(await infuraProvider.getGasPrice());
			// const actualGasPrice = recommendedGasPrice * 1.5; // to make sure our txn goes through
			// console.log("Recommended Gas Price: ", recommendedGasPrice);

			const gasLimit = await sushiswapPair.estimateGas.swap(
		        ETH_TRADE,
		        0,
		        '0x91A0c698Ac7316560307e7D689288191FA3999bD',
		        ethers.utils.toUtf8Bytes('1'),
		     );

		    const gasPrice = await wallet.getGasPrice();
			const gasCost = Number(ethers.utils.formatEther(gasPrice.mul(gasLimit)));

			console.log(gasPrice );

			// const shouldSendTx = priceFavorable
			// ? (gasCost / ETH_TRADE) < spread
			// : (gasCost / (DAI_TRADE / priceUniswap)) < spread;

			// // don't trade if gasCost is higher than the spread
			// if (!shouldSendTx) return;
			// // define options in order to send the transaction
			// const options = {
			// 	gasPrice,
			// 	gasLimit,
			// };
			// const tx = await sushiEthDai.swap(
			// 	!priceFavorable ? DAI_TRADE : 0,
			// 	priceFavorable ? ETH_TRADE : 0,
			// 	flashLoanerAddress,
			// 	ethers.utils.toUtf8Bytes('1'), options,
			// );
			// // arbitrage completed.
			// console.log('ARBITRAGE EXECUTED! PENDING TX TO BE MINED');
			// console.log(tx);
			// await tx.wait();
			// console.log('Tx mindes succesfully');
	    } 
		catch (err) 
	    {
	      		console.error(err);
	    }
	});

}

start();