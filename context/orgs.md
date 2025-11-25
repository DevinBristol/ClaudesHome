# Salesforce Org Reference

## Production
- **Alias**: BristolProd
- **Username**: devinobrien17@gmail.com
- **Org ID**: 00DHs000001vIB2MAM
- **Type**: Production / DevHub
- **Status**: Connected
- **Notes**: Primary production org. Exercise extreme caution with any changes.

## Sandboxes

### PartialCopy
- **Alias**: PartialCopy
- **Username**: devinobrien17@gmail.com.partial
- **Org ID**: 00DRT000002CAIb2AO
- **Type**: Partial Copy Sandbox
- **Status**: Connected
- **Notes**: Contains subset of production data. Good for testing with realistic data.

### Devin1 (Primary Dev)
- **Alias**: devin1
- **Username**: devinobrien17@gmail.com.devin1
- **Org ID**: 00DRT000009LyyT2AS
- **Type**: Developer Sandbox
- **Status**: Connected
- **Notes**: Primary development sandbox. Safe for experimentation.

### Devin2
- **Alias**: Devin2
- **Username**: devinobrien17@gmail.com.devin2
- **Org ID**: 00DRT000009Lywr2AC
- **Type**: Developer Sandbox
- **Status**: Connected
- **Notes**: Secondary development sandbox.

### Devin3
- **Alias**: Devin3
- **Username**: devinobrien17@gmail.com.devin3
- **Org ID**: 00DRT000009Lz052AC
- **Type**: Developer Sandbox
- **Status**: Connected
- **Notes**: Tertiary development sandbox.

### Developing
- **Alias**: Developing
- **Username**: devinobrien17@gmail.com.developing
- **Org ID**: 00DSu000000RlSfMAK
- **Type**: Developer Sandbox
- **Status**: Connected
- **Notes**: Additional development sandbox.

### FullCopy (Inactive)
- **Alias**: FullCopy
- **Username**: devinobrien17@gmail.com.fullcopy
- **Org ID**: 00DU800000571vpMAA
- **Type**: Full Copy Sandbox
- **Status**: **Inactive - Needs Re-authentication**
- **Notes**: Run `sf org login web -a FullCopy` to re-authenticate.

## Scratch Org

### myDevOrg
- **Alias**: myDevOrg
- **Username**: devin@wise-raccoon-225ghj.com
- **Org ID**: 00Dbm000001jbnfEAA
- **Type**: Scratch Org
- **Status**: Connected
- **Notes**: Ephemeral scratch org. Will expire.

## Quick Reference

| Use Case | Recommended Org |
|----------|-----------------|
| Quick testing/development | devin1 |
| Testing with prod-like data | PartialCopy |
| Isolated feature development | Devin2 or Devin3 |
| Production deployment | BristolProd (with validation first!) |
