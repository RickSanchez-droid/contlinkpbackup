import Flutter
import GameController

class VirtualGameControllerPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel?
    private var virtualController: GCController?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "virtual_game_controller", binaryMessenger: registrar.messenger())
        let instance = VirtualGameControllerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        instance.channel = channel
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "registerController":
            registerController(result: result)
        case "sendInputEvent":
            sendInputEvent(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func registerController(result: @escaping FlutterResult) {
        virtualController = GCController.controllers().first
        if virtualController == nil {
            virtualController = GCController()
            virtualController?.playerIndex = 0 // Set player index if needed
        }
        result(nil)
    }


    private func sendInputEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let type = arguments["type"] as? String,
              let value = arguments["value"] as? Double else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for sendInputEvent", details: nil))
            return
        }
        
        if type == "button" {
            guard let buttonName = arguments["button"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for sendInputEvent", details: nil))
                return
            }
            
            if let virtualController = virtualController {
                if let button = getButton(for: buttonName, controller: virtualController) {
                    button.value = value > 0 ? 1 : 0
                }
            }
        } else if type == "trigger" {
            guard let triggerName = arguments["trigger"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for sendInputEvent", details: nil))
                return
            }
            
            if let virtualController = virtualController {
                if let trigger = getAxis(for: triggerName, controller: virtualController) {
                    trigger.value = CGFloat(value)
                }
            }
        } else if type == "dpad" {
            guard let direction = arguments["direction"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for sendInputEvent", details: nil))
                return
            }
            
            if let virtualController = virtualController {
                if let dpad = getDPad(for: direction, controller: virtualController) {
                    dpad.value = value > 0 ? 1 : 0
                }
            }
        }
        
        result(nil)
    }


    // Helper functions to map button names to actual GCController elements
    private func getButton(for name: String, controller: GCController) -> GCControllerButtonInput? {
        switch name {
        case "buttonA": return controller.extendedGamepad?.buttonA
        case "buttonB": return controller.extendedGamepad?.buttonB
        case "buttonX": return controller.extendedGamepad?.buttonX
        case "buttonY": return controller.extendedGamepad?.buttonY
        case "leftShoulder": return controller.extendedGamepad?.leftShoulder
        case "rightShoulder": return controller.extendedGamepad?.rightShoulder
        default: return nil
        }
    }
    
    private func getAxis(for name: String, controller: GCController) -> GCControllerAxisInput? {
        switch name {
        case "leftTrigger": return controller.extendedGamepad?.leftTrigger
        case "rightTrigger": return controller.extendedGamepad?.rightTrigger
        default: return nil
        }
    }
    
    private func getDPad(for name: String, controller: GCController) -> GCControllerDirectionPad? {
        switch name {
        case "up": return controller.extendedGamepad?.dpad.up
        case "down": return controller.extendedGamepad?.dpad.down
        case "left": return controller.extendedGamepad?.dpad.left
        case "right": return controller.extendedGamepad?.dpad.right
        default: return nil
        }
    }
}
