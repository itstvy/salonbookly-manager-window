*** Settings ***
Resource    ../../resources/common/common-settings.robot
Suite Setup    Open Salonbookly Window App
Suite Teardown    Close Salonbookly

*** Test Cases ***
Verify the Salon user sign in successfully when input correct account in Sign In form
    [Tags]    Positive    UI
    Given system displays Sign in screen
    When user input correct data in User name field
    And user input correct data in Password field
    And user click on Sign In button
    Then system sign in successfully and navigate user to Checkout screen
    
