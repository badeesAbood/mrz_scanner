import Flutter
import UIKit
import CoreNFC

public class MrzScNfcCorePlugin: NSObject, FlutterPlugin, NFCTagReaderSessionDelegate {
  private var channel: FlutterMethodChannel?
  private var nfcSession: NFCTagReaderSession?
  private var connectedTag: NFCISO7816Tag?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "mrz_sc_nfc_core", binaryMessenger: registrar.messenger())
    let instance = MrzScNfcCorePlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startSession":
      startNfcSession(result: result)
    case "transceive":
      if let commandBytes = call.arguments as? FlutterStandardTypedData {
          transceiveCommand(commandBytes: commandBytes.data, result: result)
      } else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Command bytes are null", details: nil))
      }
    case "stopSession":
      let errorMessage = call.arguments as? String
      stopNfcSession(errorMessage: errorMessage, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func startNfcSession(result: FlutterResult) {
      guard NFCTagReaderSession.readingAvailable else {
          result(FlutterError(code: "NFC_UNAVAILABLE", message: "NFC is not available or supported", details: nil))
          return
      }
      
      nfcSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
      nfcSession?.alertMessage = "Please hold your phone near the passport."
      nfcSession?.begin()
      result(nil)
  }
  
  private func stopNfcSession(errorMessage: String?, result: FlutterResult?) {
      if let errorMsg = errorMessage {
          nfcSession?.invalidate(errorMessage: errorMsg)
      } else {
          nfcSession?.invalidate()
      }
      nfcSession = nil
      connectedTag = nil
      result?(nil)
  }

  private func transceiveCommand(commandBytes: Data, result: @escaping FlutterResult) {
      guard let tag = connectedTag else {
          result(FlutterError(code: "NO_CONNECTION", message: "No NFC tag is connected", details: nil))
          return
      }
      
      // Parse APDU from raw bytes to send via Apple's API
      guard commandBytes.count >= 4 else {
          result(FlutterError(code: "INVALID_APDU", message: "APDU too short", details: nil))
          return
      }
      
      let cla = commandBytes[0]
      let ins = commandBytes[1]
      let p1 = commandBytes[2]
      let p2 = commandBytes[3]
      
      var data: Data? = nil
      var le: Int? = nil
      
      if commandBytes.count == 5 {
          le = Int(commandBytes[4])
      } else if commandBytes.count > 5 {
          let lc = Int(commandBytes[4])
          if commandBytes.count == 5 + lc {
              data = commandBytes.subdata(in: 5..<(5 + lc))
          } else if commandBytes.count == 6 + lc {
              data = commandBytes.subdata(in: 5..<(5 + lc))
              le = Int(commandBytes[5 + lc])
          }
      }
      
      var apdu: NFCISO7816APDU?
      if let cmdData = data {
          apdu = NFCISO7816APDU(instructionClass: cla, instructionCode: ins, p1Parameter: p1, p2Parameter: p2, data: cmdData, expectedResponseLength: le ?? -1)
      } else {
          apdu = NFCISO7816APDU(instructionClass: cla, instructionCode: ins, p1Parameter: p1, p2Parameter: p2, data: Data(), expectedResponseLength: le ?? -1)
      }
      
      guard let validApdu = apdu else {
          result(FlutterError(code: "INVALID_APDU", message: "Failed to construct APDU", details: nil))
          return
      }
      
      tag.sendCommand(apdu: validApdu) { (responseData, sw1, sw2, error) in
          if let error = error {
              DispatchQueue.main.async {
                  result(FlutterError(code: "TRANSCEIVE_ERROR", message: error.localizedDescription, details: nil))
              }
              return
          }
          
          // Android IsoDep returns response payload + SW1 + SW2 concatenated. We replicate that for Dart parity.
          var returnData = Data()
          returnData.append(responseData)
          returnData.append(sw1)
          returnData.append(sw2)
          
          DispatchQueue.main.async {
              result(FlutterStandardTypedData(bytes: returnData))
          }
      }
  }

  // MARK: - NFCTagReaderSessionDelegate

  public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
      // Session began
  }
  
  public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
      connectedTag = nil
      nfcSession = nil
      
      DispatchQueue.main.async {
          self.channel?.invokeMethod("onError", arguments: error.localizedDescription)
      }
  }
  
  public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
      guard let tag = tags.first else { return }
      
      if case let NFCTag.iso7816(iso7816Tag) = tag {
          session.connect(to: tag) { (error: Error?) in
              if let error = error {
                  session.invalidate(errorMessage: "Connection failed.")
                  DispatchQueue.main.async {
                      self.channel?.invokeMethod("onError", arguments: error.localizedDescription)
                  }
                  return
              }
              self.connectedTag = iso7816Tag
              DispatchQueue.main.async {
                  self.channel?.invokeMethod("onTagDiscovered", arguments: nil)
              }
          }
      } else {
          session.invalidate(errorMessage: "Tag not supported.")
      }
  }
}
