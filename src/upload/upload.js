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
    const journalResearcher = await $.getJSON('../JournalResearcher.json')
    App.contracts.JournalResearcher = TruffleContract(journalResearcher)
    App.contracts.JournalResearcher.setProvider(App.web3Provider)
    App.journalResearcher = await App.contracts.JournalResearcher.deployed()

    const journal = await $.getJSON('../Journal.json')
    App.contracts.Journal = TruffleContract(journal)
    App.contracts.Journal.setProvider(App.web3Provider)
    App.journal = await App.contracts.Journal.deployed()
  },

  render: async () => {
    if(App.loading){
      return
    }
    App.setLoading(true)
    $('#account').html(App.account)
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

  upload: async () => {
    App.setLoading(true)
    const title = $('input[name="Title"]').val()
    const year = $('input[name="Year"]').val()
    const abstract = $('input[name="Abstract"]').val()
    await App.journal.uploadPaper(title, year, abstract)
    App.setLoading(false)
    App.showPrompt(true)
    App.cleanForm()
 
  },
  
  cleanForm:() => {
    $('input[name="Title"]').val("")
    $('input[name="Year"]').val("")
    $('input[name="Abstract"]').val("")
  },

  showPrompt:(success) => {
    const title = $('input[name="Title"]').val()
    const year = $('input[name="Year"]').val()

    $('#titlePrompt').html(title)
    $('#yearPrompt').html(year)
    $('#addressPrompt').html(App.account)
    
    if (success) {
      $('#prompt').show()
    }
  }


}

$(()=> {
  $(window).load(() => {
    App.load()
  })  
})