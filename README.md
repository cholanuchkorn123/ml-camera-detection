# Flutter Liveness & Scan ID


- Sign-in page with **username (email) & password**  
- **Form validation** for username & password:  
  - Username must be a valid email  
  - Password must be at least 8 characters, contain at least 1 number and 1 special character  
- **AES-GCM encryption** for username & password (client-side)  


## Features
## design pattern expect clean but not have time enough 
### Sign-In Page
- Input fields with email and password
- Validation and **popup alert messages**  
- Encryption using AES-GCM before sending data to API  
## Liveness Face Detect and Scan Id 
- click open liveness ekyc button to use scan face and then preview your image
 - not smile
 - look forward
 - not anything intercept face except eyeglass
 - brightness 
 - then 3 sec for auto cap and back to preview photo
 - use face detection ml kit 
- scan id 
 - scan id for is this id card with label
 - then auto capture when green border its pass
 - not find any lib for detection all 
 - use text reg kit for find wording if wording matching mean brightness,opacity,blur is good 
 - auto capture then crop by user

---

## Project Setup
## flutter clean
## flutter pub get
## flutter run 
## # ml-camera-detection
