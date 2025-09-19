# BlinkBook - Business Card Scanner

A simple, fast, and reliable iOS app that automatically extracts contact information from physical business cards and saves them directly to your phone contacts.

## 🎯 **Features**

- **Camera-based Scanning**: Use your device camera to capture business card images
- **OCR Text Extraction**: Automatically extract name, company, and phone number with high accuracy
- **Data Review & Editing**: Verify and edit extracted information before saving
- **Contact Integration**: Save verified contact information directly to your phone contacts
- **Clean UI**: Modern, intuitive interface with smooth animations

## 🚀 **Getting Started**

### **Prerequisites**
- Xcode 15.0 or later
- iOS 16.6 or later
- Physical device with camera (required for testing)

### **Installation**
1. Clone the repository
2. Open `BlinkBook.xcodeproj` in Xcode
3. Select your target device
4. Build and run the project

### **Permissions Required**
- **Camera**: To capture business card images
- **Contacts**: To save extracted information

## 📱 **How to Use**

1. **Launch the App**: Camera view opens automatically
2. **Position Card**: Align business card within the detection overlay
3. **Capture**: Tap the capture button to scan the business card
4. **Review**: Verify and edit the extracted information
5. **Save**: Tap "Save Contact" to add to your phone contacts
6. **Success**: Contact is saved and you can scan another card

## 🏗️ **Architecture**

### **MVVM + Combine Pattern**
- **Models**: `BusinessCard`, `ExtractedData`, `ConfidenceScores`
- **ViewModels**: `CameraViewModel`, `OCRViewModel`, `ContactViewModel`, `AppCoordinator`
- **Views**: `CameraView`, `ProcessingView`, `ReviewView`, `SuccessView`
- **Services**: `CameraService`, `OCRService`, `ContactService`

### **Key Components**
- **Vision Framework**: For OCR text recognition
- **AVFoundation**: For camera functionality
- **Contacts Framework**: For contact management
- **Combine**: For reactive programming and data binding

## 📁 **Project Structure**

```
BlinkBook/
├── Models/                 # Data models and business entities
│   └── BusinessCard.swift
├── ViewModels/            # Business logic and state management
│   ├── AppCoordinator.swift
│   ├── CameraViewModel.swift
│   ├── OCRViewModel.swift
│   └── ContactViewModel.swift
├── Views/                 # SwiftUI views and UI components
│   ├── CameraView.swift
│   ├── ProcessingView.swift
│   ├── ReviewView.swift
│   └── SuccessView.swift
├── Services/              # Business logic and external integrations
│   ├── CameraService.swift
│   ├── OCRService.swift
│   └── ContactService.swift
├── Utils/                 # Utilities, extensions, and helpers
│   ├── Extensions/
│   │   ├── String+Extensions.swift
│   │   └── Image+Extensions.swift
│   └── Constants.swift
└── Resources/             # Assets, configurations, and resources
    ├── Assets.xcassets
    └── Info.plist
```

## 🔧 **Technical Details**

### **OCR Processing**
- Uses Apple's Vision framework for text recognition
- Supports English language recognition
- Confidence scoring for extracted data
- Automatic data parsing and validation

### **Camera Integration**
- Real-time camera preview
- Business card detection overlay
- Automatic focus and exposure
- Image processing and optimization

### **Contact Management**
- Native iOS Contacts framework integration
- Permission handling and user feedback
- Contact creation with proper formatting
- Error handling and recovery

## 🎨 **Design System**

### **Colors**
- Primary: Blue (#007AFF)
- Success: Green (#34C759)
- Error: Red (#FF3B30)
- Warning: Orange (#FF9500)

### **Typography**
- SF Pro system font
- Dynamic type support
- Consistent sizing hierarchy

### **Components**
- Custom buttons with consistent styling
- Form fields with validation states
- Loading indicators and animations
- Error and success feedback

## 🧪 **Testing**

### **Unit Tests**
- ViewModel business logic testing
- Service layer functionality testing
- Data validation testing
- Error handling testing

### **UI Tests**
- User flow testing
- Permission handling testing
- Camera functionality testing
- Contact saving testing

## 📊 **Performance**

### **Optimizations**
- Background processing for OCR
- Image compression and resizing
- Memory management for camera
- Efficient text recognition

### **Metrics**
- OCR Accuracy: >85% for standard business cards
- Processing Speed: <3 seconds per card
- Memory Usage: <50MB
- App Launch Time: <2 seconds

## 🔒 **Privacy & Security**

### **Data Handling**
- All processing happens on-device
- No cloud storage or transmission
- Minimal permissions required
- User control over saved data

### **Permissions**
- Camera access for scanning
- Contacts access for saving
- Clear permission explanations

## 🚀 **Future Enhancements**

### **Planned Features**
- Email address extraction
- Job title recognition
- Company logo detection
- Batch scanning mode
- Export options
- iCloud sync

### **Advanced Features**
- CRM integration
- Team collaboration
- Advanced analytics
- AI-powered suggestions
- Multi-language support

## 🤝 **Contributing**

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 **Support**

For support, email support@blinkbook.app or create an issue in the repository.

---

**Version**: 1.0.0  
**Last Updated**: January 2025  
**Minimum iOS Version**: 16.6
