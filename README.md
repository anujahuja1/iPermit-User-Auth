# iPermit-User-Auth

iPermit-User-Auth is a simple IBM i / AS400 modernization demo that accepts user authority input in **XML format** and returns the authority details in **JSON format** for modern applications.

## Project Flow

```txt
XML Input → RPG / Stored Procedure → DB2 User Authority Table → JSON Output
```

## Authority Levels

| Level | Authority Name  | Description                                         |
| ----- | --------------- | --------------------------------------------------- |
| 0     | No Authority    | User has no access                                  |
| 1     | Display Only    | User can only view data                             |
| 2     | Update Only     | User can update existing data                       |
| 3     | Add Edit Delete | User can add, edit, and delete records              |
| 4     | Super User      | User has all permissions and can manage other users |

## XML Input Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<UserAuthorityRequest>
    <UserId>USER001</UserId>
</UserAuthorityRequest>
```

## JSON Output Example

```json
{
  "status": "SUCCESS",
  "userId": "USER001",
  "authorityLevel": 1,
  "authorityName": "Display Only",
  "permissions": {
    "canView": true,
    "canUpdate": false,
    "canAdd": false,
    "canEdit": false,
    "canDelete": false,
    "canManageUsers": false
  }
}
```

## Super User Output Example

```json
{
  "status": "SUCCESS",
  "userId": "USER004",
  "authorityLevel": 4,
  "authorityName": "Super User",
  "permissions": {
    "canView": true,
    "canUpdate": true,
    "canAdd": true,
    "canEdit": true,
    "canDelete": true,
    "canManageUsers": true
  }
}
```

## Purpose

This project demonstrates how a legacy IBM i / AS400 system can accept XML-based input, process user authority through RPG and DB2, and provide JSON output for modern REST-based applications.
