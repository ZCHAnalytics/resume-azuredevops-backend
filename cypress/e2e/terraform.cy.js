describe('Cloud Resume E2E', () => {
  const baseUrl = 'https://shecodesclouds.azureedge.net';
  const apiUrl = 'https://zch-resume-function-app.azurewebsites.net/api/VisitorCounter';
  
  // Generate a unique visitor ID for testing
  const testVisitorId = `cypress-test-${Date.now()}`;
  
  it('serves the static resume', () => {
    cy.visit('/')                       // uses baseUrl
    cy.contains('Zulfia').should('be.visible')
  })

  it('gets the visitor count from API', () => {
    cy.request({
      method: 'GET',
      url: `${apiUrl}?visitorId=${testVisitorId}`,
      failOnStatusCode: false
    }).then((response) => {
      expect(response.status).to.eq(200);
      expect(response.body).to.have.property('uniqueVisitors');
      expect(response.body).to.have.property('totalViews');
      expect(response.body).to.have.property('isNewVisitor');
      expect(response.body.uniqueVisitors).to.be.a('number');
      expect(response.body.totalViews).to.be.a('number');
    });
  });

  it('increments the visitor count', () => {
    let initialCount;

    // First request - get initial count
    cy.request(`${apiUrl}?visitorId=${testVisitorId}-1`)
      .then((response) => {
        initialCount = response.body.totalViews;
      });
    
    // Second request - should increment total views
    cy.request(`${apiUrl}?visitorId=${testVisitorId}-2`)
      .then((response) => {
        expect(response.body.totalViews).to.be.greaterThan(initialCount);
      });
  });
});