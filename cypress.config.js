const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'https://shecodesclouds.azureedge.net',
    supportFile: false,  // important to avoid the support file error
    pageLoadTimeout: 100000,
    env: {
      apiUrl: 'https://zchresume-api.azurewebsites.net/api/VisitorCounter',
    },
    specPattern: 'cypress/e2e/**/*.cy.js',  
  },
});


