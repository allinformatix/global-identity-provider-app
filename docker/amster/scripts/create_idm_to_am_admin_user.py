#!/usr/bin/env python3
import os
import sys
import json
import requests

# -----------------------------------------
# ENVIRONMENT VARIABLES
# -----------------------------------------
AM_URL = "http://am:80/am"
REALM = "root"
USERNAME = os.environ.get("OPENIDM_IDM_TO_AM_USERNAME", "idm-admin")
PASSWORD = os.environ.get("OPENIDM_IDM_TO_AM_PASSWORD", "supersecret123!")
AMADMIN_USERNAME = os.environ.get("GIDP_ADMIN_USERNAME", "amadmin")
AMADMIN_PASSWORD = os.environ.get("AM_PASSWORDS_AMADMIN_CLEAR", "changeit")
HEADER_USERNAME = os.environ.get("GIDP_HEADER_USERNAME", "X-OpenAM-Username")
HEADER_PASSWORD = os.environ.get("GIDP_HEADER_PASSWORD", "X-OpenAM-Password")
AM_COOKIE_NAME = os.environ.get("GIDP_COOKIE_NAME", "iPlanetDirectoryPro")
EMAIL = "idm@allinformatix.com"
GROUP_NAME = "GIDP ADMINS"
DS_SEARCH_ATTRIBUTE = "allinformatixID"

# -----------------------------------------
# Authenticate as amadmin
# -----------------------------------------
def get_am_token():
    url = f"{AM_URL}/json/realms/{REALM}/authenticate?authIndexType=service&authIndexValue=adminconsoleservice"
    headers = {
        HEADER_USERNAME: AMADMIN_USERNAME,
        HEADER_PASSWORD: AMADMIN_PASSWORD,
        "Content-Type": "application/json",
        "Accept-API-Version": "resource=2.1"
    }
    response = requests.post(url, headers=headers)
    response.raise_for_status()
    return response.json()["tokenId"]

# -----------------------------------------
# Check if user exists by UUID
# -----------------------------------------
def user_exists(token):
    url = f"{AM_URL}/json/realms/{REALM}/users?_queryFilter={DS_SEARCH_ATTRIBUTE}+eq+%22{USERNAME}%22"
    headers = {
        AM_COOKIE_NAME: token,
        "Accept-API-Version": "resource=3.0"
    }
    response = requests.get(url, headers=headers)
    response.raise_for_status()
    result = response.json()
    return len(result.get("result", [])) > 0

# -----------------------------------------
# Create user with UUID
# -----------------------------------------
def create_user(token):
    url = f"{AM_URL}/json/realms/{REALM}/users?_action=create"
    headers = {
        AM_COOKIE_NAME: token,
        "Content-Type": "application/json",
        "Accept-API-Version": "protocol=2.1,resource=3.0"
    }
    payload = {
        "username": USERNAME,
        "userpassword": PASSWORD,
        "mail": EMAIL,
        "givenName": "IDM",
        "sn": "Admin",
        DS_SEARCH_ATTRIBUTE: USERNAME
    }
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 409:
        print(f"[INFO] User '{USERNAME}' already exists.")
    else:
        response.raise_for_status()
        print(f"[OK] Created user '{USERNAME}'.")

# -----------------------------------------
# Create admin group with privileges
# -----------------------------------------
def create_group_with_privileges(token):
    url = f"{AM_URL}/json/realms/{REALM}/groups?_action=create"
    headers = {
        AM_COOKIE_NAME: token,
        "Content-Type": "application/json",
        "Accept-API-Version": "resource=1.0"
    }
    payload = {
        "username": GROUP_NAME
    }
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 409:
        print(f"[INFO] Group '{GROUP_NAME}' already exists.")
    else:
        response.raise_for_status()
        print(f"[OK] Created group '{GROUP_NAME}'.")

# -----------------------------------------
# Add user to group
# -----------------------------------------
def add_user_to_group(token):
    url = f"{AM_URL}/json/realms/{REALM}/groups/{GROUP_NAME}"
    headers = {
        AM_COOKIE_NAME: token,
        "Content-Type": "application/json",
        "Accept-API-Version": "resource=3.0"
    }
    payload = {
        "uniqueMember": [f"uid={USERNAME},ou=people,ou=identities"]
    }
    response = requests.put(url, headers=headers, json=payload)
    response.raise_for_status()
    print(f"[OK] Added user '{USERNAME}' to group '{GROUP_NAME}'.")

# -----------------------------------------
# Grant privileges to group
# -----------------------------------------
def set_group_privileges(token):
    url = f"{AM_URL}/json/realms/{REALM}/groups/{GROUP_NAME}"
    headers = {
        AM_COOKIE_NAME: token,
        "Content-Type": "application/json",
        "Accept-API-Version": "protocol=2.1,resource=4.0"
    }
    payload = {
        "_id": GROUP_NAME,
        "username": GROUP_NAME,
        "realm": "/",
        "universalid": [f"id={GROUP_NAME},ou=group,ou=am-config"],
        "members": {
            "uniqueMember": [USERNAME]
        },
        "cn": [GROUP_NAME],
        "privileges": {
            "EntitlementRestAccess": False,
            "ApplicationReadAccess": False,
            "ResourceTypeReadAccess": False,
            "PrivilegeRestReadAccess": False,
            "ApplicationTypesReadAccess": False,
            "SubjectAttributesReadAccess": False,
            "AgentAdmin": False,
            "PolicyAdmin": False,
            "LogRead": False,
            "SubjectTypesReadAccess": False,
            "CacheAdmin": False,
            "ConditionTypesReadAccess": False,
            "SessionPropertyModifyAccess": False,
            "LogWrite": False,
            "FederationAdmin": False,
            "PrivilegeRestAccess": False,
            "LogAdmin": False,
            "RealmReadAccess": False,
            "RealmAdmin": True,
            "ApplicationModifyAccess": False,
            "ResourceTypeModifyAccess": False,
            "DecisionCombinersReadAccess": False
        }
    }
    response = requests.put(url, headers=headers, json=payload)
    response.raise_for_status()
    print(f"[OK] Privileges assigned to group '{GROUP_NAME}'.")

# -----------------------------------------
# MAIN
# -----------------------------------------
if __name__ == "__main__":
    print("[INFO] Starting ForgeOps admin setup...")

    try:
        token = get_am_token()
        print("[OK] Got session token.")

        if user_exists(token):
            print(f"[INFO] User '{USERNAME}' already exists. Skipping creation.")
        else:
            print(f"[INFO] User '{USERNAME}' doesn't exist. Creating it!")
            create_user(token)

        create_group_with_privileges(token)
        add_user_to_group(token)
        set_group_privileges(token)

        print("[DONE] All steps completed successfully.")
    except Exception as e:
        print("[FATAL]", e)
        sys.exit(1)