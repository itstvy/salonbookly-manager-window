# 🪟🤖 Robot Framework + AppiumLibrary + WinAppDriver Cheat Sheet

> 🎯 **Mục tiêu:** Thực hành Automation Test cho **Windows Flutter Desktop App** bằng **Robot Framework** với **AppiumLibrary**, **WinAppDriver**, **Appium Inspector**.

---

## ⚙️ 1. Thiết lập cơ bản

```robot
*** Settings ***
Library    AppiumLibrary
Suite Setup    Open My App
Suite Teardown    Close All Applications

*** Variables ***
${REMOTE_URL}         http://127.0.0.1:4723
${APP_PATH}           C:/apps/MyFlutterApp/MyFlutterApp.exe

*** Keywords ***
Open My App
    Open Application    ${REMOTE_URL}
    ...  platformName=Windows
    ...  deviceName=WindowsPC
    ...  app=${APP_PATH}
    ...  newCommandTimeout=120
    ...  ms:waitForAppLaunch=10
    Set Appium Timeout   10 seconds
```

💡 Nhớ chạy **WinAppDriver.exe** hoặc **Appium Server** trước.

---

## 🔍 2. Locator Strategy (XPath/Locator)

| 🔑 Thuộc tính   | 📌 Mô tả                               | 🌟 Ưu tiên         |
| --------------- | -------------------------------------- | ------------------ |
| `@AutomationId` | ID nội bộ UI                           | ⭐⭐⭐ (ổn định nhất) |
| `@Name`         | Text hiển thị / Accessible name        | ⭐⭐                 |
| `@ClassName`    | Kiểu control: `Button`, `Edit`, `Text` | ⭐                  |
| `@ControlType`  | Loại control                           | ⭐ (ít dùng)        |

### 📚 Mẫu XPath hay dùng

```xpath
//*[@AutomationId='loginButton']                 
//*[@Name='Login']                               
//*[@ClassName='Edit' and @AutomationId='email']
//Window[@Name='My App']//*[@Name='Settings']    
//*[@Name[normalize-space(.)='First name is required.']]
//*[starts-with(@Name,'Email')]
//*[contains(@Name,'required')]
```

### 🔗 Tương đối theo Label

```xpath
//*[@ClassName='Text' and normalize-space(@Name)='Email']
/following::*[@ClassName='Edit'][1]
```

---

## ⌨️ 3. Keywords hữu ích (AppiumLibrary)

### ⏳ Wait

* `Wait Until Element Is Visible    xpath=...    10s`
* `Wait Until Page Contains Element    xpath=...    10s`

### 🖱️ Action

* `Click Element    xpath=...`
* `Input Text       xpath=...    value`
* `Clear Element Text    xpath=...`
* `Send Keys        xpath=...    CTRL+A`
* `Send Keys        xpath=...    DELETE`

### 🔎 Inspect

* `Get Webelement`
* `Get Element Attribute    xpath=...    Name`

### 🪟 Windows/Dialog

* `Get Window Handles`
* `Switch To Window    <handle>`
* `Switch To Active Application`

### 🖼️ Debug

* `Capture Page Screenshot`
* `Set Appium Timeout    10 seconds`

---

## 📝 4. Công thức Clear Text an toàn

```robot
Click Element    ${LOCATOR}
Send Keys        ${LOCATOR}    CTRL+A
Send Keys        ${LOCATOR}    DELETE
Input Text       ${LOCATOR}    New value
```

🚫 Tránh viết `CTRL+A+DELETE` chung một lệnh.

---

## ✅ 5. Test Case mẫu: Validate Required Field

```robot
*** Variables ***
${TXT_EMAIL}        xpath=//*[@AutomationId='email'] | //*[@ClassName='Edit'][1]
${BTN_LOGIN}        xpath=//*[@AutomationId='loginButton'] | //*[@Name='Login']
${MSG_EMAIL_REQ}    xpath=//*[normalize-space(@Name)='Email is required.']

*** Test Cases ***
Login - Validate Required Email
    Click Element     ${TXT_EMAIL}
    Send Keys         ${TXT_EMAIL}    CTRL+A
    Send Keys         ${TXT_EMAIL}    DELETE
    Click Element     ${BTN_LOGIN}
    Wait Until Page Contains Element    ${MSG_EMAIL_REQ}    5s
    Capture Page Screenshot
```

---

## 🕵️ 6. Tips Appium Inspector (Windows)

* 🔎 Ưu tiên tìm **AutomationId**.
* 👀 Kiểm tra `Name` trong Inspector (đôi khi khác text UI).
* ⏱️ Nếu "thấy trên Inspector nhưng test fail":

  1. Tăng timeout
  2. `Switch To Window` nếu là dialog mới
  3. Kiểm tra overlay che element

---

## 💡 7. Best Practices

1. 🚀 Ưu tiên `AutomationId`
2. 🙅 Tránh index `[1]` trừ khi bắt buộc
3. 🧹 Dùng `normalize-space()` tránh khoảng trắng
4. 🔗 Chain theo label → input
5. 📦 Đặt locators vào **Resource File**

```robot
*** Variables ***
${LBL_EMAIL}        xpath=//*[@ClassName='Text' and normalize-space(@Name)='Email']
${TXT_EMAIL}        xpath=${LBL_EMAIL}/following::*[@ClassName='Edit'][1]
${BTN_LOGIN}        xpath=//*[@AutomationId='loginButton'] | //*[@Name='Login']
```

---

## 🪟 8. Multi-Window/Dialog Handling

```robot
${handles}=    Get Window Handles
FOR    ${h}    IN    @{handles}
    Switch To Window    ${h}
    ${exists}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[@Name='Confirm']    0.5s
    Exit For Loop If    ${exists}
END
```

---

## 🐞 9. Khi Inspector thấy nhưng Robot không thấy

* ⏳ Dùng `Wait Until Element Is Visible`
* 🔍 `Get Webelement` để check `enabled/clickable`
* 📸 Debug bằng screenshot
* 🛡️ Kiểm tra quyền chạy (WinAppDriver & App cùng level: admin/non-admin)

---

✨ Bạn chỉ cần copy file `.md` này là có đủ 🎨 icon + màu + code block đẹp.

👉 Bạn muốn mình làm thêm **phiên bản có highlight màu code (syntax + badge UI)** không?
