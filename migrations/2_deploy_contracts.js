const Cat = artifacts.require("Cat");
const Dog = artifacts.require("Dog");
const UniswapFactory = artifacts.require("UniswapFactory");

module.exports = function(deployer) {
  deployer.deploy(Cat);
  deployer.deploy(Dog);
  deployer.deploy(UniswapFactory);
};
