const { defineConfig } = require('cypress');

module.exports = defineConfig({
  e2e: {
    baseUrl: 'https://ubds-resume.azureedge.net',
    supportFile: false,  // important to avoid the support file error
    pageLoadTimeout: 100000,
    env: {
      apiUrl: 'https://ubds-func-app.azurewebsites.net/api/VisitorCounter',
    },
    specPattern: 'cypress/e2e/**/*.cy.js',  
  },
});


