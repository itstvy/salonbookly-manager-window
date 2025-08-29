# 🪟 Robot Framework Windows App – Keyword & Locator Guide (AppiumLibrary + WinAppDriver)

> **Mục tiêu**: Tài liệu “cheat‑sheet + hướng dẫn chi tiết” bằng tiếng Việt cho tự động hoá Windows App với **Robot Framework + AppiumLibrary** (WinAppDriver). Bao gồm: cài đặt nhanh, công cụ bắt locator, công thức XPath/locator phổ biến, **keywords** quan trọng (từ cơ bản → nâng cao) và ví dụ test case.

---

## 📚 Mục lục

1. [Bối cảnh & Thiết lập nhanh](#-bối-cảnh--thiết-lập-nhanh)
2. [Công cụ bắt locator & phân tích UI](#-công-cụ-bắt-locator--phân-tích-ui)
3. [Chiến lược Locator & Công thức XPath](#-chiến-lược-locator--công-thức-xpath)
4. [Keywords “vàng” theo chủ đề + ví dụ](#-keywords-vàng-theo-chủ-đề--ví-dụ)

   * 4.1. Phiên/App (mở/đóng/chuyển, timeout, debug)
   * 4.2. Tìm kiếm & Chờ đợi phần tử
   * 4.3. Tương tác nhập liệu/nhấn/phím tắt
   * 4.4. Thuộc tính phần tử & xác minh
   * 4.5. Modal/Top-level Window/Attach theo handle
   * 4.6. List/ComboBox, Menu, Table/Grid
   * 4.7. Checkbox/Radio/Toggle
   * 4.8. Ảnh chụp màn hình & nguồn UI
5. [Mẫu từ điển Locator & Keywords tái dùng](#-mẫu-từ-điển-locator--keywords-tái-dùng)
6. [Mẹo chống flake & xử lý lỗi thường gặp](#-mẹo-chống-flake--xử-lý-lỗi-thường-gặp)
7. [Phụ lục: Template bộ khung Test Suite](#-phụ-lục-template-bộ-khung-test-suite)

---

## 🚀 Bối cảnh & Thiết lập nhanh

### ✅ Thành phần

* **Robot Framework** + **AppiumLibrary**
* **Appium Server** (hoặc Appium 2 + appium-windows-driver) **hoặc** **WinAppDriver** (cổng mặc định `4723`).
* **Windows App** (.exe/UWP) bạn cần test.

### ⚙️ Desired Capabilities (Windows)

* `platformName=Windows`
* `deviceName=WindowsPC`
* `app` = đường dẫn `.exe` **hoặc** AppId UWP **hoặc** `Root` (để attach)
* (Tuỳ chọn) `ms:waitForAppLaunch=10` (nếu app nặng)
* (Nâng cao) `appTopLevelWindow` (để attach theo Window handle, dạng hex)

**Ví dụ mở app**

```robot
*** Settings ***
Library    AppiumLibrary

*** Variables ***
${REMOTE_URL}    http://127.0.0.1:4723

*** Test Cases ***
Open My App
    Open Application    ${REMOTE_URL}
    ...    platformName=Windows
    ...    deviceName=WindowsPC
    ...    app=C:\\Apps\\MyApp\\MyApp.exe
    Set Appium Timeout    10s
```

> 💡 **Ghi chú**: Nếu mở qua **shortcut (.lnk)**, nên chạy PowerShell `Start-Process` để khởi động app rồi `Open Application` với `app=Root` và **attach** vào top-level window bằng handle (xem phần 4.5).

---

## 🔎 Công cụ bắt locator & phân tích UI

> Không chỉ Appium Inspector. Dưới đây là các lựa chọn bạn có thể dùng song song để soi **AutomationId/Name/ClassName**, cấu trúc UIA, runtime tree:

* **Appium Inspector**: Kết nối Appium/WinAppDriver để duyệt cây UI, copy XPath/locator nhanh.
* **Windows SDK – Inspect.exe**: Công cụ chuẩn của Microsoft để xem thuộc tính **UI Automation** (Name, AutomationId, ClassName, ControlType, Patterns…). Rất hữu ích khi Appium Inspector không hiển thị đủ.
* **Accessibility Insights for Windows**: Tool hiện đại của Microsoft kiểm tra accessibility & UIA tree.
* **FlaUInspect (FlaUI)**: Inspector mã nguồn mở, hiển thị đầy đủ UIA properties/patterns.
* **WinAppDriver UI Recorder (legacy/sample)**: Gợi ý bước thao tác + XPath (tham khảo, không nên phụ thuộc 100%).
* **Spy++** (Visual Studio): Xem handle cửa sổ/Win32 message (bổ trợ khi cần handle, không có UIA props).

> 🧭 **Kinh nghiệm**: Khi 1 công cụ không lộ `AutomationId`, hãy cross-check bằng **Inspect.exe** hoặc **FlaUInspect**. Chọn locator ổn định dựa trên `AutomationId` → `Name` → `ClassName` → cuối cùng mới tới `xpath`.

---

## 🧭 Chiến lược Locator & Công thức XPath

### Thứ tự ưu tiên locator (ổn định → ít ổn định)

1. **accessibility\_id** ↔ `AutomationId`  ✅ ổn định nhất
2. **name** ↔ `Name`  (dễ thay đổi do i18n/UI copy)
3. **class name** ↔ `ClassName` (thường trùng nhiều phần tử)
4. **xpath**  (dùng khi 1–3 không đủ, viết ngắn/chống vỡ)

### Locator ví dụ

```robot
# Accessibility ID (nên ưu tiên)
Click Element    accessibility_id=username
Input Text       accessibility_id=password    Secret123

# Name (fallback tốt nếu text cố định)
Click Element    name=Sign in

# Class name (kết hợp ràng buộc khác nếu cần)
Click Element    class_name=Button

# XPath (neo theo container cha để ổn định)
Click Element    xpath=//Window[@Name='Login']//Edit[@AutomationId='username']
```

### Công thức XPath “chuẩn Windows UIA”

```xpath
//Window[@Name='Login']//Edit[@AutomationId='username']                 
//Button[@Name='Sign in']                                              
//Pane[@AutomationId='MainPanel']//Text[starts-with(@Name,'Total')]     
(//Edit[@ClassName='TextBox'])[1]                                       
//Edit[@AutomationId='first_name']/following-sibling::Text[
  normalize-space(@Name)='First name is required.'
]
```
//*[@AutomationId='loginButton']                 # Ổn định nhất
//*[@Name='Login']                               # Theo text/tên hiển thị
//*[@ClassName='Edit' and @AutomationId='email'] # Input email
//Window[@Name='My App']//*[@Name='Settings']    # Nằm trong 1 cửa sổ cụ thể
//Pane//*[@AutomationId='password']/following::*[@ClassName='Button'][1]
(//*[@ClassName='Edit'])[1]                      # Chỉ số nếu buộc phải
//*[@Name[normalize-space(.)='First name is required.']]
//*[starts-with(@Name,'Email')]                  # bắt đầu bằng
//*[contains(@Name,'required')]                  # chứa chuỗi

Khi Flutter Desktop không expose AutomationId

Bật Semantics/accessibility trong app (yêu cầu dev).

Nếu vẫn “câm lặng”, bám @Name/cấu trúc tổ tiên-hậu duệ (ancestor/descendant).

Tránh following-sibling:: vì cây UIA đôi khi không coi “sibling” như bạn thấy trên UI; dùng following::*[1] linh hoạt hơn.

**Mẹo XPath**

* Dùng `normalize-space(@Name)` để bỏ khoảng trắng thừa.
* Xác định **container cha** (Window/Pane/Group) có `AutomationId`/`Name` rõ → neo XPath vào đó.
* Với **validation/label** cạnh input: dùng `following-sibling::` / `preceding-sibling::`. Nếu thông báo nằm sâu: `ancestor::` để vươn lên vùng chung.
* Tránh XPath tuyệt đối dài; hạn chế index `[1]` nếu có thể.

### Bắt validation/tooltip – công thức thường dùng

* **Validation cạnh input**

```xpath
//Edit[@AutomationId='first_name']/following-sibling::Text[
  normalize-space(@Name)='First name is required.'
]
```

* **Validation trong vùng form**

```xpath
//Pane[@AutomationId='UserForm']//Text[contains(@Name,'required')]
```

* **Tooltip hệ thống** (ControlType=`ToolTip`/`Text`)

```xpath
//ToolTip//Text[contains(@Name,'Invalid')]
```

> 🔁 **Trigger hiển thị validation**: xoá text → rời focus (click vùng trống hoặc `Press Keys TAB`) → `Wait Until Page Contains Element`.

---

## 🧩 Keywords “vàng” theo chủ đề + ví dụ

> **Lưu ý**: Các keyword dưới thuộc **AppiumLibrary** (trừ khi ghi chú khác). Không nhầm với `Browser.` (Playwright) hay `SeleniumLibrary.`. Nếu thấy lỗi kiểu *“No keyword with name 'Browser.Press Keys' found”* → bạn đang gọi nhầm library.

### 4.1. Phiên/App (mở/đóng/chuyển, timeout, debug)

**Open Application** – mở phiên Appium

```robot
Open Application    ${REMOTE_URL}    platformName=Windows    deviceName=WindowsPC    app=C:\\Apps\\MyApp.exe
```

**Close Application** – đóng phiên hiện tại

```robot
Close Application
```

**Switch Application** – chuyển phiên (khi mở nhiều app/phiên)

```robot
${id}=    Open Application    ${REMOTE_URL}    platformName=Windows    deviceName=WindowsPC    app=Root
# ... thao tác
Switch Application    ${id}
```

**Set Appium Timeout** – timeout mặc định cho lệnh chờ/tìm

```robot
Set Appium Timeout    10s
```

**Get Source / Log Source** – lấy/dump cây UI để soi locator

```robot
${xml}=    Get Source
Log    ${xml}
```

**Capture Page Screenshot** – chụp ảnh màn hình (debug, bằng chứng)

```robot
Capture Page Screenshot    logs/snap_${TEST NAME}.png
```

### 4.2. Tìm kiếm & Chờ đợi phần tử

**Wait Until Page Contains Element** – chờ phần tử có trong DOM/UI tree

```robot
Wait Until Page Contains Element    xpath=//Button[@Name='Sign in']    10s
```

**Wait Until Element Is Visible** – chờ phần tử visible

```robot
Wait Until Element Is Visible    accessibility_id=username    10s
```

**Page Should Contain Element** – xác minh tồn tại (hard assert)

```robot
Page Should Contain Element    accessibility_id=MainPanel
```

**Get Webelements** – lấy danh sách phần tử (để đếm/chọn)

```robot
@{rows}=    Get Webelements    xpath=//List[@AutomationId='UserList']//ListItem
Should Be True    ${len(${rows})} > 0
```

**Get Element Attribute** – đọc thuộc tính UIA

```robot
${val}=    Get Element Attribute    accessibility_id=first_name    Value.Value
Should Be Equal    ${val}    John
```

> 🔎 **Thuộc tính hay dùng**: `Name`, `AutomationId`, `ClassName`, `IsEnabled`, `IsOffscreen`, `Value.Value`, `Toggle.ToggleState`, `SelectionItem.IsSelected`…

### 4.3. Tương tác nhập liệu/nhấn/phím tắt

**Click Element** – nhấn nút/ô

```robot
Click Element    name=Sign in
```

**Input Text** – nhập chuỗi

```robot
Input Text    accessibility_id=first_name    Anna
```

**Clear Text** – xoá nội dung input (nếu control hỗ trợ)

```robot
Clear Text    accessibility_id=first_name
```

**Press Keys** – gửi phím/phím tắt

```robot
# Chọn hết + xoá
Press Keys    accessibility_id=first_name    CTRL+A
Press Keys    accessibility_id=first_name    DELETE
# Rời focus để trigger validation
Press Keys    accessibility_id=first_name    TAB
```

**Công thức an toàn Clear & Type**

```robot
Wait Until Element Is Visible    accessibility_id=first_name
Click Element                    accessibility_id=first_name
Press Keys                       accessibility_id=first_name    CTRL+A
Press Keys                       accessibility_id=first_name    DELETE
Input Text                       accessibility_id=first_name    ${VALUE}
```

**Công thức gõ phím ổn định (CTRL+A rồi xóa)**
```robot
Click Element    ${LOCATOR}
Send Keys        ${LOCATOR}    CTRL+A
Send Keys        ${LOCATOR}    DELETE
Input Text       ${LOCATOR}    New value
```
Tránh gộp CTRL+A+DELETE trong một lệnh nếu không chắc driver xử lý “combo” ổn định.

### 4.4. Thuộc tính phần tử & xác minh

**Wait Until Element Contains** – chờ text/giá trị xuất hiện

```robot
Wait Until Element Contains    xpath=//Text[@AutomationId='Total']    $25.00    10s
```

**Wait Until Element Does Not Contain** – chờ text biến mất

```robot
Wait Until Element Does Not Contain    xpath=//Text[@AutomationId='Status']    Loading...    15s
```

**Page Should Not Contain Element** – xác minh phần tử biến mất

```robot
Page Should Not Contain Element    xpath=//Text[contains(@Name,'Saving')]
```

**Element Should Be Visible / Enabled**

```robot
Element Should Be Visible    xpath=//Button[@Name='Submit']
```

### 4.5. Modal/Top-level Window/Attach theo handle

**Tương tác modal trong cùng phiên**

```robot
${modal}=    Set Variable    //Window[@Name='Confirm'] | //Pane[@AutomationId='ConfirmDialog']
Wait Until Page Contains Element    xpath=${modal}    10s
Click Element    xpath=${modal}//Button[@Name='OK']
```

**Attach vào cửa sổ đã mở (appTopLevelWindow)**

```robot
# 1) Mở phiên root để lấy handle của top-level window bạn quan tâm
Open Application    ${REMOTE_URL}    platformName=Windows    deviceName=WindowsPC    app=Root
${handle}=    Get Element Attribute    xpath=//Window[@Name='My App']    NativeWindowHandle
${hex}=    Evaluate    hex(int(${handle}))
Close Application

# 2) Mở phiên mới attach trực tiếp theo handle (hex, KHÔNG có '0x')
Open Application    ${REMOTE_URL}
...    platformName=Windows
...    deviceName=WindowsPC
...    appTopLevelWindow=${hex[2:]}
```

> 💡 Dùng khi app sinh **cửa sổ ký tên/print** riêng hoặc mở bằng **shortcut**. Attach giúp thao tác trực tiếp vào cửa sổ mục tiêu.

### 4.6. List/ComboBox, Menu, Table/Grid

**Chọn item trong ComboBox**

```robot
# Mở dropdown
Click Element    accessibility_id=cmbCountry
# Chọn item theo Name
Click Element    xpath=//ListItem[@Name='Vietnam']
```

**Chọn item theo AutomationId**

```robot
Click Element    xpath=//List[@AutomationId='cmbCountry_List']//ListItem[@AutomationId='VN']
```

**Menu theo đường dẫn**

```robot
Click Element    xpath=//MenuItem[@Name='File']
Click Element    xpath=//MenuItem[@Name='File']//MenuItem[@Name='Open']
```

**Table/Grid – đếm dòng/chọn ô**

```robot
@{rows}=    Get Webelements    xpath=//DataGrid[@AutomationId='Orders']//DataItem
Should Be True    ${len(${rows})} > 0
# Chọn ô theo cột
Click Element    xpath=(//DataGrid[@AutomationId='Orders']//DataItem)[1]//Text[@Name='Paid']
```

### 4.7. Checkbox/Radio/Toggle

**Đọc trạng thái**

```robot
${checked}=    Get Element Attribute    accessibility_id=chkTerms    Toggle.ToggleState
Should Be Equal As Strings    ${checked}    1    # 1=Checked, 0=Unchecked, 2=Indeterminate
```

**Click để chuyển trạng thái**

```robot
Click Element    accessibility_id=chkTerms
```

**Radio – kiểm tra chọn**

```robot
${sel}=    Get Element Attribute    xpath=//RadioButton[@Name='Male']    SelectionItem.IsSelected
Should Be Equal As Strings    ${sel}    True
```

### 4.8. Ảnh chụp màn hình & nguồn UI

**Capture Page Screenshot**

```robot
Capture Page Screenshot    logs/${TEST NAME}.png
```

**Get Source** (lưu XML để xem lại)

```robot
${xml}=    Get Source
Create File    logs/ui_${TEST NAME}.xml    ${xml}
```

---

## 🧱 Mẫu từ điển Locator & Keywords tái dùng

```robot
*** Variables ***
${LOGIN_WIN}        //Window[@Name='Login']
${FIRST_NAME}       accessibility_id=first_name
${LAST_NAME}        accessibility_id=last_name
${BTN_SIGNIN}       name=Sign in
${VAL_FIRST_NAME}   xpath=//Edit[@AutomationId='first_name']/following-sibling::Text

*** Keywords ***
Wait And Click
    [Arguments]    ${locator}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    ${timeout}
    Click Element    ${locator}

Clear And Type
    [Arguments]    ${locator}    ${text}    ${timeout}=10s
    Wait Until Element Is Visible    ${locator}    ${timeout}
    Click Element    ${locator}
    Press Keys       ${locator}    CTRL+A
    Press Keys       ${locator}    DELETE
    Input Text       ${locator}    ${text}

Should See Validation Next To
    [Arguments]    ${input_locator}    ${message}
    ${xp}=    Set Variable    ${input_locator.replace('accessibility_id=','//Edit[@AutomationId=\'')}\']//following-sibling::Text[normalize-space(@Name)='${message}']
    Wait Until Page Contains Element    xpath=${xp}    5s
```

---

## 🛡️ Mẹo chống flake & xử lý lỗi thường gặp

* **Blur để render validation**: Sau khi `Clear Text` hoặc `Input Text`, dùng `Press Keys TAB` hoặc click vào **vùng trống**/control khác.
* **Neo theo container**: Luôn bắt đầu XPath từ `Window/Pane` có `AutomationId`/`Name` ổn định.
* **Timeout đủ dài**: `Set Appium Timeout 10-15s` cho app nặng/khởi tạo chậm.
* **Không nhầm library**: Dùng `Press Keys` của **AppiumLibrary**, không phải `Browser.Press Keys`.
* **Kiểm tra UIA bằng Inspect.exe/FlaUInspect** khi Appium Inspector không trả đủ `AutomationId`.
* **Tránh index mơ hồ**: Nếu phải dùng `(…)[1]`, hãy khoanh vùng cha để giảm rủi ro.
* **Chụp ảnh & dump source khi fail**: `Capture Page Screenshot`, `Get Source` → giúp debug nhanh sự khác biệt giữa runtime & khi inspect.

---

## 🧰 Phụ lục: Template bộ khung Test Suite

```robot
*** Settings ***
Library    AppiumLibrary
Suite Setup    Open AUT
Suite Teardown    Close Application

*** Variables ***
${REMOTE_URL}    http://127.0.0.1:4723
${APP_EXE}      C:\\Apps\\MyApp\\MyApp.exe

*** Keywords ***
Open AUT
    Open Application    ${REMOTE_URL}    platformName=Windows    deviceName=WindowsPC    app=${APP_EXE}
    Set Appium Timeout  12s

# Reuse: Wait And Click, Clear And Type, Should See Validation Next To ...

*** Test Cases ***
[Positive] Login success with valid credentials
    Clear And Type    accessibility_id=username    admin
    Clear And Type    accessibility_id=password    Secret123
    Wait And Click    name=Sign in
    Wait Until Page Contains Element    accessibility_id=MainPanel    10s

[Negative] Show validation when first name empty
    Clear And Type    accessibility_id=first_name    
    Press Keys        accessibility_id=first_name    TAB
    Wait Until Page Contains Element    xpath=//Edit[@AutomationId='first_name']/following-sibling::Text[normalize-space(@Name)='First name is required.']    5s
```

---

### 🎨 Gợi ý styling/ghi chú trong tài liệu

* Dùng emoji để đánh dấu mức độ: ✅ (ưu tiên), ⚠️ (cảnh báo), 💡 (mẹo), 🔧 (sửa lỗi), 🧪 (test)
* Gắn nhãn kịch bản: **\[Positive]**, **\[Negative]**, **\[Navigate]** trước tên test case.

---