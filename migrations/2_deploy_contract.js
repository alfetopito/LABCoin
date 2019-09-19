const LABC = artifacts.require('LABC');
const ICO = artifacts.require('ICO');
const WETH = artifacts.require('WETH9');

module.exports = function(deployer, network) {
    deployer.deploy(WETH).then(() => {
        console.log('WETH: ' + WETH.address)
        return deployer.deploy(LABC, 10000).then((labc) => {
            console.log('labc: ' + labc.address)
            const ico = deployer.deploy(ICO, labc.address, WETH.address)
            labc.delegateOwnership(ico.address)
            return ico
        })
    })
}