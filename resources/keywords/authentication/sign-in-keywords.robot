*** Settings ***
Resource    ../../../resources/common/common-settings.robot

*** Keywords ***
system displays Sign in screen
    Wait Until Element Is Visible    ${SIGN_IN_FORM_TITLE}    5s

user input correct data in User name field
    Wait Until Element Is Visible    ${USER_NAME_FIELD}
    Click Element    ${USER_NAME_FIELD}
    Input Text    ${USER_NAME_FIELD}    ${CORRECT_SALON_EMAIL}

user input correct data in Password field
    Wait Until Element Is Visible    ${PASSWORD_FIELD}
    Click Element    ${PASSWORD_FIELD}
    Input Text    ${PASSWORD_FIELD}    ${CORRECT_SALON_PASSWORD}

user click on Sign In button
    Wait Until Element Is Visible    ${SIGN_IN_BUTTON}
    Click Element    ${SIGN_IN_BUTTON}
    Sleep    5s

system sign in successfully and navigate user to Checkout screen
    Wait Until Element Is Visible    ${CHECKOUT_TAB}
