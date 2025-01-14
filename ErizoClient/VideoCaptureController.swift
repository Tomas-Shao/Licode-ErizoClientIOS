/*
 * Copyright (c) 2020 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation
import WebRTC

@objcMembers
public class VideoCaptureController: NSObject {
    static let outputSizeWidth: Int32 = 1280
    static let outputSizeHeight: Int32 = 720
    static let outputFrameRate: Int32 = 30

    private let capturer = RTCCameraVideoCapturer()
    var capturerDelegate: RTCVideoCapturerDelegate? {
        set { capturer.delegate = newValue }
        get { capturer.delegate }
    }
    private let serialQueue = DispatchQueue(label: "org.elastos.foundation.videoCaptureController")
    private var isUsingFrontCamera: Bool = true
    private var isCapturing: Bool = false

    public var captureSession: AVCaptureSession {
        return capturer.captureSession
    }

    public override init() {}

    public func startCapture() {
        serialQueue.sync { [weak self] in
            // Don't call startCapture if we're actively capturing.
            guard let self = self, !self.isCapturing else { return }
            self.startCaptureSync()
        }
    }

    public func stopCapture() {
        serialQueue.sync { [weak self] in
            // Don't call stopCapture unless we're actively capturing.
            guard let self = self, self.isCapturing else { return }
            guard self.isCapturing else { return }
            self.capturer.stopCapture()
            self.isCapturing = false
        }
    }

    public func switchCamera(isUsingFrontCamera: Bool) {
        serialQueue.sync { [weak self] in
            guard let self = self else { return }

            // Only restart capturing again if the camera changes.
            if self.isUsingFrontCamera != isUsingFrontCamera {
                self.isUsingFrontCamera = isUsingFrontCamera
                self.startCaptureSync()
            }
        }
    }

    private func startCaptureSync() {
        let position: AVCaptureDevice.Position = isUsingFrontCamera ? .front : .back
        guard let device: AVCaptureDevice = self.device(position: position) else {
            assertionFailure("unable to find captureDevice")
            return
        }

        guard let format: AVCaptureDevice.Format = self.format(device: device) else {
            assertionFailure("unable to find captureDevice")
            return
        }

        let fps = self.framesPerSecond(format: format)
        capturer.startCapture(with: device, format: format, fps: fps)
        isCapturing = true
    }

    private func device(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let captureDevices = RTCCameraVideoCapturer.captureDevices()
        guard let device = (captureDevices.first { $0.position == position }) else {
            print("unable to find desired position: \(position)")
            return captureDevices.first
        }

        return device
    }

    private func format(device: AVCaptureDevice) -> AVCaptureDevice.Format? {
        let formats = RTCCameraVideoCapturer.supportedFormats(for: device)

        // For rendering, find a format that most closely matches the display size.
        // The local camera capture may be rendered full screen. However, make sure
        // the camera capture is at least our output size, which should be available
        // on all devices the client supports.
        let screenSize = UIScreen.main.nativeBounds.size
        let targetWidth = max(Int32(screenSize.width), Self.outputSizeWidth)
        let targetHeight = max(Int32(screenSize.height), Self.outputSizeHeight)

        var selectedFormat: AVCaptureDevice.Format?
        var currentDiff: Int32 = Int32.max

        for format in formats {
            let dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height)
            if diff < currentDiff {
                selectedFormat = format
                currentDiff = diff
            }
        }

        if _isDebugAssertConfiguration(), let selectedFormat = selectedFormat {
            let dimension = CMVideoFormatDescriptionGetDimensions(selectedFormat.formatDescription)
            print("selected format width: \(dimension.width) height: \(dimension.height)")
        }

        assert(selectedFormat != nil)

        return selectedFormat
    }

    private func framesPerSecond(format: AVCaptureDevice.Format) -> Int {
        var maxFrameRate: Float64 = 0
        for range in format.videoSupportedFrameRateRanges {
            maxFrameRate = max(maxFrameRate, range.maxFrameRate)
        }

        return Int(maxFrameRate)
    }
}
