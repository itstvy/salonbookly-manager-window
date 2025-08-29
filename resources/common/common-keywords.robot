*** Settings ***
Resource    ../../resources/common/common-settings.robot


*** Keywords ***
Open Salonbookly Window App
    &{caps}=    Create Dictionary
    ...    platformName=${PLATFORM_NAME}
    ...    automationName=${AUTOMATION_NAME}
    ...    app=${SALONBOOLY_DEV_APP}
    Open Application    ${REMOTE_URL}    &{caps}
    Get Source
Get and Log Source Salonbookly
    ${source_salonbookly}=    Get Source
    Log    Source Salonbookly:${source_salonbookly}

    