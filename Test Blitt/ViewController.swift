//
//  ViewController.swift
//  Test Blitt
//
//  Created by Gregorius Albert on 14/07/22.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {

    @IBOutlet weak var resultTextView: UITextView!
    
    var ocrRequest = VNRecognizeTextRequest()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resultTextView.text = ""
        configureOCR()
    }

    @IBAction func scan(_ sender: Any) {
        let scanVC = VNDocumentCameraViewController()
        scanVC.delegate = self
        present(scanVC, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        guard scan.pageCount >= 1 else {
            controller.dismiss(animated: true)
            return
        }
        
//        imageView.image = scan.imageOfPage(at: 0)
        processImage(scan.imageOfPage(at: 0))
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        resultTextView.text = ""
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([self.ocrRequest])
        } catch {
            print(error)
        }
    }
    
    
    func configureOCR() -> Void {
        ocrRequest = VNRecognizeTextRequest { (request, error) in
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            
            var ocrText = ""
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { return }
                ocrText += topCandidate.string + "\n"
            }
            
            
            DispatchQueue.main.async {
                self.resultTextView.text = ocrText
            }
            
        }
        
        ocrRequest.recognitionLevel = .accurate
        ocrRequest.recognitionLanguages = ["en-US"]
        ocrRequest.usesLanguageCorrection = true
        
    }
    
}

