import requests
import pytest

BASE_URL = "https://ubds-resume-function-app.azurewebsites.net/api"

def test_open_access():
    response = requests.get(f"{BASE_URL}/VisitorCounter?visitorId=test123")
    assert response.status_code == 200
    # Optional: check response structure
    # data = response.json()
    # assert "visitorId" in data or "count" in data
    
@pytest.mark.skip(reason="Authentication not enabled on the function app")
def test_authenticated_access():
    token = "DUMMY_TOKEN"
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.get(f"{BASE_URL}/VisitorCounter?visitorId=test123", headers=headers)
    assert response.status_code == 200