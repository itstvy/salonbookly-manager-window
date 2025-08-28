*** Settings ***
Resource    ../../../resources/common/common-settings.robot

*** Variables ***
#Data Sign in account
${CORRECT_SALON_EMAIL}    vywindow@yopmail.com
${CORRECT_SALON_PASSWORD}    Dev123!@#

#Sign in elements
${SIGN_IN_FORM_TITLE}    xpath=//Text[@Name='Sign In'][1]
${USER_NAME_FIELD}    xpath=//Text[@Name='User Name']/following::Edit[@Name='Enter your username']
${PASSWORD_FIELD}    xpath=//Text[@Name='Password']/following::Edit[@Name='Enter your password']
${SIGN_IN_BUTTON}    xpath=//Text[@Name='Sign In'][2]

#Checkout tab in Main screen
${CHECKOUT_TAB}    xpath=//Text[@Name='Checkout']