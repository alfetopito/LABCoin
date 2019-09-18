const LABC = artifacts.require('LABC');
const ICO = artifacts.require('ICO');
// const WETH = artifacts.require('canonical-weth/contracts/WETH9.sol');
// const WETH = artifacts.require('WETH9');
const contract = require('truffle-contract');
const wethArtifact = require('canonical-weth');

const weth = contract(wethArtifact);

module.exports = function(deployer, network) {
    // console.log('artifact: ' + JSON.stringify(wethArtifact))
    // console.log('contract: ' + JSON.stringify(weth))
    // console.log('weth: ' + weth.address)
    deployer.deploy(LABC)
    console.log('yay!')
    // deployer.deploy(ICO, LABC.address, weth.address)
    deployer.deploy(wethArtifact)
    // deployer.deploy(weth).then(() => {
    //     console.log('weth: ' + weth.address)
    //     return deployer.deploy(LABC).then(() => {
    //         console.log('labc: ' + LABC.address)
    //         return deployer.deploy(ICO, LABC.address, weth.address)
    //     })
    // })
}