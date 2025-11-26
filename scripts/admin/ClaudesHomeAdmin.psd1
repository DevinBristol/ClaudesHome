@{
    RootModule = 'ClaudesHomeAdmin.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'ClaudesHome'
    CompanyName = 'Bristol'
    Copyright = '(c) 2025 Bristol. All rights reserved.'
    Description = 'Unified administration module for Five9, MS365, Salesforce, Company Cam, and Google Workspace'
    PowerShellVersion = '5.1'

    # Required modules
    RequiredModules = @()

    # Functions to export
    FunctionsToExport = @(
        # Connection
        'Connect-AllPlatforms',
        'Get-ConnectionStatus',
        'Connect-Five9',
        'Connect-MS365',
        'Connect-Salesforce',
        'Connect-GoogleWorkspace',
        'Test-CompanyCamConnection',

        # Unified
        'New-UniversalUser',
        'Disable-UniversalUser',
        'Reset-UniversalPassword',
        'New-RandomPassword',

        # Five9
        'Get-Five9Users',
        'New-Five9Agent',
        'Reset-Five9UserPassword',
        'Disable-Five9User',
        'Enable-Five9User',
        'Get-Five9Campaigns',
        'Start-Five9Campaign',
        'Stop-Five9Campaign',
        'Get-Five9ANIs',
        'Set-Five9ANIStatus',
        'Get-Five9Skills',
        'Add-Five9UserSkill',
        'Remove-Five9UserSkill',

        # MS365
        'Get-MS365Users',
        'Get-MS365User',
        'New-MS365User',
        'Reset-MS365UserPassword',
        'Disable-MS365User',
        'Enable-MS365User',
        'Get-MS365Groups',
        'Get-MS365GroupMembers',
        'Add-MS365GroupMember',
        'Remove-MS365GroupMember',
        'Get-MS365UserMail',
        'Send-MS365Mail',

        # Salesforce
        'Get-SalesforceUsers',
        'Get-SalesforceUser',
        'New-SalesforceUser',
        'Reset-SalesforceUserPassword',
        'Disable-SalesforceUser',
        'Enable-SalesforceUser',
        'Invoke-SalesforceQuery',
        'Invoke-SalesforceAPI',
        'Get-SalesforceProfiles',
        'Get-SalesforcePermissionSets',
        'Get-SalesforceUserPermissionSets',
        'Add-SalesforcePermissionSetAssignment',
        'Get-SalesforceOrgLimits',

        # Company Cam (reads)
        'Get-CompanyCamProjects',
        'Get-CompanyCamProject',
        'Search-CompanyCamProjects',
        'Get-CompanyCamPhotos',
        'Get-CompanyCamPhoto',
        'Get-CompanyCamComments',
        'Get-CompanyCamUsers',
        'Get-CompanyCamCurrentUser',
        'Get-CompanyCamTags',
        'Get-CompanyCamProjectsByTag',

        # Company Cam (writes via SF)
        'New-CompanyCamProject',
        'Update-CompanyCamProject',
        'Add-CompanyCamComment',
        'Sync-CompanyCamData',

        # Helpers
        'Send-ClaudeResponse',

        # Google
        'Get-GoogleUsers',
        'Get-GoogleUser',
        'New-GoogleUser',
        'Reset-GoogleUserPassword',
        'Suspend-GoogleUser',
        'Resume-GoogleUser',
        'Get-GoogleUserAliases',
        'Add-GoogleUserAlias',
        'Get-GoogleGroups',
        'Get-GoogleGroup',
        'New-GoogleGroup',
        'Get-GoogleGroupMembers',
        'Add-GoogleGroupMember',
        'Remove-GoogleGroupMember',
        'Get-GoogleOrgUnits',
        'Move-GoogleUserToOU',
        'Get-GoogleUserLicenses',
        'Get-GoogleLicenses'
    )

    # Cmdlets to export
    CmdletsToExport = @()

    # Variables to export
    VariablesToExport = @()

    # Aliases to export
    AliasesToExport = @()

    # Private data
    PrivateData = @{
        PSData = @{
            Tags = @('Admin', 'Five9', 'MS365', 'Salesforce', 'CompanyCam', 'Google', 'Workspace')
            ProjectUri = 'https://github.com/your-repo/ClaudesHome'
        }
    }
}
