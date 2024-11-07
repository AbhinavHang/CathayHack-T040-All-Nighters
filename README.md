## Deployed server: https://test-td2g.vercel.app/api/cargo

# Cargo Label Scanner App

A mobile application for scanning and managing air cargo labels, built with Swift (iOS) and Express.js (Backend). This app helps cargo handlers efficiently process and track cargo shipments through QR code scanning.

## Deployed server: https://test-td2g.vercel.app/api/cargo

## Features

- 📱 iOS mobile app for cargo label scanning
- 🔍 QR code scanning capability
- 📦 Real-time cargo tracking
- 📝 Detailed cargo information display
- 📊 History tracking
- ⏰ Deadline management
- 🔄 Status updates

## Tech Stack

### Frontend (iOS)

- Swift
- SwiftUI
- AVFoundation (for camera handling)
- Vision framework
- CoreImage

### Backend (Express.js)

- Node.js
- Express.js
- MongoDB
- Mongoose
- CORS

## Project Structure

```
cargo-scanner/
├── backend/
│   ├── server.js
│   ├── package.json
│   └── vercel.json
│
├── ios/
│   ├── Models/
│   │   └── CargoLabel.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── CameraView.swift
│   │   ├── AwaitingScansView.swift
│   │   ├── HistoryView.swift
│   │   └── CargoDetailView.swift
│   ├── ViewModels/
│   │   ├── ScannerViewModel.swift
│   │   └── AwaitingScansViewModel.swift
│   └── Services/
│       └── APIService.swift
```

## Setup and Installation

### Backend Setup

1. Clone the repository
2. Install dependencies:

```bash
cd backend
npm install
```

3. Create `.env` file:

```env
MONGODB_URI=mongodb+srv://your_mongodb_uri
```

4. Run the server:

```bash
npm start
```

### iOS Setup

1. Open the Xcode project
2. Install required dependencies
3. Update `APIService.swift` with your backend URL
4. Build and run the project

## API Endpoints

### Cargo Management

- `GET /api/cargo/awaiting` - Get awaiting cargo
- `GET /api/cargo/history` - Get completed cargo
- `GET /api/cargo/awb/:awbNumber` - Get cargo by AWB number
- `POST /api/cargo` - Create new cargo
- `PUT /api/cargo/:awbNumber` - Update cargo status

## Features Detail

### QR Code Scanning

- Real-time camera feed
- QR code detection
- Automatic cargo lookup
- Vibration feedback

### Cargo Tracking

- Awaiting scans list
- Scan history
- Detailed cargo information
- Status updates

### Data Management

- MongoDB integration
- Real-time updates
- Error handling
- Data validation

## Usage

1. **Scanning Cargo**

   - Open the app
   - Tap the scan button
   - Align QR code within frame
   - View cargo details

2. **Viewing History**

   - Navigate to History tab
   - View all processed cargo
   - Search by AWB number

3. **Managing Awaiting Scans**
   - Check Awaiting tab
   - View pending cargo
   - Sort by deadline

## Environment Variables

### Backend

```env
MONGODB_URI=your_mongodb_connection_string
PORT=3000 (optional)
```

### iOS

Update `APIService.swift`:

```swift
#if DEBUG
private let baseURL = "http://localhost:3000/api"
#else
private let baseURL = "your_production_api_url"
#endif
```

## Required Permissions

### iOS

Add to Info.plist:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan cargo labels</string>
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Known Issues

1. Camera might not initialize on simulator

   - Solution: Test on physical device

2. QR code scanning requires good lighting
   - Solution: Use torch feature in low light

## Troubleshooting

### iOS App

- Ensure camera permissions are granted
- Check API URL configuration
- Verify network connectivity

### Backend

- Verify MongoDB connection
- Check environment variables
- Ensure correct CORS configuration

## Future Improvements

1. Offline mode support
2. Batch scanning capability
3. Enhanced error handling
4. Performance optimizations
5. Analytics integration

## License

MIT License - feel free to use this project for your cargo handling needs.
