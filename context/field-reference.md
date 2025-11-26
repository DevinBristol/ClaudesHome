# Field Reference

## Standard Objects

### Account
| Field | API Name | Type | Notes |
|-------|----------|------|-------|
| Account Name | Name | String | Required |
| Account Type | Type | Picklist | |
| Industry | Industry | Picklist | |
| Billing Address | BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry | Address | |
| Shipping Address | ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry | Address | |
| Phone | Phone | Phone | |
| Website | Website | URL | |
| Owner | OwnerId | Lookup(User) | |

### Contact
| Field | API Name | Type | Notes |
|-------|----------|------|-------|
| First Name | FirstName | String | |
| Last Name | LastName | String | Required |
| Email | Email | Email | |
| Phone | Phone | Phone | |
| Account | AccountId | Lookup(Account) | |
| Mailing Address | MailingStreet, MailingCity, etc. | Address | |

### Opportunity
| Field | API Name | Type | Notes |
|-------|----------|------|-------|
| Opportunity Name | Name | String | Required |
| Account | AccountId | Lookup(Account) | |
| Stage | StageName | Picklist | Required |
| Close Date | CloseDate | Date | Required |
| Amount | Amount | Currency | |
| Probability | Probability | Percent | Auto-set by stage |
| Is Closed | IsClosed | Boolean | Calculated |
| Is Won | IsWon | Boolean | Calculated |

### Lead
| Field | API Name | Type | Notes |
|-------|----------|------|-------|
| First Name | FirstName | String | |
| Last Name | LastName | String | Required |
| Company | Company | String | Required |
| Status | Status | Picklist | Required |
| Email | Email | Email | |
| Is Converted | IsConverted | Boolean | |

### Case
| Field | API Name | Type | Notes |
|-------|----------|------|-------|
| Case Number | CaseNumber | Auto Number | |
| Subject | Subject | String | |
| Status | Status | Picklist | Required |
| Priority | Priority | Picklist | |
| Account | AccountId | Lookup(Account) | |
| Contact | ContactId | Lookup(Contact) | |

## Custom Objects
*Add your custom objects here*

### Object Name (API: Object_Name__c)
| Field | API Name | Type | Notes |
|-------|----------|------|-------|
| | | | |

---

## Quick Tips

### Date Literals
- `TODAY`, `YESTERDAY`, `TOMORROW`
- `THIS_WEEK`, `LAST_WEEK`, `NEXT_WEEK`
- `THIS_MONTH`, `LAST_MONTH`, `NEXT_MONTH`
- `THIS_QUARTER`, `LAST_QUARTER`, `NEXT_QUARTER`
- `THIS_YEAR`, `LAST_YEAR`, `NEXT_YEAR`
- `LAST_N_DAYS:30`, `NEXT_N_DAYS:7`

### Common Field Suffixes
- `__c` - Custom field
- `__r` - Relationship (for traversing)
- `__mdt` - Custom metadata type
- `__e` - Platform event
- `__x` - External object
