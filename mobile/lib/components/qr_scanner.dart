import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:indowater_mobile/utils/constants.dart';
import 'package:indowater_mobile/components/app_button.dart';

class QRScanner extends StatefulWidget {
  final Function(String) onScanSuccess;
  final VoidCallback? onClose;
  final String title;
  final String description;
  final bool showControls;
  final bool showOverlay;
  final bool showTorch;
  final bool showSwitchCamera;
  final bool showCloseButton;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final Color? overlayColor;

  const QRScanner({
    Key? key,
    required this.onScanSuccess,
    this.onClose,
    this.title = 'Scan QR Code',
    this.description = 'Position the QR code within the frame to scan',
    this.showControls = true,
    this.showOverlay = true,
    this.showTorch = true,
    this.showSwitchCamera = true,
    this.showCloseButton = true,
    this.height,
    this.width,
    this.borderRadius,
    this.overlayColor,
  }) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  late MobileScannerController _controller;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    setState(() {
      _isTorchOn = !_isTorchOn;
      _controller.toggleTorch();
    });
  }

  void _switchCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _controller.switchCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final scannerWidth = widget.width ?? size.width * 0.8;
    final scannerHeight = widget.height ?? size.width * 0.8;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(Constants.paddingMedium),
          child: Column(
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Constants.marginSmall),
              Text(
                widget.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Scanner
        Container(
          width: scannerWidth,
          height: scannerHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(Constants.borderRadiusMedium),
            border: Border.all(
              color: theme.primaryColor,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Camera
              MobileScanner(
                controller: _controller,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null) {
                      widget.onScanSuccess(barcode.rawValue!);
                      return;
                    }
                  }
                },
              ),
              // Overlay
              if (widget.showOverlay)
                Container(
                  decoration: BoxDecoration(
                    color: widget.overlayColor ?? Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: Container(
                      width: scannerWidth * 0.7,
                      height: scannerWidth * 0.7,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                      ),
                      child: Stack(
                        children: [
                          // Top-left corner
                          Positioned(
                            top: 0,
                            left: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 4),
                                  left: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          // Top-right corner
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.white, width: 4),
                                  right: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-left corner
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white, width: 4),
                                  left: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                          // Bottom-right corner
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.white, width: 4),
                                  right: BorderSide(color: Colors.white, width: 4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Close button
              if (widget.showCloseButton)
                Positioned(
                  top: Constants.paddingSmall,
                  right: Constants.paddingSmall,
                  child: InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(Constants.borderRadiusSmall),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: Constants.iconSizeSmall,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Controls
        if (widget.showControls)
          Padding(
            padding: const EdgeInsets.all(Constants.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.showTorch)
                  IconButton(
                    onPressed: _toggleTorch,
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? theme.primaryColor : theme.iconTheme.color,
                    ),
                    tooltip: _isTorchOn ? 'Turn off torch' : 'Turn on torch',
                  ),
                if (widget.showSwitchCamera)
                  IconButton(
                    onPressed: _switchCamera,
                    icon: Icon(
                      _isFrontCamera ? Icons.camera_rear : Icons.camera_front,
                      color: theme.iconTheme.color,
                    ),
                    tooltip: _isFrontCamera ? 'Switch to back camera' : 'Switch to front camera',
                  ),
              ],
            ),
          ),
        // Cancel button
        if (widget.onClose != null)
          Padding(
            padding: const EdgeInsets.all(Constants.paddingMedium),
            child: AppButton(
              text: 'Cancel',
              type: ButtonType.outline,
              onPressed: widget.onClose,
            ),
          ),
      ],
    );
  }
}