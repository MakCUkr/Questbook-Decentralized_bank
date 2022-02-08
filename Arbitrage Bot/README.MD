The final code is almost ready. THe only difference is that with the latest Solidity upgrades, we must explicitly specify the gas limit for any funciton that we call in external contracts. 

Also remember that the .env file had the private key and other environment variables which must be created after forking the repo in the following template:
PRIVATE_KEY='0x7a......c788'
FLASH_LOANER= '0x91A0c692Ac73165603JPW2I9VK48191FD909948'
INFURA_KEY='https://rinkeby.infura.io/v3/3653806d884b401498e7a07f3f325d2e'