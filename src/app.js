App = {
    loading:false,
    contracts:{},
    load: async() => {
      await App.loadWeb3()
      await App.loadAccount()
      await App.loadContract()
      await App.render()
    },
  
    loadWeb3: async () => {
      if (typeof web3 !== 'undefined') {
        App.web3Provider = web3.currentProvider
        web3 = new Web3(web3.currentProvider)
      } else {
        window.alert("Please connect to Metamask.")
      }
      // Modern dapp browsers...
      if (window.ethereum) {
        window.web3 = new Web3(ethereum)
        try {
          // Request account access if needed
          await ethereum.enable()
          // Acccounts now exposed
          web3.eth.sendTransaction({/* ... */})
        } catch (error) {
          // User denied account access...
        }
      }
      // Legacy dapp browsers...
      else if (window.web3) {
        App.web3Provider = web3.currentProvider
        window.web3 = new Web3(web3.currentProvider)
        // Acccounts always exposed
        web3.eth.sendTransaction({/* ... */})
      }
      // Non-dapp browsers...
      else {
        console.log('Non-Ethereum browser detected. You should consider trying MetaMask!')
      }
    },
  
    loadAccount: async () => {
      App.account = web3.eth.accounts[0]
    },
  
    loadContract: async () => {      
      const journalResearcher = await $.getJSON('JournalResearcher.json')
      App.contracts.JournalResearcher = TruffleContract(journalResearcher)
      App.contracts.JournalResearcher.setProvider(App.web3Provider)
      App.journalResearcher = await App.contracts.JournalResearcher.deployed()
    },
  
    render: async () => {
      if(App.loading){
        return
      }
      App.setLoading(true)
      $('#account').html(App.account)
      await App.renderMembers()
      App.setLoading(false)
    },
  
    setLoading:(boolean) => {
      App.loading = boolean
      const loader = $('#loader')
      const content = $('#content')
      if (boolean) {
        loader.show()
        content.hide()
      } else {
        loader.hide()
        content.show()
      }
    },
  
    renderMembers: async () => {
      // Load the total task count from the blockchain
      const memberCount = await App.journalResearcher.totalResearcherNum()
      const $memberTemplate = $('.memberTemplate')
  
      // Render out each task with a new task template
      for (var i = 1; i <= memberCount; i++) {
        // Fetch the task data from the blockchain 
        const member = await App.journalResearcher.memberDict(i)
        const memberName = member[0]
        const memberOrg = member[1]
        const memberContent = memberName + '/' + memberOrg
        
        // Create the html for the task
        const $newMemberTemplate = $memberTemplate.clone()
        $newMemberTemplate.find('.content').html(memberContent)
        $('#memberList').append($newMemberTemplate)
    
        // Show the task
        $newMemberTemplate.show()
      }
    },
    
    register: async () => {
      App.setLoading(true)
      const name = $('#name').val()
      const status = $('#status').val()
      const organization = $('#organization').val()
      const email = $('#email').val()
      await App.journalResearcher.register(name, organization)
      window.location.reload()
    }
  }
  
  $(()=> {
    $(window).load(() => {
      App.load()
    })  
  })