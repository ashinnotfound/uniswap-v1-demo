import Web3 from "web3";
import factoryArtifact from "../../build/contracts/UniswapFactory.json";
import exchangeArtifact from "../../build/contracts/UniswapExchange.json";
import catArtifact from "../../build/contracts/Cat.json";
import dogArtifact from "../../build/contracts/Dog.json";

const App={
    web3:null,
    account:null,
    meta:null,
    exchange:null,
    exchangeAddress:null,
    tokenA:null,
    tokenB:null,

    start:async function() {
        const{web3}=this;

        const accounts=await web3.eth.getAccounts();
        this.account=accounts[0];

        const networkId = await web3.eth.net.getId();
        try{    
            this.meta=new web3.eth.Contract(
              factoryArtifact.abi,
              factoryArtifact.networks[networkId].address
             );  
        }catch(error){
            console.error("Could not connect to contract or chain.");
        }
        this.tokenA=new web3.eth.Contract(
          catArtifact.abi,
          catArtifact.networks[networkId].address
        )
        this.tokenB=new web3.eth.Contract(
          dogArtifact.abi,
          dogArtifact.networks[networkId].address
        )
    },

    querryExchangeByToken: async function(){
        const{searchForExchangeByToken} = this.meta.methods;
        const tokenAAddress=document.getElementById("tokenAAddress").value;
        const tokenBAddress=document.getElementById("tokenBAddress").value;
        const exchangeAddress=await searchForExchangeByToken(tokenAAddress,tokenBAddress).call();
        prompt("对应的交易合约地址为:",exchangeAddress);
    },

    createExchange:async function(){
        const{createExchange}=this.meta.methods;
        const tokenAToBeCreated=document.getElementById("tokenAToBeCreated").value;
        const tokenBToBeCreated=document.getElementById("tokenBToBeCreated").value;

        const exchangeAddress=await createExchange(tokenAToBeCreated,tokenBToBeCreated).send({from:this.account});
        alert("创建成功");
    },

    changeExchange:async function(){
      this.exchangeAddress=document.getElementById("exchangeToChange").value;
      document.getElementById("exchangeNow").innerHTML=this.exchangeAddress;
      try{
        const{web3}=this;
        this.exchange=new web3.eth.Contract(
          exchangeArtifact.abi,
          this.exchangeAddress
        )
        alert("切换成功");
      }catch(error){
        alert("切换失败");
      }
    },

    showBalanceOfTokenA:async function(){
      const{showBalanceOfTokenA}=this.exchange.methods;
      var balance=await showBalanceOfTokenA().call();
      
      alert("交易池里代币A数量为"+balance);
    },

    showBalanceOfTokenB:async function(){
      const{showBalanceOfTokenB}=this.exchange.methods;
      var balance=await showBalanceOfTokenB().call();
      alert("交易池里代币B数量为"+balance);
    },

    showLiquidity:async function(){
      const{showLiquidity}=this.exchange.methods;
      var liquidity=await showLiquidity().call();
      alert("流动性为"+liquidity);
    },

    showAddedTokenA:async function(){
      const{showAddedTokenA}=this.exchange.methods;
      var addedTokenA=await showAddedTokenA().call();
      alert(addedTokenA);
    },

    showAddedTokenB:async function(){
      const{showAddedTokenB}=this.exchange.methods;
      var addedTokenB=await showAddedTokenB().call();
      alert(addedTokenB);
    },    

    showTokenAPrice:async function(){
      const{showTokenAPrice}=this.exchange.methods;
      var tokenToUse=document.getElementById("tokenToUse").value;
      var price=await showTokenAPrice(tokenToUse).call();
      alert("价格为 "+price+" tokenB");
    },

    showTokenBPrice:async function(){
      const{showTokenBPrice}=this.exchange.methods;
      var tokenToUse=document.getElementById("tokenToUse").value;
      var price=await showTokenBPrice(tokenToUse).call();
      alert("价格为 "+price+" tokenA");
    },

    addLiquidity:async function(){
      const{addLiquidity}=this.exchange.methods;

      const tokenAToAdd=document.getElementById("tokenAToAdd").value;
      const tokenBToAdd=document.getElementById("tokenBToAdd").value;

    
      await this.tokenA.methods.approve(this.exchangeAddress,tokenAToAdd).send({gas:1000000,from:this.account});
      await this.tokenB.methods.approve(this.exchangeAddress,tokenBToAdd).send({gas:1000000,from:this.account});

      if(await addLiquidity(this.account,tokenAToAdd,tokenBToAdd).send({gas:1000000,from:this.account})){
        alert("增加成功")
      }else {
        alert("增加失败");
      }
    },

    removeLiquidity:async function(){
      const{removeLiquidity}=this.exchange.methods;

      var tokenAToRemove=document.getElementById("tokenAToRemove").value;
      var tokenBToRemove=document.getElementById("tokenBToRemove").value;

      if(await removeLiquidity(this.account,tokenAToRemove,tokenBToRemove).send({gas:1000000,from:this.account})){
        alert("减少成功")
      }else {
        alert("减少失败,这通常是由于减少的数量大于你所曾经增加的数量");
      }
    },

    buyByTokenA:async function(){
      const{swap}=this.exchange.methods;

      var tokenAToUse=document.getElementById("tokenAToUse").value;
      await this.tokenA.methods.approve(this.exchangeAddress,tokenAToUse).send({gas:1000000,from:this.account});
      
      if(await swap(this.account,tokenAToUse,0).send({gas:1000000,from:this.account})){
        alert("交易成功");
      }else{
        alert("交易失败");
      }
    },

    buyByTokenB:async function(){
      const{swap}=this.exchange.methods;

      var tokenBToUse=document.getElementById("tokenBToUse").value;
      await this.tokenB.methods.approve(this.exchangeAddress,tokenBToUse).send({gas:1000000,from:this.account});
      
      if(await swap(this.account,0,tokenBToUse).send({gas:1000000,from:this.account})){
        alert("交易成功");
      }else{
        alert("交易失败");
      }
    }
    
}

window.App = App;

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:8080. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8080"),
    );
  }

  App.start();
});