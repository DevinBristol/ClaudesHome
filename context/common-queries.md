# Common SOQL Queries

## Account Queries
```sql
-- All accounts with basic info
SELECT Id, Name, Type, Industry, BillingCity, BillingState
FROM Account
LIMIT 100

-- Account count
SELECT COUNT() FROM Account

-- Accounts created this month
SELECT Id, Name, CreatedDate
FROM Account
WHERE CreatedDate = THIS_MONTH

-- Accounts by type
SELECT Type, COUNT(Id)
FROM Account
GROUP BY Type
```

## Contact Queries
```sql
-- Contacts with account info
SELECT Id, FirstName, LastName, Email, Account.Name
FROM Contact
LIMIT 100

-- Contacts without email
SELECT Id, FirstName, LastName, Account.Name
FROM Contact
WHERE Email = null
```

## Opportunity Queries
```sql
-- Open opportunities
SELECT Id, Name, StageName, Amount, CloseDate, Account.Name
FROM Opportunity
WHERE IsClosed = false
ORDER BY CloseDate ASC

-- Opportunities closing this month
SELECT Id, Name, StageName, Amount, CloseDate
FROM Opportunity
WHERE CloseDate = THIS_MONTH AND IsClosed = false

-- Won opportunities this year
SELECT Id, Name, Amount, CloseDate
FROM Opportunity
WHERE IsWon = true AND CloseDate = THIS_YEAR
```

## User Queries
```sql
-- Active users
SELECT Id, Name, Username, Profile.Name, IsActive
FROM User
WHERE IsActive = true

-- Users by profile
SELECT Profile.Name, COUNT(Id)
FROM User
WHERE IsActive = true
GROUP BY Profile.Name
```

## Debug Queries
```sql
-- Recent debug logs
SELECT Id, LogUser.Name, Operation, Status, LogLength, StartTime
FROM ApexLog
ORDER BY StartTime DESC
LIMIT 20

-- Async jobs status
SELECT Id, JobType, Status, NumberOfErrors, CreatedDate
FROM AsyncApexJob
WHERE CreatedDate = TODAY
ORDER BY CreatedDate DESC
```

## Metadata Queries (Tooling API)
```sql
-- Apex classes
SELECT Id, Name, Status, LengthWithoutComments
FROM ApexClass
ORDER BY Name

-- Apex triggers
SELECT Id, Name, TableEnumOrId, Status
FROM ApexTrigger
ORDER BY Name

-- Custom objects
SELECT Id, DeveloperName, Label
FROM CustomObject
```

---

## Usage
Run these queries using:
```powershell
.\scripts\data\query.ps1 -Query "SELECT Id, Name FROM Account LIMIT 10" -Org devin1
```
