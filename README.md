# 📱 OCR Text Extract App

A Flutter application that extracts text from images using Google ML Kit. Users can capture images via camera or select from gallery, extract text, and perform actions like copy, share, translate, and text-to-speech.

---

## Features

- Capture image using camera  
-  Select image from gallery  
-  Extract text using Google ML Kit  
-  Text-to-Speech (read extracted text)  
-  Translate extracted text  
-  Copy text to clipboard  
-  Save extracted text locally (Hive)  
-  Share extracted text  

---

## 🛠️ Tech Stack

- Flutter (Dart)  
- Google ML Kit Text Recognition  
- Flutter TTS  
- Hive (Local Storage)  
- Image Picker & Camera  
- Translator API  
- Share Plus  

---

## 📦 Dependencies

```yaml
google_mlkit_text_recognition: ^0.15.0
flutter_tts: ^4.2.3
camera: ^0.11.2
image_picker: ^1.2.0
hive: ^2.2.3
hive_flutter: ^1.1.0
share_plus: ^12.0.0
clipboard: ^2.0.2
path_provider: ^2.1.5
image_cropper: ^12.1.0

## How to Run
### 1. Clone the repository git clone https://github.com/sushant5765/OCR_Text_extract.git
 ### 2. Move into project folder cd OCR_Text_extract
### 3. Get dependencies flutter pub get
 ### 4. Run the app
translator: ^1.0.4+1
flutter_tesseract_ocr: ^0.4.30
