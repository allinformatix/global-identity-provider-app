#!/usr/bin/env python3
import os
import requests

AM_URL = "http://am:80/am"
REALM = "root"
AM_COOKIE_NAME = os.environ.get("GIDP_COOKIE_NAME", "iPlanetDirectoryPro")
IDM_USERNAME = os.environ.get("OPENIDM_IDM_TO_AM_USERNAME", "idm-admin")
IDM_PASSWORD = os.environ.get("OPENIDM_IDM_TO_AM_PASSWORD", "supersecret123!")

TEST_USER = "test-user"
TEST_USER_PW = "Test123!"
TEST_USER_EMAIL = "test@example.com"

def authenticate(username, password):
    url = f"{AM_URL}/json/realms/{REALM}/authenticate"
    headers = {
        "X-OpenAM-Username": username,
        "X-OpenAM-Password": password,
        "Content-Type": "application/json",
        "Accept-API-Version": "resource=2.1"
    }
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    return response.json()["tokenId"]

def create_test_user(token):
    url = f"{AM_URL}/json/realms/{REALM}/users?_action=create"
    headers = {
        AM_COOKIE_NAME: token,
        "Content-Type": "application/json",
        "Accept-API-Version": "protocol=2.1,resource=3.0"
    }
    payload = {
        "username": TEST_USER,
        "userpassword": TEST_USER_PW,
        "mail": TEST_USER_EMAIL,
        "givenName": "Test",
        "sn": "User"
    }
    response = requests.post(url, headers=headers, json=payload)
    response.raise_for_status()
    print("[TEST] Test-User erfolgreich erstellt.")

def user_exists(token):
    url = f"{AM_URL}/json/realms/{REALM}/users?_queryFilter=allinformatixID+eq+%22{TEST_USER}%22"
    headers = {
        AM_COOKIE_NAME: token,
        "Accept-API-Version": "resource=3.0"
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    result = response.json().get("result", [])
    return len(result) > 0

def delete_test_user(token):
    url = f"{AM_URL}/json/realms/{REALM}/users/{TEST_USER}"
    headers = {
        AM_COOKIE_NAME: token,
        "Accept-API-Version": "resource=3.0"
    }
    response = requests.delete(url, headers=headers)
    if response.status_code == 404:
        print("[TEST] Test-User war nicht vorhanden, kein Löschen nötig.")
    else:
        response.raise_for_status()
        print("[TEST] Test-User erfolgreich gelöscht.")

def search_test_user(token):
    if user_exists(token):
        print("[TEST] Test-User wurde erfolgreich gefunden.")
    else:
        raise Exception("Test-User nicht gefunden oder mehrfach vorhanden.")

if __name__ == "__main__":
    print("[TEST] Starte Integrationstest für idm-admin...")

    try:
        token = authenticate(IDM_USERNAME, IDM_PASSWORD)
        print("[TEST] Authentifizierung erfolgreich.")

        # Vorher löschen, wenn vorhanden
        if user_exists(token):
            print("[TEST] Test-User existiert bereits – wird gelöscht.")
            delete_test_user(token)

        create_test_user(token)
        search_test_user(token)
        delete_test_user(token)

        print("[TEST] Alle Tests erfolgreich abgeschlossen.")
    except Exception as e:
        print("[FAIL]", e)
        exit(1)