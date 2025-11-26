# Salesforce Org Analysis - Deep Dive Report

**Generated:** 2025-11-26
**Source:** /mnt/c/Users/devin/IdeaProjects/salesforce-org-analysis

---

## PROJECT OVERVIEW

**Location**: /mnt/c/Users/devin/IdeaProjects/salesforce-org-analysis
**Purpose**: Production Salesforce org export + development framework for Bristol Windows Inc
**Scale**: 340 Apex classes (~21,630 LOC), 68 flows, 25 custom objects, 45 permission sets

---

## MAJOR FUNCTIONAL SYSTEMS

### 1. FIVE9 INTEGRATION (PRODUCTION-ACTIVE)
Complete working system for dialer/CRM integration:

**Webhook Receiver** - `force-app/main/default/classes/Five9Webhook.cls` (204 LOC)
- REST API endpoint (`@RestResource(UrlMapping='/Five9Webhook')`)
- Receives call events from Five9 via POST
- Creates `Call_Log__c` records with full call metadata
- HMAC-SHA256 authentication via shared secret (metadata-driven)
- Error handling with proper HTTP status codes (200/401/501/502)

**Report Manager** - `Five9ReportManager.cls` (589 LOC + 504 LOC tests)
- Integrates Five9 data into Salesforce Einstein Analytics
- Creates/updates datasets with dynamic metadata
- Implements Queueable + Database.AllowsCallouts
- Multiple constructors for different operation modes (create new, update existing)
- Handles polling and scheduling

**Voice Call Processing** - `Five9API.cls` (251 LOC)
- Task->VoiceCall conversion pipeline
- Five9 session management (login, recording retrieval)
- Audio job queue integration
- Full test coverage

**Report Scheduler** - `Five9ReportScheduler.cls` + `RecipeRunner.cls`
- Implements Schedulable for recurring jobs
- Wave recipe execution and polling

**Related Classes**: Five9Helper, Five9Response, Five9ReportRetriever, Five9ResponseTests

### 2. ANI (PHONE NUMBER) ASSIGNMENT SYSTEM (PRODUCTION-READY)
Geographic-based outbound phone assignment for lead calling:

**Queueable Implementation** - `AniAssigner.cls` (345 LOC)
- Complex city normalization and mapping
- County->City->ANI hierarchy navigation
- Load-balanced phone assignment (round-robin distribution)
- Fallback to default county (Douglas, NE) for unmatched locations
- Extensive debug logging for troubleshooting

**Batch Implementation** - `AniAssignerBatchable.cls` (193 LOC)
- Database.Batchable + Database.Stateful
- Campaign-based ANI assignment
- Stateful error tracking (badCities set)
- Finish method re-applies Five9 list source

**Test Coverage**:
- `AniAssignerTest.cls` (616 LOC) - comprehensive test suite
- `AniAssignerBatchableTest.cls` (203 LOC)

**Supporting Classes**: AniBatchAssigner, BatchAbleAniHelper

**Total**: ~1,357 LOC for complete geographic phone assignment

### 3. COMPANYCAM INTEGRATION (COMPLETE)
Photo/document management synchronization:

**API Integration** - `CompanyCamAPI.cls`
- Links CompanyCam projects to Salesforce Opportunities
- Syncs photos/comments via topic assignments
- User management integration
- @InvocableMethod for Flow integration

**OAuth2 Authentication** - `CompanyCamAuthService.cls` + `CompanyCamAuthController.cls`
- REST endpoint for OAuth callback
- Bearer token management
- Refresh token handling

### 4. CALL LOGGING INFRASTRUCTURE (ACTIVE)
**`Call_Log__c` Custom Object**
- Receives data from Five9Webhook
- Full call metadata tracking
- Call recordings, agent assignment, timing
- Ready for analytics and reporting

### 5. AUDIO/RECORDING PROCESSING (FUNCTIONAL)
**AudioJobManager.cls** (46 LOC)
- Job queue management for voice processing
- Status tracking (Completed, Failed)
- Next job firing

**AudioScavengeBatch.cls** (63 LOC)
- Batch processor for audio files
- Callout capability for file retrieval
- Includes tests

### 6. EINSTEIN ANALYTICS INTEGRATION (ADVANCED)
**RecipeRunner.cls**
- Salesforce Wave recipe execution via API
- Dynamic scheduling with polling
- Supports manual and automatic intervals

**AnalyticsUtility.cls**
- Dataset creation and metadata JSON generation
- Complex field mapping and transformation

### 7. FLOW AUTOMATION (68 PRODUCTION FLOWS)
Major Production Flows:

- `New_Call_Back_on_Account.flow-meta.xml` - Complex decision trees, formulas, screen interactions
- `Action_Campaign_Refresh_ANI_s.flow` - Campaign ANI batch refresh
- `Action_Change_Visit_Time.flow` - Service appointment rescheduling
- `AutoLaunch_WorkOrderFromVisit.flow` - Auto work order creation
- `CompanyfieldAutofill.flow` - Auto company population
- `Fast_Action_Reformat_Contact_Phones.flow` - Phone normalization
- `List_Button_Lead_Deleter.flow` - Bulk lead deletion
- `Link_CompanyCam_With_Opportunity.flow` - CompanyCam sync

**Patterns**: Dynamic choice sets, decision logic, record operations, screen-based actions

### 8. TRIGGER HANDLERS (10 TRIGGERS)
All use handler/helper pattern:
- AccountTrigger, ContactTrigger, LeadTrigger, OpportunityTrigger
- ServiceAppointmentTrigger, WorkOrderTrigger, PropertyTrigger
- PhoneNumberTrigger, TaskTrigger, AccountContactRelationTrigger

### 9. CUSTOM OBJECTS (25 TOTAL)
Core Domain Objects:
1. **ANI__c** - Outbound phone numbers with geographic assignment
2. **Call_Log__c** - Five9 call logging (receives webhook data)
3. **AudioProcessingJob__c** - Voice job queue
4. **County__c & City__c** - Geographic hierarchy for ANI assignment
5. **Property__c** - Job/property information (links to opportunities, service appointments)
6. **PhoneNumber__c & PhonePersonRelationship__c** - Phone directory/normalization
7. **Company_Cam_Bearer_Token__c** - OAuth token storage
8. **IntegratedDatasetConfig__c** - Einstein Analytics metadata
9. **Webhook_Config__mdt & Webhook_Secrets__c** - Webhook infrastructure
10. **Five9Reporter_Setting__mdt** - Five9 webhook config with secret
11. **RecipeRunnerSchedulable_Setting__mdt** - Wave recipe scheduling
12. **Process_Switches__c** - Feature flags
13. **Campaign_Daily_Totals__c** - Analytics aggregation
14. **Service_Appointment_Config__mdt** - FSL configuration

---

## CONTROLLER & SERVICE CLASSES
- **AppointmentCalendarController.cls** - Complex appointment wrapper with formatting
- **AccountDisplayController/Service** - Account display logic
- **PropertyService.cls** - Property/job management
- **ChangePasswordController/Service** - User password management
- **LWCHelperFunctions.cls** - LWC utilities

---

## REST API ENDPOINTS
1. `/Five9Webhook` - Five9 call event receiver
2. `/CompanyCamAuth` - OAuth callback handler

---

## TEST COVERAGE
**55 Test Classes** (17% of total)
- Five9: APITest (190), ReportManagerTest (504), ResponseTests (123), RetrieverTest (62)
- ANI: AniAssignerTest (616), AniAssignerBatchableTest (203)
- Audio: AudioJobManagerTest (72), AudioScavengeBatchTest (65)
- Other: AppointmentCalendarControllerTest, ChangePasswordControllerTest, BinaryFileTest, etc.

---

## WHAT'S SCAFFOLDING / EMPTY
1. **Scripts folder** - Only placeholder templates (hello.apex, account.soql)
2. **Node.js tools** - Config files only (Jest, ESLint, Prettier) - no actual scripts
3. **Python** - None found
4. **AccountService.cls** - Empty class (3 LOC)
5. **LWCHelperFunctions.cls** - Minimal utility (11 LOC)

---

## ARCHITECTURE STRENGTHS
1. **Separation of Concerns** - Trigger handler pattern, service layers, controller separation
2. **Async Processing** - Queueable + Batch patterns for long-running operations
3. **Integration Security** - HMAC-SHA256 auth, metadata-driven secrets, token storage
4. **Metadata-Driven Config** - Custom metadata types for runtime settings
5. **Error Handling** - Try-catch in async contexts, job status tracking
6. **Test Coverage** - Critical paths tested (Five9, ANI assignment)

---

## HIDDEN GEMS & PRODUCTION SYSTEMS
Most valuable/complex code:
1. **AniAssignerBatchable** (193 LOC) - Geographic phone assignment is sophisticated
2. **Five9ReportManager** (589 LOC + 504 tests) - Complex Einstein Analytics integration
3. **Five9Webhook** (204 LOC) - Secure webhook with HMAC auth
4. **CompanyCamAPI** - Complete OAuth + API integration
5. **RecipeRunner** - Salesforce Wave recipe orchestration
6. **AppointmentCalendarController** - Complex data transformation and formatting

**Total Functional Lines**: ~3,941 LOC in Five9, ANI, and Audio classes alone

---

## CONCLUSION
This is **NOT** a scaffolding project. It's a **mature, production-active Salesforce implementation** with:
- Complete Five9 integration (webhook + reporting)
- Sophisticated ANI assignment system
- CompanyCam synchronization
- 68 automation flows
- 25 custom objects modeling the window business domain
- Einstein Analytics integration
- Comprehensive test coverage for critical paths

The project is ready for extension and development. The "scripts" folder is just incomplete - the actual work is in the Apex/Flow layer, which is extensive and production-ready.
