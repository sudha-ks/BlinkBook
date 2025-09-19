# BlinkBook - Contributing Guidelines

## 🎯 **Development Philosophy**

BlinkBook follows a **clean, maintainable, and scalable** approach to iOS development. Every line of code should be written with future contributors and feature additions in mind.

## 🏗️ **Architecture Principles**

### **MVVM + Combine Pattern**
- **Models**: Pure data structures with validation logic
- **ViewModels**: Business logic, state management, and data binding
- **Views**: SwiftUI views focused on presentation only
- **Services**: Reusable business logic and external integrations

### **SOLID Principles**
- **Single Responsibility**: Each class has one reason to change
- **Open/Closed**: Open for extension, closed for modification
- **Liskov Substitution**: Derived classes must be substitutable for base classes
- **Interface Segregation**: Many specific interfaces are better than one general interface
- **Dependency Inversion**: Depend on abstractions, not concretions

## 📁 **Project Structure**

```
BlinkBook/
├── Models/                 # Data models and business entities
│   ├── BusinessCard.swift
│   ├── ExtractedData.swift
│   └── Validation/
├── ViewModels/            # Business logic and state management
│   ├── CameraViewModel.swift
│   ├── OCRViewModel.swift
│   └── ContactViewModel.swift
├── Views/                 # SwiftUI views and UI components
│   ├── CameraView.swift
│   ├── ReviewView.swift
│   └── Components/
│       ├── CustomButton.swift
│       └── LoadingView.swift
├── Services/              # Business logic and external integrations
│   ├── OCRService.swift
│   ├── ContactService.swift
│   └── CameraService.swift
├── Utils/                 # Utilities, extensions, and helpers
│   ├── Extensions/
│   │   ├── String+Extensions.swift
│   │   └── Image+Extensions.swift
│   └── Constants.swift
└── Resources/             # Assets, configurations, and resources
    ├── Assets.xcassets
    └── Info.plist
```

## 📝 **Coding Standards**

### **Swift Style Guide**
- Follow Apple's Swift API Design Guidelines
- Use meaningful, descriptive names
- Prefer composition over inheritance
- Use protocols for abstraction

### **Naming Conventions**
```swift
// Classes and Structs: PascalCase
class CameraViewModel { }
struct BusinessCard { }

// Functions and Variables: camelCase
func processImage() { }
var extractedData: ExtractedData

// Constants: camelCase
let maxImageSize = 1024

// Protocols: PascalCase ending with 'able' or 'ing'
protocol ImageProcessable { }
protocol ContactSaving { }
```

### **Code Organization**
```swift
// 1. Imports
import SwiftUI
import Combine

// 2. Protocol conformance
class CameraViewModel: ObservableObject {
    
    // 3. Properties (grouped by type)
    // MARK: - Published Properties
    @Published var isProcessing = false
    
    // MARK: - Private Properties
    private let cameraService: CameraService
    
    // MARK: - Initialization
    init(cameraService: CameraService) {
        self.cameraService = cameraService
    }
    
    // MARK: - Public Methods
    func captureImage() { }
    
    // MARK: - Private Methods
    private func processImage() { }
}
```

## 🔧 **Best Practices**

### **Error Handling**
```swift
// Use Result type for operations that can fail
func processImage(_ image: UIImage) -> Result<ExtractedData, OCRError> {
    // Implementation
}

// Handle errors gracefully with user-friendly messages
enum OCRError: LocalizedError {
    case noTextDetected
    case processingFailed
    
    var errorDescription: String? {
        switch self {
        case .noTextDetected:
            return "No text could be detected in the image. Please try again with better lighting."
        case .processingFailed:
            return "Image processing failed. Please try again."
        }
    }
}
```

### **Dependency Injection**
```swift
// Use protocols for dependencies
protocol CameraServiceProtocol {
    func captureImage() -> AnyPublisher<UIImage, CameraError>
}

// Inject dependencies through initializers
class CameraViewModel: ObservableObject {
    private let cameraService: CameraServiceProtocol
    
    init(cameraService: CameraServiceProtocol) {
        self.cameraService = cameraService
    }
}
```

### **State Management**
```swift
// Use @Published for UI state
class OCRViewModel: ObservableObject {
    @Published var extractedData: ExtractedData?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    // Use Combine for reactive programming
    private var cancellables = Set<AnyCancellable>()
}
```

### **Memory Management**
```swift
// Use weak references to avoid retain cycles
class CameraViewModel: ObservableObject {
    weak var delegate: CameraViewModelDelegate?
    
    // Properly cancel Combine subscriptions
    deinit {
        cancellables.removeAll()
    }
}
```

## 🧪 **Testing Guidelines**

### **Unit Testing**
- Test all business logic in ViewModels
- Test service layer functionality
- Mock external dependencies
- Aim for >80% code coverage

### **Test Structure**
```swift
class OCRViewModelTests: XCTestCase {
    var viewModel: OCRViewModel!
    var mockOCRService: MockOCRService!
    
    override func setUp() {
        super.setUp()
        mockOCRService = MockOCRService()
        viewModel = OCRViewModel(ocrService: mockOCRService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockOCRService = nil
        super.tearDown()
    }
    
    func testProcessImage_Success() {
        // Given
        let image = UIImage()
        mockOCRService.mockResult = .success(ExtractedData())
        
        // When
        viewModel.processImage(image)
        
        // Then
        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertNotNil(viewModel.extractedData)
    }
}
```

## 📱 **UI/UX Guidelines**

### **SwiftUI Best Practices**
- Use `@State` for local view state
- Use `@ObservedObject` for external state
- Prefer composition over complex view hierarchies
- Use `ViewModifier` for reusable UI patterns

### **Design System**
```swift
// Centralized design tokens
struct DesignSystem {
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let success = Color.green
        static let error = Color.red
    }
    
    struct Typography {
        static let title = Font.title
        static let body = Font.body
        static let caption = Font.caption
    }
    
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}
```

### **Accessibility (Future Consideration)**
- Use semantic labels for UI elements
- Support Dynamic Type
- Provide VoiceOver descriptions
- Ensure sufficient color contrast

## 🔍 **Code Review Checklist**

### **Before Submitting PR**
- [ ] Code follows project structure
- [ ] Naming conventions are followed
- [ ] Error handling is implemented
- [ ] Memory leaks are prevented
- [ ] Unit tests are written
- [ ] Documentation is updated
- [ ] No hardcoded values
- [ ] Proper separation of concerns

### **Review Criteria**
- **Functionality**: Does the code work as expected?
- **Readability**: Is the code easy to understand?
- **Maintainability**: Will future changes be easy?
- **Performance**: Are there any performance issues?
- **Security**: Are there any security concerns?

## 🚀 **Performance Guidelines**

### **Image Processing**
- Resize images before processing
- Use background queues for heavy operations
- Cache processed results when appropriate
- Release image memory promptly

### **Memory Management**
- Use weak references to avoid retain cycles
- Properly cancel Combine subscriptions
- Release large objects when not needed
- Monitor memory usage in development

### **UI Performance**
- Use `@State` for local state only
- Avoid expensive operations in view body
- Use `LazyVStack` for large lists
- Optimize image loading and caching

## 📚 **Documentation Standards**

### **Code Documentation**
```swift
/// Processes a business card image and extracts contact information
/// - Parameter image: The captured business card image
/// - Returns: A publisher that emits extracted data or an error
/// - Note: This method processes images on a background queue
func processBusinessCard(_ image: UIImage) -> AnyPublisher<ExtractedData, OCRError> {
    // Implementation
}
```

### **README Updates**
- Update README.md for new features
- Document any new dependencies
- Update installation instructions
- Add usage examples

## 🔄 **Git Workflow**

### **Branch Naming**
- `feature/feature-name` - New features
- `bugfix/bug-description` - Bug fixes
- `refactor/component-name` - Code refactoring
- `docs/documentation-update` - Documentation updates

### **Commit Messages**
```
feat: add OCR text extraction functionality
fix: resolve camera permission handling issue
refactor: improve error handling in ContactService
docs: update API documentation
```

### **Pull Request Process**
1. Create feature branch from `main`
2. Implement changes with tests
3. Update documentation
4. Create pull request with description
5. Address review feedback
6. Merge after approval

## 🛠️ **Development Setup**

### **Required Tools**
- Xcode 15.0+
- iOS 16.6+ Simulator
- Git for version control

### **Dependencies**
- SwiftUI (iOS 16.6+)
- Combine framework
- Vision framework
- AVFoundation
- Contacts framework

### **Development Environment**
- Use SwiftLint for code style enforcement
- Enable all compiler warnings
- Use Instruments for performance profiling
- Test on multiple device sizes

---

**Remember**: Every line of code is a potential source of bugs. Write code that you'd be proud to show to your future self and colleagues. When in doubt, choose clarity over cleverness.

**Last Updated**: January 2025  
**Version**: 1.0
