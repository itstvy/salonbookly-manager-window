*** Settings ***
Resource    ../../resources/common/common-settings.robot

*** Keywords ***
Open Salonbookly Window App
    &{caps}=    Create Dictionary
    ...    platformName=${PLATFORM_NAME}
    ...    automationName=${AUTOMATION_NAME}
    ...    app=${SALONBOOLY_DEV_APP}
    Open Application    ${REMOTE_URL}    &{caps}

Close Salonbookly
    Close Application